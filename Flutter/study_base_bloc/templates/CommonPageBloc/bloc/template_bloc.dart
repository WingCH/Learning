import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/common_page/bloc.dart';
import '../../../models/optional.dart';

part '{name}[-s]_event.dart';
part '{name}[-s]_state.dart';

class {name}[-C]Bloc extends CommonPageBloc<{name}[-C]State> {
  {name}[-C]Bloc() : super(const {name}[-C]State()) {
    on<{name}[-C]Event>(_on{name}[-C]Event);
  }

  void _on{name}[-C]Event({name}[-C]Event event, Emitter<{name}[-C]State> emit) async {}
}
