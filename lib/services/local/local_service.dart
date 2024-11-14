import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalService {
  static final LocalService _instance = LocalService._internal();
  factory LocalService() => _instance;
  LocalService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentsDirectory.path, 'app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE files (
        id INTEGER PRIMARY KEY,
        title TEXT,
        subject TEXT,
        description TEXT,
        content TEXT,
        type TEXT, -- 'wordlist' or 'summary'
        userId STRING,
        projectId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY, 
        title TEXT,
        description TEXT,
        dueDate TEXT,
        completed BOOLEAN,
        userId STRING,
        projectId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE deadlines (
        id INTEGER PRIMARY KEY,
        title TEXT,
        dueDate TEXT, 
        userId STRING,
        projectId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        startDate TEXT,
        endDate TEXT,
        userId STRING
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE
      )
    ''');
  }

  // CRUD operations for files
  Future<int> insertFile(Map<String, dynamic> fileData) async {
    Database db = await database;
    return await db.insert('files', fileData);
  }

  Future<List<Map<String, dynamic>>> getAllFiles(String userId) async {
    Database db = await database;
    return await db.query('files', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<int> updateFile(int id, Map<String, dynamic> fileData) async {
    Database db = await database;
    return await db.update('files', fileData, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFile(int id) async {
    Database db = await database;
    return await db.delete('files', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for tasks
  Future<int> insertTask(Map<String, dynamic> taskData) async {
    Database db = await database;
    return await db.insert('tasks', taskData);
  }

  Future<List<Map<String, dynamic>>> getAllTasks(String userId) async {
    Database db = await database;
    return await db.query('tasks', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<int> updateTask(int id, Map<String, dynamic> taskData) async {
    Database db = await database;
    return await db.update('tasks', taskData, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for deadlines
  Future<int> insertDeadline(Map<String, dynamic> deadlineData) async {
    Database db = await database;
    return await db.insert('deadlines', deadlineData);
  }

  Future<List<Map<String, dynamic>>> getAllDeadlines(String userId) async {
    Database db = await database;
    return await db
        .query('deadlines', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<int> updateDeadline(int id, Map<String, dynamic> deadlineData) async {
    Database db = await database;
    return await db
        .update('deadlines', deadlineData, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteDeadline(int id) async {
    Database db = await database;
    return await db.delete('deadlines', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for projects
  Future<int> insertProject(Map<String, dynamic> projectData) async {
    Database db = await database;
    return await db.insert('projects', projectData);
  }

  Future<List<Map<String, dynamic>>> getAllProjects(String userId) async {
    Database db = await database;
    return await db.query('projects', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<int> updateProject(int id, Map<String, dynamic> projectData) async {
    Database db = await database;
    return await db
        .update('projects', projectData, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProject(int id) async {
    Database db = await database;
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for users
  Future<int> insertUser(String email) async {
    Database db = await database;
    return await db.insert('users', {'email': email});
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> users =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    return users.isNotEmpty ? users.first : null;
  }
}
