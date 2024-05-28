import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StaffDatabaseHelper {
  static final StaffDatabaseHelper _instance = StaffDatabaseHelper._internal();
  factory StaffDatabaseHelper() => _instance;
  static Database? _database;

  StaffDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'staff.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE staff(id INTEGER PRIMARY KEY, user_id INTEGER, name TEXT, phone TEXT, city TEXT, job_id INTEGER, timing_from TEXT, timing_to TEXT, per_hour_salary REAL, per_month_salary REAL)',
    );
  }

  Future<void> insertStaff(int userId, Map<String, dynamic> staff) async {
    final db = await database;
    await db.insert(
      'staff',
      {'user_id': userId, ...staff},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getStaff(int userId) async {
    final db = await database;
    return await db.query('staff', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> updateStaff(int id, Map<String, dynamic> staff) async {
    final db = await database;
    await db.update(
      'staff',
      staff,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
