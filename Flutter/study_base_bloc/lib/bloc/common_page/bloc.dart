import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/optional.dart';

part 'event.dart';

part 'state.dart';

class CommonPageBloc<State extends CommonPageState> extends Bloc<CommonPageEvent, State> {
  CommonPageBloc(super.initialState) {
    on<SetLoadingEvent>(_onSetLoadingEvent);
    on<SetRouteNameEvent>(_onSetRouteNameEvent);
  }

  void _onSetLoadingEvent(SetLoadingEvent event, Emitter<State> emit) {
    emit(state.copyWith(isLoading: event.isLoading) as State);
  }

  void _onSetRouteNameEvent(SetRouteNameEvent event, Emitter<State> emit) {
    emit(state.copyWith(routeName: event.routeName) as State);
    // reset routeName to null after navigating
    emit(state.copyWith(routeName: Optional.empty) as State);
  }
}
