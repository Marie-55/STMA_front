// screens/pomodoro_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/pomodoro/pomodoro_bloc.dart';
import '../../bloc/pomodoro/pomodoro_state.dart';
import '../../bloc/pomodoro/pomodoro_event.dart';


class PomodoroSettingsScreen extends StatelessWidget {
  const PomodoroSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PomodoroBloc, PomodoroState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Pomodoro Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 48), // For layout balance
                    ],
                  ),

                  SizedBox(height: 24),
                  Text(
                    'Timer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Focus Time Dropdown
                  _buildSettingsDropdown(
                    context: context,
                    label: 'Focus Time',
                    value: '${state.settings.focusTime} min',
                    options: _getFocusTimeOptions(),
                    onChanged: (String value) {
                      final minutes = int.parse(value.split(' ')[0]);
                      final newSettings = state.settings.copyWith(focusTime: minutes);
                      context.read<PomodoroBloc>().add(UpdateSettings(newSettings));
                    },
                    expanded: false,
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Short Break Dropdown
                  _buildSettingsDropdown(
                    context: context,
                    label: 'Short Break',
                    value: '${state.settings.shortBreak} min',
                    options: _getShortBreakOptions(),
                    onChanged: (String value) {
                      final minutes = int.parse(value.split(' ')[0]);
                      final newSettings = state.settings.copyWith(shortBreak: minutes);
                      context.read<PomodoroBloc>().add(UpdateSettings(newSettings));
                    },
                    expanded: false,
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Long Break Dropdown
                  _buildSettingsDropdown(
                    context: context,
                    label: 'Long Break',
                    value: '${state.settings.longBreak} min',
                    options: _getLongBreakOptions(),
                    onChanged: (String value) {
                      final minutes = int.parse(value.split(' ')[0]);
                      final newSettings = state.settings.copyWith(longBreak: minutes);
                      context.read<PomodoroBloc>().add(UpdateSettings(newSettings));
                    },
                    expanded: false,
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Long Break Interval Dropdown
                  _buildSettingsDropdown(
                    context: context,
                    label: 'Long Break Interval',
                    value: '${state.settings.longBreakInterval} intervals',
                    options: _getLongBreakIntervalOptions(),
                    onChanged: (String value) {
                      final intervals = int.parse(value.split(' ')[0]);
                      final newSettings = state.settings.copyWith(longBreakInterval: intervals);
                      context.read<PomodoroBloc>().add(UpdateSettings(newSettings));
                    },
                    expanded: false,
                  ),

                  // Space for bottom navbar (not implemented per request)
                  Spacer(),
                  SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
    required bool expanded,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: expanded
          ? _buildExpandedDropdown(label, value, options, onChanged)
          : _buildCollapsedDropdown(label, value, options, onChanged),
    );
  }

  Widget _buildCollapsedDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFDACDFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Text(value),
              SizedBox(width: 4),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFFDACDFF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Text(value),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_up),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFDACDFF),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: options.map((option) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(option),
                        child: Text(option),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<String> _getFocusTimeOptions() {
    return ['25 min', '26 min', '27 min', '28 min'];
  }

  List<String> _getShortBreakOptions() {
    return ['3 min', '4 min', '5 min', '6 min', '7 min'];
  }

  List<String> _getLongBreakOptions() {
    return ['15 min', '20 min', '25 min', '30 min'];
  }

  List<String> _getLongBreakIntervalOptions() {
    return ['2 intervals', '3 intervals', '4 intervals', '5 intervals'];
  }
}