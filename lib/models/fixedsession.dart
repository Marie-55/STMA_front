
import 'dart:convert';

import 'package:http/http.dart' as http;

class FixedSession {
  final int id;
  final String title;
  final int day_index;
  final double duration;
  final String start_time;
  final int user_id;

  FixedSession({
    required this.id,
    required this.title,
    required this.day_index,
    required this.duration,
    required this.start_time,
    required this.user_id,
  });

  factory FixedSession.fromJson(Map<String, dynamic> json) {
    return FixedSession(
    id: int.parse(json['id'].toString()),
    title: json['title'],
    day_index: int.parse(json['day_index'].toString()),
    duration: (json['duration'] as num).toDouble(),
    start_time: json['start_time'],
    user_id: int.parse(json['user_id'].toString()),
  );
  }

  @override
  String toString() {
    return 'FixedSession(id: $id, title: $title, day_index: $day_index, duration: $duration, start_time: $start_time, user_id: $user_id)';
  }
}

Future<List<List<FixedSession>>> fetchWeeklyFixedSessions(int user_id) async {
  final url = Uri.parse('http://127.0.0.1:5000/api/fixedSession/user/$user_id');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success'] == true && data['data'] != null) {
      final sessions = (data['data'] as List)
          .map((json) => FixedSession.fromJson(json))
          .toList();

      // Group sessions by day_index (0-6)
      List<List<FixedSession>> result = List.generate(7, (_) => []);
      for (var session in sessions) {
        final dayIndex = session.day_index;
        if (dayIndex >= 0 && dayIndex < 7) {
          result[dayIndex].add(session);
        }
      }
      return result;
    }
  }
  throw Exception('Failed to fetch weekly fixed sessions');
}
