import 'package:flutter/material.dart';
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
  late Future<Map<String, List<List<Session>>>> _weeklyAllSessionsFuture;

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

  Future<List<List<Session>>> fetchWeeklyFixedSessions() async {
    final url = Uri.parse('https://stma-back.onrender.com/api/fixedSession/user/1/week');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        // Ensure we always return 7 lists (one per day)
        final raw = data['data'] as List;
        List<List<Session>> result = List.generate(7, (i) => []);
        for (int i = 0; i < raw.length && i < 7; i++) {
          result[i] = (raw[i] as List).map((json) => Session.fromJson(json)).toList();
        }
        return result;
      }
    }
    throw Exception('Failed to fetch weekly fixed sessions');
  }

  Future<List<List<Session>>> fetchWeeklySessions() async {
    List<List<Session>> allWeekSessions = [];
    List<DateTime> weekDates = getCurrentWeekDates();
    final sessionService = SessionService();

    for (final date in weekDates) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      print('\nFetching sessions for date: $formattedDate');

      final rawSessions = await sessionService.fetchSessionsByDate(date);
      print('Raw sessions received: ${jsonEncode(rawSessions)}');

      final filtered = rawSessions.where((session) {
        final sessionDateStr = session.date.toString();
        try {
          DateTime sessionDate = DateFormat("yyyy-MM-dd").parse(sessionDateStr);
          return sessionDate.year == date.year && sessionDate.month == date.month && sessionDate.day == date.day;
        } catch (e) {
          print("Date parsing failed for session: $session");
          return false;
        }
      }).toList();

      allWeekSessions.add(filtered);
      print('Finished processing ${filtered.length} valid session(s) for that day.');
    }

    print('\nFinished fetching sessions for all days.');
    return allWeekSessions;
  }

  Future<Map<String, List<List<Session>>>> fetchWeeklyAllSessions() async {
    final weeklySessions = await fetchWeeklySessions();
    final weeklyFixedSessions = await fetchWeeklyFixedSessions();
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

    return FutureBuilder<Map<String, List<List<Session>>>>(
      future: _weeklyAllSessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final weeklySessions = snapshot.data?['sessions'] ?? [];
        final weeklyFixedSessions = snapshot.data?['fixed'] ?? [];

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
                        ...weeklySessions.expand((sessionsForDay) {
                          return sessionsForDay.map((session) {
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

                            return Positioned(
                              left: startOffset * timeCellWidth,
                              top: dayIndex * timeCellHeight,
                              width: timeCellWidth * (duration / 60),
                              height: timeCellHeight,
                              child: FutureBuilder<String>(
                                future: fetchTaskTitle(session.taskId),
                                builder: (context, taskSnapshot) {
                                  final taskTitle = taskSnapshot.data ?? "No task found";
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
                                          taskTitle,
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
                                },
                              ),
                            );
                          });
                        }).toList(),
                        ...weeklyFixedSessions.expand((sessionsForDay) {
                          return sessionsForDay.map((session) {
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

                            return Positioned(
                              left: startOffset * timeCellWidth,
                              top: dayIndex * timeCellHeight,
                              width: timeCellWidth * (duration / 60),
                              height: timeCellHeight,
                              child: FutureBuilder<String>(
                                future: fetchTaskTitle(session.taskId),
                                builder: (context, taskSnapshot) {
                                  final taskTitle = taskSnapshot.data ?? "No task found";
                                  return Container(
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
                                          taskTitle,
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
                                          ' ${session.duration} min ',
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
                                  );
                                },
                              ),
                            );
                          });
                        }).toList(),
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

