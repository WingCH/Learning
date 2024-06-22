import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event.dart';

part 'state.dart';

class CommonPageBloc<State extends CommonPageState> extends Bloc<CommonPageEvent, State> {
  CommonPageBloc(super.initialState) {
    on<SetLoadingEvent>(_onSetLoadingEvent);
  }

  void _onSetLoadingEvent(SetLoadingEvent event, Emitter<State> emit) {
    emit(state.copyWith(isLoading: event.isLoading) as State);
  }
}
