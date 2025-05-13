import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigateToTab>(_onNavigateToTab);
  }

  void _onNavigateToTab(NavigateToTab event, Emitter<NavigationState> emit) {
    emit(state.copyWith(selectedIndex: event.index));
  }
}
