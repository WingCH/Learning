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

  /// 處理需要確認的導航通用邏輯
  Future<T?> _handleNavigationWithConfirmation<T extends Object?>(
    String location,
    Object? extra,
    Future<T?> Function() superNavigationCall,
  ) {
    final matches = routerDelegate.currentConfiguration.matches;
    final currentMatch = matches.lastOrNull;
    final currentPage = currentMatch?.matchedLocation;

    debugPrint('Attempting to $location from $currentPage');

    final context = _currentContext;
    if (context == null) return Future.value(null);

    // 檢查是否需要確認
    if (_confirmationService.shouldShowConfirmation(matches)) {
      final completer = Completer<T?>();
      _confirmationService.showConfirmationDialog(
        content: '你確定要離開當前頁面嗎？\nTrigger by GoRouter.$location',
        onConfirm: () async {
          completer.complete(await superNavigationCall());
        },
        onCancel: () {
          completer.complete(null);
        },
      );
      return completer.future;
    } else {
      return superNavigationCall();
    }
  }

  @override
  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    return _handleNavigationWithConfirmation<T>(
      location,
      extra,
      () => super.push<T>(location, extra: extra),
    );
  }

  @override
  Future<T?> pushReplacement<T extends Object?>(String location, {Object? extra}) {
    return _handleNavigationWithConfirmation<T>(
      location,
      extra,
      () => super.pushReplacement<T>(location, extra: extra),
    );
  }

  @override
  void pop<T extends Object?>([T? result]) {
    // Use PopScope only can intercept `Navigator.maybePop`, cannot intercept `GoRouter.pop`, so we need to handle it manually
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