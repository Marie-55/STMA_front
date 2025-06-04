class DailyStats {
  final int totalTasks;
  final int accomplishedTasks;
  final DateTime date;

  DailyStats({
    required this.totalTasks,
    required this.accomplishedTasks,
    required this.date,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      totalTasks: json['total_tasks'] ?? 0,
      accomplishedTasks: json['accomplished_tasks'] ?? 0,
      date: DateTime.parse(json['date']),
    );
  }
}

class Profile {
  final String name;
  final int score;
  final List<DailyStats> weeklyStats;
  final List<DailyStats> monthlyStats;

  Profile({
    required this.name,
    required this.weeklyStats,
    required this.monthlyStats,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? '',
      weeklyStats: (json['weekly_stats'] as List?)
          ?.map((stat) => DailyStats.fromJson(stat))
          .toList() ?? [],
      monthlyStats: (json['monthly_stats'] as List?)
          ?.map((stat) => DailyStats.fromJson(stat))
          .toList() ?? [],
    );
  }
}