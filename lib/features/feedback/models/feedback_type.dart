import 'package:flutter/material.dart';

/// Type of feedback submitted by users.
enum FeedbackType {
  issue,
  idea;

  String get title => switch (this) {
        FeedbackType.issue => 'Report an issue',
        FeedbackType.idea => 'Share an idea',
      };

  String get shortTitle => switch (this) {
        FeedbackType.issue => 'Issue',
        FeedbackType.idea => 'Idea',
      };

  IconData get icon => switch (this) {
        FeedbackType.issue => Icons.bug_report_outlined,
        FeedbackType.idea => Icons.lightbulb_outline_rounded,
      };

  Color get accentColor => switch (this) {
        FeedbackType.issue => const Color(0xFFEF4444),
        FeedbackType.idea => const Color(0xFFF59E0B),
      };

  static FeedbackType fromString(String? val) {
    if (val?.toLowerCase() == 'idea') return FeedbackType.idea;
    return FeedbackType.issue;
  }
}
