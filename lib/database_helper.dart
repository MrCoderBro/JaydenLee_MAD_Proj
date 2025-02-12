import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT,
        phoneNumber INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        exerciseId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,  
        imageFile TEXT,
        difficulty TEXT,
        description TEXT,
        youtubeLink TEXT,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        playlistId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE playlist_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlistId INTEGER NOT NULL,
        exerciseId INTEGER,
        duration INTEGER NOT NULL, 
        FOREIGN KEY (playlistId) REFERENCES playlists (playlistId) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (exerciseId) ON DELETE CASCADE
      )
    ''');

    // Insert initial exercises

    //Add Rest Exercise
    await db.insert('exercises', {
      'name': 'Rest', 
      'imageFile': 'images/rest.png',
      'difficulty': 'Medium',
      'description':
          'A bodyweight exercise that targets the chest, shoulders, triceps, and core by lowering and raising the body in a plank position.',
      'youtubeLink': 'https://www.youtube.com/watch?v=IODxDxX7oi4',
      'category': 'Strength'
    });

    await db.insert('exercises', {
      'name': 'Push Ups', 
      'imageFile': 'images/push_ups.png',
      'difficulty': 'Medium',
      'description':
          'A bodyweight exercise that targets the chest, shoulders, triceps, and core by lowering and raising the body in a plank position.',
      'youtubeLink': 'https://www.youtube.com/watch?v=IODxDxX7oi4',
      'category': 'Strength'
    });

    await db.insert('exercises', {
      'name': 'Planks', 
      'imageFile': 'images/planks.png',
      'difficulty': 'Medium',
      'description':
          'A core-strengthening isometric exercise where you hold a straight body position on your elbows or hands for a set time.',
      'youtubeLink':
          'https://www.youtube.com/watch?v=pSHjTRCQxIw&ab_channel=ScottHermanFitness',
      'category': 'Core'
    });

    await db.insert('exercises', {
      'name': 'Squats', 
      'imageFile': 'images/squats.png',
      'difficulty': 'Medium',
      'description':
          'A lower-body exercise that strengthens the legs and glutes by bending the knees and lowering the hips, then returning to a standing position.',
      'youtubeLink':
          'https://www.youtube.com/watch?v=YaXPRqUwItQ&ab_channel=MindBodySoul',
      'category': 'Strength'
    });

    await db.insert('exercises', {
      'name': 'Lunges', 
      'imageFile': 'images/lunges.png',
      'difficulty': 'Medium',
      'description':
          'A lower-body movement where one leg steps forward, bending both knees to a 90-degree angle, then returning to a standing position. Works legs and glutes.',
      'youtubeLink':
          'https://www.youtube.com/watch?v=QOVaHwm-Q6U&ab_channel=BowFlex',
      'category': 'Strength'
    });

    await db.insert('exercises', {
      'name': 'Jumping Jacks', 
      'imageFile': 'images/jumping_jacks.png',
      'difficulty': 'Easy',
      'description':
          'A full-body cardio exercise where you jump while spreading your arms and legs, then return to the starting position.',
      'youtubeLink':
          'https://www.youtube.com/watch?v=c4DAnQ6DtF8&ab_channel=FitnessBlender',
      'category': 'Cardio'
    });

    await db.insert('exercises', {
      'name': 'High Knees', 
      'imageFile': 'images/high_knees.png',
      'difficulty': 'Easy',
      'description':
          'A cardio move where you run in place while bringing your knees as high as possible, engaging the core and improving endurance.',
      'youtubeLink':
          'https://www.youtube.com/watch?v=FvjmPRU3zn4&ab_channel=ForeverLivingProductsUK',
      'category': 'Cardio'
    });
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise);
  }

  Future<int> insertPlaylist(Map<String, dynamic> playlist) async {
    final db = await database;
    return await db.insert('playlists', playlist);
  }

  Future<void> addExerciseToPlaylist(
      int playlistId, int exerciseId, int duration, int restTime) async {
    final db = await database;
    await db.insert('playlist_exercises', {
      'playlistId': playlistId,
      'exerciseId': exerciseId,
      'duration': duration,
    });

    if (restTime > 0) {
      await db.insert('playlist_exercises', {
        'playlistId': playlistId,
        'exerciseId': 1,
        'duration': restTime,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getPlaylistExercises(
      int playlistId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT pe.id as playlistExerciseId, e.*, pe.duration
    FROM playlist_exercises pe
    JOIN exercises e ON pe.exerciseId = e.exerciseId
    WHERE pe.playlistId = ?
  ''', [playlistId]);
  }

  Future<bool> emailExists(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    Database db = await database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getAllExercises() async {
    final db = await database;
    return await db.query(
      'exercises',
      where: 'exerciseId != ?',
      whereArgs: [1],
    );
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    if (await File(path).exists()) {
      await File(path).delete();
    }
  }

  Future<List<Map<String, dynamic>>> getUserPlaylists(int userId) async {
    final db = await database;
    return await db.query(
      'playlists',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllPlaylists() async {
    final db = await database;
    return await db.query('playlists');
  }

  Future<List<Map<String, dynamic>>> getAllPlaylistExercise() async {
    final db = await database;
    return await db.query('playlist_exercises');
  }

  Future<int> getExerciseCountForPlaylist(int playlistId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM playlist_exercises WHERE playlistId = ? AND exerciseId != 1',
      [playlistId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deletePlaylist(int playlistId) async {
    final db = await database;
    await db.delete(
      'playlists',
      where: 'playlistId = ?',
      whereArgs: [playlistId],
    );
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> updateUser(int userId, Map<String, dynamic> user) async {
    Database db = await database;
    await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

Future<void> deleteExerciseFromPlaylist(int playlistExerciseId) async {
  final db = await database;
  await db.delete(
    'playlist_exercises',
    where: 'id = ?',
    whereArgs: [playlistExerciseId],
  );
}
}
