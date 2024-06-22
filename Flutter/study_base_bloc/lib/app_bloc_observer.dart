import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template counter_observer}
/// [BlocObserver] for the counter application which
/// observes all state changes.
/// {@endtemplate}
class AppBlocObserver extends BlocObserver {
  /// {@macro counter_observer}
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // ignore: avoid_print
    print('${bloc.runtimeType} $change');
  }
}
