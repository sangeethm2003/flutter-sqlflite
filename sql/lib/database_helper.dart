import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
          
            age INTEGER,
              domain TEXT
          )
        ''');
      },
    );
  }

  // Insert user
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.rawInsert(
      'INSERT INTO users(name, age, domain) VALUES(?, ?,?)',
      [row['name'], row['age'], row['domain']],
    );
  }

  // Get all users
  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT * FROM users');
  }

  // Update user
  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.rawUpdate(
      'UPDATE users SET name = ?, age = ? , domain = ? WHERE id = ?',
      [row['name'], row['age'], row['domain'], row['id']],
    );
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.rawDelete('DELETE FROM users WHERE id = ?', [id]);
  }
}
