import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/theme.dart';
import 'package:provider/provider.dart';
import '../../services/profile_service.dart';
import '../home/home_screen.dart';

/// Letzter Onboarding-Schritt: Profilbild hochladen (optional).
/// Wird nach dem 7-Schritte-Wizard angezeigt. Der Nutzer kann
/// jederzeit ueberspringen und landet dann direkt im Discover.
class OnboardingPhotoScreen extends StatefulWidget {
  const OnboardingPhotoScreen({super.key});

  @override
  State<OnboardingPhotoScreen> createState() => _OnboardingPhotoScreenState();
}

class _OnboardingPhotoScreenState extends State<OnboardingPhotoScreen> {
  final _supabase = Supabase.instance.client;
  String? _photoUrl;
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    if (_isUploading) return;

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

      await _supabase.from('profiles').update({
        'photos': [url],
        'avatar_url': url,
      }).eq('id', userId);

      if (!mounted) return;
      setState(() {
        _photoUrl = url;
        _isUploading = false;
      });
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
    // Provider-Cache neu laden, damit Avatar/Fotos sofort sichtbar sind
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
    final hasPhoto = _photoUrl != null;

    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Schritt 8 / 8'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _goToDiscover,
            child: const Text(
              '\u00dcberspringen',
              style: TextStyle(color: HevjinTheme.textSecondary),
            ),
          ),
        ],
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
                'Dein Profilbild',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: HevjinTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Profile mit Foto werden deutlich h\u00e4ufiger '
                'angeschrieben. Du kannst das aber auch sp\u00e4ter machen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: HevjinTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUpload,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HevjinTheme.cardBg,
                    border: Border.all(
                      color: hasPhoto
                          ? HevjinTheme.secondary
                          : Colors.grey.shade300,
                      width: hasPhoto ? 3 : 2,
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
                                _photoUrl!,
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
              if (hasPhoto)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextButton.icon(
                    onPressed: _isUploading ? null : _pickAndUpload,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Anderes Foto w\u00e4hlen'),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : (hasPhoto ? _goToDiscover : _pickAndUpload),
                  child: Text(
                    hasPhoto ? 'Los geht\'s' : 'Foto hochladen',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (!hasPhoto)
                TextButton(
                  onPressed: _isUploading ? null : _goToDiscover,
                  child: const Text(
                    'Sp\u00e4ter erledigen',
                    style: TextStyle(color: HevjinTheme.textSecondary),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}
