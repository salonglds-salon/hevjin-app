import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  UserProfile? _currentProfile;
  List<UserProfile> _discoveryProfiles = [];
  bool _isDeactivated = false;
  bool _isLoading = false;

  UserProfile? get currentProfile => _currentProfile;
  List<UserProfile> get discoveryProfiles => _discoveryProfiles;
  bool get isLoading => _isLoading;
  bool get isDeactivated => _isDeactivated;
  bool get hasProfile => _currentProfile != null && !_isDeactivated;

  /// Reset state on logout
  void reset() {
    _currentProfile = null;
    _discoveryProfiles = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data != null) {
      // Check if account is deactivated
      if (data['deleted_at'] != null) {
        _isDeactivated = true;
        _currentProfile = UserProfile.fromJson(data);
        notifyListeners();
        return;
      }
      _isDeactivated = false;
      _currentProfile = UserProfile.fromJson(data);
      notifyListeners();
    }
  }

  /// Create or update profile
  Future<bool> saveProfile(Map<String, dynamic> profileData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id ?? profileData['id'];
      if (userId == null) throw Exception('Kein User eingeloggt');
      profileData['id'] = userId;

      print('=== SAVING PROFILE ===');
      print('UserID: $userId');
      print('Data: $profileData');

      await _supabase.from('profiles').upsert(profileData);
      await fetchProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('=== PROFILE SAVE ERROR ===');
      print('Error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _casteFilter;
  String? get casteFilter => _casteFilter;

  void setCasteFilter(String? caste) {
    _casteFilter = caste;
    fetchDiscoveryProfiles();
  }

  /// Fetch profiles for discovery/swiping
  Future<void> fetchDiscoveryProfiles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get IDs of users already liked
      List<String> excludeIds = [userId];
      try {
        final likedData = await _supabase
            .from('likes')
            .select('to_user')
            .eq('from_user', userId);
        excludeIds.addAll(likedData.map<String>((l) => l['to_user'].toString()));
      } catch (_) {
        // If likes table fails, just exclude own ID
      }

      // Get IDs of matched users
      try {
        final matchData = await _supabase
            .from('matches')
            .select('user1, user2')
            .or('user1.eq.$userId,user2.eq.$userId');
        for (final match in matchData) {
          final otherId = match['user1'] == userId ? match['user2'] : match['user1'];
          if (!excludeIds.contains(otherId)) excludeIds.add(otherId.toString());
        }
      } catch (_) {}

      // Get IDs of blocked users
      try {
        final blockedData = await _supabase
            .from('blocks')
            .select('blocked_id')
            .eq('blocker_id', userId);
        excludeIds.addAll(blockedData.map<String>((b) => b['blocked_id'].toString()));
      } catch (_) {}

      // Determine opposite gender for filtering
      String? myGender;
      try {
        final myProfile = await _supabase.from('profiles').select('gender').eq('id', userId).maybeSingle();
        myGender = myProfile?['gender']?.toString();
        print('My gender: $myGender, userId: $userId');
      } catch (e) {
        print('Gender fetch error: $e');
      }
      
      // If user is male -> show female, if female -> show male
      final oppositeGender = myGender == 'male' ? 'female' : myGender == 'female' ? 'male' : null;
      print('Showing profiles with gender: $oppositeGender');

      // Fetch profiles excluding already liked/matched, filtered by gender
      var query = _supabase
          .from('profiles')
          .select()
          .not('id', 'in', '(${excludeIds.join(",")})')
          .isFilter('deleted_at', null); // Don't show deactivated profiles
      
      if (oppositeGender != null) {
        query = query.eq('gender', oppositeGender);
      }
      
      final data = await query.limit(20);

      _discoveryProfiles = data.map((json) => UserProfile.fromJson(json)).toList();
    } catch (e) {
      print('Discover error: $e');
      _discoveryProfiles = [];
    }
      if (const bool.fromEnvironment('MATCH_PREVIEW')) {
        _discoveryProfiles = [..._discoveryProfiles, ..._demoProfiles()];
      }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Like a user - returns the matchId if mutual, else null.
  /// Wirft nie: Ein fehlgeschlagener Like darf den Like-Button nicht blockieren.
  Future<String?> likeUser(String targetUserId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      // Doppel-Like darf nicht crashen (moeglicher Unique-Constraint auf likes)
      try {
        await _supabase.from('likes').insert({
          'from_user': userId,
          'to_user': targetUserId,
        });
      } catch (_) {
        // Like existiert bereits - egal, Match-Pruefung laeuft trotzdem weiter
      }

      // Check for mutual like (= match!)
      final mutual = await _supabase
          .from('likes')
          .select()
          .eq('from_user', targetUserId)
          .eq('to_user', userId)
          .maybeSingle();

      if (mutual == null) return null;

      // Bestehendes Match wiederverwenden statt ein Duplikat anzulegen
      // (Richtung ist nicht garantiert -> beide Kombinationen pruefen)
      final existing = await _supabase
          .from('matches')
          .select('id')
          .or('and(user1.eq.$userId,user2.eq.$targetUserId),'
              'and(user1.eq.$targetUserId,user2.eq.$userId)')
          .maybeSingle();

      if (existing != null) return existing['id']?.toString();

      final match = await _supabase.from('matches').insert({
        'user1': userId,
        'user2': targetUserId,
      }).select('id').maybeSingle();

      return match?['id']?.toString();
    } catch (e) {
      print('likeUser error: $e');
      return null;
    }
  }

  /// Upload profile photo
  Future<String?> uploadPhoto(String filePath, String fileName) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final path = '$userId/$fileName';

      final url = _supabase.storage
          .from('profile-photos')
          .getPublicUrl(path);

      return url;
    } catch (e) {
      return null;
    }
  }

  /// Demo-Profile fuer den Test-Modus (--dart-define=MATCH_PREVIEW=true).
  /// Landen NIE in einem normalen Build.
  List<UserProfile> _demoProfiles() {
    UserProfile p(String id, String name, int age, String caste, String city,
        String bio, List<String> interests) {
      return UserProfile(
        id: id,
        displayName: name,
        birthDate: DateTime(DateTime.now().year - age, 5, 12),
        gender: 'female',
        caste: caste,
        lookingFor: 'heirat',
        city: city,
        bio: bio,
        interests: interests,
        createdAt: DateTime.now(),
        isVerified: true,
      );
    }

    return [
      p('demo-1', 'Z\u00een', 26, 'murid', 'K\u00f6ln',
          'Liebe die kurdische Musik und gutes Essen. Suche etwas Ernstes.',
          ['Musik', 'Kochen', 'Reisen']),
      p('demo-2', 'Nasrin', 29, 'pir', 'Hannover',
          'Krankenschwester, familienorientiert, humorvoll.',
          ['Familie', 'Lesen', 'Yoga']),
      p('demo-3', 'Delal', 24, 'murid', 'Bielefeld',
          'Studentin. Mag lange Gespr\u00e4che und Spaziergaenge.',
          ['Kunst', 'Natur', 'Fotografie']),
    ];
  }
}
