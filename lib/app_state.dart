import 'dart:async';

import 'package:c25k/database_helper.dart';

class AppState {
  static final AppState _appState = AppState._internal();

  factory AppState() {
    return _appState;
  }

  String title = 'C25K';

  Stopwatch stopwatch = Stopwatch();
  Timer? _autosaveTimer;
  Timer? _elapseTimer;
  int elapsed_recovered = 0;
  int elapsed = 0;

  AppState._internal();

  void parseDuration() {
    int inMillis = stopwatch.elapsedMilliseconds;
    print(elapsed);
  }

  void startStopwatch() {
    stopwatch.start();
    _elapseTimer ??= Timer.periodic(Duration(milliseconds: 100), (timer) {
      elapsed = elapsed_recovered + stopwatch.elapsedMilliseconds;
    });
    _autosaveTimer ??= Timer.periodic(Duration(milliseconds: 500), (timer) {
      _saveElapsedTime();
    });
  }

  void stopStopwatch() {
    stopwatch.stop();
    _autosaveTimer?.cancel();
    _autosaveTimer = null;
    _elapseTimer?.cancel();
    _elapseTimer = null;
  }

  Future<void> resetStopwatch() async {
    stopwatch.stop();
    stopwatch.reset();
    elapsed = 0;
    elapsed_recovered = 0;
    await DatabaseHelper.deleteTimeSession();
  }

  // Priv
  Future<void> _saveElapsedTime() async {
    await DatabaseHelper.storeTimeSession(elapsed);
  }
}
