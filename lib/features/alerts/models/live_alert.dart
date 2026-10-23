enum AlertType {
  newUser,
  newFeedback,
  system;

  String get label => switch (this) {
        AlertType.newUser => 'New User',
        AlertType.newFeedback => 'Feedback',
        AlertType.system => 'System',
      };
}

class LiveAlert {
  const LiveAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.metadata,
  });

  factory LiveAlert.fromProfileInsert(Map<String, dynamic> record) {
    final username = record['username'] as String?;
    final name = record['first_name'] != null
        ? '${record['first_name']} ${record['last_name'] ?? ''}'.trim()
        : (record['name'] ?? username ?? record['email'] ?? 'A new reader');

    final timeStr = record['created_at'] ?? record['updated_at'];

    return LiveAlert(
      id: record['id']?.toString() ?? DateTime.now().toIso8601String(),
      type: AlertType.newUser,
      title: 'New User Registered',
      message: '$name just joined Verso!',
      timestamp: timeStr != null
          ? DateTime.tryParse(timeStr.toString()) ?? DateTime.now()
          : DateTime.now(),
      metadata: record,
    );
  }

  factory LiveAlert.fromFeedbackInsert(Map<String, dynamic> record) {
    final type = record['type']?.toString().toUpperCase() ?? 'FEEDBACK';
    final user = record['user_email'] ?? 'Anonymous';

    return LiveAlert(
      id: record['id']?.toString() ?? DateTime.now().toIso8601String(),
      type: AlertType.newFeedback,
      title: 'New $type Received',
      message: 'From $user: "${record['message'] ?? 'No message'}"',
      timestamp: record['created_at'] != null
          ? DateTime.tryParse(record['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      metadata: record,
    );
  }

  final String id;
  final AlertType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
}
