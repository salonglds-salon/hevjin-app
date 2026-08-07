import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessage {
  final String id;
  final String matchId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.content,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    var createdAt = DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now();
    // Supabase timestamps sind UTC
    if (!createdAt.isUtc) {
      createdAt = createdAt.toUtc();
    }
    return ChatMessage(
      id: json['id'] ?? '',
      matchId: json['match_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: createdAt,
    );
  }
}

class MatchWithProfile {
  final String matchId;
  final String otherId;
  final String displayName;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool hasUnread;

  MatchWithProfile({
    required this.matchId,
    required this.otherId,
    required this.displayName,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.hasUnread = false,
  });

  /// Compact signature used to detect real changes (avoids needless rebuilds)
  String get signature =>
      '$matchId|$displayName|$avatarUrl|$lastMessage|${lastMessageTime?.millisecondsSinceEpoch}|$hasUnread';
}

class ChatService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<MatchWithProfile> _matches = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<MatchWithProfile> get matches => _matches;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  String get _userId => _supabase.auth.currentUser?.id ?? '';

  /// Fetch all matches with profile info
  Future<void> fetchMatches() async {
    // Only show loading spinner on first load (when list is empty)
    if (_matches.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        if (_isLoading) {
          _isLoading = false;
          notifyListeners();
        }
        return;
      }

      // --- QUERY 1: all matches ---
      final matchesData = await _supabase
          .from('matches')
          .select()
          .or('user1.eq.$userId,user2.eq.$userId');

      if (matchesData.isEmpty) {
        final changed = _matches.isNotEmpty || _isLoading;
        _matches = [];
        _isLoading = false;
        if (changed) notifyListeners();
        return;
      }

      // Collect ids for batch lookups
      final matchIds = <String>[];
      final otherIdByMatch = <String, String>{};
      for (final m in matchesData) {
        final mid = m['id'].toString();
        matchIds.add(mid);
        otherIdByMatch[mid] = (m['user1'] == userId ? m['user2'] : m['user1']).toString();
      }
      final otherIds = otherIdByMatch.values.toSet().toList();

      // --- QUERY 2: all profiles at once ---
      final profilesData = await _supabase
          .from('profiles')
          .select('id, display_name, avatar_url')
          .inFilter('id', otherIds);

      final profileById = <String, Map<String, dynamic>>{};
      for (final p in profilesData) {
        profileById[p['id'].toString()] = p;
      }

      // --- QUERY 3: all messages for these matches at once ---
      final messagesData = await _supabase
          .from('messages')
          .select('id, match_id, sender_id, content, is_read, created_at')
          .inFilter('match_id', matchIds)
          .order('created_at', ascending: false);

      // Reduce in memory: newest message + unread flag per match
      final lastMsgByMatch = <String, Map<String, dynamic>>{};
      final unreadByMatch = <String, bool>{};
      for (final msg in messagesData) {
        final mid = msg['match_id'].toString();
        lastMsgByMatch.putIfAbsent(mid, () => msg); // first = newest (sorted desc)
        if (msg['is_read'] == false && msg['sender_id'].toString() != userId) {
          unreadByMatch[mid] = true;
        }
      }

      // --- Build list ---
      final newMatches = <MatchWithProfile>[];
      for (final mid in matchIds) {
        final otherId = otherIdByMatch[mid]!;
        final profile = profileById[otherId];
        final lastMsg = lastMsgByMatch[mid];

        String? lastMessagePreview;
        if (lastMsg != null && lastMsg['content'] != null) {
          final content = lastMsg['content'].toString();
          final isMine = lastMsg['sender_id'].toString() == userId;
          if (content.startsWith('[IMAGE]')) {
            lastMessagePreview = isMine ? 'Du: \u{1F4F7} Bild' : '\u{1F4F7} Bild';
          } else {
            lastMessagePreview = isMine ? 'Du: $content' : content;
          }
        }

        newMatches.add(MatchWithProfile(
          matchId: mid,
          otherId: otherId,
          displayName: profile?['display_name'] ?? 'Unbekannt',
          avatarUrl: profile?['avatar_url'],
          lastMessage: lastMessagePreview,
          lastMessageTime: lastMsg != null
              ? (DateTime.tryParse(lastMsg['created_at'] ?? '') ?? DateTime.now()).toUtc()
              : null,
          hasUnread: unreadByMatch[mid] ?? false,
        ));
      }

      // Newest message on top
      newMatches.sort((a, b) {
        final aTime = a.lastMessageTime ?? DateTime(2000);
        final bTime = b.lastMessageTime ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      // Only notify when something actually changed -> no flicker
      final oldSig = _matches.map((m) => m.signature).join(';');
      final newSig = newMatches.map((m) => m.signature).join(';');
      final wasLoading = _isLoading;

      _matches = newMatches;
      _isLoading = false;

      if (oldSig != newSig || wasLoading) {
        notifyListeners();
      }
    } catch (e) {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Fetch messages for a specific match
  Future<void> fetchMessages(String matchId) async {
    final data = await _supabase
        .from('messages')
        .select()
        .eq('match_id', matchId)
        .order('created_at', ascending: true);

    _messages = data.map((json) => ChatMessage.fromJson(json)).toList();
    notifyListeners();

    // Markiere alle Nachrichten von der anderen Person als gelesen
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('match_id', matchId)
        .neq('sender_id', _userId)
        .eq('is_read', false);
  }

  /// Send a message
  Future<bool> sendMessage(String matchId, String content) async {
    try {
      await _supabase.from('messages').insert({
        'match_id': matchId,
        'sender_id': _userId,
        'content': content,
      });

      // Add locally without full reload (get latest message for real ID)
      final latest = await _supabase
          .from('messages')
          .select()
          .eq('match_id', matchId)
          .eq('sender_id', _userId)
          .order('created_at', ascending: false)
          .limit(1)
          .single();
      
      // Only add if not already in list
      if (!_messages.any((m) => m.id == latest['id'])) {
        _messages.add(ChatMessage.fromJson(latest));
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Send message error: $e');
      return false;
    }
  }

  /// Subscribe to realtime messages
  void subscribeToMessages(String matchId) {
    _supabase
        .channel('messages:$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            final newMessage = ChatMessage.fromJson(payload.newRecord);
            if (newMessage.senderId != _userId) {
              _messages.add(newMessage);
              notifyListeners();
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            final deletedId = payload.oldRecord['id']?.toString();
            if (deletedId != null) {
              _messages.removeWhere((m) => m.id == deletedId);
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  void unsubscribeFromMessages(String matchId) {
    _supabase.removeChannel(_supabase.channel('messages:$matchId'));
  }
}
