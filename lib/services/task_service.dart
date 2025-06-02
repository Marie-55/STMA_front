import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TaskService {
  //static const String baseUrl = 'https://stma-back.onrender.com/api/tasks';
  static const String baseUrl = 'http://127.0.0.1:5000/api/tasks';




// Work : ALready tested and working
/// Function to create a new task for a specific user 
  Future<Map<String, dynamic>> createTask({
    required String title,
    required String category,
    required String deadline,
    required int duration,
    required String priority,
    bool isScheduled = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'category': category,
          'deadline': deadline,
          'duration': duration.toString(),
          'priority': priority,
          'is_scheduled': isScheduled,
          'is_synched': false,
          'to_reschedule': false,
          'user': 1,   //need to change this to dynamic user id
          'status': 'To Do',
          
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating task: $e');
    }
  }

// Not Working ( tested, url working, my be problem back end ) / Always return empty list
/// function to fetch all tasks for a specific user
  Future<List<Map<String, dynamic>>> fetchAllTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/1'), // by user id 
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tasksData = data['data'] as List;

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



// depends on fetchAllTasks
/// function to fetch tasks that need to be rescheduled
  Future<List<Map<String, dynamic>>> fetchTasksToReschedule() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user/1'), // assuming this returns all tasks
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tasksData = (data['data'] ?? []) as List;

      return tasksData.where((json) => json['to_reschedule'] == true).map((json) {
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
    throw Exception('Error fetching tasks to reschedule: $e');
  }
}


// The route is not implemented in the backend, so this function will not work until the backend is updated
  Future<List<Map<String, dynamic>>> searchTasks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tasksData = data['tasks'] as List;

        return tasksData.map((json) {
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


// the route is not implemented in the backend, so this function will not work until the backend is updated
  Future<Map<String, dynamic>> deleteTaskById(int  taskId) async {
   final url = Uri.parse('$baseUrl/tasks/delete/$taskId');
  final response = await http.delete(url, headers: {'Content-Type': 'application/json'});

  if (response.statusCode == 200) {
    return {'success': true};
  } else {
    String message = 'Failed to delete task.';
    try {
      final errorBody = json.decode(response.body);
      message = errorBody['error'] ?? message;
    } catch (_) {}
    return {'success': false, 'message': message};
  }
 }



// not working ( tested, the problem is with the taskid, in the firebase it is a string, but here it is an int )
 Future<Map<String, dynamic>> fetchTaskById(String taskId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/$taskId'),  // Use the updated route to fetch task by ID
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final taskData = data['task'];

      if (taskData != null) {
        return {
          'id': taskData['id'].toString(),
          'title': taskData['title'].toString(),
          'category': taskData['category'].toString(),
          'priority': taskData['priority'].toString(),
          'status': taskData['status']?.toString() ?? 'To-do',
          'deadline': taskData['deadline'].toString(),
          'duration': taskData['duration']?.toString() ?? '60',
          'is_scheduled': taskData['is_scheduled'] ?? false,
          'is_synched': taskData['is_synched'] ?? false,
          'to_reschedule': taskData['to_reschedule'] ?? false,
          'user': taskData['user']?.toString() ?? '',
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


// not woorking, depends on fetchTaskById
Future<String> fetchTaskTitle(String taskId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/$taskId'),  // Use the appropriate API endpoint
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final taskData = data['task'];

      if (taskData != null) {
        return taskData['title'].toString();  // Return the task's title
      } else {
        throw Exception('Task not found');
      }
    } else {
      throw Exception('Failed to fetch task title: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching task title: $e');
  }
}


}
