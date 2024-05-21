import 'package:flutter/material.dart';

class AlertDialogService2 {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void createAlertDialog() {
    showDialog(
      context: navigatorKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("App Change Detected"),
          content: const Text("You have switched to another app."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
