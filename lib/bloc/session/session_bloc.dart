import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/session.dart';
import '../../services/session_service.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionService _sessionService;

  SessionBloc(this._sessionService) : super(const SessionState()) {
    on<SessionEvent>(_onSessionEvent);
    
    // Fetch all sessions when the bloc is created
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Fetch all sessions
      final sessions = await _sessionService.fetchAllSessions();
      
      emit(
        state.copyWith(
          isLoading: false,
          allSessions: sessions,
          selectedDate: DateTime.now().toString().split(' ')[0],
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to fetch sessions: $e',
        ),
      );
    }
  }

  Future<void> _onSessionEvent(SessionEvent event, Emitter<SessionState> emit) async {
    // Update selected date without fetching again
    emit(
      state.copyWith(
        selectedDate: event.session.date,
      ),
    );
  }
}
