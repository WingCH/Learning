import 'package:equatable/equatable.dart';

abstract class CounterEvent extends Equatable {}

class LoadingEvent extends CounterEvent {
  final bool isLoading;

  LoadingEvent({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class IncrementEvent extends CounterEvent {
  @override
  List<Object> get props => [];
}
