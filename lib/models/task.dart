import 'package:intl/intl.dart';

class Task {
  final String id;
  final String title;
  final String category;
  final DateTime deadline;
  final int duration;
  final String priority;
  final bool isScheduled;
  final bool isSynched;
  final bool toReschedule;
  final String user;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.deadline,
    required this.duration,
    required this.priority,
    required this.isScheduled,
    required this.isSynched,
    required this.toReschedule,
    required this.user,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    DateTime parseDeadline(dynamic value) {
      if (value == null) return DateTime.now();
      
      try {
        if (value is String) {
          // Try different date formats
          try {
            return DateTime.parse(value);
          } catch (e) {
            // Try parsing Unix timestamp (milliseconds)
            final timestamp = int.tryParse(value);
            if (timestamp != null) {
              return DateTime.fromMillisecondsSinceEpoch(timestamp);
            }
            // Try custom format if needed
            final formats = [
              'yyyy-MM-dd',
              'yyyy-MM-dd HH:mm:ss',
              'MM/dd/yyyy',
              'dd/MM/yyyy',
            ];
            for (final format in formats) {
              try {
                return DateFormat(format).parse(value);
              } catch (_) {
                continue;
              }
            }
          }
        } else if (value is Map) {
          // Handle Firestore Timestamp
          if (value['_seconds'] != null) {
            return DateTime.fromMillisecondsSinceEpoch(value['_seconds'] * 1000);
          }
        } else if (value is int) {
          // Handle Unix timestamp
          return DateTime.fromMillisecondsSinceEpoch(value);
        }
      } catch (e) {
        print('Error parsing deadline: $e');
        print('Original value was: $value');
      }
      return DateTime.now();
    }

    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      deadline: parseDeadline(json['deadline']),
      duration: json['duration'] is String 
          ? int.tryParse((json['duration'] as String).replaceAll(RegExp(r'[^0-9]'), '')) ?? 60
          : json['duration'] is int 
              ? json['duration'] 
              : 60,
      priority: json['priority']?.toString() ?? 'Medium',
      isScheduled: json['is_scheduled'] ?? false,
      isSynched: json['is_synched'] ?? false,
      toReschedule: json['to_reschedule'] ?? false,
      user: json['user']?.toString() ?? '',
      status: json['status']?.toString() ?? 'To-do',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'deadline': deadline.toIso8601String(),
      'duration': duration,
      'priority': priority,
      'is_scheduled': isScheduled,
      'is_synched': isSynched,
      'to_reschedule': toReschedule,
      'user': user,
      'status': status,
    };
  }
}
