class PomodoroSettings {
  final int focusTime; // in minutes
  final int shortBreak; // in minutes
  final int longBreak; // in minutes
  final int longBreakInterval; // number of pomodoros before long break

  PomodoroSettings({
    this.focusTime = 25,
    this.shortBreak = 5,
    this.longBreak = 20,
    this.longBreakInterval = 2,
  });

  PomodoroSettings copyWith({
    int? focusTime,
    int? shortBreak,
    int? longBreak,
    int? longBreakInterval,
  }) {
    return PomodoroSettings(
      focusTime: focusTime ?? this.focusTime,
      shortBreak: shortBreak ?? this.shortBreak,
      longBreak: longBreak ?? this.longBreak,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
    );
  }
}