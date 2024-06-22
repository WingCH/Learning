import '../../bloc/page/bloc.dart';

class LoginState extends PageState {
  final String username;
  final String password;

  const LoginState({
    super.isLoading,
    this.username = '',
    this.password = '',
  });

  @override
  LoginState copyWith({
    bool? isLoading,
    String? username,
    String? password,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  List<Object> get props => [isLoading, username, password];
}