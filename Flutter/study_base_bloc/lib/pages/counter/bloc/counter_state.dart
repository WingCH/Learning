part of 'counter_bloc.dart';

class CounterState extends CommonPageState {
  final int counter;

  const CounterState({
    super.isLoading,
    super.routeName,
    this.counter = 0,
  });

  @override
  CounterState copyWith({
    bool? isLoading,
    Optional<String?>? routeName,
    int? counter,
  }) {
    return CounterState(
      isLoading: isLoading ?? this.isLoading,
      routeName: routeName ?? this.routeName,
      counter: counter ?? this.counter,
    );
  }

  @override
  List<Object> get props => [isLoading, routeName, counter];
}
