import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/common_page/bloc.dart';
import '../../../models/optional.dart';
import '../../counter/counter_page.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends CommonPageBloc<LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginSubmitEvent>(_onLoginSubmitEvent);
    on<LoginSuccessEvent>(_onLoginSuccessEvent);
  }

  void _onLoginSubmitEvent(LoginSubmitEvent event, Emitter<LoginState> emit) async {
    add(SetLoadingEvent(isLoading: true));
    await Future.delayed(const Duration(seconds: 5));
    add(SetLoadingEvent(isLoading: false));
    add(LoginSuccessEvent());
  }

  void _onLoginSuccessEvent(LoginSuccessEvent event, Emitter<LoginState> emit) {
    add(SetRouteNameEvent(routeName: const Optional(CounterPage.routeName)));
  }
}
