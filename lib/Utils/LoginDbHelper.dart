import 'package:home_attendance_system/Models/UserModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LoginDatabaseHelper {
  static final LoginDatabaseHelper _instance = LoginDatabaseHelper._internal();
  static Database? _database;

  factory LoginDatabaseHelper() {
    return _instance;
  }

  LoginDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
          ''',
        );
      },
    );
  }

  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }
}
