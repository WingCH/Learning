import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  // Helper method to show confirmation dialog
  Future<void> showNavigationConfirmDialog({
    required String title,
    required String content,
    required Function() onConfirm,
    required Function() onCancel,
  }) {
    return showDialog<void>(
      context: this,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel();
              },
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