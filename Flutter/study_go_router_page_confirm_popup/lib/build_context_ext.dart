import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  // Helper method to show confirmation dialog
  Future<T?> showNavigationConfirmDialog<T>({
    required String title,
    required String content,
    required Function() onConfirm,
  }) {
    return showDialog<T>(
      context: this,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('確認'),
            ),
          ],
        );
      },
    );
  }
}