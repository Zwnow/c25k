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
