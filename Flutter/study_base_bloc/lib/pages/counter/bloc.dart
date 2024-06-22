import 'package:flutter_bloc/flutter_bloc.dart';

import 'event.dart';
import 'state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState()) {
    on<LoadingEvent>(_onLoadingEvent);
    on<IncrementEvent>(_onIncrementEvent);
  }

  void _onLoadingEvent(LoadingEvent event, Emitter<CounterState> emit) async {
    emit(state.copyWith(isLoading: event.isLoading));
  }

  void _onIncrementEvent(IncrementEvent event, Emitter<CounterState> emit) async {
    add(LoadingEvent(isLoading: true));
    await Future.delayed(const Duration(seconds: 2));
    add(LoadingEvent(isLoading: false));
    emit(state.copyWith(counter: state.counter + 1));
  }
}
