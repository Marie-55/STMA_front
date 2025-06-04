// // // // import 'package:frontend/services/session_service.dart';

// // // // void main() async {
// // // //   final sessionService = SessionService();
// // // //   try {
// // // //     final sessions = await sessionService.fetchAllSessions(1); // or any user_id
// // // //     print('Fetched sessions:');
// // // //     for (var session in sessions) {
// // // //       print(session);
// // // //     }
// // // //   } catch (e) {
// // // //     print('Error: $e');
// // // //   }
// // // // }


// // // import 'package:frontend/services/session_service.dart';

// // // void main() async {
// // //   final sessionService = SessionService();
// // //   final testDate = DateTime(2025, 6, 10); // Change to any date you want to test

// // //   try {
// // //     final sessions = await sessionService.fetchSessionsByDate(testDate);
// // //     print('Fetched sessions for $testDate:');
// // //     for (var session in sessions) {
// // //       print(session);
// // //     }
// // //   } catch (e) {
// // //     print('Error: $e');
// // //   }
// // // }



// // import 'dart:convert';
// // import 'package:http/http.dart' as http;

// // Future<bool> createFixedSession(Map<String, dynamic> data) async {
// //   try {
// //     final url = 'http://127.0.0.1:5000/api/fixedSession/create';
// //     final response = await http.post(
// //       Uri.parse(url),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode(data),
// //     );
// //     if (response.statusCode == 200 || response.statusCode == 201) {
// //       print("Created fixed session");
// //       return true;
// //     } else {
// //       print("Failed to create fixed session: ${response.body}");
// //       return false;
// //     }
// //   } catch (e) {
// //     print('Error creating fixed session: $e');
// //     return false;
// //   }
// // }

// // void main() async {
// //   final data = {
// //     "title": "Test Fixed Session",
// //     "day_index": 2,
// //     "duration": 0.5, // 30 min
// //     "start_time": "10:00",
// //     "user_id": 1,
// //   };

// //   final result = await createFixedSession(data);
// //   print('Result: $result');
// // }

// import 'dart:convert';
// import 'dart:ffi';
// import 'package:http/http.dart' as http;

// class FixedSession {
//   final int id;
//   final String title;
//   final int day_index;
//   final double duration;
//   final String start_time;
//   final int user_id;

//   FixedSession({
//     required this.id,
//     required this.title,
//     required this.day_index,
//     required this.duration,
//     required this.start_time,
//     required this.user_id,
//   });

//   factory FixedSession.fromJson(Map<String, dynamic> json) {
//     return FixedSession(
//     id: int.parse(json['id'].toString()),
//     title: json['title'],
//     day_index: int.parse(json['day_index'].toString()),
//     duration: (json['duration'] as num).toDouble(),
//     start_time: json['start_time'],
//     user_id: int.parse(json['user_id'].toString()),
//   );
//   }

//   @override
//   String toString() {
//     return 'FixedSession(id: $id, title: $title, day_index: $day_index, duration: $duration, start_time: $start_time, user_id: $user_id)';
//   }
// }

// Future<List<List<FixedSession>>> fetchWeeklyFixedSessions(int user_id) async {
//   final url = Uri.parse('http://127.0.0.1:5000/api/fixedSession/user/$user_id');
//   final response = await http.get(url);

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       final sessions = (data['data'] as List)
//           .map((json) => FixedSession.fromJson(json))
//           .toList();

//       // Group sessions by day_index (0-6)
//       List<List<FixedSession>> result = List.generate(7, (_) => []);
//       for (var session in sessions) {
//         final dayIndex = session.day_index;
//         if (dayIndex >= 0 && dayIndex < 7) {
//           result[dayIndex].add(session);
//         }
//       }
//       return result;
//     }
//   }
//   throw Exception('Failed to fetch weekly fixed sessions');
// }

// void main() async {
//   try {
//     final weeklySessions = await fetchWeeklyFixedSessions(1);
//     for (int i = 0; i < weeklySessions.length; i++) {
//       print('Day $i:');
//       for (var session in weeklySessions[i]) {
//         print('  ${session.toString()}');
//       }
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }




import '../views/widgets/weekly_schedule_grid.dart';
void main() async {
  // Create an instance of your state class
  final state = _WeeklyScheduleGridState();

  // Call the fetch function directly
  final result = await state.fetchWeeklyAllSessions();

  print('Weekly Sessions:');
  print(result['sessions']);

  print('Weekly Fixed Sessions:');
  print(result['fixed']);
}