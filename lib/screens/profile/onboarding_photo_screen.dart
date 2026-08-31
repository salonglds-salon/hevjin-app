import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/theme.dart';
import 'package:provider/provider.dart';
import '../../services/profile_service.dart';
import '../home/home_screen.dart';

/// Mindestanzahl Fotos, die vor dem Discover-Zugang benoetigt werden.
const int kMinPhotos = 2;

/// Letzter Onboarding-Schritt: Profilfotos hochladen (PFLICHT).
/// Kein Ueberspringen mehr moeglich (Anti-Fake-Massnahme, Release 108).
class OnboardingPhotoScreen extends StatefulWidget {
  const OnboardingPhotoScreen({super.key});

  @override
  State<OnboardingPhotoScreen> createState() => _OnboardingPhotoScreenState();
}

class _OnboardingPhotoScreenState extends State<OnboardingPhotoScreen> {
  final _supabase = Supabase.instance.client;
  final List<String> _photos = [];
  bool _isUploading = false;

  bool get _isComplete => _photos.length >= kMinPhotos;

  Future<void> _pickAndUpload() async {
    if (_isUploading) return;
    if (_photos.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximal 6 Fotos erlaubt')),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      final bytes = await picked.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';

      await _supabase.storage.from('profile-photos').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final url =
          _supabase.storage.from('profile-photos').getPublicUrl(filePath);

      _photos.add(url);

      await _supabase.from('profiles').update({
        'photos': _photos,
        'avatar_url': _photos.first,
      }).eq('id', userId);

      if (!mounted) return;
      setState(() => _isUploading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload fehlgeschlagen: $e'),
          backgroundColor: HevjinTheme.error,
        ),
      );
    }
  }

  Future<void> _goToDiscover() async {
    if (!_isComplete) return;
    await context.read<ProfileService>().fetchProfile();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _photos.isNotEmpty;

    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Schritt 8 / 8'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 1.0,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          const AlwaysStoppedAnimation(HevjinTheme.secondary),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Deine Fotos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: HevjinTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Hevj\u00een lebt von echten Profilen. Bitte lade '
                    'mindestens zwei Fotos hoch \u2014 so wissen andere, '
                    'mit wem sie es zu tun haben.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: HevjinTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _isUploading ? null : _pickAndUpload,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HevjinTheme.cardBg,
                        border: Border.all(
                          color: _isComplete
                              ? HevjinTheme.secondary
                              : (hasPhoto
                                  ? HevjinTheme.secondary.withOpacity(0.6)
                                  : Colors.grey.shade300),
                          width: _isComplete ? 3 : 2,
                        ),
                      ),
                      child: _isUploading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: HevjinTheme.secondary,
                              ),
                            )
                          : hasPhoto
                              ? ClipOval(
                                  child: Image.network(
                                    _photos.last,
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: HevjinTheme.textSecondary,
                                    ),
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 48,
                                      color: HevjinTheme.secondary,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Foto ausw\u00e4hlen',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: HevjinTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_photos.length} von $kMinPhotos Fotos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isComplete
                          ? HevjinTheme.secondary
                          : HevjinTheme.textSecondary,
                    ),
                  ),
                  if (hasPhoto)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: TextButton.icon(
                        onPressed: _isUploading ? null : _pickAndUpload,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(_isComplete
                            ? 'Weiteres Foto hinzuf\u00fcgen'
                            : 'Zweites Foto hinzuf\u00fcgen'),
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isUploading
                          ? null
                          : (_isComplete ? _goToDiscover : _pickAndUpload),
                      child: Text(
                        _isComplete ? 'Los geht\'s' : 'Foto hochladen',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
