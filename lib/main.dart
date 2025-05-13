import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
import 'package:frontend/data/auth_repo.dart';
import 'package:frontend/bloc/navigation/navigation_bloc.dart';
import 'package:frontend/bloc/pomodoro/pomodoro_bloc.dart';
import 'views/screens/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        primaryColor: const Color(0xFF5E32E0),
        scaffoldBackgroundColor: const Color(0xFFF2F6F7),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<PomodoroBloc>(
            create: (context) => PomodoroBloc(),
          ),
          
          BlocProvider<NavigationBloc>(
            create: (context) => NavigationBloc(),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
                AuthRepository(baseUrl: "https://stma-back.onrender.com/api")),
          ),
        ],
        child: MainLayout(),
      ),
    );
  }
}
