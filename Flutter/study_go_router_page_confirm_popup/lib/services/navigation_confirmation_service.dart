import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_go_router_page_confirm_popup/build_context_ext.dart';

class NavigationConfirmationService {
  static const String _tag = 'NavigationConfirmationService';
  
  /// Routes that require confirmation before navigating away
  final Set<String> routesRequiringConfirmation = {'/pageA'};
  
  final GlobalKey<NavigatorState> navigationKey;
  BuildContext? get _currentContext => navigationKey.currentContext;

  RouteMatchList _routeMatchList = RouteMatchList.empty;
  
  /// Flag to skip next route change checking
  /// Since iOS swipe back cannot be intercepted in GoRouter.pop,
  /// we cannot stop the navigation if user uses swipe gesture.
  bool _skipNextRouteChangeChecking = false;
  bool _isShowingConfirmationDialog = false;

  NavigationConfirmationService({
    required this.navigationKey,
  }) {
    debugPrint('[$_tag] Initialized with confirmation routes: $routesRequiringConfirmation');
  }

  /// Handles route changes and shows confirmation dialog if needed
  void onRouteChange(RouteMatchList routeMatchList) {
    return; // no need to check route change now, temporary disable
    final previousLocations = _routeMatchList.matches.map((e) => e.matchedLocation).toList();
    final currentLocations = routeMatchList.matches.map((e) => e.matchedLocation).toList();
    
    debugPrint('[$_tag] onRouteChange: previous=$previousLocations, current=$currentLocations');
    debugPrint('[$_tag] skipNextRouteCheck: $_skipNextRouteChangeChecking, isShowingDialog: $_isShowingConfirmationDialog');

    bool previousPageRequiredConfirmation = _isLastPageRequiringConfirmation(_routeMatchList);
    bool currentPageRequiresConfirmation = _isLastPageRequiringConfirmation(routeMatchList);
    
    debugPrint('[$_tag] previousPageRequiredConfirmation: $previousPageRequiredConfirmation');
    debugPrint('[$_tag] currentPageRequiresConfirmation: $currentPageRequiresConfirmation');

    // Check if we're navigating away from a page that requires confirmation
    if (previousPageRequiredConfirmation &&
        !currentPageRequiresConfirmation &&
        !_skipNextRouteChangeChecking &&
        !_isShowingConfirmationDialog) {
      debugPrint('[$_tag] 🚨 Detected unauthorized navigation away from a confirmation page!');
      _isShowingConfirmationDialog = true;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('[$_tag] Showing swipe back confirmation dialog after frame');
        _currentContext?.showNavigationConfirmDialog(
          title: 'Swipe Back Detected',
          content: 'Do you want to go back?',
          onConfirm: () {
            debugPrint('[$_tag] Swipe back confirmed by user');
            _isShowingConfirmationDialog = false;
          },
          onCancel: () {
            debugPrint('[$_tag] Swipe back cancelled by user, navigating back to previous page');
            if (_currentContext != null) {
              final targetLocation = _routeMatchList.matches.last.matchedLocation;
              debugPrint('[$_tag] Navigating back to: $targetLocation');
            } else {
              debugPrint('[$_tag] ⚠️ Cannot navigate back - context is null');
            }
            _isShowingConfirmationDialog = false;
          },
        );
      });
    } else if (previousPageRequiredConfirmation && !currentPageRequiresConfirmation) {
      debugPrint('[$_tag] Navigation away from confirmation page was authorized (skipCheck: $_skipNextRouteChangeChecking)');
    }
    
    _routeMatchList = routeMatchList;
    resetSkipNextRouteChangeChecking();
  }

  /// Shows a confirmation dialog for navigation
  Future<void> showConfirmationDialog({
    required Function() onConfirm,
    required Function() onCancel,
    String title = 'Confirm Navigation',
    String content = 'Are you sure you want to leave this page?',
  }) {
    debugPrint('[$_tag] Showing confirmation dialog - title: "$title", content: "$content"');
    return _currentContext?.showNavigationConfirmDialog(
          title: title,
          content: content,
          onConfirm: () {
            debugPrint('[$_tag] User confirmed navigation');
            onConfirm();
          },
          onCancel: () {
            debugPrint('[$_tag] User cancelled navigation');
            onCancel();
          },
        ) ??
        Future.value();
  }

  // ===== ROUTE CHECKING UTILITIES =====
  /// Checks if the current route requires confirmation before navigating away
  bool shouldShowConfirmation(List<RouteMatch> matches) {
    final currentMatch = matches.lastOrNull;
    final currentPage = currentMatch?.matchedLocation;
    
    final needsConfirmation = currentPage != null &&
        routesRequiringConfirmation.contains(currentPage);
        
    debugPrint('[$_tag] shouldShowConfirmation: $needsConfirmation for page $currentPage');
    return needsConfirmation;
  }

  /// Sets flag to skip the next route change checking
  void setSkipNextRouteChangeChecking() {
    _skipNextRouteChangeChecking = true;
    debugPrint('[$_tag] Set skip next route change checking to: $_skipNextRouteChangeChecking');
  }

  /// Resets the flag for route change checking
  void resetSkipNextRouteChangeChecking() {
    final previousValue = _skipNextRouteChangeChecking;
    _skipNextRouteChangeChecking = false;
    debugPrint('[$_tag] Reset skip next route change checking from: $previousValue to: $_skipNextRouteChangeChecking');
  }

  /// Checks if the last page in the route list requires confirmation
  bool _isLastPageRequiringConfirmation(RouteMatchList routeMatchList) {
    if (routeMatchList.isEmpty) {
      debugPrint('[$_tag] _isLastPageRequiringConfirmation: routeMatchList is empty');
      return false;
    }
    
    for (final match in routeMatchList.matches) {
      if (routesRequiringConfirmation.contains(match.matchedLocation)) {
        debugPrint('[$_tag] Found page requiring confirmation: ${match.matchedLocation}');
        return true;
      }
    }
    
    debugPrint('[$_tag] No pages in route stack require confirmation');
    return false;
  }
}
