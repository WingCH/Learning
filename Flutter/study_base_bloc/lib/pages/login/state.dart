import '../../bloc/common_page/bloc.dart';
import '../../models/optional.dart';

class LoginState extends CommonPageState {
  final String username;
  final String password;

  const LoginState({
    super.isLoading,
    super.routeName,
    this.username = '',
    this.password = '',
  });

  @override
  LoginState copyWith({
    bool? isLoading,
    Optional<String?>? routeName,
    String? username,
    String? password,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      routeName: routeName ?? this.routeName,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [isLoading, routeName, username, password];
}
