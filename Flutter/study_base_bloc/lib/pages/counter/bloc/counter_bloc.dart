import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/common_page/bloc.dart';
import '../../../models/optional.dart';

part 'counter_event.dart';

part 'counter_state.dart';

class CounterBloc extends CommonPageBloc<CounterState> {
  CounterBloc() : super(const CounterState()) {
    on<IncrementEvent>(_onIncrementEvent);
  }

  void _onIncrementEvent(IncrementEvent event, Emitter<CounterState> emit) async {
    add(SetLoadingEvent(isLoading: true));
    await Future.delayed(const Duration(seconds: 2));
    add(SetLoadingEvent(isLoading: false));
    emit(state.copyWith(counter: state.counter + 1));
  }
}
