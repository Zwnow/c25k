import 'dart:async';

import 'package:c25k/app_state.dart';
import 'package:c25k/database_helper.dart';
import 'package:flutter/material.dart';

class C25KStopwatch extends StatefulWidget {
  final void Function(int seconds)? onSecondTick;

  const C25KStopwatch({Key? key, this.onSecondTick}) : super(key: key);

  @override
  State<C25KStopwatch> createState() => _C25KStopwatchState();
}

class _C25KStopwatchState extends State<C25KStopwatch> {
  Timer? _timer;
  AppState appState = AppState();
  int _lastEmittedSecond = 0;

  Future<void> recoverTimeSession() async {
    int elapsedMillis = await DatabaseHelper.getTimeSession();
    appState.elapsed_recovered = elapsedMillis;
    appState.elapsed = elapsedMillis;
    _lastEmittedSecond = elapsedMillis ~/ 1000;
    setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {});

      int currentSecond = appState.elapsed ~/ 1000;
      if (currentSecond != _lastEmittedSecond) {
        _lastEmittedSecond = currentSecond;
        if (widget.onSecondTick != null) {
          print("Firing");
          widget.onSecondTick!(currentSecond);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (appState.stopwatch.isRunning) {
      _startTimer();
    }

    recoverTimeSession();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${Duration(milliseconds: appState.elapsed)}".substring(
                  0, "${Duration(milliseconds: appState.elapsed)}".length - 5),
              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: 2,
              onPressed: () async {
                await appState.resetStopwatch();
                setState(() {});
              },
              child: const Icon(Icons.stop),
            ),
            const SizedBox(width: 32),
            FloatingActionButton(
              heroTag: 1,
              onPressed: () {
                if (appState.stopwatch.isRunning) {
                  appState.stopStopwatch();
                  _timer?.cancel();
                  _timer = null;
                  setState(() {});
                } else {
                  appState.startStopwatch();
                  _startTimer();
                }
              },
              child: appState.stopwatch.isRunning
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
            ),
          ],
        ),
      ],
    );
  }
}
