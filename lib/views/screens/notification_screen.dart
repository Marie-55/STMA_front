import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/notification_card.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the NavigationBloc from the main layout
    final navigationBloc = BlocProvider.of<NavigationBloc>(context, listen: false);
    
    // Static notification data
    final List<Map<String, dynamic>> notifications = [
      {
        'icon': Icons.access_time,
        'title': 'Upcoming Task Reminder',
        'content': "Hey! You've got Study for Math Quiz starting in 10 minutes.",
        'day': '2 days ago',
      },
      {
        'icon': Icons.task_alt,
        'title': 'Task Completion Reminder',
        'content': 'Did you finish your English essay? Mark it done to track your progress',
        'day': '5 days ago',
      },
      {
        'icon': Icons.insights,
        'title': 'Productivity Summary',
        'content': 'Nice work! You completed 4/5 tasks today',
        'day': '9 days ago',
      },
      {
        'icon': Icons.warning_amber_rounded,
        'title': 'Task Deadline Alert',
        'content': "You've got a deadline tomorrow for Security Project",
        'day': '13 days ago',
      },
      {
        'icon': Icons.psychology,
        'title': 'Gentle Nudges',
        'content': "We noticed you skipped 'Read History Chapter 3' again. Need help rescheduling?",
        'day': '4 days ago',
      },
      {
        'icon': Icons.emoji_events,
        'title': 'Goal Achievement',
        'content': "oohoo! You've completed all your tasks for the day! Time to celebrate.",
        'day': '1 week ago',
      },
    ];

    return BlocProvider.value(
      value: navigationBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Notification',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationCard(
                icon: notification['icon'],
                title: notification['title'],
                content: notification['content'],
                day: notification['day'],
                isRead: index > 1,
              );
            },
          ),
        ),
       
      ),
    );
  }
} 