import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TaskService {
  static const String baseUrl = 'https://stma-back.onrender.com/api/tasks';

  Future<List<Map<String, dynamic>>> fetchAllTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/read/all'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tasksData = data['tasks'] as List;
        
        return tasksData.map((json) {
          return {
            'id': json['id']?.toString() ?? '',
            'title': json['title']?.toString() ?? '',
            'category': json['category']?.toString() ?? '',
            'deadline': json['deadline']?.toString() ?? DateTime.now().toIso8601String(),
            'duration': json['duration']?.toString() ?? '60',
            'priority': json['priority']?.toString() ?? 'Medium',
            'is_scheduled': json['is_scheduled'] ?? false,
            'is_synched': json['is_synched'] ?? false,
            'to_reschedule': json['to_reschedule'] ?? false,
            'user': json['user']?.toString() ?? '',
            'status': json['status']?.toString() ?? 'To-do',
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTasksToReschedule() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/read/to_reschedule'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['tasks']);
      } else {
        throw Exception('Failed to fetch tasks to reschedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks to reschedule: $e');
    }
  }

  Future<Map<String, dynamic>> addTask({
    required String title,
    required String category,
    required String deadline,
    required String duration,
    required String priority,
    bool isScheduled = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/write/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'category': category,
          'deadline': deadline,
          'duration': duration,
          'priority': priority,
          'is_scheduled': isScheduled,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add task');
      }
    } catch (e) {
      throw Exception('Error adding task: $e');
    }
  }

  Future<Map<String, dynamic>> createTask({
    required String title,
    required String category,
    required String deadline,
    required int duration,
    required String priority,
    bool isScheduled = false,
  }) async {
    try {
      print('TaskService: Creating task with following data:');
      print('Title: $title');
      print('Category: $category');
      print('Deadline: $deadline');
      print('Duration: $duration minutes');
      print('Priority: $priority');
      
      final response = await http.post(
        Uri.parse('$baseUrl/write/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'category': category,
          'deadline': deadline,
          'duration': duration.toString(),
          'priority': priority,
          'is_scheduled': isScheduled,
          'to_reschedule': false,
          'is_synched': false,
          'status': 'To Do',
          'user': 'test@gmail.com'
        }),
      );

      print('TaskService: Response status code: ${response.statusCode}');
      print('TaskService: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      print('TaskService ERROR: $e');
      throw Exception('Error creating task: $e');
    }
  }

  Future<Map<String, dynamic>> fetchTaskById(String taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/read/all'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tasksData = data['tasks'] as List;
        // Find the task with matching ID
        final taskData = tasksData.firstWhere(
          (task) => task['id'].toString() == taskId,
          orElse: () => null,
        );

        if (taskData != null) {
          return {
            'title': taskData['title'].toString(),
            'category': taskData['category'].toString(),
            'priority': taskData['priority'].toString(),
            'status': taskData['status']?.toString() ?? 'To-do',
            'deadline': taskData['deadline'].toString(),
          };
        } else {
          throw Exception('Task not found');
        }
      } else {
        throw Exception('Failed to fetch task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching task: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchTasks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/$query'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tasksData = data['tasks'] as List;
        
        return tasksData.map((json) {
          // Format date
          final date = json['deadline'].toString();
          DateTime parsedDate;
          
          try {
            parsedDate = DateTime.parse(date);
          } catch (_) {
            final format = DateFormat('EEE, dd MMM yyyy HH:mm:ss z');
            parsedDate = format.parse(date);
          }
          
          final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

          return {
            'title': json['title'].toString(),
            'category': json['category'].toString(),
            'date': formattedDate,
            'status': json['status'].toString(),
            'to_reschedule': json['to_reschedule'] ?? false,
            'priority': json['priority']?.toString() ?? 'Medium',
            'duration': json['duration']?.toString() ?? '60',
            'id': json['id']?.toString() ?? '',
            'is_scheduled': json['is_scheduled'] ?? false,
            'is_synched': json['is_synched'] ?? false,
            'user': json['user']?.toString() ?? '',
          };
        }).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to search tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching tasks: $e');
    }
  }
}