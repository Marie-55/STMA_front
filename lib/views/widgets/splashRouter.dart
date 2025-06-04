import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
import 'package:frontend/bloc/auth/auth_state.dart';
import 'package:frontend/views/screens/main_layout.dart';
import 'package:frontend/views/screens/welcome.dart';

class SplashRouter extends StatelessWidget {
  const SplashRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return MainLayout(); // user is logged in
        } else if (state is Unauthenticated) {
          return const WelcomeScreen(); // or LoginScreen()
        } else if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          // return const Scaffold(
          //   body: Center(child: Text('Unknown state')),
          // );
          return const WelcomeScreen(); // or LoginScreen()
        }
      },
    );
  }
}
