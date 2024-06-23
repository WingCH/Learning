part of 'home_bloc.dart';

class HomeState extends CommonPageState {
  const HomeState({
    super.isLoading,
    super.routeName,
  });

  @override
  HomeState copyWith({
    bool? isLoading,
    Optional<String?>? routeName,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      routeName: routeName ?? this.routeName,
    );
  }

  @override
  List<Object> get props => [isLoading, routeName];
}
