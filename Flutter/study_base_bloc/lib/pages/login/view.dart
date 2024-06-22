import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/page/view.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginBloc(),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    final bloc = BlocProvider.of<LoginBloc>(context);

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return BasePage(
          isLoading: state.isLoading,
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
                if (!bloc.state.isLoading) {
                  bloc.add(LoginEvent());
                }
              },
              tooltip: 'Login',
              child: const Icon(Icons.login),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ),
        );
      },
    );
  }
}
