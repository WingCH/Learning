import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/common_page/view.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  static const routeName = '/counter';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CounterBloc(),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    final bloc = BlocProvider.of<CounterBloc>(context);

    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        return CommonPage(
          isLoading: state.isLoading,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text("Counter Page"),
            ),
            body: BlocConsumer<CounterBloc, CounterState>(
              listener: (context, state) {},
              builder: (context, state) {
                return Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'You have pushed the button this many times:',
                          ),
                          Text(
                            state.counter.toString(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
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
                  bloc.add(IncrementEvent());
                }
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ),
        );
      },
    );
  }
}
