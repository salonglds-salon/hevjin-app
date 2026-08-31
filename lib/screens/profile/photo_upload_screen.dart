import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/theme.dart';

class PhotoUploadScreen extends StatefulWidget {
  final bool isOnboarding;
  const PhotoUploadScreen({super.key, this.isOnboarding = false});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final _supabase = Supabase.instance.client;
  List<String> _photoUrls = [];
  bool _isUploading = false;
  final int _maxPhotos = 6;

  @override
  void initState() {
    super.initState();
    _loadExistingPhotos();
  }

  Future<void> _loadExistingPhotos() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final data = await _supabase
        .from('profiles')
        .select('photos, avatar_url')
        .eq('id', userId)
        .maybeSingle();

    if (data != null && data['photos'] != null) {
      setState(() {
        _photoUrls = List<String>.from(data['photos']);
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_photoUrls.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximal 6 Fotos erlaubt')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileBytes = await pickedFile.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';

      await _supabase.storage
          .from('profile-photos')
          .uploadBinary(filePath, fileBytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));

      final url = _supabase.storage
          .from('profile-photos')
          .getPublicUrl(filePath);

      final wasBelowMin = _photoUrls.length < 2;
      _photoUrls.add(url);
      await _savePhotos();

      setState(() => _isUploading = false);

      // Minimum (2 Fotos) gerade erreicht -> direkt zurueck zum HomeScreen,
      // damit das Gate verschwindet und die Willkommensnachricht erscheint.
      if (!widget.isOnboarding &&
          wasBelowMin &&
          _photoUrls.length >= 2 &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil freigeschaltet'),
            backgroundColor: Color(0xFF28A745),
            duration: Duration(milliseconds: 900),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 650));
        if (mounted) Navigator.of(context).pop(true);
      }
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
    setState(() {
      _photoUrls.removeAt(index);
    });
    await _savePhotos();
  }

  Future<void> _savePhotos() async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('profiles').update({
      'photos': _photoUrls,
      'avatar_url': _photoUrls.isNotEmpty ? _photoUrls.first : null,
    }).eq('id', userId);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _photoUrls.removeAt(oldIndex);
      _photoUrls.insert(newIndex, item);
    });
    _savePhotos();

    // Feedback wenn Profilbild sich ändert
    if (newIndex == 0 || oldIndex == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profilbild aktualisiert ✓'),
          backgroundColor: Color(0xFF28A745),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(
        title: const Text('Fotos'),
        actions: [
          if (widget.isOnboarding)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fertig'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fotos sortieren',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Halte gedrückt und verschiebe — erstes Foto = Profilbild',
              style: TextStyle(fontSize: 13, color: HevjinTheme.textSecondary),
            ),
            const SizedBox(height: 20),

            // Reorderable Photo Grid
            Expanded(
              child: _photoUrls.isEmpty && !_isUploading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 64, color: HevjinTheme.textSecondary),
                          const SizedBox(height: 16),
                          const Text('Noch keine Fotos'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _pickAndUploadPhoto,
                            icon: const Icon(Icons.add),
                            label: const Text('Foto hinzufügen'),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: _photoUrls.length,
                      onReorder: _onReorder,
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: child,
                        );
                      },
                      itemBuilder: (context, index) {
                        return ReorderableDragStartListener(
                          key: ValueKey(_photoUrls[index]),
                          index: index,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: index == 0
                                  ? Border.all(color: HevjinTheme.secondary, width: 2)
                                  : Border.all(color: Colors.grey.shade200),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                // Foto
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                                  child: Image.network(
                                    _photoUrls[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 100,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Info
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (index == 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: HevjinTheme.secondary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            '⭐ Profilbild',
                                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        )
                                      else
                                        Text(
                                          'Foto ${index + 1}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        index == 0 ? 'Wird beim Swipen angezeigt' : 'Zum Verschieben gedrückt halten',
                                        style: TextStyle(fontSize: 11, color: HevjinTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),

                                // Drag handle + Delete
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.drag_handle, color: HevjinTheme.textSecondary),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _removePhoto(index),
                                      child: const Icon(Icons.delete_outline, color: Color(0xFFDC3545), size: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Add Photo Button (unten)
            if (_photoUrls.isNotEmpty && _photoUrls.length < _maxPhotos)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isUploading ? null : _pickAndUploadPhoto,
                    icon: _isUploading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add_a_photo),
                    label: Text(_isUploading ? 'Wird hochgeladen...' : 'Foto hinzufügen (${_photoUrls.length}/$_maxPhotos)'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
