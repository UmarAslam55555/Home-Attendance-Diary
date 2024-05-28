import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AttendanceDatabaseHelper {
  static final AttendanceDatabaseHelper _instance =
      AttendanceDatabaseHelper._internal();
  factory AttendanceDatabaseHelper() => _instance;
  static Database? _database;

  AttendanceDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'attendance.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE attendance(id INTEGER PRIMARY KEY, user_id INTEGER, staff_id INTEGER, date TEXT, checkin_time TEXT, checkout_time TEXT, status TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertAttendance(Map<String, dynamic> attendance) async {
    final db = await database;
    await db.insert('attendance', attendance,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateAttendance(int id, Map<String, dynamic> attendance) async {
    final db = await database;
    await db.update('attendance', attendance, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAttendance(int userId) async {
    final db = await database;
    return await db
        .query('attendance', where: 'user_id = ?', whereArgs: [userId]);
  }
}
