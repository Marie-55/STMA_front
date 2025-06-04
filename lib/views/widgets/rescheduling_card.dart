import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../services/task_service.dart';

class ReschedulingCard extends StatefulWidget {
  final String title;
  final String category;
  final String missedDate;
  final VoidCallback onReschedule;
  final int taskId;
  final VoidCallback onTaskDeleted;

  const ReschedulingCard({
    super.key,
    required this.title,
    required this.category,
    required this.missedDate,
    required this.taskId,
    required this.onReschedule,
    required this.onTaskDeleted,
  });

  @override
  State<ReschedulingCard> createState() => _ReschedulingCardState();
}

class _ReschedulingCardState extends State<ReschedulingCard> {
  bool _isDeleting = false;

  Future<void> _deleteTask(BuildContext context) async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    try {
      final taskService = TaskService(); // ✅ Instantiate the service
      final result = await taskService
          .deleteTaskById(widget.taskId); // ✅ Use the method from the instance

      if (result['success']) {
        widget.onTaskDeleted();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Failed to delete task.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }

    setState(() => _isDeleting = false);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: constraints.maxWidth < 340
                    ? constraints.maxWidth * 0.9
                    : 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    const SizedBox(height: 4),
                    Text(widget.category,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 15)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Color(0xFF5E32E0), size: 28),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Deadline Missed',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                            Text(widget.missedDate,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _isDeleting ? null : () => _deleteTask(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1EDFF),
                              foregroundColor: const Color(0xFF5E32E0),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _isDeleting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Text('Remove',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onReschedule,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E32E0),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Reschedule'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
