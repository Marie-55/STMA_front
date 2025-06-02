import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/session.dart';

class SessionService {
  //static const String baseUrl = 'https://stma-back.onrender.com/api/session';    // checked the right URL
  static const String baseUrl = 'http://127.0.0.1:5000/api/session'; // For local development



  /// Works: ALready tested and working
  /// This function fetches all sessions for a specific user.
  Future<List<Session>> fetchAllSessions([int user_id = 1]) async {
    try {
      final url = Uri.parse('$baseUrl/user/$user_id');
      print('Sending GET request to: $url');

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final sessionsData = data['data'];
        if (sessionsData == null) {
          print('Warning: data["data"] is null');
          return [];
        }

        return (sessionsData as List).map((json) => _sessionFromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch sessions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchAllSessions: $e');
      throw Exception('Error fetching sessions: $e');
    }
  }





  /// this function fetches all sessions for a specific date
  /// It takes a DateTime object as input and returns a list of Session objects.
  /// it works but we should consider the fetching based on the user from the backend
  /// This function is useful for getting all sessions for a specific date.
  Future<List<Session>> fetchSessionsByDate(DateTime date) async {
    try {
      final formattedDate =
          "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final url = Uri.parse('$baseUrl/schedule/$formattedDate');
      print('📡 Sending GET request to: $url');

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionsData = data['data'];
        if (sessionsData == null) {
          print('Warning: data["data"] is null');
          return [];
        }

        return (sessionsData as List).map((json) => _sessionFromJson(json)).toList();
      } else {
        print('⚠️ No sessions found for date: $formattedDate');
        return [];
      }
    } catch (e) {
      print('Error in fetchSessionsByDate: $e');
      throw Exception('Error fetching sessions: $e');
    }
  }



  /// Helper to parse a session from JSON
  Session _sessionFromJson(dynamic json) {
    final startTime = json['start_time']?.toString() ?? '00:00:00';
    return Session(
      id: json['id'].toString(),
      date: json['date'].toString(),
      duration: json['duration'] is int
          ? json['duration'] as int
          : int.tryParse(json['duration'].toString()) ?? 0,
      startTime: startTime,
      taskId: json['task_id']?.toString() ?? '',
    );
  }





















  
}
