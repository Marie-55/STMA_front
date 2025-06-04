import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/task/task_bloc.dart';
import 'package:frontend/bloc/task/task_event.dart';
import 'package:frontend/models/task.dart';
import 'package:frontend/views/widgets/rescheduling_card.dart';
import 'package:intl/intl.dart';

import 'task_detail_modal.dart';

class TaskCard extends StatelessWidget {
  final String category;
  final String title;
  final String timeRange;
  final String date;
  final String status;
  final String priority;
  final String? duration;

  /// need to be added, loop on files and update the taskCard calls
  final bool toReschedule;
  final String id;

  const TaskCard({
    super.key,
    this.category = 'Studies',
    this.title = 'Time series analysis worksheet',
    this.timeRange = '05:00AM - 08:00AM',
    this.date = '05/03/2025',
    this.status = 'To-do',
    this.priority = 'Important',
    this.duration,
    this.toReschedule = false, // updates
    required this.id,

    /// updates
  });

  Color _getStatusColor() {
    switch (status) {
      case 'Done':
        return const Color(0xFFE8F5E9); // Light green background
      case 'In Progress':
        return const Color(0xFFFFF3E0); // Light orange background
      default:
        return const Color(
            0xFFE3F2FD); // Light blue background (for To-do and any other status)
    }
  }

  Color _getStatusTextColor() {
    switch (status) {
      case 'Done':
        return const Color(0xFF43A047); // Darker green text
      case 'In Progress':
        return const Color(0xFFF57C00); // Darker orange text
      default:
        return const Color(
            0xFF1976D2); // Darker blue text (for To-do and any other status)
    }
  }

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'important':
      case 'high':
      case 'urgent':
        return const Color(0xFFFFEBEE); // Light red background
      case 'medium':
      case 'normal':
        return const Color(0xFFFFF3E0); // Light orange background
      default:
        return const Color(0xFFE8F5E9); // Light green background
    }
  }

  Color _getPriorityTextColor() {
    switch (priority.toLowerCase()) {
      case 'important':
      case 'high':
      case 'urgent':
        return const Color(0xFFE53935); // Darker red text
      case 'medium':
      case 'normal':
        return const Color(0xFFF57C00); // Darker orange text
      default:
        return const Color(0xFF43A047); // Darker green text
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (toReschedule == 5) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return ReschedulingCard(
                title: title,
                category: category,
                missedDate: date,
                taskId: int.parse(id),
                onReschedule: () {
                  Navigator.of(context).pop();
                  context.read<TaskBloc>().add(
                      LoadTasks()); // dunno what is this problem with the read
                },
                onTaskDeleted: () {
                  context.read<TaskBloc>().add(LoadTasks());
                },
              );
            },
          );
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.3,
                maxChildSize: 0.95,
                expand: false,
                builder: (context, scrollController) {
                  return TaskDetailModal(
                    title: title,
                    category: category,
                    timeRange: timeRange,
                    date: date,
                    status: status,
                    priority: priority,
                    duration: duration ?? "3 hours",
                    scrollController: scrollController,
                  );
                },
              );
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusTextColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E32E0).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time_filled,
                      size: 14,
                      color: Color(0xFF5E32E0),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeRange,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E32E0).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      size: 14,
                      color: Color(0xFF5E32E0),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
