import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseTrailock {
  static final _dataBaseName = 'codeTrailock.db';
  static final _dataBaseVersion = 1;

  static final DataBaseTrailock _instance = new DataBaseTrailock.internal();
  factory DataBaseTrailock() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await _initDatabase();
    return _db;
  }

  DataBaseTrailock.internal();
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dataBaseName);
    return await openDatabase(path,
        version: _dataBaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE codes (
            local_id INTEGER PRIMARY KEY AUTOINCREMENT,
            padlock_name TEXT NOT NULL,
            code TEXT NOT NULL
          )
          ''');
  }

  deleteDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dataBaseName);
    await deleteDatabase(path);
    _db = null;
    await _initDatabase();
  }
}
