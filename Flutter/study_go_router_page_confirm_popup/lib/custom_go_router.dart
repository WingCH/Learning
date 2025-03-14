import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_go_router_page_confirm_popup/build_context_ext.dart';

class CustomGoRouter extends GoRouter {
  CustomGoRouter({
    required List<RouteBase> routes,
    GoRouterRedirect? redirect,
    super.initialLocation,
    super.observers,
    super.navigatorKey,
  }) : super.routingConfig(
          routingConfig: _ConstantRoutingConfig(
            RoutingConfig(
              routes: routes,
              redirect: redirect ?? (_, __) => null,
            ),
          ),
        );

  // Getter methods for navigation state
  List<RouteMatch> get matches => routerDelegate.currentConfiguration.matches;
  RouteMatch? get currentMatch => matches.lastOrNull;
  String? get currentPage => currentMatch?.matchedLocation;
  
  // Helper method to get current context
  BuildContext? get _currentContext => configuration.navigatorKey.currentContext;
  
  // Helper method to check if current page needs confirmation
  bool get _isCurrentPageRequiringConfirmation => currentPage == '/pageA';



  @override
  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    debugPrint('Attempting to push: $location from $currentPage');

    if (_isCurrentPageRequiringConfirmation) {
      final context = _currentContext;
      if (context == null) return Future.value(null);

      return context.showNavigationConfirmDialog<T>(
        title: '確認導航',
        content: '你確定要離開當前頁面嗎？\nTrigger by GoRouter.push',
        onConfirm: () => super.push<T>(location, extra: extra),
      );
    } else {
      return super.push(location, extra: extra);
    }
  }

  @override
  void pop<T extends Object?>([T? result]) {
    debugPrint('Attempting to pop from $currentPage');
    
    final context = _currentContext;
    if (context == null) return;
    
    if (_isCurrentPageRequiringConfirmation) {
      context.showNavigationConfirmDialog<T>(
        title: '確認返回',
        content: '你確定要離開當前頁面嗎？\nTrigger by GoRouter.pop',
        onConfirm: () => super.pop(result),
      );
    } else {
      super.pop(result);
    }
  }
}

class _ConstantRoutingConfig extends ValueListenable<RoutingConfig> {
  const _ConstantRoutingConfig(this.value);

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  final RoutingConfig value;
}
