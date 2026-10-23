class VersoUserProfile {
  const VersoUserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.gender,
    required this.role,
    required this.streakCount,
    required this.isStreakFrozen,
    required this.otChaptersCompleted,
    required this.ntChaptersCompleted,
    required this.canonType,
    required this.bibleLanguage,
    required this.createdAt,
    this.birthday,
    this.lastSeenAt,
  });

  factory VersoUserProfile.fromJson(Map<String, dynamic> json) {
    final username = json['username'] as String?;
    final rawName = json['name'] as String? ?? json['full_name'] as String?;
    final firstName = json['first_name'] as String?;
    final lastName = json['last_name'] as String?;
    final email = json['email'] as String?;

    final displayName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (username != null && username.trim().isNotEmpty)
            ? username.trim()
            : (firstName != null
                ? '$firstName ${lastName ?? ''}'.trim()
                : (email ?? 'Reader'));

    final streak = (json['current_streak'] as num?)?.toInt() ??
        (json['streak_count'] as num?)?.toInt() ??
        0;

    final createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ??
            DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
            DateTime.now()
        : (json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now());

    final lastSeenAt = json['last_seen'] != null
        ? DateTime.tryParse(json['last_seen'].toString())
        : (json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null);

    return VersoUserProfile(
      id: json['id'] as String? ?? '',
      email: email ??
          (username != null && username.contains('@')
              ? username
              : '${displayName.toLowerCase().replaceAll(' ', '')}@verso.app'),
      name: displayName,
      gender: json['gender'] as String? ?? 'male',
      role: json['role'] as String? ?? 'reader',
      streakCount: streak,
      isStreakFrozen: (json['is_streak_frozen'] as bool?) ??
          (json['streak_freeze_active'] as bool?) ??
          false,
      otChaptersCompleted:
          (json['ot_chapters_completed'] as num?)?.toInt() ?? 0,
      ntChaptersCompleted:
          (json['nt_chapters_completed'] as num?)?.toInt() ?? 0,
      canonType: json['canon_type'] as String? ?? 'catholic',
      bibleLanguage: json['bible_language'] as String? ?? 'en',
      birthday: json['birthday'] as String? ?? json['birthdate'] as String?,
      createdAt: createdAt,
      lastSeenAt: lastSeenAt,
    );
  }

  final String id;
  final String email;
  final String name;
  final String gender;
  final String role;
  final int streakCount;
  final bool isStreakFrozen;
  final int otChaptersCompleted;
  final int ntChaptersCompleted;
  final String canonType;
  final String bibleLanguage;
  final String? birthday;
  final DateTime createdAt;
  final DateTime? lastSeenAt;

  bool get isAdmin => role == 'admin';

  double get otProgress => (otChaptersCompleted / 929.0).clamp(0.0, 1.0);
  double get ntProgress => (ntChaptersCompleted / 260.0).clamp(0.0, 1.0);
}

class UserReadingChapters {
  const UserReadingChapters({
    required this.otChapters,
    required this.ntChapters,
  });

  final int otChapters;
  final int ntChapters;

  double get otProgress => (otChapters / 929.0).clamp(0.0, 1.0);
  double get ntProgress => (ntChapters / 260.0).clamp(0.0, 1.0);
}
