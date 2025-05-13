import '../../models/task.dart';

class TaskState {
  final bool isLoading;
  final List<Task> tasks;
  final String? error;

  const TaskState({
    required this.isLoading,
    required this.tasks,
    this.error,
  });

  factory TaskState.initial() {
    return const TaskState(
      isLoading: false,
      tasks: [],
      error: null,
    );
  }

  TaskState copyWith({
    bool? isLoading,
    List<Task>? tasks,
    String? error,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      error: error ?? this.error,
    );
  }
}
