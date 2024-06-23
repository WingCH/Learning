import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/common_page/view.dart';
import 'bloc/{name}[-c]_bloc.dart';

class {name}[-C]PageArguments {}

class {name}[-C]Page extends StatelessWidget {
  const {name}[-C]Page({super.key});

  static const routeName = '/{name}[-c]';

  static Route<void> route(RouteSettings settings) {
    final arguments = settings.arguments as {name}[-C]PageArguments?;
    return CupertinoPageRoute(
      builder: (context) {
        return const {name}[-C]Page();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<{name}[-C]Bloc>(
          create: (context) => {name}[-C]Bloc(),
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
    final bloc = BlocProvider.of<{name}[-C]Bloc>(context);

    return CommonPage<{name}[-C]Bloc, {name}[-C]State>(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("{name}[-C] Page"),
        ),
        body: BlocConsumer<{name}[-C]Bloc, {name}[-C]State>(
          listener: (context, state) {},
          builder: (context, state) {
            return Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        '{name}[-C]',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
