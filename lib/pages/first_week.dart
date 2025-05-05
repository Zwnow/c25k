import 'package:c25k/app_state.dart';
import 'package:c25k/stopwatch.dart';
import 'package:flutter/material.dart';

class FirstWeek extends StatefulWidget {
  @override
  State<FirstWeek> createState() => _FirstWeekState();
}

class _FirstWeekState extends State<FirstWeek> {
  AppState appState = AppState();
  int walkPhase = 3;
  int walkIntervalSeconds = 2;
  int jogIntervalSeconds = 4;
  String currentPhase = "Walk";
  int seconds_elapsed = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SafeArea(child: SizedBox()),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Week 1",
                    style:
                        TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      currentPhase,
                      style: TextStyle(fontSize: 38.0),
                    ),
                  ),
                  Text("${seconds_elapsed}"),
                ],
              ),
            ),
            C25KStopwatch(
              onSecondTick: (seconds) {
                seconds_elapsed = seconds;
                setState(() {});
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
