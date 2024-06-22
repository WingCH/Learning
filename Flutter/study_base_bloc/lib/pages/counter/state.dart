import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  final bool isLoading;

  final int counter;

  const CounterState({
    this.isLoading = false,
    this.counter = 0,
  });

  CounterState copyWith({
    bool? isLoading,
    int? counter,
  }) {
    return CounterState(
      isLoading: isLoading ?? this.isLoading,
      counter: counter ?? this.counter,
    );
  }

  @override
  List<Object> get props => [isLoading, counter];
}
