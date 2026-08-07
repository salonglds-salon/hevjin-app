import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/chat_service.dart';
import '../../utils/theme.dart';
import '../../widgets/report_sheet.dart';
import 'view_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final String otherName;
  final String? otherAvatar;
  final String? otherUserId;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.otherName,
    this.otherAvatar,
    this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  bool _showEmojis = false;
  bool _isOnline = false;
  bool _isBlocked = false;       // Ich habe den anderen blockiert
  bool _isBlockedByOther = false; // Der andere hat MICH blockiert
  String? _lastSeen;
  Timer? _presenceTimer;
  final List<String> _quickEmojis = [
    '😊', '😂', '🥰', '😍', '😘', '🤗', '😎', '🙈', '🤔', '😅',
    '❤️', '💕', '💖', '🔥', '✨', '🌹', '💋', '🫶', '💯', '🎉',
    '👍', '👋', '💪', '🙏', '👀', '🤝', '✌️', '🫡', '😇', '🥺',
    '😤', '😭', '🤣', '😏', '🙄', '😴', '🤭', '😋', '🥳', '😈',
  ];

  @override
  void initState() {
    super.initState();
    _chatService.addListener(_onMessagesChanged);
    _loadMessages();
    _chatService.subscribeToMessages(widget.matchId);
    // Online-Status deactivated for now
    // _checkOnlineStatus();
    // _presenceTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkOnlineStatus());
    _checkBlocked();
  }

  Future<void> _checkBlocked() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      
      // Prüfe ob ICH den anderen blockiert habe
      final iBlocked = await Supabase.instance.client
          .from('blocks')
          .select('id')
          .eq('blocker_id', userId)
          .eq('blocked_id', widget.otherUserId ?? '')
          .maybeSingle();
      
      // Prüfe ob der ANDERE MICH blockiert hat
      final otherBlockedMe = await Supabase.instance.client
          .from('blocks')
          .select('id')
          .eq('blocker_id', widget.otherUserId ?? '')
          .eq('blocked_id', userId)
          .maybeSingle();
      
      if (mounted) {
        setState(() {
          _isBlocked = iBlocked != null;
          _isBlockedByOther = otherBlockedMe != null;
        });
      }
    } catch (_) {}
  }

  Future<void> _blockUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nutzer blockieren?'),
        content: Text('${widget.otherName} wird blockiert. Du siehst diese Person nicht mehr und sie kann dir keine Nachrichten senden.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Blockieren', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await Supabase.instance.client.from('blocks').insert({
        'blocker_id': Supabase.instance.client.auth.currentUser!.id,
        'blocked_id': widget.otherUserId,
      });
      setState(() => _isBlocked = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.otherName} wurde blockiert'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Blockieren'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _unblockUser() async {
    try {
      await Supabase.instance.client.from('blocks')
          .delete()
          .eq('blocker_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('blocked_id', widget.otherUserId ?? '');
      setState(() => _isBlocked = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.otherName} wurde entblockt'), backgroundColor: HevjinTheme.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _checkOnlineStatus() async {
    try {
      // Update own last_seen
      final myId = Supabase.instance.client.auth.currentUser?.id;
      if (myId != null) {
        await Supabase.instance.client.from('profiles').update({
          'last_seen': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', myId);
      }

      // Check partner's last_seen
      final partner = await Supabase.instance.client
          .from('profiles')
          .select('last_seen')
          .eq('id', widget.otherUserId ?? '')
          .maybeSingle();

      if (partner != null && partner['last_seen'] != null) {
        final lastActive = DateTime.parse(partner['last_seen']).toUtc();
        final diff = DateTime.now().toUtc().difference(lastActive);

        if (mounted) {
          setState(() {
            if (diff.inMinutes < 2) {
              _isOnline = true;
              _lastSeen = 'Online';
            } else if (diff.inMinutes < 60) {
              _isOnline = false;
              _lastSeen = 'Vor ${diff.inMinutes} Min. aktiv';
            } else if (diff.inHours < 24) {
              _isOnline = false;
              _lastSeen = 'Vor ${diff.inHours} Std. aktiv';
            } else {
              _isOnline = false;
              _lastSeen = 'Vor ${diff.inDays} Tagen aktiv';
            }
          });
        }
      } else {
        if (mounted) setState(() { _isOnline = false; _lastSeen = ''; });
      }
    } catch (_) {
      if (mounted) setState(() => _lastSeen = '');
    }
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    _chatService.removeListener(_onMessagesChanged);
    _chatService.unsubscribeFromMessages(widget.matchId);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMessagesChanged() {
    if (mounted) setState(() {});
    _scrollToBottom();
  }

  Future<void> _loadMessages() async {
    await _chatService.fetchMessages(widget.matchId);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() => _isSending = true);

    await _chatService.sendMessage(widget.matchId, text);

    setState(() => _isSending = false);
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 70);
      if (image == null) return;

      setState(() => _isSending = true);

      // Read image bytes
      final bytes = await image.readAsBytes();
      final fileName = 'chat/${widget.matchId}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Supabase Storage
      await Supabase.instance.client.storage
          .from('chat-images')
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));

      // Get public URL
      final imageUrl = Supabase.instance.client.storage
          .from('chat-images')
          .getPublicUrl(fileName);

      // Send as message with image prefix
      await _chatService.sendMessage(widget.matchId, '[IMAGE]$imageUrl');

      setState(() => _isSending = false);
      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bild konnte nicht gesendet werden: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  Future<void> _deleteMessage(String messageId, String content) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nachricht l\u00f6schen?'),
        content: const Text('M\u00f6chtest du diese Nachricht nur f\u00fcr dich oder f\u00fcr alle l\u00f6schen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(ctx, 'me'), child: const Text('F\u00fcr mich l\u00f6schen')),
          TextButton(onPressed: () => Navigator.pop(ctx, 'all'), child: const Text('F\u00fcr alle l\u00f6schen', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (result == null) return;

    try {
      if (result == 'all') {
        // Delete from database (for everyone)
        await Supabase.instance.client.from('messages').delete().eq('id', messageId);
      }
      
      // Remove from local list immediately (for both options)
      setState(() {
        _chatService.messages.removeWhere((m) => m.id == messageId);
        _chatService.notifyListeners();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result == 'all' ? 'Nachricht f\u00fcr alle gel\u00f6scht' : 'Nachricht f\u00fcr dich ausgeblendet'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final messages = _chatService.messages;

    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            if (_isBlockedByOther) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Du kannst dieses Profil nicht sehen'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
              );
              return;
            }
            if (widget.otherUserId != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(userId: widget.otherUserId!)));
            }
          },
          child: Row(
            children: [
              // Avatar mit Online-Status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFF5F5F5),
                    backgroundImage: widget.otherAvatar != null ? NetworkImage(widget.otherAvatar!) : null,
                    child: widget.otherAvatar == null ? const Icon(Icons.person, size: 18) : null,
                  ),
                  // Online-Dot (nur wenn online)
                  if (_isOnline)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: HevjinTheme.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(_lastSeen ?? '', style: TextStyle(fontSize: 11, color: _isOnline ? HevjinTheme.success : HevjinTheme.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: HevjinTheme.textSecondary),
            onSelected: (value) {
              if (value == 'report') {
                showReportSheet(context, userId: widget.otherUserId ?? '', userName: widget.otherName);
              } else if (value == 'block') {
                _blockUser();
              } else if (value == 'unblock') {
                _unblockUser();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'report', child: Row(children: [Icon(Icons.flag_outlined, size: 20, color: Colors.orange), SizedBox(width: 8), Text('Melden')])),
              PopupMenuItem(value: _isBlocked ? 'unblock' : 'block', child: Row(children: [
                Icon(_isBlocked ? Icons.lock_open : Icons.block, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                Text(_isBlocked ? 'Blockierung aufheben' : 'Blockieren'),
              ])),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: HevjinTheme.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text('Sag Hallo! 👋', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('Schreibe die erste Nachricht', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == userId;
                      final showDate = index == 0 ||
                          messages[index].createdAt.toLocal().day != messages[index - 1].createdAt.toLocal().day;
                      final isLast = index == messages.length - 1;
                      final isMessageRead = msg.isRead;

                      return Column(
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(_formatDate(msg.createdAt), style: const TextStyle(fontSize: 11, color: HevjinTheme.textSecondary)),
                              ),
                            ),
                          _MessageBubble(
                            message: msg.content,
                            isMe: isMe,
                            time: '${msg.createdAt.toLocal().hour.toString().padLeft(2, '0')}:${msg.createdAt.toLocal().minute.toString().padLeft(2, '0')}',
                            isRead: isMe && isMessageRead,
                            onDelete: isMe ? () => _deleteMessage(msg.id, msg.content) : null,
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Emoji Picker
          if (_showEmojis)
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: _quickEmojis.length,
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () {
                    // Emoji ins Textfeld einfuegen (nicht senden!)
                    final text = _messageController.text;
                    final selection = _messageController.selection;
                    final newText = text.replaceRange(
                      selection.start < 0 ? text.length : selection.start,
                      selection.end < 0 ? text.length : selection.end,
                      _quickEmojis[i],
                    );
                    _messageController.text = newText;
                    _messageController.selection = TextSelection.collapsed(
                      offset: (selection.start < 0 ? text.length : selection.start) + _quickEmojis[i].length,
                    );
                  },
                  child: Center(
                    child: Text(_quickEmojis[i], style: const TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ),

          // Message Input (or blocked message)
          if (_isBlocked || _isBlockedByOther)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border(top: BorderSide(color: Colors.red.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _isBlocked ? AppLocalizations.of(context)?.blocked ?? 'Du hast diesen Nutzer blockiert' : AppLocalizations.of(context)?.blockedByOther ?? 'Du wurdest blockiert',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  if (_isBlocked) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _unblockUser,
                      child: const Text('Aufheben', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            )
          else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Emoji Button
                  GestureDetector(
                    onTap: () => setState(() => _showEmojis = !_showEmojis),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _showEmojis ? HevjinTheme.secondary.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Icon(
                        _showEmojis ? Icons.keyboard : Icons.emoji_emotions_outlined,
                        color: _showEmojis ? HevjinTheme.secondary : HevjinTheme.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Text Input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Nachricht schreiben...',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      onTap: () {
                        if (_showEmojis) setState(() => _showEmojis = false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Image Button
                  GestureDetector(
                    onTap: _isSending ? null : () => _sendImage(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Icon(Icons.image_outlined, color: HevjinTheme.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send Button
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: HevjinTheme.secondary,
                        borderRadius: BorderRadius.circular(21),
                        boxShadow: [BoxShadow(color: HevjinTheme.secondary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    if (local.day == now.day && local.month == now.month && local.year == now.year) {
      return 'Heute';
    }
    if (local.day == now.day - 1 && local.month == now.month && local.year == now.year) {
      return 'Gestern';
    }
    return '${local.day}.${local.month}.${local.year}';
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final bool isRead;
  final VoidCallback? onDelete;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.time,
    this.isRead = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Check if message is an image
    final isImage = message.startsWith('[IMAGE]');
    
    // Check if message is just an emoji
    final isEmoji = !isImage && message.length <= 4 && RegExp(r'^[\p{Emoji}]+$', unicode: true).hasMatch(message);

    if (isImage) {
      final imageUrl = message.replaceFirst('[IMAGE]', '');
      return GestureDetector(
        onLongPress: onDelete,
        child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: 200, height: 150,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    width: 200, height: 150,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(time, style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 10)),
                    if (isMe && isRead) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.done_all, size: 14, color: Colors.blue.shade300),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      );
    }

    if (isEmoji) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 40)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(time, style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 10)),
                  if (isMe && isRead) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.done_all, size: 14, color: Colors.blue.shade300),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: onDelete,
      child: Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? HevjinTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : HevjinTheme.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMe ? Colors.white60 : HevjinTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
                // Lesebestätigung (Doppel-Häkchen)
                if (isMe && isRead) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 14, color: Colors.blue.shade300),
                ] else if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done, size: 14, color: isMe ? Colors.white60 : HevjinTheme.textSecondary),
                ],
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}


