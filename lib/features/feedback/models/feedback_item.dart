import 'package:verso_admin/features/feedback/models/feedback_type.dart';

class FeedbackItem {
  const FeedbackItem({
    required this.id,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.status,
    this.userId,
    this.userEmail,
    this.imageUrls = const [],
    this.appVersion = '2.0.0',
    this.platform = 'unknown',
  });

  final String id;
  final String? userId;
  final String? userEmail;
  final FeedbackType type;
  final String message;
  final List<String> imageUrls;
  final String appVersion;
  final String platform;
  final String status; // 'open', 'in_progress', 'resolved'
  final DateTime createdAt;

  bool get isResolved => status == 'resolved';
  bool get isInProgress => status == 'in_progress';
  bool get isOpen => status == 'open' || status.isEmpty;

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    final rawImages = json['image_urls'];
    List<String> images = [];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    } else if (json['image_url'] != null) {
      images = [json['image_url'].toString()];
    }

    return FeedbackItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] as String?,
      userEmail: json['user_email'] as String? ?? 'anonymous@user.app',
      type: FeedbackType.fromString(json['type'] as String?),
      message: json['message'] as String? ?? '',
      imageUrls: images,
      appVersion: json['app_version'] as String? ?? '2.0.0',
      platform: json['platform'] as String? ?? 'mobile',
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
