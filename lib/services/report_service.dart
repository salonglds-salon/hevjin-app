import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  final _supabase = Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  /// Block a user
  Future<bool> blockUser(String blockedUserId) async {
    try {
      await _supabase.from('blocks').insert({
        'blocker_id': _userId,
        'blocked_id': blockedUserId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Unblock a user
  Future<bool> unblockUser(String blockedUserId) async {
    try {
      await _supabase.from('blocks')
          .delete()
          .eq('blocker_id', _userId)
          .eq('blocked_id', blockedUserId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Report a user
  Future<bool> reportUser(String reportedUserId, String reason, {String? details}) async {
    try {
      await _supabase.from('reports').insert({
        'reporter_id': _userId,
        'reported_id': reportedUserId,
        'reason': reason,
        'details': details,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if a user is blocked
  Future<bool> isBlocked(String userId) async {
    final result = await _supabase.from('blocks')
        .select()
        .eq('blocker_id', _userId)
        .eq('blocked_id', userId)
        .maybeSingle();
    return result != null;
  }

  /// Get list of blocked user IDs
  Future<List<String>> getBlockedUserIds() async {
    final result = await _supabase.from('blocks')
        .select('blocked_id')
        .eq('blocker_id', _userId);
    return result.map<String>((r) => r['blocked_id'] as String).toList();
  }
}
