import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final basePath = await databaseFactory.getDatabasesPath();
  final dbPath = p.join(basePath, 'kids_eco.db');
  stdout.writeln('Databases folder: $basePath');
  stdout.writeln('Database file:    $dbPath');
  stdout.writeln('Exists:           ${File(dbPath).existsSync()}');
  stdout.writeln('');

  final db = await openDatabase(
    dbPath,
    version: 2,
    onCreate: (database, version) async {
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
      await database.execute('''
        CREATE TABLE profile(
          id INTEGER PRIMARY KEY,
          child_name TEXT NOT NULL,
          total_stars INTEGER NOT NULL DEFAULT 0,
          badges INTEGER NOT NULL DEFAULT 0
        );
      ''');
      await database.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          created_at TEXT NOT NULL
        );
      ''');
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
      stdout.writeln('(Created new database with seed data)');
    },
    onUpgrade: (database, oldVersion, newVersion) async {
      if (oldVersion < 2) {
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
    },
  );

  for (final table in ['profile', 'levels', 'users']) {
    stdout.writeln('=== $table ===');
    final rows = await db.query(table);
    if (rows.isEmpty) {
      stdout.writeln('(empty)');
    } else {
      final show = table == 'levels' ? rows.take(8) : rows;
      for (final row in show) {
        stdout.writeln(row);
      }
      if (table == 'levels' && rows.length > 8) {
        stdout.writeln('... +${rows.length - 8} more rows');
      }
    }
    stdout.writeln('');
  }

  await db.close();
}
