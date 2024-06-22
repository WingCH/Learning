import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CounterBloc(),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    final bloc = BlocProvider.of<CounterBloc>(context);

    return Stack(
      children: [
        Scaffold(
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
        BlocSelector<CounterBloc, CounterState, bool>(
            selector: (state) => state.isLoading,
            builder: (context, isLoading) {
              if (isLoading) {
                return Container(
                  color: Colors.grey.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            })
      ],
    );
  }
}
