import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  // static lets the database be shared with the entire app
  // Database? is a class from the sqflite package and the ? lets it be null
  // database is just the variable name
  static Database? database;

  // static makes this function belong to the class
  // future is used bc it takes time to open a database
  // and async is you can await inside it
  static Future<Database> getDatabase() async {
    if (database != null) return database!; // exclamation is to tell it that it isn't null

    sqfliteFfiInit(); // starts the FFI version of SQLite (for windows)
    databaseFactory = databaseFactoryFfi; // switches flutter to the desktop database engine rather than the mobile one

    Directory folder = await getApplicationCacheDirectory(); // finds a safe folder for the database
    String path = join(folder.path, 'app_database_v3.db'); // creates the full file path where the database will be stored

    database = await databaseFactory.openDatabase( // if it exists it opens it, if it doesn't exist it creates it
      path, // where to store the file
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) async { // this only runs the first time the database is created and its where the tables are defined
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
          await db.execute('''
            CREATE TABLE user_recipes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              userId INTEGER,
              name TEXT,
              image TEXT,
              instructions TEXT
            )
          ''');
        },
      ),
    );

    return database!;
  }

  static Future<void> createUser( // its async and doesn't return anything
      String firstName,
      String lastName,
      String email,
      String password,
      ) async {
    final db = await getDatabase(); // makes sure the database is open and uses it if it is or opens it

    await db.insert( // it inserts a new row in the users table for each thingy
      'users', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'favorites': jsonEncode([]), // this stores strings not lists, so you put a empty list into json so that each user has their own favorites list
    });
  }

  static Future<Map<String, dynamic>?> loginUser(
      String email, String password) async { // takes email and password as inputs
    final db = await getDatabase();

    final result = await db.query( // searches for email and password in the database
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) return result.first; // gets the things inside the first row the results match with
    return null;
  }

  static Future<void> updateFavorites(
      int userId, List<String> favoritesList) async { // takes a users id and the updated favorites
    final db = await getDatabase();

    await db.update(
      'users', // updates the users table
      {'favorites': jsonEncode(favoritesList)}, // sets the favs column to a json string version of the favs list
      where: 'id = ?',
      whereArgs: [userId], // only updates the row where id = userId
    );
  }

  static Future<List<String>> getFavorites(int userId) async { // returns a user's favorites as a list of strings
    final db = await getDatabase();

    final result = await db.query( // gets only the favs column from users row
      'users',
      columns: ['favorites'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isEmpty) return []; // no user, return empty list

    // gets the raw json string if its null then it default to a empty list
    final raw = result.first['favorites'] as String? ?? '[]'; // sqlite can store dart lists only text so it get saved as json text, not a real list
    return List<String>.from(jsonDecode(raw)); // turns json string into real list of strings
  }

  static Future<void> addUserRecipe( // defines a function that will add one recipe to the database for a specific user
      int userId,
      String name,
      String image,
      String instructions,
      ) async {
    final db = await getDatabase();

    await db.insert('user_recipes', { // adds a new line into the table with all these values
      'userId': userId,
      'name': name,
      'image': image,
      'instructions': instructions,
    });
  }

  static Future<List<Map<String, dynamic>>> getUserRecipes(int userId) async {
    final db = await getDatabase();

    return await db.query(
      'user_recipes',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
  static Future<void> deleteUserRecipe(int userId, String name) async {
    final db = await getDatabase();

    await db.delete(
      'user_recipes',
      where: "userId = ? AND name = ?",
      whereArgs: [userId, name],
    );
  }
}



