import 'package:flutter/material.dart';
import 'package:frontend/core/themes/radius_size.dart';

class DialogWidget {
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.rxl),
          ),
          title: Center(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          content: Text(message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // tutup dialog
                if (onOk != null) onOk();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
