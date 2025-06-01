import 'package:flutter/material.dart';
import 'package:frontend/views/screens/notification_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/views/widgets/weekly_schedule_grid.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl package to pubspec.yaml
import 'package:frontend/views/widgets/add_fixed_session.dart';


class TimetableHeader extends StatelessWidget {
  const TimetableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current date
    final now = DateTime.now();
    final formattedMonthYear = DateFormat.yMMMM().format(now).toUpperCase(); // "APRIL 2025"

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0), // Only top and bottom padding
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          formattedMonthYear,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            showDialog(
    context: context,
    builder: (BuildContext context) {
      return const AddFixedSession(); // Your card widget
    },
  );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:  const Color(0xFF5E32E0), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          child: const Text(
            'Edit Timetable',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ], ),
    ),);
  }
}












class WeeklyTimetable extends StatelessWidget {
  const WeeklyTimetable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: const Color(0xFFF2F6F7),
          centerTitle: true,
          elevation: 0,
          title: const Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text(
              "TimeTable",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () {
                  // Navigate to the notification screen
                  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: BlocProvider.of<NavigationBloc>(context),
      child: NotificationScreen(),
    ),
  ),
);

                },
              ),
            ),
          ],
        ),
      body: Column(
        children: [
          TimetableHeader(),
         
          Expanded(
            child: WeeklyScheduleGrid(
  startHour: 6,
  endHour: 22,
)
            )
         


        ],
      ),
    );
  }
} 