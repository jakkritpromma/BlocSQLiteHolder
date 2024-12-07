import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'posts.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE posts(
          id INTEGER PRIMARY KEY,
          title TEXT,
          body TEXT
        )
      ''');
    });
  }

  Future<void> insertPosts(List<Map<String, dynamic>> posts) async {
    final db = await database;
    for (var post in posts) {
      await db.insert('posts', post, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Map<String, dynamic>>> getPosts() async {
    final db = await database;
    return await db.query('posts');
  }
}
