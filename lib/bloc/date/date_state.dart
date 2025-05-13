part of 'date_bloc.dart';

class DateState {
  final DateTime selectedDate;

  DateState({required this.selectedDate});

  DateState copyWith({DateTime? selectedDate}) {
    return DateState(
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
