// blocs/pomodoro_event.dart
import '../../models/pomodoro_settings.dart';

abstract class PomodoroEvent {}

class StartTimer extends PomodoroEvent {}

class PauseTimer extends PomodoroEvent {}

class ResetTimer extends PomodoroEvent {}

class UpdateSettings extends PomodoroEvent {
  final PomodoroSettings settings;

  UpdateSettings(this.settings);
}

class TimerTick extends PomodoroEvent {
  final int remainingSeconds;

  TimerTick(this.remainingSeconds);
}