import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:untitled/alert_dialog_service/overlay_widget.dart';
import 'package:untitled/alertdialog.dart';
import 'package:untitled/countdown.dart';
import 'package:untitled/local_notifictions.dart';
import 'package:untitled/monitoring/monitoring_service.dart';
import 'package:untitled/monitoring/utils/flutter_background_service_utils.dart';

// onStart() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();

//   await startMonitoringService();
// }

// @pragma("vm:entry-point")
// void overlayMain() async {
//   debugPrint("Starting Alerting Window Isolate!");
//   WidgetsFlutterBinding.ensureInitialized();

//   runApp(MaterialApp(debugShowCheckedModeBanner: false, home: OverlayWidget()));
// }

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // initializeService();
  await LocalNotification.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp(),
  );
}
//-----------------------------------------

// void initializeService() async {
//   FlutterBackgroundService().configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onMonitoringServiceStart,
//       autoStart: true,
//       isForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onMonitoringServiceStart,
//       // onBackground: () => onMonitoringServiceStart,
//     ),
//   );
//   FlutterBackgroundService().startService();
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // navigatorKey: AlertDialogService2.navigatorKey,
      home: CountdownPage(),
    );
  }
}
