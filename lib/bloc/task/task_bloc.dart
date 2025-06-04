import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _taskService;

  TaskBloc(this._taskService) : super(TaskState.initial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadTasksToReschedule>(_onLoadTasksToReschedule);
    on<SearchTasks>(_onSearchTasks);
    on<CreateTask>(_onCreateTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final tasks = await _taskService.fetchAllTasks();
      emit(state.copyWith(
        isLoading: false,
        tasks: tasks.map((task) => Task.fromJson(task)).toList(),
      ));
    } catch (e) {
      print("lolaloal: $e");
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTasksToReschedule(
      LoadTasksToReschedule event, Emitter<TaskState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final tasks = await _taskService.fetchTasksToReschedule();
      emit(state.copyWith(
        isLoading: false,
        tasks: tasks.map((task) => Task.fromJson(task)).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSearchTasks(
      SearchTasks event, Emitter<TaskState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final tasks = await _taskService.searchTasks(event.query);
      emit(state.copyWith(
        isLoading: false,
        tasks: tasks.map((task) => Task.fromJson(task)).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      print('TaskBloc: Sending task to backend...');
      print('Task details:');
      print('- Title: ${event.task.title}');
      print('- Category: ${event.task.category}');
      print('- Deadline: ${event.task.deadline}');
      print('- Duration: ${event.task.duration}');
      print('- Priority: ${event.task.priority}');

      // Format the date as yyyy-MM-dd for the backend
      final formattedDeadline =
          event.task.deadline.toIso8601String().split('.').first;
      print('TaskBloc: Formatted deadline: $formattedDeadline');

      final newTask = await _taskService.createTask(
        title: event.task.title,
        category: event.task.category,
        deadline: formattedDeadline,
        duration: event.task.duration,
        priority: event.task.priority,
        isScheduled: event.task.isScheduled,
      );
      print('TaskBloc: Task created successfully in backend!');

      // Convert the new task to Task model and add it to the current state
      final taskModel = Task.fromJson(newTask);
      final updatedTasks = List<Task>.from(state.tasks)..add(taskModel);

      // Update the state with the new task list
      emit(state.copyWith(
        isLoading: false,
        tasks: updatedTasks,
      ));
      print('TaskBloc: Task list updated successfully!');
    } catch (e) {
      print('TaskBloc: Error creating task: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
