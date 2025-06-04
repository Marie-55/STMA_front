// blocs/pomodoro_state.dart
import '../../models/pomodoro_settings.dart';
enum TimerStatus { initial, running, paused, finished }

class PomodoroState {
  final PomodoroSettings settings;
  final TimerStatus status;
  final int remainingSeconds;
  final int completedPomodoros;

  PomodoroState({
    required this.settings,
    this.status = TimerStatus.initial,
    this.remainingSeconds = 0,
    this.completedPomodoros = 0,
  });

  factory PomodoroState.initial() {
    final settings = PomodoroSettings();
    return PomodoroState(
      settings: settings,
      remainingSeconds: settings.focusTime * 60,
    );
  }

  PomodoroState copyWith({
    PomodoroSettings? settings,
    TimerStatus? status,
    int? remainingSeconds,
    int? completedPomodoros,
  }) {
    return PomodoroState(
      settings: settings ?? this.settings,
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
    );
  }

  String get timeLeftString {
    final minutes = (remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}