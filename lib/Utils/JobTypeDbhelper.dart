import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class JobTypeDatabaseHelper {
  static final JobTypeDatabaseHelper _instance = JobTypeDatabaseHelper._internal();
  factory JobTypeDatabaseHelper() => _instance;
  static Database? _database;

  JobTypeDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'job_types.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE job_types(id INTEGER PRIMARY KEY, user_id INTEGER, name TEXT)',
    );
  }

  Future<void> insertJobType(int userId, String name) async {
    final db = await database;
    await db.insert(
      'job_types',
      {'user_id': userId, 'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getJobTypes(int userId) async {
    final db = await database;
    return await db
        .query('job_types', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> updateJobType(int id, String name) async {
    final db = await database;
    await db.update(
      'job_types',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
