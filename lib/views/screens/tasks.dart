import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/services/task_service.dart';
import 'package:intl/intl.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../widgets/task_card.dart';
import 'add_task.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';
import 'notification_screen.dart';
import '../widgets/rescheduling_card.dart';
import 'package:frontend/models/task.dart';
import '../widgets/task_detail_modal.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showRescheduledOnly = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc(TaskService())..add(LoadTasks()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F6F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2F6F7),
          centerTitle: true,
          elevation: 0,
          title: const Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text(
              "Your Tasks",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () {
                  // Navigate to the notification screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NotificationScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
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

            final allTasks = state.tasks;
            final displayedTasks = allTasks.where((task) {
              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                if (!task.title.toLowerCase().contains(query) &&
                    !task.category.toLowerCase().contains(query)) {
                  return false;
                }
              }
              // Apply reschedule filter if active
              if (_showRescheduledOnly && !task.toReschedule) {
                return false;
              }
              return true;
            }).toList();

            return Column(
              children: [
                const SizedBox(height: 20),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search tasks...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Filter buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterButton(
                        'All Tasks',
                        !_showRescheduledOnly,
                        () => setState(() => _showRescheduledOnly = false),
                      ),
                      const SizedBox(width: 10),
                      _buildFilterButton(
                        'To Be Rescheduled',
                        _showRescheduledOnly,
                        () => setState(() => _showRescheduledOnly = true),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Task List or Empty State
                Expanded(
                  child: displayedTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No tasks found for "$_searchQuery"'
                                    : 'No tasks found',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedTasks.length,
                          itemBuilder: (context, index) {
                            final task = displayedTasks[index];
                            return GestureDetector(
                              onTap: () {
                                if (task.toReschedule) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) {
                                      return ReschedulingCard(
                                        title: task.title,
                                        category: task.category,
                                        missedDate: DateFormat('MMM dd, yyyy').format(task.deadline),
                                        taskId: int.parse(task.id),
                                        onReschedule: () {
                                          Navigator.of(context).pop();
                                          context.read<TaskBloc>().add(LoadTasks());
                                        },
                                        onTaskDeleted: () {
                                          context.read<TaskBloc>().add(LoadTasks());
                                        },
                                      );
                                    },
                                  );
                                }
                                // else do nothing
                              },
                              child: TaskCard(
                                title: task.title,
                                category: task.category,
                                timeRange: '${task.duration} minutes',
                                date: DateFormat('MMM dd, yyyy').format(task.deadline),
                                status: task.status,
                                priority: task.priority,
                                duration: '${task.duration} minutes',
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTaskScreen()),
            );
          },
          backgroundColor: const Color(0xFF5E32E0),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5E32E0) : const Color(0xFFECE5FF),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF5E32E0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}