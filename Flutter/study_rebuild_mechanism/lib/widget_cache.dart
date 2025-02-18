import 'package:flutter/material.dart';

class WidgetCache<T> extends StatefulWidget {
  const WidgetCache({
    super.key,
    required this.value,
    required this.builder,
  });

  final T value;
  final Widget Function(BuildContext context, T value) builder;

  @override
  WidgetCacheState<T> createState() => WidgetCacheState<T>();
}

class WidgetCacheState<T> extends State<WidgetCache<T>> {
  Widget? cache;
  T? previousValue;

  @override
  Widget build(BuildContext context) {
    print('WidgetCache build cache: ${cache}, previousValue: $previousValue');
    if (identical(widget.value, previousValue) == false) {
      previousValue = widget.value;
      cache = Builder(
        builder: (context) => widget.builder(context, widget.value),
      );
    }
    return cache ?? const SizedBox.shrink();
  }
}
