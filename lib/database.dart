import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static Database? database;

  static Future<Database> getDatabase() async {
    if (database != null) return database!;

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    Directory folder = await getApplicationCacheDirectory();
    String path = join(folder.path, 'app_database_v2.db');

    database = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              firstName TEXT,
              lastName TEXT,
              email TEXT,
              password TEXT,
              favorites TEXT
            )
          ''');
        },
      ),
    );

    return database!;
  }

  static Future<void> createUser(
      String firstName,
      String lastName,
      String email,
      String password,
      ) async {
    final db = await getDatabase();

    await db.insert('users', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'favorites': jsonEncode([]),
    });
  }

  static Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    final db = await getDatabase();

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) return result.first;
    return null;
  }

  static Future<void> updateFavorites(
      int userId, List<String> favoritesList) async {
    final db = await getDatabase();

    await db.update(
      'users',
      {'favorites': jsonEncode(favoritesList)},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  static Future<List<String>> getFavorites(int userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'users',
      columns: ['favorites'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isEmpty) return [];

    // ⭐ SAFE CAST
    final raw = result.first['favorites'] as String? ?? '[]';
    return List<String>.from(jsonDecode(raw));
  }
}



