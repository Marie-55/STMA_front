import 'package:flutter/material.dart';
import 'package:frontend/models/fixedsession.dart';
import 'package:frontend/models/task.dart';
import 'package:frontend/services/task_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/session_service.dart';
import '../../models/session.dart';

class WeeklyScheduleGrid extends StatefulWidget {
  final int startHour;
  final int endHour;

  const WeeklyScheduleGrid({
    Key? key,
    this.startHour = 6,
    this.endHour = 22,
  }) : super(key: key);

  @override
  State<WeeklyScheduleGrid> createState() => _WeeklyScheduleGridState();
}

class _WeeklyScheduleGridState extends State<WeeklyScheduleGrid> {
  late Future<Map<String, dynamic>> _weeklyAllSessionsFuture;

  @override
  void initState() {
    super.initState();
    _weeklyAllSessionsFuture = fetchWeeklyAllSessions();
  }

  List<DateTime> getCurrentWeekDates() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;

    DateTime startOfWeek = now.subtract(Duration(days: currentWeekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

 
  Future<List<List<Session>>> fetchWeeklySessions() async {
    List<List<Session>> allWeekSessions = [];
    List<DateTime> weekDates = getCurrentWeekDates();
    final sessionService = SessionService();

    for (final date in weekDates) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      print('\n Grid: Fetching sessions for date: $formattedDate');

      final rawSessions = await sessionService.fetchSessionsByDate(date);
      print('Grid: Raw sessions received: ${jsonEncode(rawSessions)}');

      final filtered = rawSessions.where((session) {
        final sessionDateStr = session.date.toString();
        try {
          DateTime sessionDate = DateFormat("yyyy-MM-dd").parse(sessionDateStr);
          return sessionDate.year == date.year && sessionDate.month == date.month && sessionDate.day == date.day;
        } catch (e) {
          print("Grid: Date parsing failed for session: $session");
          return false;
        }
      }).toList();

      allWeekSessions.add(filtered);
      print('Grid: Finished processing ${filtered.length} valid session(s) for that day.');
    }

    print('\n Grid: Finished fetching sessions for all days.');
    return allWeekSessions;
  }


Future<List<List<FixedSession>>> fetchWeeklyFixedSessionsForUser(int userId) async {
  userId = 1; // Hardcoded user_id for testing
  print('Grid : Fetching weekly fixed sessions for user ID: $userId');
  final result = await fetchWeeklyFixedSessions(userId);
  print('Grid : Fetched weekly fixed sessions: $result');
  print('Grid : Done fetching weekly fixed sessions.');
  return result;
}

  Future<Map<String, dynamic>> fetchWeeklyAllSessions() async {
    final weeklySessions = await fetchWeeklySessions();
    final weeklyFixedSessions = await fetchWeeklyFixedSessionsForUser(1); // Hardcoded user_id for testing
    return {
      'sessions': weeklySessions,
      'fixed': weeklyFixedSessions,
    };
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getCurrentWeekDates();
    final totalHours = widget.endHour - widget.startHour;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final timeCellWidth = screenWidth * 0.16;
    final timeCellHeight = screenHeight * 0.09;
    final dayLabelWidth = screenWidth * 0.08;
    final dayLabelHeight = timeCellHeight * 0.9;

    return FutureBuilder<Map<String, dynamic>>(
      future: _weeklyAllSessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // final weeklySessions = snapshot.data?['sessions'] ?? [];
        // final weeklyFixedSessions = snapshot.data?['fixed'] ?? [];

        final weeklySessions = snapshot.data?['sessions'] as List<List<Session>>? ?? [];
        final weeklyFixedSessions = snapshot.data?['fixed'] as List<List<FixedSession>>? ?? [];

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Column(
                  children: [
                    SizedBox(height: timeCellHeight),
                    ...weekDates.map((date) {
                      final dayLetter = DateFormat.E().format(date).substring(0, 1);
                      final dayNum = date.day;
                      return Container(
                        width: dayLabelWidth,
                        height: dayLabelHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBCAEF2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$dayLetter\n$dayNum',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 50, 49, 49),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(totalHours, (index) {
                        final hour = widget.startHour + index;
                        final label = DateFormat.j().format(DateTime(0, 0, 0, hour));
                        return Container(
                          width: timeCellWidth,
                          height: timeCellHeight,
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }),
                    ),
                    Stack(
                      children: [
                        Column(
                          children: List.generate(7, (dayIndex) {
                            return Row(
                              children: List.generate(totalHours, (hourIndex) {
                                return Container(
                                  width: timeCellWidth,
                                  height: timeCellHeight,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                                      bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                                    ),
                                    color: Color(0xFFF8F9FB),
                                  ),
                                );
                              }),
                            );
                          }),
                        ),
                        // ...weeklySessions.expand((sessionsForDay) => sessionsForDay.map((session)  {
                        //   return sessionsForDay.map((session) {
                        //     DateTime sessionDate = DateFormat("yyyy-MM-dd").parse(session.date);
                        //     int dayIndex = weekDates.indexWhere((d) =>
                        //         d.year == sessionDate.year &&
                        //         d.month == sessionDate.month &&
                        //         d.day == sessionDate.day);

                        //     TimeOfDay startTime = TimeOfDay(
                        //         hour: int.parse(session.startTime.split(':')[0]),
                        //         minute: int.parse(session.startTime.split(':')[1]));

                        //     int startOffset = startTime.hour - widget.startHour;
                        //     int duration = session.duration;

                        //     if (dayIndex < 0 || startOffset < 0 || startOffset >= totalHours) {
                        //       return const SizedBox.shrink();
                        //     }

                        //     return Positioned(
                        //       left: startOffset * timeCellWidth,
                        //       top: dayIndex * timeCellHeight,
                        //       width: timeCellWidth * (duration / 60),
                        //       height: timeCellHeight,
                        //       child: FutureBuilder<String>(
                        //         future: fetchTaskTitle(session.taskId),
                        //         builder: (context, taskSnapshot) {
                        //           final taskTitle = taskSnapshot.data ?? "No task found";
                        //           return Container(
                        //             margin: const EdgeInsets.all(6),
                        //             padding: const EdgeInsets.all(6),
                        //             decoration: BoxDecoration(
                        //               color: Color(0xFFA892EE),
                        //               borderRadius: BorderRadius.circular(13),
                        //             ),
                        //             child: Column(
                        //               mainAxisAlignment: MainAxisAlignment.center,
                        //               crossAxisAlignment: CrossAxisAlignment.center,
                        //               children: [
                        //                 Text(
                        //                   taskTitle,
                        //                   style: const TextStyle(
                        //                     color: Colors.black,
                        //                     fontSize: 12,
                        //                     fontWeight: FontWeight.w600,
                        //                   ),
                        //                   overflow: TextOverflow.ellipsis,
                        //                   maxLines: 1,
                        //                 ),
                        //                 SizedBox(height: 4),
                        //                 Text(
                        //                   ' ${session.duration} min ',
                        //                   style: const TextStyle(
                        //                     color: Color(0xFF6E6A7C),
                        //                     fontSize: 10,
                        //                   ),
                        //                   overflow: TextOverflow.ellipsis,
                        //                   maxLines: 1,
                        //                 ),
                        //               ],
                        //             ),
                        //           );
                        //         },
                        //       ),
                        //     );
                        //   });
                        // })).toList(),
                     
                     
//                      ...weeklySessions.expand((sessionsForDay) => sessionsForDay.map((session) {
//   DateTime sessionDate = DateFormat("yyyy-MM-dd").parse(session.date);
//   int dayIndex = weekDates.indexWhere((d) =>
//       d.year == sessionDate.year &&
//       d.month == sessionDate.month &&
//       d.day == sessionDate.day);

//   TimeOfDay startTime = TimeOfDay(
//       hour: int.parse(session.startTime.split(':')[0]),
//       minute: int.parse(session.startTime.split(':')[1]));

//   int startOffset = startTime.hour - widget.startHour;
//   int duration = session.duration;

//   if (dayIndex < 0 || startOffset < 0 || startOffset >= totalHours) {
//     return const SizedBox.shrink();
//   }
// final Future<String> taskTitleFuture = fetchTaskTitle(session.taskId);
//   return Positioned(
//     left: startOffset * timeCellWidth,
//     top: dayIndex * timeCellHeight,
//     width: timeCellWidth * (duration / 60),
//     height: timeCellHeight,
//     child: FutureBuilder<String>(
//       future:  taskTitleFuture,
//       builder: (context, taskSnapshot) {
//         final taskTitle = taskSnapshot.data ?? "No task found";


        
//         return Container(
//           margin: const EdgeInsets.all(6),
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: Color(0xFFA892EE),
//             borderRadius: BorderRadius.circular(13),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 taskTitle,
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//               ),
//               SizedBox(height: 4),
//               Text(
//                 ' ${session.duration} min ',
//                 style: const TextStyle(
//                   color: Color(0xFF6E6A7C),
//                   fontSize: 10,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//               ),
//             ],
//           ),
//         );
//       },
//     ),
//   );
// })),
                     
                     
                     
                     
                     ...weeklySessions.expand((sessionsForDay) => sessionsForDay.map((session) {
  DateTime sessionDate = DateFormat("yyyy-MM-dd").parse(session.date);
  int dayIndex = weekDates.indexWhere((d) =>
      d.year == sessionDate.year &&
      d.month == sessionDate.month &&
      d.day == sessionDate.day);

  TimeOfDay startTime = TimeOfDay(
      hour: int.parse(session.startTime.split(':')[0]),
      minute: int.parse(session.startTime.split(':')[1]));

  int startOffset = startTime.hour - widget.startHour;
  int duration = session.duration;

  if (dayIndex < 0 || startOffset < 0 || startOffset >= totalHours) {
    return const SizedBox.shrink();
  }

  // Store the future in a variable for clarity and debugging
  final Future<String> taskTitleFuture = fetchTaskTitle(session.taskId);

  return Positioned(
    left: startOffset * timeCellWidth,
    top: dayIndex * timeCellHeight,
    width: timeCellWidth * (duration / 60),
    height: timeCellHeight,
    child: FutureBuilder<String>(
      future: taskTitleFuture,
      builder: (context, taskSnapshot) {
        // Debug print for state and data
        print('FutureBuilder for taskId ${session.taskId}: state=${taskSnapshot.connectionState}, data=${taskSnapshot.data}, error=${taskSnapshot.error}');
        if (taskSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)));
        } else if (taskSnapshot.hasError) {
          return Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(0xFFA892EE),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              'Error: ${taskSnapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else if (taskSnapshot.hasData) {
          return Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(0xFFA892EE),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  taskSnapshot.data!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  ' ${session.duration} min ',
                  style: const TextStyle(
                    color: Color(0xFF6E6A7C),
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          );
        } else {
          return const Text('No title');
        }
      },
    ),
  );
})).toList(),
                     
...weeklyFixedSessions.expand((sessionsForDay) => sessionsForDay.map((session) {
  // Use day_index directly (0 for Monday, 6 for Sunday)
  int dayIndex = session.day_index;

  // Parse start_time (HH:MM)
  TimeOfDay startTime = TimeOfDay(
    hour: int.parse(session.start_time.split(':')[0]),
    minute: int.parse(session.start_time.split(':')[1]),
  );

  int startOffset = startTime.hour - widget.startHour;
  double durationInMinutes = session.duration * 60; // duration is in hours

  if (dayIndex < 0 || dayIndex >= weekDates.length || startOffset < 0 || startOffset >= totalHours) {
    return const SizedBox.shrink();
  }

  return Positioned(
    left: startOffset * timeCellWidth,
    top: dayIndex * timeCellHeight,
    width: timeCellWidth * (durationInMinutes / 60),
    height: timeCellHeight,
    child: Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Color(0xFF6ED2F0),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.blueAccent, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            session.title, // <-- Use the title directly!
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: 4),
          Text(
            ' ${durationInMinutes.toInt()} min ',
            style: const TextStyle(
              color: Color(0xFF6E6A7C),
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            'Fixed',
            style: TextStyle(
              color: Colors.blue[900],
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
})).toList(),
                      
                      
                      
                      
                      
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> fetchTaskTitle(String taskId) async {
    try {
      print('Fetching task title for task ID: $taskId');
      final task = await TaskService().fetchTaskById(taskId);
      final taskTitle = task?['title'] ?? "No title available";
      print('Fetched task title: $taskTitle');
      return taskTitle;
    } catch (e) {
      print("Error fetching task title: $e");
      return "Error fetching title";
    }
  }
}

