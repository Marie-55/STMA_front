import '../../models/task.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class LoadTasksToReschedule extends TaskEvent {}

class SearchTasks extends TaskEvent {
  final String query;
  SearchTasks(this.query);
}

class CreateTask extends TaskEvent {
  final Task task;
  CreateTask(this.task);
}
