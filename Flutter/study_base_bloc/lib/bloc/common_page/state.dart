part of 'bloc.dart';

abstract class CommonPageState extends Equatable {
  final bool isLoading;
  final Optional<String?> routeName;

  const CommonPageState({this.isLoading = false, this.routeName = Optional.empty});

  CommonPageState copyWith({
    bool? isLoading,
    Optional<String?>? routeName,
  });

  @override
  List<Object?> get props => [isLoading, routeName];
}
