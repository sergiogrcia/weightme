import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/weight_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'weightme_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            weightKg REAL NOT NULL,
            note TEXT,
            delta REAL NOT NULL DEFAULT 0.0
          )
        ''');

        await db.execute('''
          CREATE TABLE profile (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            name TEXT NOT NULL,
            startingWeight REAL NOT NULL,
            targetWeight REAL NOT NULL,
            unit TEXT NOT NULL,
            dailyReminders INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // Entries CRUD
  Future<List<WeightEntry>> getEntries() async {
    final db = await database;
    final maps = await db.query('entries', orderBy: 'date DESC');
    return maps.map((map) => WeightEntry.fromJson(map)).toList();
  }

  Future<void> insertEntry(WeightEntry entry) async {
    final db = await database;
    await db.insert(
      'entries',
      entry.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertEntries(List<WeightEntry> entries) async {
    final db = await database;
    final batch = db.batch();
    for (final entry in entries) {
      batch.insert(
        'entries',
        entry.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateEntry(WeightEntry entry) async {
    final db = await database;
    await db.update(
      'entries',
      entry.toJson(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteEntry(String id) async {
    final db = await database;
    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllEntries() async {
    final db = await database;
    await db.delete('entries');
  }

  // Profile CRUD
  Future<UserProfile?> getProfile() async {
    final db = await database;
    final maps = await db.query('profile', where: 'id = 1');
    if (maps.isNotEmpty) {
      final data = Map<String, dynamic>.from(maps.first);
      data['dailyReminders'] = (data['dailyReminders'] as int) == 1;
      return UserProfile.fromJson(data);
    }
    return null;
  }

  Future<void> saveProfile(UserProfile profile) async {
    final db = await database;
    final data = profile.toJson();
    data['id'] = 1;
    data['dailyReminders'] = profile.dailyReminders ? 1 : 0;
    await db.insert('profile', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> replaceAllData(UserProfile profile, List<WeightEntry> entries) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('entries');
      await txn.delete('profile');

      final profileData = profile.toJson();
      profileData['id'] = 1;
      profileData['dailyReminders'] = profile.dailyReminders ? 1 : 0;
      await txn.insert('profile', profileData, conflictAlgorithm: ConflictAlgorithm.replace);

      for (final entry in entries) {
        await txn.insert('entries', entry.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
