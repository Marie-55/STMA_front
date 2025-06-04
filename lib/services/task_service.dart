import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TaskService {
  //static const String baseUrl = 'https://stma-back.onrender.com/api/tasks';
  static const String baseUrl = 'https://stma-back.onrender.com/api/tasks';
  final _storage = const FlutterSecureStorage();

  // Cache for tasks
  static Map<String, List<Map<String, dynamic>>> _tasksCache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);
  static DateTime? _lastCacheUpdate;

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<String?> _getUserId() async {
    final token = await _getToken();
    if (token != null) {
      try {
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        return decodedToken['user_id']?.toString();
      } catch (e) {
        print('Error decoding token: $e');
        throw Exception('Invalid token');
      }
    }
    throw Exception('No token found');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration;
  }

  void _updateCache(String key, List<Map<String, dynamic>> tasks) {
    _tasksCache[key] = tasks;
    _lastCacheUpdate = DateTime.now();
  }

  Future<List<Map<String, dynamic>>> fetchAllTasks() async {
    try {
      // Check cache first
      if (_isCacheValid() && _tasksCache.containsKey('all_tasks')) {
        return _tasksCache['all_tasks']!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/4'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Fetch tasks response status: ${response.statusCode}');
      print('Fetch tasks response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tasksData = data['data'] as List;
        final tasks = tasksData.map((json) {
          return {
            'id': json['id']?.toString() ?? '',
            'title': json['title']?.toString() ?? '',
            'category': json['category']?.toString() ?? '',
            'deadline': json['deadline']?.toString() ??
                DateTime.now().toIso8601String(),
            'duration': json['duration']?.toString() ?? '60',
            'priority': json['priority']?.toString() ?? 'Medium',
            'is_scheduled': json['is_scheduled'] ?? false,
            'is_synched': json['is_synched'] ?? false,
            'to_reschedule': json['to_reschedule'] ?? false,
            'user_id': json['user_id']?.toString() ?? '',
            'status': json['status']?.toString() ?? 'To-do',
          };
        }).toList();

        // Update cache
        _updateCache('all_tasks', tasks);
        return tasks;
      } else {
        throw Exception(
            'Failed to fetch tasks: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      throw Exception('Error fetching tasks: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTasksToReschedule() async {
    try {
      // Check cache first
      if (_isCacheValid() && _tasksCache.containsKey('to_reschedule')) {
        return _tasksCache['to_reschedule']!;
      }

      //final headers = await _getAuthHeaders();
      final userId = await _getUserId();
      final response = await http.get(
        Uri.parse('$baseUrl/user/4/to_reschedule'),
        //headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tasks = List<Map<String, dynamic>>.from(data['tasks']);

        // Update cache
        _updateCache('to_reschedule', tasks);
        return tasks;
      } else {
        throw Exception(
            'Failed to fetch tasks to reschedule: ${response.statusCode}');
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
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'category': category,
          'deadline': deadline,
          'duration': duration,
          'priority': priority,
          'user_id': '4',
          //'is_scheduled': isScheduled,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Task added successfully: ${response.body}');
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
          'to_reschedule': false,
          'is_synched': false,
          'status': 'To Do',
          'user_id': '4'
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);

        // Create a properly formatted task object
        final newTask = {
          'id': result['id']?.toString() ?? '',
          'title': title,
          'category': category,
          'deadline': deadline,
          'duration': duration.toString(),
          'priority': priority,
          'is_scheduled': isScheduled,
          'is_synched': false,
          'to_reschedule': false,
          'user_id': '4',
          'status': 'To Do',
        };

        // Update the cache by appending the new task
        if (_tasksCache.containsKey('all_tasks')) {
          final currentTasks =
              List<Map<String, dynamic>>.from(_tasksCache['all_tasks']!);
          currentTasks.add(newTask);
          _updateCache('all_tasks', currentTasks);
        }

        return newTask;
      } else {
        throw Exception(
            'Failed to create task: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error details: $e');
      throw Exception('Error creating task: $e');
    }
  }

  Future<Map<String, dynamic>> fetchTaskById(String taskId) async {
    try {
      //final headers = await _getAuthHeaders();
      //final userId = await _getUserId();
      final response = await http.get(
        Uri.parse('$baseUrl/user/4/task/$taskId'),
        //headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'title': data['title'].toString(),
          'category': data['category'].toString(),
          'priority': data['priority'].toString(),
          'status': data['status']?.toString() ?? 'To-do',
          'deadline': data['deadline'].toString(),
        };
      } else {
        throw Exception('Task not found');
      }
    } catch (e) {
      throw Exception('Error fetching task: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchTasks(String query) async {
    try {
      //final headers = await _getAuthHeaders();
      //final userId = await _getUserId();
      final response = await http.get(
        Uri.parse('$baseUrl/user/4/search/$query'),
        //headers: headers,
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

  Future<Map<String, dynamic>> deleteTaskById(int taskId) async {
    try {
      //final headers = await _getAuthHeaders();
      //final userId = await _getUserId();
      final response = await http.delete(
        Uri.parse('$baseUrl/user/4/task/$taskId'),
        //headers: headers,
      );

      if (response.statusCode == 200) {
        // Invalidate cache when deleting a task
        _tasksCache.clear();
        _lastCacheUpdate = null;
        return {'success': true};
      } else {
        String message = 'Failed to delete task.';
        try {
          final errorBody = json.decode(response.body);
          message = errorBody['error'] ?? message;
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
