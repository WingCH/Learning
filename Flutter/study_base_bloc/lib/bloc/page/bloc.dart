import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


// Event
abstract class PageEvent extends Equatable {}

class SetLoadingEvent extends PageEvent {
  final bool isLoading;

  SetLoadingEvent({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

// State
abstract class PageState extends Equatable {
  final bool isLoading;

  const PageState({this.isLoading = false});

  PageState copyWith({
    bool? isLoading,
  });
}

// Bloc
class PageBloc<State extends PageState> extends Bloc<PageEvent, State> {
  PageBloc(super.initialState) {
    on<SetLoadingEvent>(_onSetLoadingEvent);
  }

  void _onSetLoadingEvent(SetLoadingEvent event, Emitter<State> emit) {
    emit(state.copyWith(isLoading: event.isLoading) as State);
  }
}
