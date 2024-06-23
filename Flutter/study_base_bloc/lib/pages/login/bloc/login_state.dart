part of 'login_bloc.dart';

class LoginState extends CommonPageState {
  const LoginState({
    super.isLoading,
    super.routeName,
  });

  @override
  LoginState copyWith({
    bool? isLoading,
    Optional<String?>? routeName,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      routeName: routeName ?? this.routeName,
    );
  }

  @override
  List<Object> get props => [isLoading, routeName];
}
