// blocs/pomodoro_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import './pomodoro_event.dart';
import './pomodoro_state.dart';


class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  Timer? _timer;

  PomodoroBloc() : super(PomodoroState.initial()) {
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResetTimer>(_onResetTimer);
    on<UpdateSettings>(_onUpdateSettings);
    on<TimerTick>(_onTimerTick);
  }

  void _onStartTimer(StartTimer event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    emit(state.copyWith(status: TimerStatus.running));
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final newRemainingSeconds = state.remainingSeconds - 1;
      if (newRemainingSeconds <= 0) {
        _handleTimerComplete(emit);
      } else {
        add(TimerTick(newRemainingSeconds));
      }
    });
  }

  void _onPauseTimer(PauseTimer event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    emit(state.copyWith(status: TimerStatus.paused));
  }

  void _onResetTimer(ResetTimer event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    emit(state.copyWith(
      remainingSeconds: state.settings.focusTime * 60,
      status: TimerStatus.initial,
    ));
  }

  void _onUpdateSettings(UpdateSettings event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    emit(PomodoroState(
      settings: event.settings,
      remainingSeconds: event.settings.focusTime * 60,
      status: TimerStatus.initial,
    ));
  }

  void _onTimerTick(TimerTick event, Emitter<PomodoroState> emit) {
    emit(state.copyWith(remainingSeconds: event.remainingSeconds));
  }

  void _handleTimerComplete(Emitter<PomodoroState> emit) {
    _cancelTimer();
    emit(state.copyWith(
      status: TimerStatus.finished,
      completedPomodoros: state.completedPomodoros + 1,
      remainingSeconds: state.settings.focusTime * 60,
    ));
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}