import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/optional.dart';
import 'bloc.dart';

class CommonPage<B extends Bloc<CommonPageEvent, S>, S extends CommonPageState> extends StatelessWidget {
  final Widget child;

  const CommonPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, S>(
      listenWhen: (previous, current) {
        return previous.routeName != current.routeName;
      },
      listener: (context, state) {
        final routeName = state.routeName.raw;
        if (routeName != null) {
          Navigator.of(context).pushNamed(routeName);
          // reset routeName to null after navigating
          context.read<B>().add(
                SetRouteNameEvent(routeName: const Optional(null)),
              );
        }
      },
      buildWhen: (previous, current) {
        return previous.isLoading != current.isLoading;
      },
      builder: (context, state) {
        return Stack(
          children: [
            child,
            if (state.isLoading)
              Container(
                color: Colors.grey.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
