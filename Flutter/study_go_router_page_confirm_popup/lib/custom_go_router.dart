import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_go_router_page_confirm_popup/services/navigation_confirmation_service.dart';

class CustomGoRouter extends GoRouter {
  CustomGoRouter({
    required List<RouteBase> routes,
    GoRouterRedirect? redirect,
    super.initialLocation,
    super.observers,
    super.navigatorKey,
    required NavigationConfirmationService confirmationService,
  })  : _confirmationService = confirmationService,
        super.routingConfig(
          routingConfig: _ConstantRoutingConfig(
            RoutingConfig(
              routes: routes,
              redirect: redirect ?? (_, __) => null,
            ),
          ),
        ) {
    
    // 註冊路由變更監聽器
    routerDelegate.addListener(_onRouteChange);
  }

  final NavigationConfirmationService _confirmationService;

  List<RouteMatch> get matches => routerDelegate.currentConfiguration.matches;

  // Helper method to get current context
  BuildContext? get _currentContext =>
      configuration.navigatorKey.currentContext;

  @override
  void dispose() {
    routerDelegate.removeListener(_onRouteChange);
    super.dispose();
  }

  void _onRouteChange() {
    _confirmationService.onRouteChange(routerDelegate.currentConfiguration);
  }

  @override
  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    final matches = routerDelegate.currentConfiguration.matches;
    final currentMatch = matches.lastOrNull;
    final currentPage = currentMatch?.matchedLocation;

    debugPrint('Attempting to push: $location from $currentPage');

    final context = _currentContext;
    if (context == null) return Future.value(null);

    // 檢查是否需要確認
    if (_confirmationService.shouldShowConfirmation(matches)) {
      final completer = Completer<T?>();
      _confirmationService.showConfirmationDialog(
        content: '你確定要離開當前頁面嗎？\nTrigger by GoRouter.push',
        onConfirm: () async {
          completer.complete(await super.push<T>(location, extra: extra));
        },
        onCancel: () {
          completer.complete(null);
        },
      );
      return completer.future;
    } else {
      return super.push<T>(location, extra: extra);
    }
  }

  @override
  void pop<T extends Object?>([T? result]) {
    final matches = routerDelegate.currentConfiguration.matches;
    final currentMatch = matches.lastOrNull;
    final currentPage = currentMatch?.matchedLocation;

    debugPrint('Attempting to pop from $currentPage');

    final context = _currentContext;
    if (context == null) return;

    // 檢查是否需要確認
    if (_confirmationService.shouldShowConfirmation(matches)) {
      _confirmationService.showConfirmationDialog(
        content: '你確定要離開當前頁面嗎？\nTrigger by GoRouter.pop',
        onConfirm: () {
          _confirmationService.setSkipNextRouteChangeChecking();
          super.pop(result);
        },
        onCancel: () {},
      );
    } else {
      super.pop(result);
    }
  }
}

/// Copy from go_router/lib/src/router.dart
/// A routing config that is never going to change.
class _ConstantRoutingConfig extends ValueListenable<RoutingConfig> {
  const _ConstantRoutingConfig(this.value);
  @override
  void addListener(VoidCallback listener) {
    // Intentionally empty because listener will never be called.
  }

  @override
  void removeListener(VoidCallback listener) {
    // Intentionally empty because listener will never be called.
  }

  @override
  final RoutingConfig value;
}