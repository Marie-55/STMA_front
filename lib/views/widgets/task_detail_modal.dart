import 'package:flutter/material.dart';

class TaskDetailModal extends StatelessWidget {
  final String title;
  final String category;
  final String timeRange;
  final String date;
  final String status;
  final String priority;
  final String duration;
  final int progressPercentage;
  final ScrollController scrollController;

  const TaskDetailModal({
    Key? key,
    required this.title,
    required this.category,
    required this.timeRange,
    required this.date,
    required this.status,
    required this.priority,
    required this.duration,
    this.progressPercentage = 0,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time range and status indicators
          Row(
            children: [
              Container(
                  child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: Color(0xFF5E32E0),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    timeRange,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 158, 154, 167),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )),
              const Spacer(),
              
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: _getPriorityTextColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusTextColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Task title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 2),

          // Category
          Text(
            category,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // Deadline
          Row(
            children: [
              Container(
                child: Icon(
                  Icons.calendar_month,
                  color: Color(0xFF5E32E0),
                  size: 35,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Deadline",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Duration
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E32E0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_filled,
                  color: Color(0xFF5E32E0),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Duration",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress bar
          Center(
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                color: const Color(0xAA8F70EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width:
                            constraints.maxWidth * (progressPercentage / 100),
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E32E0).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Text(
                        "$progressPercentage%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Status and Priority Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getPriorityColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: _getPriorityTextColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusTextColor().withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      status.toLowerCase().contains('done') ? Icons.check_circle_outline :
                      status.toLowerCase().contains('progress') ? Icons.refresh :
                      Icons.schedule,
                      size: 16,
                      color: _getStatusTextColor(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color: _getStatusTextColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Start Study session button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Add logic to start a study session
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E32E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Start Study session",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Color _getStatusColor() {
    switch (status) {
      case 'Done':
        return const Color(0xFFE8F5E9); // Light green background
      case 'In Progress':
        return const Color(0xFFFFF3E0); // Light orange background
      default:
        return const Color(0xFFE3F2FD); // Light blue background
    }
  }

  Color _getStatusTextColor() {
    switch (status) {
      case 'Done':
        return const Color(0xFF43A047); // Darker green text
      case 'In Progress':
        return const Color(0xFFF57C00); // Darker orange text
      default:
        return const Color(0xFF1976D2); // Darker blue text
    }
  }
}
