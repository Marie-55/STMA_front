// auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/auth_repo.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.login(event.email, event.password);
        emit(Authenticated());
      } catch (e) {
        emit(Unauthenticated());
      }
    });

    on<SignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signup(event.email, event.password);
        emit(Authenticated());
      } catch (e) {
        emit(Unauthenticated());
      }
    });

    on<LoginSuccessEvent>((event, emit) {
      emit(Authenticated());
    });
  }
}
