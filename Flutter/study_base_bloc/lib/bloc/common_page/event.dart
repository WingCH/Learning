part of 'bloc.dart';

abstract class CommonPageEvent extends Equatable {}

class SetLoadingEvent extends CommonPageEvent {
  final bool isLoading;

  SetLoadingEvent({required this.isLoading});

  @override
  List<Object> get props => [isLoading];
}

class SetRouteNameEvent extends CommonPageEvent {
  final Optional<String>? routeName;

  SetRouteNameEvent({required this.routeName});

  @override
  List<Object?> get props => [routeName];
}
