class UserProfile {
  final String id;
  final String? phone;
  final String displayName;
  final DateTime birthDate;
  final String? gender;
  final String? bio;
  final String? city;
  final String? zipCode;
  final String country;
  final String caste; // scheich, pir, murid
  final String? tribe; // Ashiret
  final String lookingFor; // heirat, dating, freundschaft
  final List<String> photos;
  final String? avatarUrl;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;

  // Neue Felder
  final int? height; // cm
  final String? education; // Bildungsabschluss
  final String? job; // Beruf
  final String? jobStatus; // angestellt, selbstaendig, student, etc.
  final String? familyStatus; // ledig, geschieden, verwitwet
  final bool? hasChildren;
  final String? childWish; // ja, vielleicht, nein
  final List<String> tags; // Selbstbeschreibung-Tags (max 3)
  final List<String> interests; // Interessen (max 5)
  final List<String> sports; // Sport-Tags
  final List<String> travel; // Reise-Tags
  final String? smoking; // Rauchen
  final String? favMovies; // Liebste Serien & Filme
  final String? favMusic; // Musik
  final String? favBooks; // Lieblingsbuecher
  final String? pets; // Haustiere
  final bool photosPrivate; // Foto-Privatsph\u00e4re
  final List<Map<String, String>> promptAnswers; // Profilfragen: [{q,a}]

  UserProfile({
    required this.id,
    this.phone,
    required this.displayName,
    required this.birthDate,
    this.gender,
    this.bio,
    this.city,
    this.zipCode,
    this.country = 'DE',
    required this.caste,
    this.tribe,
    required this.lookingFor,
    this.photos = const [],
    this.avatarUrl,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.height,
    this.education,
    this.job,
    this.jobStatus,
    this.familyStatus,
    this.hasChildren,
    this.childWish,
    this.tags = const [],
    this.interests = const [],
    this.sports = const [],
    this.travel = const [],
    this.smoking,
    this.favMovies,
    this.favMusic,
    this.favBooks,
    this.pets,
    this.photosPrivate = false,
    this.promptAnswers = const [],
  });

  int get age {
    final now = DateTime.now();
    int a = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      a--;
    }
    return a;
  }

  String get casteDisplay {
    switch (caste) {
      case 'scheich':
        return 'Scheich';
      case 'pir':
        return 'Pir';
      case 'murid':
        return 'Murid';
      default:
        return caste;
    }
  }

  String get lookingForDisplay {
    switch (lookingFor) {
      case 'heirat':
        return 'Heirat';
      case 'dating':
        return 'Dating';
      case 'freundschaft':
        return 'Freundschaft';
      default:
        return lookingFor;
    }
  }

  String get educationDisplay {
    switch (education) {
      case 'hauptschule':
        return 'Hauptschule';
      case 'realschule':
        return 'Realschule / Ausbildung';
      case 'abitur':
        return 'Abitur / Fachabitur';
      case 'studium':
        return 'Noch im Studium';
      case 'bachelor':
        return 'Bachelor';
      case 'master':
        return 'Master / Promotion';
      default:
        return education ?? '';
    }
  }

  String get familyStatusDisplay {
    switch (familyStatus) {
      case 'ledig':
        return 'Ledig';
      case 'geschieden':
        return 'Geschieden';
      case 'getrennt':
        return 'Getrennt lebend';
      case 'verwitwet':
        return 'Verwitwet';
      default:
        return familyStatus ?? '';
    }
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      displayName: (json['display_name']?.toString().trim().isNotEmpty ?? false)
          ? json['display_name'].toString()
          : 'Mitglied',
      birthDate: DateTime.tryParse(json['birth_date']?.toString() ?? '') ?? DateTime(2000, 1, 1),
      gender: json['gender']?.toString(),
      bio: json['bio']?.toString(),
      city: json['city']?.toString(),
      zipCode: json['zip_code']?.toString(),
      country: json['country']?.toString() ?? 'DE',
      // caste/lookingFor sind non-nullable -> NULL in der DB darf die App nicht
      // abschiessen (war die Ursache des "Null check operator"-Crashs im Discover)
      caste: json['caste']?.toString() ?? '',
      tribe: json['tribe']?.toString(),
      lookingFor: json['looking_for']?.toString() ?? '',
      photos: _toStringList(json['photos']),
      avatarUrl: json['avatar_url']?.toString(),
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      height: json['height'],
      education: json['education'],
      job: json['job'],
      jobStatus: json['job_status'],
      familyStatus: json['family_status'],
      hasChildren: json['has_children'],
      childWish: json['child_wish'],
      tags: _toStringList(json['tags']),
      interests: _toStringList(json['interests']),
      sports: _toStringList(json['sports']),
      travel: _toStringList(json['travel']),
      smoking: json['smoking']?.toString(),
      favMovies: json['fav_movies']?.toString(),
      favMusic: json['fav_music']?.toString(),
      favBooks: json['fav_books']?.toString(),
      pets: json['pets']?.toString(),
      photosPrivate: json['photos_private'] ?? false,
      promptAnswers: ((json['prompt_answers'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => {
                'q': e['q']?.toString() ?? '',
                'a': e['a']?.toString() ?? '',
              })
          .where((e) => (e['a'] ?? '').trim().isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_answers': promptAnswers,
      'id': id,
      'phone': phone,
      'display_name': displayName,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'gender': gender,
      'bio': bio,
      'city': city,
      'zip_code': zipCode,
      'country': country,
      'caste': caste,
      'tribe': tribe,
      'looking_for': lookingFor,
      'photos': photos,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'is_active': isActive,
      'height': height,
      'education': education,
      'job': job,
      'job_status': jobStatus,
      'family_status': familyStatus,
      'has_children': hasChildren,
      'child_wish': childWish,
      'tags': tags,
      'interests': interests,
      'sports': sports,
      'travel': travel,
      'smoking': smoking,
      'photos_private': photosPrivate,
    };
  }
}
