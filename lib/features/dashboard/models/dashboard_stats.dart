class DashboardStats {
  const DashboardStats({
    required this.totalUsers,
    required this.activeReadersToday,
    required this.newSignupsToday,
    required this.openFeedbackCount,
    required this.lastRefreshedAt,
  });

  final int totalUsers;
  final int activeReadersToday;
  final int newSignupsToday;
  final int openFeedbackCount;
  final DateTime lastRefreshedAt;

  factory DashboardStats.empty() => DashboardStats(
        totalUsers: 0,
        activeReadersToday: 0,
        newSignupsToday: 0,
        openFeedbackCount: 0,
        lastRefreshedAt: DateTime.now(),
      );
}
