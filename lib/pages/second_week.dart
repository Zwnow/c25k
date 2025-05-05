import 'package:c25k/app_state.dart';
import 'package:c25k/database_helper.dart';
import 'package:c25k/stopwatch.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class SecondWeek extends StatefulWidget {
  @override
  State<SecondWeek> createState() => _SecondWeekState();
}

class Phase {
  String name;
  int interval;

  Phase({required this.name, required this.interval});
}

class _SecondWeekState extends State<SecondWeek> {
  AppState appState = AppState();
  List<Phase> phases = [
    // 5 min
    Phase(name: "Walk", interval: 300),

    // 10 min
    Phase(name: "Jog", interval: 90),
    Phase(name: "Walk", interval: 180),
    Phase(name: "Jog", interval: 90),
    Phase(name: "Walk", interval: 180),

    // 15 min
    Phase(name: "Jog", interval: 90),
    Phase(name: "Walk", interval: 180),
    Phase(name: "Jog", interval: 90),
    Phase(name: "Walk", interval: 180),

    // 20 min
    Phase(name: "Jog", interval: 90),
    Phase(name: "Walk", interval: 180),
    Phase(name: "Jog", interval: 90),
    Phase(name: "Walk", interval: 180),

    // 25 min
    Phase(name: "Jog", interval: 90),
    Phase(name: "Walk", interval: 180),
    Phase(name: "Jog", interval: 90),
    Phase(name: "Walk", interval: 180),
  ];
  bool stopIncrementing = false;
  int phaseIndex = 0;
  int seconds_elapsed = 0;

  Future<void> recoverState() async {
    appState.openWeek = 2;
    final state = await DatabaseHelper.getWeekState(2);
    if (state != null) {
      phaseIndex = state['phase_index'] as int;
      seconds_elapsed = state['seconds_elapsed'] as int;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    recoverState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Top title
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Week 2",
                    style:
                        TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Centered phase text
              Center(
                child: Text(
                  phases[phaseIndex].name,
                  style: TextStyle(fontSize: 52.0),
                ),
              ),

              // Bottom stopwatch
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: C25KStopwatch(
                    onSecondTick: (seconds) async {
                      seconds_elapsed += 1;
                      // Store state
                      await DatabaseHelper.storeWeekState(
                          2, phaseIndex, seconds_elapsed);

                      if (seconds_elapsed >= phases[phaseIndex].interval &&
                          !stopIncrementing) {
                        seconds_elapsed = 0;
                        phaseIndex += 1;

                        // Vibrate
                        if (await Vibration.hasCustomVibrationsSupport()) {
                          Vibration.vibrate(duration: 3000, amplitude: 255);
                        } else {
                          Vibration.vibrate(amplitude: 255);
                          await Future.delayed(Duration(milliseconds: 3000));
                          Vibration.vibrate();
                        }

                        if (phaseIndex == phases.length) {
                          phaseIndex = phases.length - 1;
                          stopIncrementing = true;
                        }
                        setState(() {});
                      }
                    },
                    onReset: () {
                      phaseIndex = 0;
                      seconds_elapsed = 0;
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
