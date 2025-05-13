import 'package:flutter_bloc/flutter_bloc.dart';

part 'task_category_event.dart';
part 'task_category_state.dart';

class TaskCategoryBloc extends Bloc<TaskCategoryEvent, TaskCategoryState> {
  TaskCategoryBloc() : super(TaskCategoryState(selectedIndex: 0)) {
    on<TaskCategoryEvent>(_onTaskCategoryEvent);
  }

  void _onTaskCategoryEvent(TaskCategoryEvent event, Emitter<TaskCategoryState> emit) {
    emit(state.copyWith(selectedIndex: event.index));
  }
}
