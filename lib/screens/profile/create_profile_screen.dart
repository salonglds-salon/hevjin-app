import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';
import '../../utils/theme.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  final int startPage;
  final String? userId;
  const CreateProfileScreen({super.key, this.startPage = 0, this.userId});
  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _tribeController = TextEditingController();
  final _jobController = TextEditingController();
  final _zipController = TextEditingController();

  String _gender = 'male';
  String _caste = 'murid';
  String _lookingFor = 'heirat';
  String? _education;
  String? _jobStatus;
  String? _familyStatus;
  String? _childWish;
  bool? _hasChildren;
  int _height = 175;
  DateTime? _birthDate;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.startPage;
    _prefillFromAuthMetadata();
  }

  /// Prefills name, birthdate and gender from auth user_metadata
  /// (saved during registration or provided by Google OAuth)
  void _prefillFromAuthMetadata() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final meta = user.userMetadata;
    if (meta == null) return;

    // Name: registration name > Google full_name > Google name
    final name = (meta['full_name'] ?? meta['name'])?.toString().trim();
    if (name != null && name.isNotEmpty && _nameController.text.trim().isEmpty) {
      _nameController.text = name;
    }

    // Birthdate (yyyy-MM-dd from registration)
    final bd = meta['birth_date']?.toString();
    if (bd != null && bd.isNotEmpty && _birthDate == null) {
      final parsed = DateTime.tryParse(bd);
      if (parsed != null) _birthDate = parsed;
    }

    // Gender
    final g = meta['gender']?.toString();
    if (g == 'male' || g == 'female') {
      _gender = g!;
    }
  }

  // Tags & Interests
  List<String> _selectedTags = [];
  List<String> _selectedInterests = [];

  final List<String> _availableTags = [
    'Humorvoll', 'Romantisch', 'Sportlich', 'Familiär',
    'Zuverlässig', 'Ehrgeizig', 'Herzlich', 'Weltoffen',
    'Traditionell', 'Spontan', 'Kreativ', 'Spirituell',
    'Fürsorglich', 'Liebevoll', 'Gelassen', 'Schüchtern',
    'Zielstrebig', 'Abenteuerlustig', 'Empathisch', 'Loyal',
  ];

  final List<Map<String, String>> _availableInterests = [
    {'icon': '🏋️', 'label': 'Sport & Fitness'},
    {'icon': '👨👩👧', 'label': 'Zeit mit Familie'},
    {'icon': '🍳', 'label': 'Kochen & Essen'},
    {'icon': '🌍', 'label': 'Reisen'},
    {'icon': '📚', 'label': 'Lesen & Lernen'},
    {'icon': '🎮', 'label': 'Gaming & Filme'},
    {'icon': '🎵', 'label': 'Musik & Tanzen'},
    {'icon': '🌿', 'label': 'Natur & Spazieren'},
    {'icon': '☕', 'label': 'Café & Freunde'},
    {'icon': '📸', 'label': 'Fotografie'},
    {'icon': '🚗', 'label': 'Autos & Technik'},
    {'icon': '🎨', 'label': 'Kunst & Design'},
  ];

  // Total pages
  final int _totalPages = 7;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _tribeController.dispose();
    _jobController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)?.step ?? 'Schritt'} ${_currentPage - widget.startPage + 1} / ${_totalPages - widget.startPage}'),
        automaticallyImplyLeading: false,
        actions: [
          // Überspringen Button (nicht auf Pflicht-Seiten)
          if (_currentPage > 0 && _currentPage < _totalPages - 1)
            TextButton(
              onPressed: _nextPage,
              child: Text(AppLocalizations.of(context)?.skip ?? 'Ueberspringen',
                  style: const TextStyle(color: HevjinTheme.textSecondary)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentPage - widget.startPage + 1) / (_totalPages - widget.startPage),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(HevjinTheme.secondary),
            minHeight: 3,
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildPage(),
            ),
          ),

          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentPage > widget.startPage)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentPage--),
                      child: Text(AppLocalizations.of(context)?.back ?? 'Zur\u00fcck'),
                    ),
                  ),
                if (_currentPage > widget.startPage) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _currentPage == _totalPages - 1
                        ? _saveProfile
                        : _nextPage,
                    child: Text(
                      _currentPage == _totalPages - 1 ? (AppLocalizations.of(context)?.createProfile ?? 'Profil erstellen') : (AppLocalizations.of(context)?.next ?? 'Weiter'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    // Validierung nur auf Pflicht-Seiten
    if (_currentPage == 0) {
      if (_nameController.text.trim().isEmpty || _birthDate == null) {
        _showError('Name und Geburtsdatum sind Pflicht');
        return;
      }
    }
    if (_currentPage == 1 && _caste.isEmpty) {
      _showError('Bitte wähle deine Kaste');
      return;
    }
    setState(() => _currentPage++);
  }

  Widget _buildPage() {
    switch (_currentPage) {
      case 0:
        return _buildBasicInfo();
      case 1:
        return _buildYezidiInfo();
      case 2:
        return _buildBodyAndLife();
      case 3:
        return _buildJobEducation();
      case 4:
        return _buildFamilyKids();
      case 5:
        return _buildTagsAndInterests();
      case 6:
        return _buildBioAndCity();
      default:
        return const SizedBox();
    }
  }

  // ===== PAGE 0: Grunddaten (PFLICHT) =====
  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.basicInfo ?? 'Grunddaten', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('', style: TextStyle(color: HevjinTheme.textSecondary)),
        const SizedBox(height: 24),

        Text('${AppLocalizations.of(context)?.firstName ?? 'Vorname'} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.firstName ?? 'Vorname',
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 20),

        Text('${AppLocalizations.of(context)?.birthDate ?? 'Geburtsdatum'} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: const Color(0xFFF1F3F5),
          leading: const Icon(Icons.calendar_today),
          title: Text(
            _birthDate == null
                ? 'Geburtsdatum wählen'
                : '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}',
          ),
          trailing: _birthDate != null
              ? Text('${_calculateAge()} Jahre', style: const TextStyle(color: HevjinTheme.secondary, fontWeight: FontWeight.w600))
              : null,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime(2000, 1, 1),
              firstDate: DateTime(1960),
              lastDate: DateTime(2008),
            );
            if (date != null) setState(() => _birthDate = date);
          },
        ),
        if (_birthDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Andere sehen nur dein Alter', style: TextStyle(fontSize: 11, color: HevjinTheme.textSecondary)),
          ),
        const SizedBox(height: 20),

        const Text('Geschlecht *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _genderButton('male', AppLocalizations.of(context)?.male ?? 'M\u00e4nnlich', Icons.male)),
            const SizedBox(width: 12),
            Expanded(child: _genderButton('female', AppLocalizations.of(context)?.female ?? 'Weiblich', Icons.female)),
          ],
        ),
      ],
    );
  }

  // ===== PAGE 1: Êzîdische Identität (PFLICHT) =====
  Widget _buildYezidiInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.ezidiIdentity ?? '\u00cazidische Identit\u00e4t', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context)?.caste ?? 'Kaste, Stamm und was du suchst', style: const TextStyle(color: HevjinTheme.textSecondary)),
        const SizedBox(height: 24),

        Text('${AppLocalizations.of(context)?.caste ?? 'Kaste'} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _casteButton('scheich', '\u2606', 'Scheich')),
            const SizedBox(width: 8),
            Expanded(child: _casteButton('pir', '\u2605', 'Pir')),
            const SizedBox(width: 8),
            Expanded(child: _casteButton('murid', '\u2661', 'Murid')),
          ],
        ),
        const SizedBox(height: 20),

        Text(AppLocalizations.of(context)?.tribe ?? 'Stamm / Ashiret', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _tribeController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.tribe ?? 'z.B. Haskan, Sipka...',
            prefixIcon: const Icon(Icons.groups_outlined),
          ),
        ),
        const SizedBox(height: 20),

        Text('${AppLocalizations.of(context)?.iAmLookingFor ?? 'Ich suche'} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _lookingForButton('heirat', '\u2764', AppLocalizations.of(context)?.marriage ?? 'Heirat')),
            const SizedBox(width: 8),
            Expanded(child: _lookingForButton('dating', '\u2665', AppLocalizations.of(context)?.dating ?? 'Dating')),
            const SizedBox(width: 8),
            Expanded(child: _lookingForButton('freundschaft', '\u263A', AppLocalizations.of(context)?.friendship ?? 'Freunde')),
          ],
        ),
      ],
    );
  }

  // ===== PAGE 2: Koerper & Wohnort =====
  Widget _buildBodyAndLife() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.aboutYou ?? '\u00dcber dich', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),

        const Text('K\u00f6rpergr\u00f6\u00dfe', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _height.toDouble(),
                min: 140,
                max: 220,
                divisions: 80,
                activeColor: HevjinTheme.secondary,
                label: '$_height cm',
                onChanged: (v) => setState(() => _height = v.round()),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: HevjinTheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$_height cm', style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(AppLocalizations.of(context)?.city ?? 'Wohnort', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            hintText: 'z.B. Bielefeld, Oldenburg...',
            prefixIcon: const Icon(Icons.location_city),
          ),
        ),
      ],
    );
  }

  // ===== PAGE 3: Beruf & Bildung =====
  Widget _buildJobEducation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.jobTitle ?? 'Beruf & Bildung', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('', style: TextStyle(color: HevjinTheme.textSecondary)),
        const SizedBox(height: 24),

        Text(AppLocalizations.of(context)?.jobTitle ?? 'Beruf', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _jobController,
          decoration: const InputDecoration(
            hintText: 'z.B. Ingenieur, Lehrerin, Arzt...',
            prefixIcon: Icon(Icons.work_outline),
          ),
        ),
        const SizedBox(height: 20),

        const Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _jobStatus,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.badge_outlined)),
          hint: const Text('Wählen...'),
          items: const [
            DropdownMenuItem(value: 'angestellt', child: Text('Angestellt')),
            DropdownMenuItem(value: 'selbstaendig', child: Text('Selbständig')),
            DropdownMenuItem(value: 'student', child: Text('Student/in')),
            DropdownMenuItem(value: 'ausbildung', child: Text('In Ausbildung')),
            DropdownMenuItem(value: 'arbeitssuchend', child: Text('Arbeitssuchend')),
          ],
          onChanged: (v) => setState(() => _jobStatus = v),
        ),
        const SizedBox(height: 20),

        Text(AppLocalizations.of(context)?.educationLevel ?? 'Bildungsabschluss', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _education,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.school_outlined)),
          hint: const Text('Wählen...'),
          items: const [
            DropdownMenuItem(value: 'hauptschule', child: Text('Hauptschule')),
            DropdownMenuItem(value: 'realschule', child: Text('Realschule / Ausbildung')),
            DropdownMenuItem(value: 'abitur', child: Text('Abitur / Fachabitur')),
            DropdownMenuItem(value: 'studium', child: Text('Noch im Studium')),
            DropdownMenuItem(value: 'bachelor', child: Text('Bachelor')),
            DropdownMenuItem(value: 'master', child: Text('Master / Promotion')),
          ],
          onChanged: (v) => setState(() => _education = v),
        ),
      ],
    );
  }

  // ===== PAGE 4: Familie & Kinder =====
  Widget _buildFamilyKids() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.familyStatus ?? 'Familie', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('', style: TextStyle(color: HevjinTheme.textSecondary)),
        const SizedBox(height: 24),

        Text(AppLocalizations.of(context)?.familyStatus ?? 'Familienstand', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chipButton('ledig', AppLocalizations.of(context)?.single ?? 'Ledig', _familyStatus == 'ledig', (v) => setState(() => _familyStatus = v)),
            _chipButton('geschieden', AppLocalizations.of(context)?.divorced ?? 'Geschieden', _familyStatus == 'geschieden', (v) => setState(() => _familyStatus = v)),
            _chipButton('getrennt', 'Getrennt', _familyStatus == 'getrennt', (v) => setState(() => _familyStatus = v)),
            _chipButton('verwitwet', AppLocalizations.of(context)?.widowed ?? 'Verwitwet', _familyStatus == 'verwitwet', (v) => setState(() => _familyStatus = v)),
          ],
        ),
        const SizedBox(height: 24),

        Text(AppLocalizations.of(context)?.children ?? 'Hast du Kinder?', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _boolButton(true, AppLocalizations.of(context)?.yes ?? 'Ja', _hasChildren == true, () => setState(() => _hasChildren = true))),
            const SizedBox(width: 12),
            Expanded(child: _boolButton(false, AppLocalizations.of(context)?.no ?? 'Nein', _hasChildren == false, () => setState(() => _hasChildren = false))),
          ],
        ),
        const SizedBox(height: 24),

        Text(AppLocalizations.of(context)?.childWish ?? 'Kinderwunsch?', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chipButton('ja', AppLocalizations.of(context)?.yes ?? 'Ja', _childWish == 'ja', (v) => setState(() => _childWish = v)),
            _chipButton('vielleicht', AppLocalizations.of(context)?.maybeChildren ?? 'Vielleicht', _childWish == 'vielleicht', (v) => setState(() => _childWish = v)),
            _chipButton('nein', AppLocalizations.of(context)?.no ?? 'Nein', _childWish == 'nein', (v) => setState(() => _childWish = v)),
          ],
        ),
      ],
    );
  }

  // ===== PAGE 5: Tags & Interessen =====
  Widget _buildTagsAndInterests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.characterTraits ?? 'Pers\u00f6nlichkeit', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context)?.interestsHobbies ?? 'Interessen & Hobbys', style: const TextStyle(color: HevjinTheme.textSecondary)),
        const SizedBox(height: 20),

        Text('W\u00e4hle bis zu 5 Eigenschaften (${_selectedTags.length}/5)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final selected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: selected,
              selectedColor: HevjinTheme.secondary.withOpacity(0.2),
              checkmarkColor: HevjinTheme.secondary,
              onSelected: (v) {
                setState(() {
                  if (v && _selectedTags.length < 5) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        Text('Interessen — bis zu 5 wählen (${_selectedInterests.length}/5)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableInterests.map((item) {
            final selected = _selectedInterests.contains(item['label']);
            return FilterChip(
              avatar: Text(item['icon']!, style: const TextStyle(fontSize: 16)),
              label: Text(item['label']!),
              selected: selected,
              selectedColor: HevjinTheme.secondary.withOpacity(0.2),
              checkmarkColor: HevjinTheme.secondary,
              onSelected: (v) {
                setState(() {
                  if (v && _selectedInterests.length < 5) {
                    _selectedInterests.add(item['label']!);
                  } else {
                    _selectedInterests.remove(item['label']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ===== PAGE 6: Bio =====
  Widget _buildBioAndCity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.aboutMe ?? 'Bio', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),

        const Text('Bio', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _bioController,
          maxLines: 4,
          maxLength: 300,
          decoration: const InputDecoration(
            hintText: 'Was macht dich aus? Was ist dir wichtig?',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 20),

        // Privacy note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: HevjinTheme.secondary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: HevjinTheme.secondary, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Deine Privatsph\u00e4re ist uns wichtig. Du entscheidest was andere sehen.',
                  style: TextStyle(fontSize: 12, color: HevjinTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== HELPER WIDGETS =====
  Widget _genderButton(String value, String label, IconData icon) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? HevjinTheme.secondary : Colors.grey.shade200, width: 2),
          color: selected ? HevjinTheme.secondary.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: selected ? HevjinTheme.secondary : HevjinTheme.textSecondary),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _casteButton(String value, String emoji, String label) {
    final selected = _caste == value;
    return GestureDetector(
      onTap: () => setState(() => _caste = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? HevjinTheme.secondary : Colors.grey.shade200, width: 2),
          color: selected ? HevjinTheme.secondary.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _lookingForButton(String value, String emoji, String label) {
    final selected = _lookingFor == value;
    return GestureDetector(
      onTap: () => setState(() => _lookingFor = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? HevjinTheme.secondary : Colors.grey.shade200, width: 2),
          color: selected ? HevjinTheme.secondary.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _chipButton(String value, String label, bool selected, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? HevjinTheme.secondary : Colors.grey.shade300),
          color: selected ? HevjinTheme.secondary.withOpacity(0.1) : Colors.white,
        ),
        child: Text(label, style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? HevjinTheme.primary : HevjinTheme.textSecondary,
        )),
      ),
    );
  }

  Widget _boolButton(bool value, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? HevjinTheme.secondary : Colors.grey.shade200, width: 2),
          color: selected ? HevjinTheme.secondary.withOpacity(0.05) : Colors.white,
        ),
        child: Center(child: Text(label, style: TextStyle(
          fontSize: 16, fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ))),
      ),
    );
  }

  int _calculateAge() {
    if (_birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month || (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      age--;
    }
    return age;
  }

  // ===== SAVE =====
  Future<void> _saveProfile() async {
    // Only validate name/birthdate if user started at page 0 (full wizard)
    if (widget.startPage == 0 && (_nameController.text.trim().isEmpty || _birthDate == null)) {
      _showError('Name und Geburtsdatum sind Pflicht');
      return;
    }

    final profileService = context.read<ProfileService>();
    final user = Supabase.instance.client.auth.currentUser;
    final phone = user?.phone;
    final uid = user?.id ?? widget.userId;
    
    final profileData = <String, dynamic>{};
    if (uid != null) profileData['id'] = uid;
    
    // Set display_name — NEVER fall back to the email prefix
    if (_nameController.text.trim().isNotEmpty) {
      profileData['display_name'] = _nameController.text.trim();
    } else if (widget.startPage == 0) {
      final user = Supabase.instance.client.auth.currentUser;
      final metaName = (user?.userMetadata?['full_name'] ?? user?.userMetadata?['name'])?.toString().trim();
      if (metaName != null && metaName.isNotEmpty) {
        profileData['display_name'] = metaName;
      }
      // else: leave display_name unset so the user is asked again
      // instead of silently storing the email prefix
    }
    // If startPage > 0: don't touch display_name (already saved)
    
    // Set birthdate if available
    if (_birthDate != null) {
      profileData['birth_date'] = _birthDate!.toIso8601String().split('T').first;
    }
    // Set gender if on page 0 or if selected
    if (_gender.isNotEmpty) {
      profileData['gender'] = _gender;
    }
    
    // Always save optional fields
    profileData['caste'] = _caste;
    if (_tribeController.text.trim().isNotEmpty) profileData['tribe'] = _tribeController.text.trim();
    profileData['looking_for'] = _lookingFor;
    if (_bioController.text.trim().isNotEmpty) profileData['bio'] = _bioController.text.trim();
    if (_cityController.text.trim().isNotEmpty) profileData['city'] = _cityController.text.trim();
    if (_zipController.text.trim().isNotEmpty) profileData['zip_code'] = _zipController.text.trim();
    if (_height != 175) profileData['height'] = _height;
    if (_education != null && _education!.isNotEmpty) profileData['education'] = _education;
    if (_jobController.text.trim().isNotEmpty) profileData['job'] = _jobController.text.trim();
    if (_jobStatus != null && _jobStatus!.isNotEmpty) profileData['job_status'] = _jobStatus;
    if (_familyStatus != null && _familyStatus!.isNotEmpty) profileData['family_status'] = _familyStatus;
    profileData['has_children'] = _hasChildren;
    if (_childWish != null && _childWish!.isNotEmpty) profileData['child_wish'] = _childWish;
    if (_selectedTags.isNotEmpty) profileData['tags'] = _selectedTags;
    if (_selectedInterests.isNotEmpty) profileData['interests'] = _selectedInterests;
    
    // Only include phone if user actually has one (not Google login)
    if (phone != null && phone.isNotEmpty) {
      profileData['phone'] = phone;
    }
    
    final success = await profileService.saveProfile(profileData);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      final error = profileService.errorMessage ?? 'Unbekannter Fehler';
      _showError('Fehler: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: HevjinTheme.error),
    );
  }
}
