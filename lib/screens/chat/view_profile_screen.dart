import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart';
import '../../utils/theme.dart';
import '../../widgets/report_sheet.dart';

class ViewProfileScreen extends StatefulWidget {
  final String userId;

  const ViewProfileScreen({super.key, required this.userId});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', widget.userId)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _profile = UserProfile.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: HevjinTheme.background,
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator(color: HevjinTheme.secondary)),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: HevjinTheme.background,
        appBar: AppBar(),
        body: const Center(child: Text('Profil nicht gefunden')),
      );
    }

    final profile = _profile!;

    return Scaffold(
      backgroundColor: HevjinTheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar mit Foto
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: HevjinTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => showReportSheet(context, userId: profile.id, userName: profile.displayName),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () {
                  if (profile.photos.isNotEmpty) {
                    _showPhotoViewer(context, profile.photos, 0);
                  }
                },
                child: profile.avatarUrl != null
                    ? Image.network(profile.avatarUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Alter + Kaste
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${profile.displayName}, ${profile.age}',
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                            if (profile.city != null) ...[
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.location_on, size: 14, color: HevjinTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text(profile.city!, style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 14)),
                              ]),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: HevjinTheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(profile.casteDisplay,
                            style: const TextStyle(color: HevjinTheme.secondary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Steckbrief - ALLE Felder
                  _sectionCard('STECKBRIEF', [
                    _infoRow(Icons.stars_outlined, 'Kaste', profile.casteDisplay),
                    if (profile.tribe != null) _infoRow(Icons.groups_outlined, 'Stamm', profile.tribe!),
                    _infoRow(Icons.favorite_outline, 'Sucht', profile.lookingForDisplay),
                    if (profile.city != null) _infoRow(Icons.location_on_outlined, 'Wohnort', profile.city!),
                    if (profile.height != null) _infoRow(Icons.straighten, 'Gr\u00f6\u00dfe', '${profile.height} cm'),
                    if (profile.education != null) _infoRow(Icons.school_outlined, 'Bildung', profile.educationDisplay),
                    if (profile.job != null) _infoRow(Icons.work_outline, 'Beruf', profile.job!),
                    if (profile.familyStatus != null) _infoRow(Icons.people_outline, 'Familienstand', profile.familyStatusDisplay),
                    if (profile.hasChildren != null) _infoRow(Icons.child_care, 'Kinder', profile.hasChildren! ? 'Ja' : 'Keine Kinder'),
                    if (profile.childWish != null) _infoRow(Icons.child_friendly, 'Kinderwunsch', profile.childWish == 'ja' ? 'Ja' : profile.childWish == 'nein' ? 'Nein' : 'Vielleicht'),
                  ]),
                  const SizedBox(height: 12),

                  // Bio
                  if (profile.bio != null)
                    _sectionCard('UEBER MICH', [
                      Text(profile.bio!, style: const TextStyle(fontSize: 15, height: 1.6, fontStyle: FontStyle.italic)),
                    ]),
                  if (profile.bio != null) const SizedBox(height: 12),

                  // Interessen
                  if (profile.interests.isNotEmpty)
                    _sectionCard('INTERESSEN', [
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: profile.interests.map((i) => _chip(i)).toList(),
                      ),
                    ]),
                  if (profile.interests.isNotEmpty) const SizedBox(height: 12),

                  // Tags
                  if (profile.tags.isNotEmpty)
                    _sectionCard('CHARAKTER & EIGENSCHAFTEN', [
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: profile.tags.map((t) => _chip(t)).toList(),
                      ),
                    ]),
                  if (profile.tags.isNotEmpty) const SizedBox(height: 12),

                  // Lifestyle Fotos (extra laden)
                  FutureBuilder(
                    future: _loadLifestylePhotos(),
                    builder: (ctx, snapshot) {
                      if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
                        final lifestylePhotos = snapshot.data as List<String>;
                        return Column(
                          children: [
                            _sectionCard('WAS ICH BESONDERS MAG', [
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: lifestylePhotos.length,
                                  itemBuilder: (ctx, i) => GestureDetector(
                                    onTap: () => _showPhotoViewer(context, lifestylePhotos, i),
                                    child: Container(
                                      width: 100, height: 120,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(image: NetworkImage(lifestylePhotos[i]), fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 12),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),

                  // Fotos
                  if (profile.photos.isNotEmpty)
                    _sectionCard('FOTOS', [
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: profile.photos.length,
                          itemBuilder: (ctx, i) => GestureDetector(
                            onTap: () => _showPhotoViewer(context, profile.photos, i),
                            child: Container(
                              width: 120, height: 150,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(profile.photos[i]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _loadLifestylePhotos() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('lifestyle_photos')
          .eq('id', widget.userId)
          .maybeSingle();
      if (data != null && data['lifestyle_photos'] != null) {
        return List<String>.from(data['lifestyle_photos']);
      }
    } catch (_) {}
    return [];
  }

  void _showPhotoViewer(BuildContext context, List<String> photos, int startIndex) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _PhotoViewerScreen(photos: photos, initialIndex: startIndex),
    ));
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(child: Icon(Icons.person, size: 80, color: HevjinTheme.textSecondary.withOpacity(0.3))),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
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
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HevjinTheme.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: HevjinTheme.secondary),
          const SizedBox(width: 10),
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: HevjinTheme.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HevjinTheme.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}

// ===== PHOTO VIEWER - Vollbild =====
class _PhotoViewerScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _PhotoViewerScreen({required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.photos.length}', style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Photos
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (ctx, i) => InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  widget.photos[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 60),
                ),
              ),
            ),
          ),
          // Linker Pfeil
          if (_currentIndex > 0)
            Positioned(
              left: 12,
              top: 0, bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          // Rechter Pfeil
          if (_currentIndex < widget.photos.length - 1)
            Positioned(
              right: 12,
              top: 0, bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

