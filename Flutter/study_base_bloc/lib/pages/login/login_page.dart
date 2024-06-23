import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/common_page/view.dart';
import 'bloc/login_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  static Route<void> route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (context) {
        return const LoginPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return _buildPage(context);
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    final bloc = BlocProvider.of<LoginBloc>(context);

    return CommonPage<LoginBloc, LoginState>(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Login Page"),
        ),
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {},
          builder: (context, state) {
            return const Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Login Form Goes Here'),
                      // Add your login form fields here
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            bloc.add(LoginSubmitEvent());
          },
          tooltip: 'Login',
          child: const Icon(Icons.login),
        ),
      ),
    );
  }
}
