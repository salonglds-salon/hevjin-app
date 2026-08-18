import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';
import '../../utils/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _tribeController = TextEditingController();
  final _jobController = TextEditingController();
  final _moviesController = TextEditingController();
  final _musicController = TextEditingController();
  final _booksController = TextEditingController();
  final _languagesController = TextEditingController();
  final _petsController = TextEditingController();

  String _caste = 'murid';
  String _lookingFor = 'heirat';
  String? _education;
  String? _jobStatus;
  String? _familyStatus;
  String? _childWish;
  String? _smoking;
  String? _sportFrequency;
  bool? _hasChildren;
  int _height = 175;
  bool _isSaving = false;

  // Tags & Interests & Sport & Travel
  List<String> _selectedTags = [];
  List<String> _selectedInterests = [];
  List<String> _selectedSports = [];
  List<String> _selectedTravel = [];

  final List<String> _availableTags = [
    'Humorvoll', 'Romantisch', 'Sportlich', 'Familiär',
    'Zuverlässig', 'Ehrgeizig', 'Herzlich', 'Weltoffen',
    'Traditionell', 'Spontan', 'Kreativ', 'Spirituell',
    'Fürsorglich', 'Liebevoll', 'Gelassen', 'Schüchtern',
    'Zielstrebig', 'Abenteuerlustig', 'Empathisch', 'Loyal',
  ];

  final List<String> _availableInterests = [
    'Sport & Fitness', 'Zeit mit Familie', 'Kochen & Essen', 'Reisen',
    'Lesen & Lernen', 'Gaming & Filme', 'Musik & Tanzen', 'Natur & Spazieren',
    'Café & Freunde', 'Fotografie', 'Autos & Technik', 'Kunst & Design',
  ];

  final List<String> _availableSports = [
    'Fitness', 'Fußball', 'Schwimmen', 'Joggen', 'Yoga', 'Boxen',
    'Basketball', 'Tennis', 'Kampfsport', 'Tanzen', 'Radfahren', 'Wandern',
  ];

  final List<String> _availableTravel = [
    'Strandurlaub', 'Städtereisen', 'Aktivurlaub', 'Camping & Natur',
    'Wellness', 'Backpacking', 'Familienurlaub', 'Kreuzfahrt',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profile = context.read<ProfileService>().currentProfile;
    if (profile != null) {
      _nameController.text = profile.displayName;
      _bioController.text = profile.bio ?? '';
      _cityController.text = profile.city ?? '';
      _tribeController.text = profile.tribe ?? '';
      _jobController.text = profile.job ?? '';
      // Nur gueltige Werte uebernehmen - NULL/Altdaten wuerden sonst den
      // CHECK-Constraint (profiles_caste_check) beim Speichern verletzen.
      _caste = const ['scheich', 'pir', 'murid'].contains(profile.caste)
          ? profile.caste
          : 'murid';
      _lookingFor =
          const ['heirat', 'dating', 'freundschaft'].contains(profile.lookingFor)
              ? profile.lookingFor
              : 'heirat';
      _education = profile.education;
      _jobStatus = profile.jobStatus;
      _familyStatus = profile.familyStatus;
      _childWish = profile.childWish;
      _hasChildren = profile.hasChildren;
      _height = profile.height ?? 175;
      // Limit auch beim Laden durchsetzen (Altdaten koennen mehr enthalten)
      _selectedTags = List<String>.from(profile.tags).take(5).toList();
      _selectedInterests = List<String>.from(profile.interests).take(5).toList();
      _selectedSports = List<String>.from(profile.sports).take(5).toList();
      _selectedTravel = List<String>.from(profile.travel).take(5).toList();
    }
  }

  @override
  void dispose() {
    _chipSaveTimer?.cancel();
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _tribeController.dispose();
    _jobController.dispose();
    _moviesController.dispose();
    _musicController.dispose();
    _booksController.dispose();
    _languagesController.dispose();
    _petsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(
        title: const Text('Profil bearbeiten'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: Text('Speichern', style: TextStyle(color: HevjinTheme.secondary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === GRUNDDATEN ===
            _sectionHeader('GRUNDDATEN'),
            _textField(_nameController, 'Vorname', Icons.person_outline),
            const SizedBox(height: 14),
            _dropdown('Geschlecht', null, [
              const MapEntry('male', 'Männlich'),
              const MapEntry('female', 'Weiblich'),
            ]),
            const SizedBox(height: 14),
            _textField(_cityController, 'Stadt', Icons.location_city),
            const SizedBox(height: 28),

            // === ÊZÎDISCHE IDENTITÄT ===
            _sectionHeader('ÊZÎDISCHE IDENTITÄT'),
            _label('Kaste'),
            Row(
              children: [
                _casteChip('scheich', '☀️ Scheich'),
                const SizedBox(width: 8),
                _casteChip('pir', '🌙 Pir'),
                const SizedBox(width: 8),
                _casteChip('murid', '⭐ Murid'),
              ],
            ),
            const SizedBox(height: 14),
            _textField(_tribeController, 'Stamm / Ashiret', Icons.groups_outlined),
            const SizedBox(height: 14),
            _label('Ich suche'),
            Row(
              children: [
                _lookingChip('heirat', '💍 Heirat'),
                const SizedBox(width: 8),
                _lookingChip('dating', '❤️ Dating'),
                const SizedBox(width: 8),
                _lookingChip('freundschaft', '🤝 Freunde'),
              ],
            ),
            const SizedBox(height: 28),

            // === ÜBER MICH ===
            _sectionHeader('ÜBER MICH'),
            TextField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(hintText: 'Erzähl etwas über dich...'),
            ),
            const SizedBox(height: 28),

            // === KÖRPER & LEBENSSTIL ===
            _sectionHeader('KÖRPER & LEBENSSTIL'),
            _label('Körpergröße: $_height cm'),
            Slider(
              value: _height.toDouble(),
              min: 140, max: 220, divisions: 80,
              activeColor: HevjinTheme.secondary,
              label: '$_height cm',
              onChanged: (v) => setState(() => _height = v.round()),
            ),
            const SizedBox(height: 14),
            _dropdownField('Rauchverhalten', _smoking, [
              const MapEntry('nie', 'Nichtraucher'),
              const MapEntry('gelegentlich', 'Gelegentlich'),
              const MapEntry('regelmaessig', 'Regelmäßig'),
            ], (v) => setState(() => _smoking = v)),
            const SizedBox(height: 14),
            _dropdownField('Sport', _sportFrequency, [
              const MapEntry('taeglich', 'Täglich'),
              const MapEntry('mehrmals_woche', 'Mehrmals/Woche'),
              const MapEntry('mehrmals_monat', 'Mehrmals/Monat'),
              const MapEntry('selten', 'Selten'),
              const MapEntry('nie', 'Gar nicht'),
            ], (v) => setState(() => _sportFrequency = v)),
            const SizedBox(height: 14),
            _textField(_languagesController, 'Sprachen', Icons.translate),
            const SizedBox(height: 14),
            _textField(_petsController, 'Haustiere', Icons.pets),
            const SizedBox(height: 28),

            // === BERUF & BILDUNG ===
            _sectionHeader('BERUF & BILDUNG'),
            _textField(_jobController, 'Beruf', Icons.work_outline),
            const SizedBox(height: 14),
            _dropdownField('Status', _jobStatus, [
              const MapEntry('angestellt', 'Angestellt'),
              const MapEntry('selbstaendig', 'Selbständig'),
              const MapEntry('student', 'Student/in'),
              const MapEntry('ausbildung', 'In Ausbildung'),
              const MapEntry('arbeitssuchend', 'Arbeitssuchend'),
            ], (v) => setState(() => _jobStatus = v)),
            const SizedBox(height: 14),
            _dropdownField('Bildungsabschluss', _education, [
              const MapEntry('hauptschule', 'Hauptschule'),
              const MapEntry('realschule', 'Realschule / Ausbildung'),
              const MapEntry('abitur', 'Abitur / Fachabitur'),
              const MapEntry('studium', 'Noch im Studium'),
              const MapEntry('bachelor', 'Bachelor'),
              const MapEntry('master', 'Master / Promotion'),
            ], (v) => setState(() => _education = v)),
            const SizedBox(height: 28),

            // === FAMILIE ===
            _sectionHeader('FAMILIE'),
            _dropdownField('Familienstand', _familyStatus, [
              const MapEntry('ledig', 'Ledig'),
              const MapEntry('geschieden', 'Geschieden'),
              const MapEntry('getrennt', 'Getrennt lebend'),
              const MapEntry('verwitwet', 'Verwitwet'),
            ], (v) => setState(() => _familyStatus = v)),
            const SizedBox(height: 14),
            _label('Hast du Kinder?'),
            Row(
              children: [
                _boolChip(true, 'Ja', _hasChildren == true),
                const SizedBox(width: 8),
                _boolChip(false, 'Nein', _hasChildren == false),
              ],
            ),
            const SizedBox(height: 14),
            _dropdownField('Kinderwunsch', _childWish, [
              const MapEntry('ja', 'Ja'),
              const MapEntry('vielleicht', 'Vielleicht'),
              const MapEntry('nein', 'Nein'),
            ], (v) => setState(() => _childWish = v)),
            const SizedBox(height: 28),

            // === CHARAKTER & EIGENSCHAFTEN ===
            _sectionHeader('CHARAKTER & EIGENSCHAFTEN'),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _availableTags.map((tag) {
                final selected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: _chipBody(tag, selected),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // === INTERESSEN & HOBBYS ===
            _sectionHeader('INTERESSEN & HOBBYS'),
            _chipSelection(_availableInterests, _selectedInterests, 5),
            const SizedBox(height: 28),

            // === SPORT ===
            _sectionHeader('SPORT'),
            _chipSelection(_availableSports, _selectedSports, 5),
            const SizedBox(height: 28),

            // === REISEN ===
            _sectionHeader('REISEN'),
            _chipSelection(_availableTravel, _selectedTravel, 5),
            const SizedBox(height: 28),

            // === ENTERTAINMENT ===
            _sectionHeader('ENTERTAINMENT'),
            _textField(_moviesController, 'Liebste Serien & Filme', Icons.movie_outlined),
            const SizedBox(height: 14),
            _textField(_musicController, 'Musik', Icons.music_note),
            const SizedBox(height: 14),
            _textField(_booksController, 'Lieblingsbücher', Icons.book_outlined),
            const SizedBox(height: 32),

            // === SPEICHERN ===
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Änderungen speichern'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ===== HELPER WIDGETS =====

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: HevjinTheme.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: HevjinTheme.textPrimary,
            letterSpacing: 1.2,
          )),
        ],
      ),
    );
  }

  // ===== CHIP LOOK & EMOJIS =====
  static const Map<String, String> _chipEmojis = {
    // Interessen & Hobbys
    'Sport & Fitness': '\u{1F4AA}',
    'Zeit mit Familie': '\u{1F46A}',
    'Kochen & Essen': '\u{1F373}',
    'Reisen': '\u{2708}',
    'Lesen & Lernen': '\u{1F4DA}',
    'Gaming & Filme': '\u{1F3AE}',
    'Musik & Tanzen': '\u{1F3B5}',
    'Natur & Spazieren': '\u{1F33F}',
    'Caf\u00e9 & Freunde': '\u{2615}',
    'Cafe & Freunde': '\u{2615}',
    'Fotografie': '\u{1F4F7}',
    'Autos & Technik': '\u{1F697}',
    'Kunst & Design': '\u{1F3A8}',
    // Sport
    'Fitness': '\u{1F3CB}',
    'Fu\u00dfball': '\u{26BD}',
    'Fussball': '\u{26BD}',
    'Schwimmen': '\u{1F3CA}',
    'Joggen': '\u{1F3C3}',
    'Yoga': '\u{1F9D8}',
    'Boxen': '\u{1F94A}',
    'Basketball': '\u{1F3C0}',
    'Tennis': '\u{1F3BE}',
    'Kampfsport': '\u{1F94B}',
    'Tanzen': '\u{1F483}',
    'Radfahren': '\u{1F6B4}',
    'Wandern': '\u{1F97E}',
    // Reisen
    'Strandurlaub': '\u{1F3D6}',
    'St\u00e4dtereisen': '\u{1F3D9}',
    'Staedtereisen': '\u{1F3D9}',
    'Aktivurlaub': '\u{1F9D7}',
    'Camping & Natur': '\u{26FA}',
    'Wellness': '\u{1F486}',
    'Backpacking': '\u{1F392}',
    'Familienurlaub': '\u{1F46A}',
    'Kreuzfahrt': '\u{1F6F3}',
    // Charakter & Eigenschaften
    'Humorvoll': '\u{1F604}',
    'Romantisch': '\u{1F339}',
    'Sportlich': '\u{1F3C5}',
    'Famili\u00e4r': '\u{1F3E1}',
    'Familiaer': '\u{1F3E1}',
    'Zuverl\u00e4ssig': '\u{1F91D}',
    'Zuverlaessig': '\u{1F91D}',
    'Ehrgeizig': '\u{1F3AF}',
    'Herzlich': '\u{1F49B}',
    'Weltoffen': '\u{1F30D}',
    'Traditionell': '\u{1F54A}',
    'Spontan': '\u{26A1}',
    'Kreativ': '\u{2728}',
    'Spirituell': '\u{1F56F}',
    'F\u00fcrsorglich': '\u{1F91A}',
    'Fuersorglich': '\u{1F91A}',
    'Liebevoll': '\u{1F970}',
    'Gelassen': '\u{1F60C}',
    'Sch\u00fcchtern': '\u{1F648}',
    'Schuechtern': '\u{1F648}',
    'Zielstrebig': '\u{1F680}',
    'Abenteuerlustig': '\u{1F9ED}',
    'Empathisch': '\u{1F932}',
    'Loyal': '\u{1F6E1}',
  };

  Widget _chipBody(String label, bool sel) {
    final emoji = _chipEmojis[label];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: sel
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HevjinTheme.secondary,
                  Color.lerp(HevjinTheme.secondary, Colors.black, 0.28)!,
                ],
              )
            : null,
        color: sel ? null : Colors.white,
        border: Border.all(
          color: sel ? Colors.transparent : Colors.grey.shade300,
          width: 1.2,
        ),
        boxShadow: sel
            ? [BoxShadow(
                color: HevjinTheme.secondary.withOpacity(0.30),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )]
            : [BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              )],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(
            fontSize: 13.5,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            color: sel ? Colors.white : HevjinTheme.textPrimary,
          )),
          if (sel) ...[
            const SizedBox(width: 5),
            const Icon(Icons.check_rounded, size: 15, color: Colors.white),
          ],
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
    );
  }

  Widget _textField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 20)),
    );
  }

  Widget _dropdown(String hint, String? value, List<MapEntry<String, String>> options) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(hintText: hint),
      items: options.map((o) => DropdownMenuItem(value: o.key, child: Text(o.value))).toList(),
      onChanged: (v) {},
    );
  }

  Widget _dropdownField(String label, String? value, List<MapEntry<String, String>> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: options.map((o) => DropdownMenuItem(value: o.key, child: Text(o.value))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _casteChip(String value, String label) {
    final selected = _caste == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _caste = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? HevjinTheme.secondary.withOpacity(0.1) : const Color(0xFFF5F5F5),
            border: Border.all(color: selected ? HevjinTheme.secondary : Colors.grey.shade300),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
        ),
      ),
    );
  }

  Widget _lookingChip(String value, String label) {
    final selected = _lookingFor == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _lookingFor = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? HevjinTheme.secondary.withOpacity(0.1) : const Color(0xFFF5F5F5),
            border: Border.all(color: selected ? HevjinTheme.secondary : Colors.grey.shade300),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
        ),
      ),
    );
  }

  // ===== CHIP AUTO-SAVE =====
  // Chips speichern sofort (debounced), damit der Steckbrief live mitgeht.
  Timer? _chipSaveTimer;

  void _autoSaveChips() {
    _chipSaveTimer?.cancel();
    _chipSaveTimer = Timer(const Duration(milliseconds: 700), () async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      try {
        await Supabase.instance.client.from('profiles').update({
          'tags': _selectedTags,
          'interests': _selectedInterests,
          'sports': _selectedSports,
          'travel': _selectedTravel,
        }).eq('id', userId);
        if (mounted) await context.read<ProfileService>().fetchProfile();
      } catch (e) {
        debugPrint('Chip auto-save failed: $e');
      }
    });
  }

  Widget _chipSelection(List<String> available, List<String> selected, int max) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: available.map((item) {
        final isSelected = selected.contains(item);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selected.remove(item);
              } else {
                selected.add(item);
              }
            });
            _autoSaveChips();
          },
          child: _chipBody(item, isSelected),
        );
      }).toList(),
    );
  }

  Widget _boolChip(bool value, String label, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _hasChildren = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? HevjinTheme.secondary.withOpacity(0.1) : const Color(0xFFF5F5F5),
            border: Border.all(color: selected ? HevjinTheme.secondary : Colors.grey.shade300),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
        ),
      ),
    );
  }

  // ===== SAVE =====
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name darf nicht leer sein')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      await Supabase.instance.client.from('profiles').update({
        'display_name': _nameController.text.trim(),
        'bio': _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        'city': _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        'tribe': _tribeController.text.trim().isNotEmpty ? _tribeController.text.trim() : null,
        'job': _jobController.text.trim().isNotEmpty ? _jobController.text.trim() : null,
        // Whitelist-Guard: nur DB-erlaubte Werte schreiben, sonst NULL
        'caste': const ['scheich', 'pir', 'murid'].contains(_caste) ? _caste : null,
        'looking_for':
            const ['heirat', 'dating', 'freundschaft'].contains(_lookingFor)
                ? _lookingFor
                : null,
        'height': _height != 175 ? _height : null,
        'education': _education,
        'job_status': _jobStatus,
        'family_status': _familyStatus,
        'has_children': _hasChildren,
        'child_wish': _childWish,
        'smoking': _smoking,
        'sport_frequency': _sportFrequency,
        'languages': _languagesController.text.trim().isNotEmpty ? _languagesController.text.trim() : null,
        'pets': _petsController.text.trim().isNotEmpty ? _petsController.text.trim() : null,
        'fav_movies': _moviesController.text.trim().isNotEmpty ? _moviesController.text.trim() : null,
        'fav_music': _musicController.text.trim().isNotEmpty ? _musicController.text.trim() : null,
        'fav_books': _booksController.text.trim().isNotEmpty ? _booksController.text.trim() : null,
        'tags': _selectedTags,
        'interests': _selectedInterests,
        'sports': _selectedSports,
        'travel': _selectedTravel,
      }).eq('id', userId);

      // Refresh profile
      if (mounted) {
        await context.read<ProfileService>().fetchProfile();
        setState(() => _isSaving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil gespeichert ✓'), backgroundColor: HevjinTheme.success),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e'), backgroundColor: HevjinTheme.error),
        );
      }
    }
  }
}

