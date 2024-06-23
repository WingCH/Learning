part of '{name}[-s]_bloc.dart';

class {name}[-C]State extends CommonPageState {
  const {name}[-C]State({
    super.isLoading,
    super.routeName,
  });

  @override
  {name}[-C]State copyWith({
    bool? isLoading,
    Optional<String?>? routeName,
  }) {
    return {name}[-C]State(
      isLoading: isLoading ?? this.isLoading,
      routeName: routeName ?? this.routeName,
    );
  }

  @override
  List<Object> get props => [isLoading, routeName];
}
