import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalService {
  static final LocalService _instance = LocalService._internal();
  factory LocalService() => _instance;

  LocalService._internal();

  Database? _database;
  final StreamController<void> _updateController =
      StreamController<void>.broadcast();

  Stream<void> get updateStream => _updateController.stream;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'local_database.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE items (id TEXT PRIMARY KEY, name TEXT, description TEXT)',
    );
  }

  Future<List<Map<String, dynamic>>> fetchAll(String tableName) async {
    final db = await database;
    return db.query(tableName);
  }

  Future<Map<String, dynamic>?> fetchById(String tableName, String id) async {
    final db = await database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insert(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    final result = await db.insert(tableName, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    _updateController.add(null);
    return result;
  }

  Future<int> update(
      String tableName, Map<String, dynamic> data, String id) async {
    final db = await database;
    final result =
        await db.update(tableName, data, where: 'id = ?', whereArgs: [id]);
    _updateController.add(null);
    return result;
  }

  Future<int> delete(String tableName, String id) async {
    final db = await database;
    final result = await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    _updateController.add(null);
    return result;
  }

  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
    _updateController.add(null);
  }

  Future<void> close() async {
    await _database?.close();
    await _updateController.close();
  }
}
