import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../services/task_service.dart';
import '../../bloc/session/session_bloc.dart';
import '../../bloc/session/session_event.dart';
import '../../bloc/session/session_state.dart';
import '../../bloc/date/date_bloc.dart';
import '../../models/session.dart';
import '../widgets/task_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/notification_screen.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionService _sessionService = SessionService();
  final TaskService _taskService = TaskService();
  
  // Cache for task details to avoid repeated API calls
  final Map<String, Map<String, dynamic>> _taskCache = {};
  
  // Selected filter state
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Initialize the session bloc with the current date
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    context.read<SessionBloc>().add(SessionEvent(
      Session(
        id: '',
        date: formattedDate,
        duration: 0,
        startTime: '',
        taskId: '',
      ),
    ));
  }

  // Fetch task details and cache them
  Future<Map<String, dynamic>> _getTaskDetails(String taskId) async {
    if (_taskCache.containsKey(taskId)) {
      return _taskCache[taskId]!;
    }
    
    try {
      print('1.... Fetching task details for ID: $taskId'); // Debug print
      final taskDetails = await _taskService.fetchTaskById(taskId);
      _taskCache[taskId] = taskDetails;
      return taskDetails;
    } catch (e) {
      print('Error fetching task details: $e'); // Debug print
      return {
        'title': 'Task $taskId',
        'category': 'General',
        'priority': 'Medium',
        'status': 'Scheduled'
      };
    }
  }

  // Build filter chip widget
  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5E32E0) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen build called');
    return BlocProvider(
      create: (context) => SessionBloc(_sessionService),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          centerTitle: true,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: const Text(
              "Daily Sessions",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () {
                  context.read<NavigationBloc>().add(NavigateToTab(2));
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10),
              
              // Date selector
              Container(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<DateBloc, DateState>(
                  builder: (context, state) {
                    final selectedDate = state.selectedDate;
                    final days = _generateDaysAround(selectedDate);
                    
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: days.map((date) {
                          final isSelected = date.day == selectedDate.day &&
                              date.month == selectedDate.month &&
                              date.year == selectedDate.year;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () {
                                context.read<DateBloc>().add(DateEvent(date));
                                // Fetch sessions for the selected date
                                final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                context.read<SessionBloc>().add(SessionEvent(
                                  Session(
                                    id: '',
                                    date: formattedDate,
                                    duration: 0,
                                    startTime: '',
                                    taskId: '',
                                  ),
                                ));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF5E32E0) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getMonthName(date.month),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _getDayName(date.weekday),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              // Filter tabs
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterChip('All', _selectedFilter == 'All'),
                        _buildFilterChip('Done', _selectedFilter == 'Done'),
                        _buildFilterChip('To-do', _selectedFilter == 'To-do'),
                        _buildFilterChip('In Progress', _selectedFilter == 'In Progress'),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Session list
              Expanded(
                child: BlocBuilder<SessionBloc, SessionState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.error != null) {
                      return Center(
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    return BlocBuilder<DateBloc, DateState>(
                      builder: (context, dateState) {
                        print('DateBloc builder called');
                        final selectedDate = dateState.selectedDate;
                        print('Selected date: $selectedDate');

                        return FutureBuilder<List<Session>>(
  future: _sessionService.fetchSessionsByDate(selectedDate),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text(
          'Error: ${snapshot.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(
        child: Text('No sessions for this day'),
      );
    } else {
      final sessions = snapshot.data!;

      // Filter sessions based on _selectedFilter
      List<Session> filteredSessions = sessions;
      if (_selectedFilter != 'All') {
        filteredSessions = sessions.where((session) {
          final taskStatus = _taskCache[session.taskId]?['status']?.toString().toLowerCase();
          return taskStatus == _selectedFilter.toLowerCase();
        }).toList();
      }

      return ListView.builder(
        shrinkWrap: true,
        itemCount: filteredSessions.length,
        itemBuilder: (context, index) {
          final session = filteredSessions[index];
          return FutureBuilder<Map<String, dynamic>>(
            future: _getTaskDetails(session.taskId),
            builder: (context, taskSnapshot) {
              if (!taskSnapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final taskDetails = taskSnapshot.data!;
              return TaskCard(
                title: taskDetails['title'] ?? 'Session ${session.id}',
                category: taskDetails['category'] ?? '',
                timeRange: session.startTime,
                date: session.date,
                status: taskDetails['status'] ?? '',
                priority: taskDetails['priority']?.toString() ?? '',
                duration: '${session.duration} min',
              );
            },
          );
        },
      );
    }
  },
);

                      
                      
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DateTime> _generateDaysAround(DateTime selectedDate) {
    final days = <DateTime>[];
    final DateTime start = selectedDate.subtract(const Duration(days: 2));
    for (int i = 0; i < 5; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }

  String _getMonthName(int month) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    final days = [
       'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];
    return days[weekday - 1];
  }


}
