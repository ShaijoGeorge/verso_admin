import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso_admin/core/supabase/supabase_provider.dart';
import 'package:verso_admin/features/feedback/data/feedback_repository.dart';
import 'package:verso_admin/features/feedback/models/feedback_item.dart';
import 'package:verso_admin/features/feedback/models/feedback_type.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FeedbackRepository(client: client);
});

class FeedbackTypeFilterNotifier extends Notifier<FeedbackType?> {
  @override
  FeedbackType? build() => null;

  @override
  set state(FeedbackType? value) => super.state = value;
}

final feedbackTypeFilterProvider =
    NotifierProvider<FeedbackTypeFilterNotifier, FeedbackType?>(
  FeedbackTypeFilterNotifier.new,
);

class FeedbackStatusFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  @override
  set state(String? value) => super.state = value;
}

final feedbackStatusFilterProvider =
    NotifierProvider<FeedbackStatusFilterNotifier, String?>(
  FeedbackStatusFilterNotifier.new,
);

final feedbackInboxProvider =
    AsyncNotifierProvider<FeedbackInboxNotifier, List<FeedbackItem>>(
  FeedbackInboxNotifier.new,
);

class FeedbackInboxNotifier extends AsyncNotifier<List<FeedbackItem>> {
  @override
  Future<List<FeedbackItem>> build() async {
    final type = ref.watch(feedbackTypeFilterProvider);
    final status = ref.watch(feedbackStatusFilterProvider);
    final repo = ref.watch(feedbackRepositoryProvider);
    return repo.fetchFeedbacks(type: type, status: status);
  }

  Future<void> updateStatus(String feedbackId, String newStatus) async {
    final repo = ref.read(feedbackRepositoryProvider);
    await repo.updateFeedbackStatus(
      feedbackId: feedbackId,
      newStatus: newStatus,
    );
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
