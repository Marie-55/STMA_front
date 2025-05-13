import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/session.dart';
import 'package:intl/intl.dart';

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
          // The date will be in yyyy-MM-dd format
          final date = json['date'].toString();

          // Handle time format
          String startTime = json['start_time']?.toString() ?? '00:00:00';

          return Session(
            id: json['id'].toString(),
            date:
                date, // No need to parse and reformat since it's already in the correct format
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
        // If no sessions found for the date, return empty list
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching sessions: $e');
    }
  }
}
