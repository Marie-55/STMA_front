import '../../models/session.dart';

class SessionState {
  final List<Session> allSessions;
  final String selectedDate;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.allSessions = const [],
    this.selectedDate = '',
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    List<Session>? allSessions,
    String? selectedDate,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      allSessions: allSessions ?? this.allSessions,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Get sessions for the selected date
  List<Session> get sessions => allSessions.where((session) => session.date == selectedDate).toList();
}
