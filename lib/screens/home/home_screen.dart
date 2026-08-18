import '../match/match_screen.dart';
import 'dart:async';
import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../models/user_profile.dart';
import '../../utils/theme.dart';
import '../../utils/chip_emojis.dart';
import '../profile/photo_upload_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../splash_screen.dart';
import '../chat/chat_screen.dart';
import '../../widgets/edit_field_sheet.dart';
import '../../widgets/report_sheet.dart';
import '../settings/support_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_screen.dart';
import '../legal/imprint_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    // Delay to ensure auth session is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ProfileService>().fetchDiscoveryProfiles();
      }
    });
    _checkUnread();
    _startUnreadTimer();
  }

  void _startUnreadTimer() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _checkUnread();
        _startUnreadTimer();
      }
    });
  }

  Future<void> _checkUnread() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      
      // Hole meine Match-IDs
      final matches = await Supabase.instance.client
          .from('matches')
          .select('id')
          .or('user1.eq.$userId,user2.eq.$userId');
      
      if (matches.isEmpty) {
        if (mounted) setState(() => _unreadCount = 0);
        return;
      }
      
      final matchIds = matches.map((m) => m['id'].toString()).toList();
      
      // Zähle ungelesene Nachrichten in meinen Matches (nicht von mir gesendet)
      final result = await Supabase.instance.client
          .from('messages')
          .select('id')
          .eq('is_read', false)
          .neq('sender_id', userId)
          .inFilter('match_id', matchIds);
      
      if (mounted) {
        setState(() => _unreadCount = result.length);
      }
    } catch (_) {
      if (mounted) setState(() => _unreadCount = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevjinTheme.background,
      body: Column(
        children: [
          // Top Header Bar (Parship Style)
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                // Logo Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      // Logo
                      Row(
                        children: [
                          const Text('Hevjîn', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: HevjinTheme.primary)),
                          const SizedBox(width: 4),
                          Icon(Icons.favorite, color: HevjinTheme.secondary, size: 20),
                        ],
                      ),
                      const Spacer(),
                      // Avatar
                      GestureDetector(
                        onTap: () => setState(() => _currentIndex = 3),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF5F5F5),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(Icons.person, size: 20, color: HevjinTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                // Navigation Pills (Parship Style)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: Row(
                    children: [
                      _navPill(0, Icons.explore_outlined, AppLocalizations.of(context)?.discover ?? 'Discover'),
                      const SizedBox(width: 6),
                      _navPill(1, Icons.favorite, AppLocalizations.of(context)?.likes ?? 'Likes', hasHighlight: true),
                      const SizedBox(width: 6),
                    _navPill(2, Icons.chat_bubble_outline, AppLocalizations.of(context)?.chats ?? 'Chats', badge: _unreadCount),
                      const SizedBox(width: 6),
                      _navPill(3, Icons.person_outline, AppLocalizations.of(context)?.profile ?? 'Profil'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                DiscoverTab(),
                MatchesTab(),
                ChatsTab(),
                ProfileTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navPill(int index, IconData icon, String label, {bool hasHighlight = false, int badge = 0}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 2) {
          // Reset unread counter when entering Chats tab
          setState(() => _unreadCount = 0);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (hasHighlight ? HevjinTheme.secondary : HevjinTheme.primary)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: isSelected ? null : Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16,
                  color: isSelected ? Colors.white : HevjinTheme.textSecondary),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : HevjinTheme.textSecondary,
                )),
              ],
            ),
          ),
          if (badge > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                child: Center(child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              ),
            ),
        ],
      ),
    );
  }
}

// ===== DISCOVER TAB - Parship 2-Column Style =====
class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = context.watch<ProfileService>();
    final profiles = profileService.discoveryProfiles;

    if (profileService.isLoading) {
      return const Center(child: CircularProgressIndicator(color: HevjinTheme.secondary));
    }

    if (profiles.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: HevjinTheme.secondary.withOpacity(0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: HevjinTheme.secondary.withOpacity(0.35), width: 2),
                ),
                child: const Icon(Icons.favorite_border,
                    size: 48, color: HevjinTheme.secondary),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)?.noNewProfiles ??
                    'Keine neuen Profile',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HevjinTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Du hast alle Profile gesehen, die zu dir passen.\nEs kommen laufend neue Mitglieder dazu \u2014 schau sp\u00e4ter nochmal vorbei!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: HevjinTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () => profileService.fetchDiscoveryProfiles(),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Neu laden'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: HevjinTheme.secondary,
                  side: const BorderSide(color: HevjinTheme.secondary, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Tipp: Vervollst\u00e4ndige dein Profil \u2014 das erh\u00f6ht deine Treffer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: HevjinTheme.textSecondary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final profile = profiles.first;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700; // 2-column on wide screens

    return Stack(
      children: [
        // Scrollable Content
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: isWide
                ? _buildWideLayout(profile)
                : _buildNarrowLayout(profile),
          ),
        ),

        // Fixed Bottom Action Bar
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _buildActionBar(profileService, profiles, context),
        ),
      ],
    );
  }

  // ===== WIDE LAYOUT (2 columns like Parship Desktop) =====
  static Widget _buildWideLayout(UserProfile profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN - Photo + Bio + Interests
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _photoCard(profile),
              const SizedBox(height: 12),
              _bioCard(profile),
              const SizedBox(height: 12),
              _interestsCard(profile),
              const SizedBox(height: 12),
              _tagsCard(profile),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // RIGHT COLUMN - Quick Facts + Compatibility
        Expanded(
          flex: 2,
          child: Column(
            children: [
                  _compatibilityCard(profile),
              const SizedBox(height: 12),
              _quickFactsCard(profile),
              const SizedBox(height: 12),
              _promptCard(profile),
            ],
          ),
        ),
      ],
    );
  }

  // ===== NARROW LAYOUT (single column for mobile) =====
  static Widget _buildNarrowLayout(UserProfile profile) {
    return Column(
      children: [
        _photoCard(profile),
        const SizedBox(height: 12),
                _compatibilityCard(profile),
        const SizedBox(height: 12),
        _bioCard(profile),
        const SizedBox(height: 12),
        _quickFactsCard(profile),
        const SizedBox(height: 12),
        _interestsCard(profile),
        const SizedBox(height: 12),
        _tagsCard(profile),
        const SizedBox(height: 12),
        _promptCard(profile),
      ],
    );
  }

  // ===== PHOTO CARD =====
  static Widget _photoCard(UserProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Photo
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  height: 320,
                  child: profile.avatarUrl != null
                      ? Image.network(profile.avatarUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _genderPlaceholder(profile.gender))
                      : _genderPlaceholder(profile.gender),
                ),
              ),
              // Fotos ansehen badge
              Positioned(
                bottom: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: HevjinTheme.secondary, borderRadius: BorderRadius.circular(6)),
                  child: const Text('Fotos ansehen', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          // Name + Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${profile.displayName}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(', ${profile.age}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: HevjinTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                if (profile.city != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: HevjinTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(profile.city!, style: const TextStyle(fontSize: 13, color: HevjinTheme.textSecondary)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: HevjinTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 5, height: 5, decoration: const BoxDecoration(color: HevjinTheme.success, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            const Text('Neu dabei', style: TextStyle(fontSize: 10, color: HevjinTheme.success, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                        child: const Text('Jetzt aktiv', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== COMPATIBILITY CARD =====
  static Widget _compatibilityCard(UserProfile profile) {
    final score = 70 + (profile.displayName.length * 3) % 25;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: HevjinTheme.secondary.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(
              child: Text('❤️', style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$score %', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: HevjinTheme.secondary)),
              const Text('\u00dcbereinstimmung', style: TextStyle(fontSize: 11, color: HevjinTheme.textSecondary)),
            ],
          ),
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => showReportSheet(ctx, userId: profile.id, userName: profile.displayName),
              child: const Icon(Icons.more_horiz, color: HevjinTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ===== BIO CARD =====
  static Widget _bioCard(UserProfile profile) {
    if (profile.bio == null) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.bio!,
            style: const TextStyle(fontSize: 15, height: 1.6, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.favorite_border, color: HevjinTheme.textSecondary.withOpacity(0.4), size: 20),
          ),
        ],
      ),
    );
  }

  // ===== QUICK FACTS CARD (Sidebar style) =====
  static Widget _quickFactsCard(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _factRow(Icons.stars_outlined, 'KASTE', profile.casteDisplay),
          if (profile.tribe != null) _factRow(Icons.groups_outlined, 'STAMM', profile.tribe!),
          _factRow(Icons.favorite_outline, 'SUCHT', profile.lookingForDisplay),
          if (profile.city != null) _factRow(Icons.location_on_outlined, 'WOHNORT', profile.city!),
          if (profile.height != null) _factRow(Icons.straighten, 'FIGUR', '${profile.height} cm'),
          if (profile.education != null) _factRow(Icons.school_outlined, 'BILDUNG', profile.educationDisplay),
          if (profile.job != null) _factRow(Icons.work_outline, 'BERUF', profile.job!),
          if (profile.familyStatus != null) _factRow(Icons.people_outline, 'FAMILIENSTAND', profile.familyStatusDisplay),
          if (profile.hasChildren != null) _factRow(Icons.child_care, 'KINDER', profile.hasChildren! ? 'Ja' : 'Keine Kinder'),
          if (profile.childWish != null) _factRow(Icons.child_friendly, 'KINDERWUNSCH', profile.childWish == 'ja' ? 'Ja, wünsche ich mir' : profile.childWish == 'nein' ? 'Nein' : 'Vielleicht'),
        ],
      ),
    );
  }

  static Widget _factRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: HevjinTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== INTERESTS CARD =====
  static Widget _interestsCard(UserProfile profile) {
    if (profile.interests.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('INTERESSEN UND HOBBYS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 1.2)),
              const Spacer(),
              Icon(Icons.favorite_border, color: HevjinTheme.textSecondary.withOpacity(0.4), size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.interests.map((i) => _emojiChip(
              i,
              _interestEmoji[i] ?? '\u{2728}',
              const Color(0xFFFFF3F0),
              const Color(0xFFFFD9D0),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ===== TAGS / CHARAKTER CARD =====
  static Widget _tagsCard(UserProfile profile) {
    if (profile.tags.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('CHARAKTER UND EIGENSCHAFTEN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 1.2)),
              const Spacer(),
              Icon(Icons.favorite_border, color: HevjinTheme.textSecondary.withOpacity(0.4), size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.tags.map((t) => _emojiChip(
              t,
              _tagEmoji[t] ?? '\u{2728}',
              const Color(0xFFFDF6E9),
              const Color(0xFFF0DCB4),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ===== EMOJI-MAPPING FUER CHIPS =====
  static const Map<String, String> _interestEmoji = {
    'Sport & Fitness': '\u{1F4AA}',
    'Zeit mit Familie': '\u{1F46A}',
    'Kochen & Essen': '\u{1F373}',
    'Reisen': '\u{1F30E}',
    'Lesen & Lernen': '\u{1F4DA}',
    'Gaming & Filme': '\u{1F3AE}',
    'Musik & Tanzen': '\u{1F3B5}',
    'Natur & Spazieren': '\u{1F33F}',
    'Fotografie': '\u{1F4F7}',
    'Autos & Technik': '\u{1F697}',
    'Kunst & Design': '\u{1F3A8}',
  };

  static const Map<String, String> _tagEmoji = {
    'Humorvoll': '\u{1F604}',
    'Romantisch': '\u{1F339}',
    'Sportlich': '\u{1F3C3}',
    'Zuverlaessig': '\u{1F91D}',
    'Ehrgeizig': '\u{1F3AF}',
    'Herzlich': '\u{1F49B}',
    'Weltoffen': '\u{1F30D}',
    'Traditionell': '\u{2600}',
    'Spontan': '\u{26A1}',
    'Kreativ': '\u{1F3A8}',
    'Spirituell': '\u{1F54A}',
    'Liebevoll': '\u{1F49E}',
    'Gelassen': '\u{1F9D8}',
    'Zielstrebig': '\u{1F680}',
    'Abenteuerlustig': '\u{1F9ED}',
    'Empathisch': '\u{1F932}',
    'Loyal': '\u{1F6E1}',
  };

  /// Chip mit Emoji + warmem Farbton statt Einheits-Icon.
  static Widget _emojiChip(String label, String emoji, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15, height: 1.1)),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3A2A22),
            ),
          ),
        ],
      ),
    );
  }
  // ===== PROMPT CARD (echte Profilfragen) =====
  static Widget _promptCard(UserProfile profile) {
    // Nur anzeigen, wenn das Profil wirklich Fragen beantwortet hat.
    final answers = profile.promptAnswers
        .where((e) => (e['a'] ?? '').trim().isNotEmpty)
        .toList();
    if (answers.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < answers.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),
            Text(
              (answers[i]['q'] ?? '').trim(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: HevjinTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (answers[i]['a'] ?? '').trim(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: Color(0xFF3A2A22),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===== ACTION BAR =====
  static Widget _buildActionBar(ProfileService profileService, List<UserProfile> profiles, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dislike - animated broken heart button
          _AnimatedDislikeButton(
            onTap: () async {
              if (profiles.isEmpty) return;
              await profileService.dislikeUser(profiles.first.id);
            },
          ),
          const SizedBox(width: 20),
          // Like - 3D animated button
          _AnimatedLikeButton(
            onTap: () async {
              if (profiles.isEmpty) return;
              final liked = profiles.first;
              final isDemo = liked.id.startsWith('demo-');
              final matchId = isDemo ? 'demo' : await profileService.likeUser(liked.id);
              profileService.discoveryProfiles.removeAt(0);
              // ignore: invalid_use_of_protected_member
              profileService.notifyListeners();
              if (matchId != null && context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => MatchScreen(
                    matchId: matchId,
                    otherUserId: liked.id,
                    otherName: liked.displayName,
                    otherAvatar: liked.avatarUrl ??
                        (liked.photos.isNotEmpty ? liked.photos.first : null),
                    myAvatar: profileService.currentProfile?.avatarUrl,
                    preview: isDemo,
                  ),
                ));
              }
            },
          ),
          const SizedBox(width: 20),
          // Next (arrow)
          GestureDetector(
            onTap: () {
              profileService.discoveryProfiles.removeAt(0);
              // ignore: invalid_use_of_protected_member
              profileService.notifyListeners();
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.arrow_forward, color: HevjinTheme.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _genderPlaceholder(String? gender) {
    final isFemale = gender == 'female';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isFemale
              ? [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)]
              : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFemale ? Icons.face_3 : Icons.face,
              size: 90,
              color: isFemale ? const Color(0xFFE91E63).withOpacity(0.4) : const Color(0xFF1976D2).withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            Text(
              isFemale ? 'Frau' : 'Mann',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isFemale ? const Color(0xFFE91E63).withOpacity(0.5) : const Color(0xFF1976D2).withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== MATCHES / LIKES TAB =====
class MatchesTab extends StatelessWidget {
  const MatchesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Likes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Personen die dich mögen', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 13)),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_outline, size: 56, color: HevjinTheme.textSecondary),
                    SizedBox(height: 16),
                    Text('Noch keine Likes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text('Wenn jemand dein Profil liked,\nerscheint es hier.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: HevjinTheme.textSecondary, height: 1.4)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== CHATS TAB =====
class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});
  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final _chatService = ChatService();
  late final _refreshTimer = Stream.periodic(const Duration(seconds: 15));
  late final _refreshSub;

  @override
  void initState() {
    super.initState();
    _chatService.addListener(() { if (mounted) setState(() {}); });
    _chatService.fetchMatches();
    // Refresh chat previews every 10 seconds (soft update, no flicker)
    _refreshSub = _refreshTimer.listen((_) {
      if (mounted) _chatService.fetchMatches();
    });
  }

  @override
  void dispose() {
    _refreshSub.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final matches = _chatService.matches;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chats', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(AppLocalizations.of(context)?.yourConversations ?? 'Deine Unterhaltungen', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          if (_chatService.isLoading)
            const Center(child: CircularProgressIndicator(color: HevjinTheme.secondary))
          else if (matches.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        color: HevjinTheme.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.chat_bubble_outline, size: 32, color: HevjinTheme.secondary.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Noch keine Chats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('Matche mit jemandem und\nstarte eine Unterhaltung!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: HevjinTheme.textSecondary, height: 1.4)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: matches.length,
                separatorBuilder: (_, __) => Divider(height: 1, indent: 76, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return ListTile(
                    key: ValueKey(match.matchId),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFF5F5F5),
                      backgroundImage: match.avatarUrl != null ? NetworkImage(match.avatarUrl!) : null,
                      child: match.avatarUrl == null ? const Icon(Icons.person, color: HevjinTheme.textSecondary) : null,
                    ),
                    title: Text(match.displayName, style: TextStyle(
                      fontWeight: match.hasUnread ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                    )),
                    subtitle: Text(
                      match.lastMessage ?? 'Sag Hallo!',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: match.hasUnread ? HevjinTheme.textPrimary : HevjinTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: match.hasUnread ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: match.lastMessageTime != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${match.lastMessageTime!.toLocal().hour.toString().padLeft(2, '0')}:${match.lastMessageTime!.toLocal().minute.toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 11, color: match.hasUnread ? HevjinTheme.secondary : HevjinTheme.textSecondary),
                              ),
                              if (match.hasUnread) ...[
                                const SizedBox(height: 4),
                                Container(
                                  width: 10, height: 10,
                                  decoration: const BoxDecoration(color: HevjinTheme.secondary, shape: BoxShape.circle),
                                ),
                              ],
                            ],
                          )
                        : null,
                    onTap: () async {
                      await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ChatScreen(matchId: match.matchId, otherName: match.displayName, otherAvatar: match.avatarUrl, otherUserId: match.otherId)),
                      );
                      if (context.mounted) {
                        _chatService.fetchMatches(); // Refresh unread status
                        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                        homeState?._checkUnread();
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ===== PROFILE TAB - Parship Style =====
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _calculateCompleteness(UserProfile profile) {
    int score = 0;
    int total = 10;
    if (profile.displayName.isNotEmpty) score++;
    if (profile.avatarUrl != null) score++;
    if (profile.bio != null && profile.bio!.isNotEmpty) score++;
    if (profile.city != null) score++;
    if (profile.tribe != null) score++;
    if (profile.photos.isNotEmpty) score++;
    if (profile.height != null) score++;
    if (profile.job != null) score++;
    if (profile.education != null) score++;
    if (profile.interests.isNotEmpty) score++;
    return ((score / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileService>().currentProfile;
    if (profile == null) return const Center(child: CircularProgressIndicator(color: HevjinTheme.secondary));

    final completeness = _calculateCompleteness(profile);

    return Scaffold(
      backgroundColor: HevjinTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Banner + Avatar Header
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Banner
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Banner Background
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              HevjinTheme.secondary.withOpacity(0.3),
                              HevjinTheme.secondary.withOpacity(0.1),
                              const Color(0xFFF5F5F5),
                            ],
                          ),
                        ),
                      ),
                      // Avatar (tap to upload photo)
                      Positioned(
                        bottom: -40,
                        left: 20,
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhotoUploadScreen())).then((_) {
                            // Refresh profile after upload
                            context.read<ProfileService>().fetchProfile();
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                            ),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 52,
                                  backgroundColor: const Color(0xFFF5F5F5),
                                  backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                                  child: profile.avatarUrl == null
                                      ? const Icon(Icons.camera_alt, size: 32, color: HevjinTheme.textSecondary)
                                      : null,
                                ),
                                // + indicator
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    width: 26, height: 26,
                                    decoration: BoxDecoration(
                                      color: HevjinTheme.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Settings & Verification buttons (top right)
                      Positioned(
                        top: 50,
                        right: 16,
                        child: Row(
                          children: [
                            _circleIconButton(Icons.verified_outlined, 'SMS\nVerifiziert', true),
                            const SizedBox(width: 12),
                            _circleIconButton(Icons.settings_outlined, 'Daten &\nEinstellungen', false,
                              onTap: () {}),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Name + Age section
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 60),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(profile.displayName,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_ios, size: 14, color: HevjinTheme.textSecondary),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('${profile.age} Jahre',
                                style: const TextStyle(fontSize: 14, color: HevjinTheme.textSecondary)),
                            ],
                          ),
                        ),
                        // Caste Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: HevjinTheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(profile.casteDisplay,
                            style: const TextStyle(color: HevjinTheme.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: HevjinTheme.secondary,
                  indicatorWeight: 2.5,
                  labelColor: HevjinTheme.secondary,
                  unselectedLabelColor: HevjinTheme.textSecondary,
                  labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: AppLocalizations.of(context)?.profile ?? 'Profil'),
                    Tab(text: AppLocalizations.of(context)?.photos ?? 'Fotos'),
                    Tab(text: AppLocalizations.of(context)?.settings ?? 'Einstellungen'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: Profil
            _buildProfileContent(profile, completeness),
            // TAB 2: Fotos
            _buildPhotosContent(profile),
            // TAB 3: Einstellungen
            _buildSettingsContent(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(UserProfile profile, int completeness) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN - Content
                Expanded(flex: 3, child: _leftColumn(profile)),
                const SizedBox(width: 16),
                // RIGHT COLUMN - Sidebar
                Expanded(flex: 2, child: _rightColumn(profile, completeness)),
              ],
            )
          : Column(
              children: [
                _leftColumn(profile),
                const SizedBox(height: 16),
                _rightColumn(profile, completeness),
              ],
            ),
    );
  }

  Widget _leftColumn(UserProfile profile) {
    return Column(
      children: [
        // UEBER MICH
        _sectionCard(
          title: '\u00dcBER MICH',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.bio ?? 'Erzähl etwas über dich...',
                style: TextStyle(
                  fontSize: 14, height: 1.5,
                  color: profile.bio != null ? HevjinTheme.textPrimary : HevjinTheme.textSecondary,
                  fontStyle: profile.bio == null ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
          onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
        ),
        const SizedBox(height: 12),

        // PROFILFRAGEN
        _sectionCard(
          title: 'PROFILFRAGEN',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profile.promptAnswers.isEmpty)
                Text(
                  'Noch keine Frage beantwortet. Beantworte Fragen, damit andere dich besser kennenlernen.',
                  style: TextStyle(
                      fontSize: 13,
                      color: HevjinTheme.textSecondary,
                      fontStyle: FontStyle.italic),
                ),
              for (int i = 0; i < profile.promptAnswers.length; i++) ...[
                if (i > 0) const Divider(height: 24),
                _promptQuestion(context, profile, i),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPromptSheet(context, profile),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Weitere Frage beantworten'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HevjinTheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // LIFESTYLE - Was ich besonders mag (separate Lifestyle-Fotos)
        _LifestyleSection(profile: profile),
        const SizedBox(height: 12),

        // INTERESSEN UND HOBBYS - Inline klickbar
        _InlineChips(title: 'INTERESSEN UND HOBBYS', field: 'interests', selected: profile.interests, options: const ['Sport & Fitness', 'Zeit mit Familie', 'Kochen & Essen', 'Reisen', 'Lesen & Lernen', 'Gaming & Filme', 'Musik & Tanzen', 'Natur & Spazieren', 'Fotografie', 'Autos & Technik', 'Kunst & Design']),
        const SizedBox(height: 12),

        // SPORT - Inline klickbar
        _InlineChips(title: 'SPORT', field: 'sports', selected: profile.sports, options: const ['Fitness', 'Fussball', 'Schwimmen', 'Joggen', 'Yoga', 'Boxen', 'Basketball', 'Tennis', 'Kampfsport', 'Tanzen', 'Radfahren', 'Wandern']),
        const SizedBox(height: 12),

        // REISEN - Inline klickbar
        _InlineChips(title: 'REISEN', field: 'travel', selected: profile.travel, options: const ['Strandurlaub', 'Staedtereisen', 'Aktivurlaub', 'Camping & Natur', 'Wellness', 'Backpacking', 'Familienurlaub', 'Kreuzfahrt']),
        const SizedBox(height: 12),

        // CHARAKTER UND EIGENSCHAFTEN - Inline klickbar
        _InlineChips(title: 'CHARAKTER UND EIGENSCHAFTEN', field: 'tags', selected: profile.tags, options: const ['Humorvoll', 'Romantisch', 'Sportlich', 'Zuverlaessig', 'Ehrgeizig', 'Herzlich', 'Weltoffen', 'Traditionell', 'Spontan', 'Kreativ', 'Spirituell', 'Liebevoll', 'Gelassen', 'Zielstrebig', 'Abenteuerlustig', 'Empathisch', 'Loyal']),
        const SizedBox(height: 30),

        // Logout
        TextButton.icon(
          onPressed: () async {
            context.read<ProfileService>().reset();
            await context.read<AuthService>().signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const SplashScreen()), (route) => false);
            }
          },
          icon: Icon(Icons.logout, color: HevjinTheme.error, size: 16),
          label: Text('Ausloggen', style: TextStyle(color: HevjinTheme.error, fontSize: 13)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _rightColumn(UserProfile profile, int completeness) {
    return Column(
      children: [
        // PROFILVOLLSTAENDIGKEIT
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Column(
            children: [
              const Text('PROFILVOLLST\u00c4NDIGKEIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 1)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 50, height: 50,
                        child: CircularProgressIndicator(
                          value: completeness / 100, strokeWidth: 4,
                          backgroundColor: const Color(0xFFF5F5F5),
                          valueColor: AlwaysStoppedAnimation<Color>(completeness > 70 ? HevjinTheme.success : HevjinTheme.error),
                        ),
                      ),
                      Text('$completeness%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      completeness < 80
                          ? 'Achtung, du verschenkst wertvolle Chancen! Komplettiere jetzt dein Profil.'
                          : 'Super! Dein Profil ist fast vollständig.',
                      style: const TextStyle(fontSize: 12, height: 1.4, color: HevjinTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // STECKBRIEF
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)?.profile ?? 'STECKBRIEF', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 1.5)),
              const SizedBox(height: 14),
              _steckbriefRow(Icons.location_on_outlined, AppLocalizations.of(context)?.city ?? 'WOHNORT', profile.city ?? 'Keine Angabe',
                onTap: () => showTextEditSheet(context, title: AppLocalizations.of(context)?.city ?? 'Wohnort', field: 'city', currentValue: profile.city, hint: 'z.B. Bielefeld, Oldenburg...')),
              _steckbriefRow(Icons.person_outline, 'GESCHLECHT', profile.gender == 'male' ? (AppLocalizations.of(context)?.male ?? 'Mann') : (AppLocalizations.of(context)?.female ?? 'Frau')),
              _steckbriefRow(Icons.stars_outlined, AppLocalizations.of(context)?.caste ?? 'KASTE', profile.casteDisplay),
              _steckbriefRow(Icons.groups_outlined, AppLocalizations.of(context)?.tribe ?? 'STAMM', profile.tribe ?? 'Keine Angabe',
                onTap: () => showTextEditSheet(context, title: AppLocalizations.of(context)?.tribe ?? 'Stamm / Ashiret', field: 'tribe', currentValue: profile.tribe, hint: 'z.B. Haskan, Sipka...')),
              _steckbriefRow(Icons.work_outline, AppLocalizations.of(context)?.job ?? 'BERUF', profile.job ?? 'Keine Angabe',
                onTap: () => showTextEditSheet(context, title: AppLocalizations.of(context)?.job ?? 'Beruf', field: 'job', currentValue: profile.job, hint: 'z.B. Ingenieur, Lehrerin...')),
              _steckbriefRow(Icons.straighten, 'GR\u00d6SSE', profile.height != null ? '${profile.height} cm' : 'Keine Angabe',
                onTap: () => showSliderEditSheet(context, title: 'Gr\u00f6\u00dfe', field: 'height', currentValue: profile.height ?? 175)),
              _steckbriefRow(Icons.school_outlined, AppLocalizations.of(context)?.education ?? 'BILDUNG', profile.education != null ? profile.educationDisplay : 'Keine Angabe',
                onTap: () => showDropdownEditSheet(context, title: AppLocalizations.of(context)?.education ?? 'Bildung', field: 'education', currentValue: profile.education,
                  options: [const MapEntry('hauptschule', 'Hauptschule'), const MapEntry('realschule', 'Realschule / Ausbildung'), const MapEntry('abitur', 'Abitur'), const MapEntry('studium', 'Noch im Studium'), const MapEntry('bachelor', 'Bachelor'), const MapEntry('master', 'Master / Promotion')])),
              _steckbriefRow(Icons.interests, 'INTERESSEN', profile.interests.isNotEmpty ? profile.interests.join(', ') : 'Keine Angabe'),
              _steckbriefRow(Icons.smoke_free, 'RAUCHEN', profile.smoking != null ? profile.smokingDisplay : 'Keine Angabe',
                onTap: () => showDropdownEditSheet(context, title: 'Rauchen', field: 'smoking',
                  options: [const MapEntry('nie', 'Nichtraucher'), const MapEntry('gelegentlich', 'Gelegentlich'), const MapEntry('regelmaessig', 'Regelm\u00e4\u00dfig')])),
              _steckbriefRow(Icons.fitness_center, 'SPORT', profile.sports.isNotEmpty ? profile.sports.join(', ') : 'Keine Angabe'),
              _steckbriefRow(Icons.flight_takeoff, 'REISEN', profile.travel.isNotEmpty ? profile.travel.join(', ') : 'Keine Angabe'),
              _steckbriefRow(Icons.pets, 'HAUSTIERE', profile.pets ?? 'Keine Angabe',
                onTap: () => showTextEditSheet(context, title: 'Haustiere', field: 'pets', currentValue: profile.pets, hint: 'z.B. Katze, Hund, keine...')),
              _steckbriefRow(Icons.favorite_outline, 'FAMILIENSTAND', profile.familyStatus != null ? profile.familyStatusDisplay : 'Keine Angabe',
                onTap: () => showDropdownEditSheet(context, title: 'Familienstand', field: 'family_status', currentValue: profile.familyStatus,
                  options: [const MapEntry('ledig', 'Ledig'), const MapEntry('geschieden', 'Geschieden'), const MapEntry('getrennt', 'Getrennt lebend'), const MapEntry('verwitwet', 'Verwitwet')])),
              _steckbriefRow(Icons.child_care, 'KINDER', profile.hasChildren != null ? (profile.hasChildren! ? 'Ja' : 'Keine Kinder') : 'Keine Angabe',
                onTap: () => showBoolEditSheet(context, title: 'Hast du Kinder?', field: 'has_children', currentValue: profile.hasChildren)),
              _steckbriefRow(Icons.child_friendly, 'KINDERWUNSCH', profile.childWish != null ? profile.childWishDisplay : 'Keine Angabe',
                onTap: () => showDropdownEditSheet(context, title: 'Kinderwunsch', field: 'child_wish', currentValue: profile.childWish,
                  options: [const MapEntry('ja', 'Ja'), const MapEntry('vielleicht', 'Vielleicht'), const MapEntry('nein', 'Nein')])),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ENTERTAINMENT
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ENTERTAINMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 1.5)),
              const SizedBox(height: 14),
              _steckbriefRow(Icons.movie_outlined, 'LIEBSTE SERIEN & FILME', profile.favMovies ?? 'Keine Angabe',
                onTap: () => showTextEditSheet(context, title: 'Liebste Serien & Filme', field: 'fav_movies', currentValue: profile.favMovies, hint: 'z.B. Breaking Bad, Inception...', maxLines: 2, maxLength: 200)),
              _steckbriefRow(Icons.music_note, 'MUSIK', profile.favMusic ?? 'Keine Angabe',
                onTap: () => showTextEditSheet(context, title: 'Musik', field: 'fav_music', currentValue: profile.favMusic, hint: 'z.B. Kurdische Musik, Pop, RnB...', maxLines: 2, maxLength: 200)),
              _steckbriefRow(Icons.book_outlined, 'LIEBLINGSB\u00dcCHER', profile.favBooks ?? 'Keine Angabe',
                onTap: () => showTextEditSheet(context, title: 'Lieblingsb\u00fccher', field: 'fav_books', currentValue: profile.favBooks, hint: 'z.B. Der kleine Prinz, Quran...', maxLines: 2, maxLength: 200)),
            ],
          ),
        ),
      ],
    );
  }

  // ===== HELPER WIDGETS =====

  Widget _sectionCard({required String title, String? subtitle, required Widget child, VoidCallback? onEdit}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 1.5)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
              if (onEdit != null)
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Bearbeiten', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: HevjinTheme.secondary)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 12, color: HevjinTheme.secondary),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Future<void> _savePrompts(
      BuildContext context, List<Map<String, String>> list) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    await Supabase.instance.client
        .from('profiles')
        .update({'prompt_answers': list})
        .eq('id', userId);
    if (context.mounted) context.read<ProfileService>().fetchProfile();
  }

  Widget _promptQuestion(
      BuildContext context, UserProfile profile, int index) {
    final list = profile.promptAnswers
        .map((e) => {'q': e['q'] ?? '', 'a': e['a'] ?? ''})
        .toList();
    final item = list[index];
    final isFirst = index == 0;
    final isLast = index == list.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item['q'] ?? '',
            style:
                TextStyle(fontSize: 12, color: HevjinTheme.textSecondary)),
        const SizedBox(height: 6),
        Text(item['a'] ?? '',
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: isFirst
                  ? null
                  : () {
                      final m = list.removeAt(index);
                      list.insert(index - 1, m);
                      _savePrompts(context, list);
                    },
              child: Icon(Icons.arrow_upward,
                  size: 16,
                  color: HevjinTheme.textSecondary
                      .withOpacity(isFirst ? 0.25 : 0.75)),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: isLast
                  ? null
                  : () {
                      final m = list.removeAt(index);
                      list.insert(index + 1, m);
                      _savePrompts(context, list);
                    },
              child: Icon(Icons.arrow_downward,
                  size: 16,
                  color: HevjinTheme.textSecondary
                      .withOpacity(isLast ? 0.25 : 0.75)),
            ),
            const Spacer(),
            InkWell(
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: const Text('Antwort l\u00f6schen?'),
                    content: Text(item['q'] ?? ''),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(d, false),
                          child: const Text('Abbrechen')),
                      TextButton(
                        onPressed: () => Navigator.pop(d, true),
                        child: Text('L\u00f6schen',
                            style: TextStyle(color: HevjinTheme.error)),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  list.removeAt(index);
                  await _savePrompts(context, list);
                }
              },
              child: Row(children: [
                Text('L\u00f6schen',
                    style: TextStyle(
                        fontSize: 11, color: HevjinTheme.textSecondary)),
                const SizedBox(width: 4),
                Icon(Icons.delete_outline,
                    size: 15, color: HevjinTheme.textSecondary),
              ]),
            ),
            const SizedBox(width: 14),
            InkWell(
              onTap: () =>
                  _showPromptSheet(context, profile, editIndex: index),
              child: Row(children: [
                Text('Bearbeiten',
                    style: TextStyle(
                        fontSize: 11, color: HevjinTheme.textSecondary)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios,
                    size: 12, color: HevjinTheme.textSecondary),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _LifestyleSection({required UserProfile profile}) {
    return _LifestyleSectionWidget(profile: profile);
  }

  void _showPromptSheet(BuildContext context, UserProfile profile,
      {int? editIndex}) {
    final prompts = [
      'Drei Dinge, die mir wichtig sind:',
      'Mein perfekter Sonntag:',
      'Das macht mich gl\u00fccklich:',
      'In 5 Jahren sehe ich mich:',
      'Das sch\u00e4tze ich an einem Partner:',
      'Das solltest du \u00fcber mich wissen:',
      'Mein lustigstes Erlebnis:',
      'Das kann ich besonders gut:',
    ];
    final existing = profile.promptAnswers
        .map((e) => {'q': e['q'] ?? '', 'a': e['a'] ?? ''})
        .toList();
    final ei = editIndex ?? -1;
    final isEdit = ei >= 0 && ei < existing.length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String? selectedPrompt = isEdit ? existing[ei]['q'] : null;
        final answerController =
            TextEditingController(text: isEdit ? existing[ei]['a'] : '');
        final available = prompts
            .where((p) => !existing.any((e) => e['q'] == p))
            .toList();

        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text(isEdit ? 'Antwort bearbeiten' : 'Profilfrage beantworten',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (selectedPrompt == null) ...[
                  Text('W\u00e4hle eine Frage:',
                      style: TextStyle(
                          fontSize: 13, color: HevjinTheme.textSecondary)),
                  const SizedBox(height: 12),
                  if (available.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('Du hast schon alle Fragen beantwortet.',
                          style: TextStyle(
                              fontSize: 13, color: HevjinTheme.textSecondary)),
                    ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: available
                            .map((p) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(p,
                                      style: const TextStyle(fontSize: 14)),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      size: 14),
                                  onTap: () =>
                                      setSheetState(() => selectedPrompt = p),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(selectedPrompt!,
                      style: TextStyle(
                          fontSize: 14, color: HevjinTheme.textSecondary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: answerController,
                    maxLines: 3,
                    maxLength: 200,
                    autofocus: true,
                    decoration:
                        const InputDecoration(hintText: 'Deine Antwort...'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final text = answerController.text.trim();
                        if (text.isEmpty) return;
                        final entry = {'q': selectedPrompt!, 'a': text};
                        if (isEdit) {
                          existing[ei] = entry;
                        } else {
                          final at = existing
                              .indexWhere((e) => e['q'] == selectedPrompt);
                          if (at >= 0) {
                            existing[at] = entry;
                          } else {
                            existing.add(entry);
                          }
                        }
                        final userId =
                            Supabase.instance.client.auth.currentUser!.id;
                        await Supabase.instance.client
                            .from('profiles')
                            .update({'prompt_answers': existing})
                            .eq('id', userId);
                        if (ctx.mounted) {
                          ctx.read<ProfileService>().fetchProfile();
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Speichern'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chipWithIcon(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HevjinTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _addChip(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HevjinTheme.secondary.withOpacity(0.4)),
          color: HevjinTheme.secondary.withOpacity(0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle, size: 16, color: HevjinTheme.secondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: HevjinTheme.secondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _steckbriefRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: HevjinTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 0.8)),
                  const SizedBox(height: 1),
                  Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (onTap != null) Icon(Icons.arrow_forward_ios, size: 14, color: HevjinTheme.textSecondary.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosContent(UserProfile profile) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (profile.photos.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 48, color: HevjinTheme.textSecondary.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    const Text('Noch keine Fotos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhotoUploadScreen())),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Fotos hinzufügen'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
                ),
                itemCount: profile.photos.length + 1,
                itemBuilder: (context, index) {
                  if (index == profile.photos.length) {
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhotoUploadScreen())),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add, size: 32, color: HevjinTheme.textSecondary),
                      ),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(profile.photos[index], fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF5F5F5), child: const Icon(Icons.broken_image))),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _settingsItem(Icons.lock_outline, 'Privatsph\u00e4re', 'Fotos: ${profile.photosPrivate ? "Privat" : "\u00d6ffentlich"}', onTap: () async {
            final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
              title: const Text('Privatsph\u00e4re \u00e4ndern'),
              content: Text('Fotos auf "${profile.photosPrivate ? "\u00d6ffentlich" : "Privat"}" setzen?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ja')),
              ],
            ));
            if (confirm == true) {
              final newVal = !profile.photosPrivate;
              await Supabase.instance.client.from('profiles').update({'photos_private': newVal}).eq('id', profile.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fotos jetzt ${newVal ? "privat" : "\u00d6ffentlich"}'), backgroundColor: HevjinTheme.success));
                setState(() {});
              }
            }
          }),
          _settingsItem(Icons.notifications_outlined, 'Benachrichtigungen', 'Aktiviert', onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Push-Benachrichtigungen kommen bald!')));
          }),
          _settingsItem(Icons.shield_outlined, 'Verifizierung', 'SMS verifiziert', onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dein Account ist verifiziert!'), backgroundColor: Color(0xFF4CAF50), duration: Duration(seconds: 2)));
          }),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: HevjinTheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.help_outline, color: HevjinTheme.secondary),
            ),
            title: const Text('Hilfe & Support', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Probleme melden, Fragen stellen', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: HevjinTheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.description_outlined, color: HevjinTheme.secondary),
            ),
            title: const Text('Rechtliches', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Datenschutz, AGB, Impressum', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    const Text('Rechtliches', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined, color: HevjinTheme.secondary),
                      title: const Text('Datenschutzerkl\u00e4rung'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.gavel_outlined, color: HevjinTheme.secondary),
                      title: const Text('Nutzungsbedingungen (AGB)'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: HevjinTheme.secondary),
                      title: const Text('Impressum'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ImprintScreen()));
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (const bool.fromEnvironment('MATCH_PREVIEW'))
            _settingsItem(Icons.favorite, 'Match-Screen testen', 'Nur im Debug-Modus', onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const MatchScreen(
                  matchId: 'debug',
                  otherUserId: 'debug-user',
                  otherName: 'Z\u00een',
                  otherAvatar: 'https://i.pravatar.cc/300?img=45',
                  myAvatar: 'https://i.pravatar.cc/300?img=12',
                  preview: true,
                ),
              ));
            }),
          _settingsItem(Icons.email_outlined, 'E-Mail', Supabase.instance.client.auth.currentUser?.email ?? '-'),
          const SizedBox(height: 8),
          _settingsItem(Icons.logout, 'Abmelden', 'Ausloggen', onTap: () async {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (route) => false,
              );
            }
          }),
          _settingsItem(Icons.delete_outline, 'Account l\u00f6schen', 'Unwiderruflich', isDestructive: true, onTap: () {
            // Step 1: Info dialog
            showDialog(context: context, builder: (ctx) => AlertDialog(
              title: const Text('Account l\u00f6schen'),
              content: const Text('Wenn du deinen Account l\u00f6schst:\n\n\u2022 Alle deine Daten, Matches und Nachrichten werden entfernt\n\u2022 Du hast 14 Tage Zeit dich an den Support zu wenden um deinen Account zu reaktivieren\n\u2022 Nach 14 Tagen werden alle Daten unwiderruflich gel\u00f6scht\n\nSupport: hevjinsupport@gmail.com'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Step 2: Final confirmation
                    showDialog(context: context, builder: (ctx2) => AlertDialog(
                      title: const Text('Bist du sicher?'),
                      content: const Text('Dein Account wird jetzt gel\u00f6scht. Dieser Vorgang kann nicht sofort r\u00fcckg\u00e4ngig gemacht werden.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Abbrechen')),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx2);
                            try {
                              // Soft-delete: mark as deleted (can be reactivated within 14 days)
                              final uid = Supabase.instance.client.auth.currentUser?.id;
                              if (uid != null) {
                                await Supabase.instance.client.from('profiles').update({
                                  'deleted_at': DateTime.now().toUtc().toIso8601String(),
                                }).eq('id', uid);
                              }
                              // Sign out
                              await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
                            } catch (e) {
                              try {
                                await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
                              } catch (_) {}
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('\u2705 Account gel\u00f6scht. Innerhalb von 14 Tagen kannst du dich an hevjinsupport@gmail.com wenden.'),
                                  duration: Duration(seconds: 5),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const SplashScreen()),
                                (route) => false,
                              );
                            }
                          },
                          child: const Text('Endg\u00fcltig l\u00f6schen', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ));
                  },
                  child: const Text('Ich habe verstanden', style: TextStyle(color: Colors.red)),
                ),
              ],
            ));
          }),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, String label, bool isVerified, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: isVerified ? HevjinTheme.success : Colors.grey.shade300),
            ),
            child: Icon(icon, size: 20, color: isVerified ? HevjinTheme.success : HevjinTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: HevjinTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: HevjinTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _settingsItem(IconData icon, String title, String subtitle, {bool isDestructive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDestructive ? HevjinTheme.error : HevjinTheme.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                    color: isDestructive ? HevjinTheme.error : HevjinTheme.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: HevjinTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: HevjinTheme.textSecondary.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

// Helper for pinned TabBar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: HevjinTheme.background,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

// ===== INLINE CHIPS - Click to toggle, saves immediately =====
class _InlineChips extends StatefulWidget {
  final String title;
  final String field;
  final List<String> selected;
  final List<String> options;

  const _InlineChips({
    required this.title,
    required this.field,
    required this.selected,
    required this.options,
  });

  @override
  State<_InlineChips> createState() => _InlineChipsState();
}

class _InlineChipsState extends State<_InlineChips> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  void didUpdateWidget(covariant _InlineChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _selected = List.from(widget.selected);
    }
  }

  Future<void> _toggle(String item) async {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });

    // Sofort speichern
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await Supabase.instance.client.from('profiles').update({widget.field: _selected}).eq('id', userId);
      if (mounted) {
        Future.microtask(() {
          if (mounted) context.read<ProfileService>().fetchProfile();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.options.map((item) {
              final isSelected = chipSelected(_selected, item);
              return GestureDetector(
                onTap: () => _toggle(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected ? HevjinTheme.secondary.withOpacity(0.12) : Colors.white,
                    border: Border.all(
                      color: isSelected ? HevjinTheme.secondary : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text('${chipEmoji(item)}  $item', style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? HevjinTheme.secondary : HevjinTheme.textSecondary,
                  )),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ===== LIFESTYLE SECTION - Separate Photo Upload =====
class _LifestyleSectionWidget extends StatefulWidget {
  final UserProfile profile;
  const _LifestyleSectionWidget({required this.profile});

  @override
  State<_LifestyleSectionWidget> createState() => _LifestyleSectionState();
}

class _LifestyleSectionState extends State<_LifestyleSectionWidget> {
  List<String> _lifestylePhotos = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final data = await Supabase.instance.client
        .from('profiles')
        .select('lifestyle_photos')
        .eq('id', userId)
        .maybeSingle();

    if (data != null && data['lifestyle_photos'] != null) {
      setState(() => _lifestylePhotos = List<String>.from(data['lifestyle_photos']));
    }
  }

  Future<void> _uploadPhoto() async {
    if (_lifestylePhotos.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximal 6 Lifestyle-Fotos')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final fileBytes = await pickedFile.readAsBytes();
      final fileName = 'lifestyle_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';

      await Supabase.instance.client.storage
          .from('profile-photos')
          .uploadBinary(filePath, fileBytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));

      final url = Supabase.instance.client.storage
          .from('profile-photos')
          .getPublicUrl(filePath);

      _lifestylePhotos.add(url);

      await Supabase.instance.client.from('profiles').update({
        'lifestyle_photos': _lifestylePhotos,
      }).eq('id', userId);

      setState(() => _isUploading = false);
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload fehlgeschlagen: $e')),
        );
      }
    }
  }

  Future<void> _removePhoto(int index) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    setState(() => _lifestylePhotos.removeAt(index));
    await Supabase.instance.client.from('profiles').update({
      'lifestyle_photos': _lifestylePhotos,
    }).eq('id', userId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LIFESTYLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          const Text('WAS ICH BESONDERS MAG', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _lifestylePhotos.length + 1,
              itemBuilder: (ctx, i) {
                // Letzter = Add Button
                if (i == _lifestylePhotos.length) {
                  return GestureDetector(
                    onTap: _isUploading ? null : _uploadPhoto,
                    child: Container(
                      width: 120, height: 140,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: _isUploading
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: HevjinTheme.secondary.withOpacity(0.6), size: 28),
                                const SizedBox(height: 6),
                                Text('Foto\nhinzufügen', textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10, color: HevjinTheme.textSecondary)),
                              ],
                            ),
                    ),
                  );
                }
                // Vorhandenes Lifestyle-Foto
                return Stack(
                  children: [
                    Container(
                      width: 120, height: 140,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(_lifestylePhotos[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4, right: 14,
                      child: GestureDetector(
                        onTap: () => _removePhoto(i),
                        child: Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===== ANIMATED LIKE BUTTON (3D with visible press) =====
class _AnimatedLikeButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedLikeButton({required this.onTap});
  @override
  State<_AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<_AnimatedLikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) async {
        await Future.delayed(const Duration(milliseconds: 80));
        _controller.reverse();
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed
                      ? [const Color(0xFF8B6014), const Color(0xFF6B4A0F)]
                      : [const Color(0xFFEEB840), const Color(0xFFE02020), const Color(0xFFB87A1F)],
                ),
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: HevjinTheme.secondary.withOpacity(0.5),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                          spreadRadius: 2,
                        ),
                      ],
              ),
              child: Icon(
                Icons.favorite,
                color: _isPressed ? Colors.white70 : Colors.white,
                size: _isPressed ? 26 : 30,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===== ANIMATED DISLIKE BUTTON (broken heart on press) =====
class _AnimatedDislikeButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedDislikeButton({required this.onTap});
  @override
  State<_AnimatedDislikeButton> createState() => _AnimatedDislikeButtonState();
}

class _AnimatedDislikeButtonState extends State<_AnimatedDislikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _showBrokenHeart = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        setState(() { _isPressed = true; _showBrokenHeart = true; });
      },
      onTapUp: (_) async {
        await Future.delayed(const Duration(milliseconds: 150));
        _controller.reverse();
        setState(() { _isPressed = false; });
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() => _showBrokenHeart = false);
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() { _isPressed = false; _showBrokenHeart = false; });
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isPressed ? const Color(0xFFFFEBEE) : Colors.white,
                border: Border.all(
                  color: _isPressed ? const Color(0xFFE53935) : Colors.grey.shade300,
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: _isPressed
                    ? []
                    : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Center(
                child: _showBrokenHeart
                    ? const Text('\ud83d\udc94', style: TextStyle(fontSize: 24))
                    : Icon(Icons.close, color: _isPressed ? const Color(0xFFE53935) : Colors.grey.shade600, size: 26),
              ),
            ),
          );
        },
      ),
    );
  }
}
