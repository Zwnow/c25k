import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'c25k_database.db');

    //await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE time_session (
      id INTEGER PRIMARY KEY,
      elapsed_millis INTEGER NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE week_state (
      id INTEGER PRIMARY KEY,
      phase_index INTEGER,
      seconds_elapsed INTEGER
    )
    ''');
  }

  static Future<int> storeWeekState(int week, int index, int seconds) async {
    final db = await database;
    return await db.insert(
        'week_state',
        {
          'id': week,
          'phase_index': index,
          'seconds_elapsed': seconds,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, Object?>?> getWeekState(int week) async {
    final db = await database;
    final res = await db.rawQuery(
        'SELECT phase_index, seconds_elapsed FROM week_state WHERE id = ?',
        [week]);
    if (res.length == 1) {
      return res.first;
    } else {
      return null;
    }
  }

  static Future<int> deleteWeekState(int week) async {
    final db = await database;
    return await db.rawDelete('DELETE FROM week_state WHERE id = ?', [week]);
  }

  static Future<int> getTimeSession() async {
    final db = await database;
    final res = await db
        .rawQuery('SELECT elapsed_millis FROM time_session WHERE id = ?', [1]);

    if (res.isNotEmpty) {
      final entry = res.first;
      return entry['elapsed_millis'] as int;
    }
    return 0;
  }

  static Future<int> deleteTimeSession() async {
    final db = await database;
    return await db.rawDelete('DELETE FROM time_session WHERE id = ?', [1]);
  }

  static Future<int> storeTimeSession(int millis) async {
    final db = await database;
    return await db.insert(
        'time_session',
        {
          'id': 1,
          'elapsed_millis': millis,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
