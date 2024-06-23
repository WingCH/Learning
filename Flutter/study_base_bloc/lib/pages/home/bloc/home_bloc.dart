import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/common_page/bloc.dart';
import '../../../models/optional.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends CommonPageBloc<HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeEvent>(_onHomeEvent);
  }

  void _onHomeEvent(HomeEvent event, Emitter<HomeState> emit) async {}
}
