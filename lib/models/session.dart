class Session {
  final String id;
  final String date;
  final int duration;
  final String startTime;
  final String taskId;

  Session({
    required this.id,
    required this.date,
    required this.duration,
    required this.startTime,
    required this.taskId,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'].toString(),
      date: json['date'].toString(),
      duration: json['duration'] as int,
      startTime: json['start_time'] ?? json['time'],
      taskId: json['task_id']?.toString() ?? json['task_ID']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'duration': duration,
      'start_time': startTime,
      'task_id': taskId,
    };
  }
}
