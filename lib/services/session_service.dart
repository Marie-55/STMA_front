import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/session.dart';

class SessionService {
  static const String baseUrl = 'https://stma-back.onrender.com/api/session';

  Future<List<Session>> fetchAllSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/read/all'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionsData = data['session'] as List;

        return sessionsData.map((json) {
          final date = json['date'].toString();
          String startTime = json['start_time']?.toString() ?? '00:00:00';

          return Session(
            id: json['id'].toString(),
            date: date,
            duration: json['duration'] as int,
            startTime: startTime,
            taskId: json['task_id']?.toString() ?? '',
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sessions: $e');
    }
  }

  Future<List<Session>> fetchSessionsByDate(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/read/date/$date'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionsData = data['session'] as List;

        return sessionsData.map((json) {
          String startTime = json['start_time']?.toString() ?? '00:00:00';

          return Session(
            id: json['id'].toString(),
            date: date,
            duration: json['duration'] as int,
            startTime: startTime,
            taskId: json['task_id']?.toString() ?? '',
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching sessions: $e');
    }
  }

  Future<List<dynamic>> fetchSessionsForDay(DateTime date) async {
    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    final url = Uri.parse('https:/stma-back.onrender.com/api/day/read/day_sessions/$formattedDate');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['schedule']; // This is a list of session maps
    } else {
      return [];
    }
  }
}
