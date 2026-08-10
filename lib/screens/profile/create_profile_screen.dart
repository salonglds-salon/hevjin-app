import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';
import '../../utils/theme.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_photo_screen.dart';

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
  bool _art9Consent = false;
  String _lookingFor = 'heirat';
  String? _education;
  String? _jobStatus;
  String? _familyStatus;
  String? _childWish;
  bool? _hasChildren;
  int _height = 175;
  DateTime? _birthDate;
  int _currentPage = 0;

  /// Effective start page. Falls back to 0 when the basics (name/birthdate)
  /// are missing, so we never persist a profile without a display_name.
  late final int _effStart;

  @override
  void initState() {
    super.initState();
    _prefillFromAuthMetadata();
    // Guard: register_screen passes startPage=2 to skip the basics page.
    // If the auth metadata did not supply name/birthdate, show the full
    // wizard instead of silently writing a NULL display_name.
    final basicsMissing =
        _nameController.text.trim().isEmpty || _birthDate == null;
    _effStart = (widget.startPage > 0 && basicsMissing) ? 0 : widget.startPage;
    _currentPage = _effStart;
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
        title: Text('${AppLocalizations.of(context)?.step ?? 'Schritt'} ${_currentPage - _effStart + 1} / ${_totalPages - _effStart}'),
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
            value: (_currentPage - _effStart + 1) / (_totalPages - _effStart),
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
                if (_currentPage > _effStart)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentPage--),
                      child: Text(AppLocalizations.of(context)?.back ?? 'Zur\u00fcck'),
                    ),
                  ),
                if (_currentPage > _effStart) const SizedBox(width: 12),
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
    if (_currentPage == 1) {
      if (!_art9Consent) {
        _showError('Bitte best\u00e4tige die Einwilligung zu Kaste und Stamm');
        return;
      }
      if (_caste.isEmpty) {
        _showError('Bitte w\u00e4hle deine Kaste');
        return;
      }
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
        _buildArt9Consent(),

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
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.swipe_vertical_outlined, size: 15, color: HevjinTheme.secondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Zwei Bereiche - scrolle nach unten f\u00fcr die Interessen',
                style: TextStyle(fontSize: 12, color: HevjinTheme.secondary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ===== Bereich 1: Eigenschaften =====
        _chipSection(
          icon: Icons.psychology_outlined,
          title: 'Eigenschaften',
          subtitle: 'Was beschreibt dich?',
          count: _selectedTags.length,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final selected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: selected,
                backgroundColor: Colors.white,
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
        ),

        const SizedBox(height: 18),

        // ===== Bereich 2: Interessen =====
        _chipSection(
          icon: Icons.interests_outlined,
          title: 'Interessen',
          subtitle: 'Was machst du gerne?',
          count: _selectedInterests.length,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableInterests.map((item) {
              final selected = _selectedInterests.contains(item['label']);
              return FilterChip(
                avatar: Text(item['icon']!, style: const TextStyle(fontSize: 16)),
                label: Text(item['label']!),
                selected: selected,
                backgroundColor: Colors.white,
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
        ),
      ],
    );
  }

  /// Abgesetzte Karte mit Kopfzeile + Zaehler, damit auf dem Handy
  /// sofort sichtbar ist, dass es zwei getrennte Auswahl-Bereiche gibt.
  Widget _chipSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required int count,
    required Widget child,
  }) {
    final active = count > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: HevjinTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? HevjinTheme.secondary.withOpacity(0.45) : Colors.grey.shade300,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: HevjinTheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11.5, color: HevjinTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: active ? HevjinTheme.secondary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count/5',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : HevjinTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          child,
        ],
      ),
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

  Widget _buildArt9Consent() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2A1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _art9Consent ? const Color(0xFF4CAF50) : const Color(0xFF7A2E2E),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, size: 18, color: Color(0xFFFF8A80)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Besonders gesch\u00fctzte Daten',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFFFF8A80),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Kaste und Stamm geh\u00f6ren zu deiner ethnischen und religi\u00f6sen '
            'Herkunft. Diese Angaben sind nach Art. 9 DSGVO besonders '
            'gesch\u00fctzt. Wir verarbeiten sie ausschlie\u00dflich, um dir '
            'passende Profile zu zeigen \u2013 niemals f\u00fcr Werbung, und wir '
            'geben sie nicht an Dritte weiter. Du kannst deine Einwilligung '
            'jederzeit widerrufen, indem du dein Profil l\u00f6schst.',
            style: TextStyle(fontSize: 12, height: 1.45, color: Color(0xFFD9CFC6)),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => setState(() => _art9Consent = !_art9Consent),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Checkbox(
                    value: _art9Consent,
                    onChanged: (v) => setState(() => _art9Consent = v ?? false),
                    activeColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFFD9CFC6), width: 1.5),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Expanded(
                    child: Text(
                      'Ich willige ausdr\u00fccklich in die Verarbeitung dieser Angaben ein.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
    if (_effStart == 0 && (_nameController.text.trim().isEmpty || _birthDate == null)) {
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
    } else if (_effStart == 0) {
      final user = Supabase.instance.client.auth.currentUser;
      final metaName = (user?.userMetadata?['full_name'] ?? user?.userMetadata?['name'])?.toString().trim();
      if (metaName != null && metaName.isNotEmpty) {
        profileData['display_name'] = metaName;
      }
      // else: leave display_name unset so the user is asked again
      // instead of silently storing the email prefix
    }
    // If startPage > 0: don't touch display_name (already saved)
    
    // Hard guard: never persist a profile row without a display name
    // (display_name is NOT NULL in the database).
    if (!profileData.containsKey('display_name')) {
      _showError('Name und Geburtsdatum sind Pflicht');
      return;
    }

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
    profileData['art9_consent_at'] = DateTime.now().toUtc().toIso8601String();
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
        MaterialPageRoute(builder: (_) => const OnboardingPhotoScreen()),
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
