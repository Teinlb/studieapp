import 'dart:async';

import 'package:studieapp/models/planning_models.dart';
import 'package:studieapp/services/local/database_service.dart';
import 'package:studieapp/extensions/list/filter.dart';
import 'package:studieapp/services/local/local_constants.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/services/local/subs/user_service.dart';
import '../local_exceptions.dart';

class TaskService {
  List<Task> _tasks = [];

  DatabaseUser? _user;

  final DatabaseService _databaseService = DatabaseService();
  final UserService _userService = UserService();

  static final TaskService _shared = TaskService._sharedInstance();
  TaskService._sharedInstance() {
    _tasksStreamController = StreamController<List<Task>>.broadcast(
      onListen: () {
        _tasksStreamController.sink.add(_tasks);
      },
    );

    _init();
  }
  factory TaskService() => _shared;

  late final StreamController<List<Task>> _tasksStreamController;

  // Initialiseer de taken door ze te cachen
  Future<void> _init() async {
    await _cacheTasks();
  }

  Stream<List<Task>> get allTasks =>
      _tasksStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingData();
        }
      });

  Future<void> _cacheTasks() async {
    final allTasks = await getAllTasks();
    _tasks = allTasks.toList();
    _tasksStreamController.add(_tasks);
  }

  Future<Task> updateTask({
    required int id,
    required bool isCompleted,
  }) async {
    final db = await _databaseService.database;

    // make sure note exists
    await getTask(id: id);

    // update DB
    final updatesCount = await db.update(
      taskTable,
      {
        isCompletedColumn: isCompleted,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateData();
    } else {
      final updatedTask = await getTask(id: id);
      _tasks.removeWhere((note) => note.id == updatedTask.id);
      _tasks.add(updatedTask);
      _tasksStreamController.add(_tasks);
      return updatedTask;
    }
  }

  Future<Iterable<Task>> getAllTasks() async {
    final db = await _databaseService.database;
    final tasks = await db.query(taskTable);

    return tasks.map((noteRow) => Task.fromRow(noteRow));
  }

  Future<Task> getTask({required int id}) async {
    final db = await _databaseService.database;

    final tasks = await db.query(
      taskTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (tasks.isEmpty) {
      throw CouldNotFindData();
    } else {
      final task = Task.fromRow(tasks.first);
      _tasks.removeWhere((task) => task.id == id);
      _tasks.add(task);
      _tasksStreamController.add(_tasks);
      return task;
    }
  }

  Future<void> deleteTask({required int id}) async {
    final db = await _databaseService.database;
    final deletedCount = await db.delete(
      taskTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteData();
    } else {
      _tasks.removeWhere((task) => task.id == id);
      _tasksStreamController.add(_tasks);
    }
  }

  Future<Task> createTask({
    required DatabaseUser owner,
    required String title,
    DateTime? dueDate,
    required bool isCompleted,
  }) async {
    final db = await _databaseService.database;

    // make sure owner exists in the database with the correct id
    final dbUser = await _userService.getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    final String dueDateString = dueDate!.toIso8601String();

    // create the task
    final taskId = await db.insert(taskTable, {
      userIdColumn: owner.id,
      titleColumn: title,
      dueDateColumn: dueDateString,
      isCompletedColumn: isCompleted ? 1 : 0,
    });
    final task = Task(
      id: taskId,
      userId: owner.id,
      title: title,
      dueDate: dueDate,
      isCompleted: isCompleted,
    );

    _tasks.add(task);
    _tasksStreamController.add(_tasks);

    return task;
  }
}
