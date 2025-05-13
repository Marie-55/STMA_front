// screens/study_session_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/pomodoro/pomodoro_bloc.dart';
import '../../bloc/pomodoro/pomodoro_state.dart';
import '../../bloc/pomodoro/pomodoro_event.dart';
import './pomodoro_settings_screen.dart';

class StudySessionScreen extends StatelessWidget {
  const StudySessionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PomodoroBloc, PomodoroState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Study Session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          final pomodoroBloc = context.read<PomodoroBloc>(); // ✅ SAFELY get the bloc

                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return BlocProvider.value(
                                value: pomodoroBloc,
                                child: const PomodoroSettingsScreen(),
                              );
                            },
                          );
                        },

                      ),
                    ],
                  ),
                  
                  Expanded(
                    child: Center(
                      child: _buildTimerCircle(state),
                    ),
                  ),
                  
                  // Controls
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            context.read<PomodoroBloc>().add(ResetTimer());
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      _buildPlayPauseButton(context, state),
                      SizedBox(width: 20),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: IconButton(
                          icon: Icon(Icons.music_note),
                          onPressed: () {
                            // Implementation for sound management
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Space for bottom navbar (not implemented per request)
                  SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTimerCircle(PomodoroState state) {
    return Container(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: CircularProgressIndicator(
              value: state.remainingSeconds / (state.settings.focusTime * 60),
              strokeWidth: 10,
              backgroundColor: Colors.deepPurple.withOpacity(0.2),
              color: Colors.deepPurple,
            ),
          ),
          Text(
            state.timeLeftString,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, PomodoroState state) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        icon: Icon(
          state.status == TimerStatus.running ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 32,
        ),
        onPressed: () {
          if (state.status == TimerStatus.running) {
            context.read<PomodoroBloc>().add(PauseTimer());
          } else {
            context.read<PomodoroBloc>().add(StartTimer());
          }
        },
      ),
    );
  }
}