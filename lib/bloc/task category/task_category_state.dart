part of 'task_category_bloc.dart';

class TaskCategoryState {
  final int selectedIndex;

  TaskCategoryState({required this.selectedIndex});

  TaskCategoryState copyWith({int? selectedIndex}) {
    return TaskCategoryState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
