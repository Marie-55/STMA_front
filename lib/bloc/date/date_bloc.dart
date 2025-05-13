import 'package:flutter_bloc/flutter_bloc.dart';

part 'date_event.dart';
part 'date_state.dart';

class DateBloc extends Bloc<DateEvent, DateState> {
  DateBloc() : super(DateState(selectedDate: DateTime.now())) {
    on<DateEvent>(_onDateEvent);
  }

  void _onDateEvent(DateEvent event, Emitter<DateState> emit) {
    emit(state.copyWith(selectedDate: event.date));
  }
}
