import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  static bool _factoryInitialized = false;

  /// Must run before any database access (call from [main]).
  static Future<void> initialize() async {
    if (_factoryInitialized) return;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _factoryInitialized = true;
  }

  Future<Database> get db async {
    if (_db != null) return _db!;
    await initialize();
    final basePath = await getDatabasesPath();
    _db = await openDatabase(
      join(basePath, 'kids_eco.db'),
      version: 2,
      onCreate: (database, version) async {
        await _createLevelsTable(database);
        await _createProfileTable(database);
        await _createUsersTable(database);
        await _seedInitialData(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createUsersTable(database);
        }
      },
    );
    return _db!;
  }

  Future<void> _createLevelsTable(Database database) async {
    await database.execute('''
      CREATE TABLE levels(
        id INTEGER PRIMARY KEY,
        world_id TEXT NOT NULL,
        title TEXT NOT NULL,
        stars INTEGER NOT NULL DEFAULT 0,
        unlocked INTEGER NOT NULL DEFAULT 0,
        best_score INTEGER NOT NULL DEFAULT 0
      );
    ''');
  }

  Future<void> _createProfileTable(Database database) async {
    await database.execute('''
      CREATE TABLE profile(
        id INTEGER PRIMARY KEY,
        child_name TEXT NOT NULL,
        total_stars INTEGER NOT NULL DEFAULT 0,
        badges INTEGER NOT NULL DEFAULT 0
      );
    ''');
  }

  Future<void> _createUsersTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');
  }

  Future<void> _seedInitialData(Database database) async {
    await database.insert('profile', {
      'id': 1,
      'child_name': 'ضيف صغير',
      'total_stars': 0,
      'badges': 0,
    });

    final worlds = ['colors', 'animals', 'numbers', 'memory'];
    var id = 1;
    for (final world in worlds) {
      for (var i = 1; i <= 6; i++) {
        await database.insert('levels', {
          'id': id,
          'world_id': world,
          'title': 'المستوى $i',
          'stars': 0,
          'unlocked': i == 1 ? 1 : 0,
          'best_score': 0,
        });
        id++;
      }
    }
  }
}
