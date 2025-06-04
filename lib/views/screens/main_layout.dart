import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/custom_bottom_nav.dart';
import 'package:frontend/bloc/navigation/navigation_bloc.dart';
import 'package:frontend/bloc/navigation/navigation_event.dart';
import 'package:frontend/bloc/session/session_bloc.dart';
import 'package:frontend/bloc/date/date_bloc.dart';
import 'package:frontend/services/session_service.dart';
import 'package:frontend/services/task_service.dart';
import 'package:frontend/bloc/task/task_bloc.dart';
import 'package:frontend/bloc/task/task_event.dart';
import '../widgets/add_task_modal.dart';
import 'home.dart';
import 'tasks.dart';
import 'profile_screen.dart';
//import 'notification_screen.dart';
import 'welcome.dart';
import 'signup.dart';
import 'login.dart';
//import 'notes_screen.dart';
//import 'profile_screen.dart';

class MainLayout extends StatelessWidget {
  MainLayout({super.key});

  final List<Widget> _screens = [
    const HomeScreen(),
    const TasksScreen(),
    Container(), // Placeholder for FAB
    Container(), // Notes screen placeholder
    const ProfileScreen(),
    const SignupScreen(), // index 4 - Profile
    const LoginScreen(), // index 5
    const WelcomeScreen(),

    const LoginScreen(), // index 5
    const SignupScreen(), // index 4 - Profile
    // const NotesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationBloc()),
        BlocProvider(create: (context) => SessionBloc(SessionService())),
        BlocProvider(create: (context) => DateBloc()),
        BlocProvider(
          create: (context) => TaskBloc(TaskService())..add(LoadTasks()),
          lazy: false,
        ),
      ],
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            body: IndexedStack(
              index: state.selectedIndex,
              children: _screens,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: const AddTaskModal(),
                    );
                  },
                );
              },
              backgroundColor: const Color(0xFF5E32E0),
              elevation: 4,
              highlightElevation: 8,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                size: 32,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: const CustomBottomNavBar(),
          );
        },
      ),
    );
  }
}
