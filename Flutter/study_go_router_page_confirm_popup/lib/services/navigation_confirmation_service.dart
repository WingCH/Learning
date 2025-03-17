import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_go_router_page_confirm_popup/build_context_ext.dart';

class NavigationConfirmationService {
  // 需要確認的路由列表
  final List<String> routesRequiringConfirmation = ['/pageA'];

  NavigationConfirmationService();

  // 檢查當前路由是否需要確認
  bool shouldShowConfirmation(List<RouteMatch> matches) {
    // 使用完整的路由堆疊判斷邏輯
    final currentMatch = matches.lastOrNull;
    final currentPage = currentMatch?.matchedLocation;
    
    // 檢查當前頁面是否在需要確認的列表中
    return currentPage != null && routesRequiringConfirmation.contains(currentPage);
  }

  // 顯示導航確認對話框
  Future<void> showConfirmationDialog({
    required BuildContext context,
    required Function() onConfirm,
    required Function() onCancel,
    String title = '確認導航',
    String content = '你確定要離開當前頁面嗎？',
  }) {
    print('[NavigationConfirmationService] showConfirmationDialog');
    return context.showNavigationConfirmDialog(
      title: title,
      content: content,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  // go back previous page
  void goBack(BuildContext context) {
    print('[NavigationConfirmationService] goBack');
  }
} 