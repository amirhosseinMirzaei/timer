import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/local_notifictions.dart';

class CountdownPage extends StatefulWidget {
  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage>
    with WidgetsBindingObserver {
  late MethodChannel _channel;

  int countdownSeconds = 3000;
  late Timer countdownTimer;
  late OverlayEntry _overlayEntry;
  bool countdownActive = false;
  bool onWillPop = true;

  @override
  void initState() {
    listenToNotifications();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _channel = MethodChannel('background_service');
    initial();
    // startCountdown();
  }

  //listen any notification clicked or not
  listenToNotifications() {
    print('listen to notification');
    LocalNotification.onClickedNotifiction.stream.listen((event) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CountdownPage()));
    });
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> initial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final remainingSeconds = prefs.getInt('countdownSeconds');

    if (remainingSeconds != null) {
      setState(() {
        countdownSeconds = remainingSeconds;
      });
    }
    final DateTime dateTimeNow = DateTime.now();
    final endTime = dateTimeNow.add(Duration(seconds: countdownSeconds));
    prefs.setString('end_time', endTime.toString());
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (countdownSeconds > 0) {
        _stopBackgroundService();
        // removeOverlay();
        final prefs = await SharedPreferences.getInstance();
        final endingTime = prefs.getString('end_time');

        if (endingTime != null) {
          final endTime = DateTime.parse(endingTime);
          Duration _remaining = endTime.difference(DateTime.now());

          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('countdownSeconds', _remaining.inSeconds);

          final remain = prefs.getInt('countdownSeconds');
          setState(() {
            countdownSeconds = remain!;
          });
        }
      }
    } else if (state == AppLifecycleState.paused) {
      _startBackgroundService();

      final prefs = await SharedPreferences.getInstance();
      final remainingSeconds = countdownSeconds;
      prefs.setInt('countdownSeconds', remainingSeconds);
    }
  }

  void _startBackgroundService() {
    try {
      _channel.invokeMethod('startService');
    } catch (e) {
      print("Failed to start background service: $e");
    }
  }

  void _stopBackgroundService() {
    try {
      _channel.invokeMethod('stopService');
    } catch (e) {
      print("Failed to stop background service: $e");
    }
  }

  void showOverlayBackGround() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Text(
                'Countdown is active. Please back to the app',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry);
  }

  void removeOverlay() {
    _overlayEntry.remove();
  }

  void startCountdown() async {
    countdownActive = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.white.withOpacity(0),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry);

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdownSeconds > 0) {
          countdownSeconds--;
          onWillPop = true;
        } else {
          LocalNotification.showSimpleNotification(
              title: 'Notruphil',
              body: 'this is a notification',
              payload: 'timer is down');
          countdownActive = false;
          clearSharedPreferences();
          _overlayEntry.remove();
          timer.cancel();
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('cout down ended'),
                    content: Text('count down recahed zero'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('تمام'),
                      ),
                    ],
                  ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (countdownActive) {
          didPop = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('هشدار'),
                    content: const Text('آیا مطمعن هستید میخواهید خارج شوید؟'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('خیر'),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text('خروج'))
                    ],
                  ));
        } else {
          didPop = true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Countdown Timer'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(onPressed: startCountdown, child: Text('شروع')),
              Text(
                '${countdownSeconds ~/ 60}:${(countdownSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 24),
              ),
              ElevatedButton(onPressed: () {}, child: const Text('بازگشت'))
            ],
          ),
        ),
      ),
    );
  }
}
