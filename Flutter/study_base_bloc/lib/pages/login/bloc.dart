import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/page/bloc.dart';
import 'event.dart';
import 'state.dart';

class LoginBloc extends PageBloc<LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginEvent>(_onLoginEvent);
  }

  void _onLoginEvent(LoginEvent event, Emitter<LoginState> emit) async {
    add(SetLoadingEvent(isLoading: true));
    await Future.delayed(const Duration(seconds: 2));
    add(SetLoadingEvent(isLoading: false));
  }
}
