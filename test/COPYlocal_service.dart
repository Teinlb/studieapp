import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:studieapp/extensions/list/filter.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/models/planning_models.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/crud_constants.dart';
import 'package:studieapp/services/local/crud_exceptions.dart';

class LocalService {
  Database? _db;
  DatabaseUser? _user;

  List<File> _files = [];
  List<Task> _tasks = [];
  List<Deadline> _deadlines = [];
  List<Project> _projects = [];

  static final LocalService _shared = LocalService._sharedInstance();
  LocalService._sharedInstance() {
    _initStreams();
  }
  factory LocalService() => _shared;

  //

  // initialize streams
  void _initStreams() {
    _filesStreamController = StreamController<List<File>>.broadcast(
      onListen: () {
        _filesStreamController.sink.add(_files);
      },
    );
    _tasksStreamController = StreamController<List<Task>>.broadcast(
      onListen: () {
        _tasksStreamController.sink.add(_tasks);
      },
    );
    _deadlinesStreamController = StreamController<List<Deadline>>.broadcast(
      onListen: () {
        _deadlinesStreamController.sink.add(_deadlines);
      },
    );
    _projectsStreamController = StreamController<List<Project>>.broadcast(
      onListen: () {
        _projectsStreamController.sink.add(_projects);
      },
    );
  }

  late final StreamController<List<File>> _filesStreamController;
  late final StreamController<List<Task>> _tasksStreamController;
  late final StreamController<List<Deadline>> _deadlinesStreamController;
  late final StreamController<List<Project>> _projectsStreamController;

  Stream<List<File>> get filesStream =>
      _filesStreamController.stream.filter((file) {
        final currentUser = _user;
        if (currentUser != null) {
          return file.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingData();
        }
      });
  Stream<List<Task>> get tasksStream =>
      _tasksStreamController.stream.filter((task) {
        final currentUser = _user;
        if (currentUser != null) {
          return task.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingData();
        }
      });
  Stream<List<Deadline>> get deadlinesStream =>
      _deadlinesStreamController.stream.filter((deadline) {
        final currentUser = _user;
        if (currentUser != null) {
          return deadline.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingData();
        }
      });
  Stream<List<Project>> get projectsStream =>
      _projectsStreamController.stream.filter((project) {
        final currentUser = _user;
        if (currentUser != null) {
          return project.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingData();
        }
      });

  void dispose() {
    _filesStreamController.close();
    _tasksStreamController.close();
    _deadlinesStreamController.close();
    _projectsStreamController.close();
  }

  //

  // supply a user and update _user
  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  //

  // cache all data from specific table
  Future<void> _cacheFiles() async {
    final allFiles = await getAllFiles();
    _files = allFiles.toList();
    _filesStreamController.add(_files);
  }

  Future<void> _cacheTasks() async {
    final allTasks = await getAllTasks();
    _tasks = allTasks.toList();
    _tasksStreamController.add(_tasks);
  }

  Future<void> _cacheDeadlines() async {
    final allDeadlines = await getAllDeadlines();
    _deadlines = allDeadlines.toList();
    _deadlinesStreamController.add(_deadlines);
  }

  Future<void> _cacheProjects() async {
    final allProjects = await getAllProjects();
    _projects = allProjects.toList();
    _projectsStreamController.add(_projects);
  }

  //

  // get all data from specific table
  Future<Iterable<File>> getAllFiles() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> files;
    await db.transaction((txn) async {
      files = await txn.query(fileTable);
    });

    return files.map((fileRow) => File.fromRow(fileRow));
  }

  Future<Iterable<Task>> getAllTasks() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> tasks;
    await db.transaction((txn) async {
      tasks = await txn.query(taskTable);
    });

    return tasks.map((taskRow) => Task.fromRow(taskRow));
  }

  Future<Iterable<Deadline>> getAllDeadlines() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> deadlines;
    await db.transaction((txn) async {
      deadlines = await txn.query(deadlineTable);
    });

    return deadlines.map((deadlineRow) => Deadline.fromRow(deadlineRow));
  }

  Future<Iterable<Project>> getAllProjects() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> projects;
    await db.transaction((txn) async {
      projects = await txn.query(projectTable);
    });

    return projects.map((projectRow) => Project.fromRow(projectRow));
  }

  //

  // get a specific object from db
  Future<File> getFile({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Haal het bestand op uit de database
    late final List<Map<String, dynamic>> files;
    await db.transaction((txn) async {
      files = await txn.query(
        fileTable,
        limit: 1,
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    if (files.isEmpty) {
      throw CouldNotFindData();
    } else {
      // Update de laatst geopende tijd
      final now = DateTime.now();
      await db.transaction((txn) async {
        await txn.update(
          fileTable,
          {
            lastOpenedColumn: now.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      });
      // Maak een bestand van de database-rij
      final file = File.fromRow(files.first);

      // Werk de lastOpened van het lokale bestand bij
      final updatedFile =
          file.copyWith(lastOpened: now); // Assuming you have a copyWith method

      // Werk de lokale lijst en stream bij
      _files.removeWhere((file) => file.id == id);
      _files.add(updatedFile);
      _filesStreamController.add(_files);

      return updatedFile;
    }
  }

  Future<Task> getTask({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> tasks;
    await db.transaction((txn) async {
      tasks = await txn.query(
        taskTable,
        limit: 1,
        where: 'id = ?',
        whereArgs: [id],
      );
    });

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

  Future<Deadline> getDeadline({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> deadlines;
    await db.transaction((txn) async {
      deadlines = await txn.query(
        deadlineTable,
        limit: 1,
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    if (deadlines.isEmpty) {
      throw CouldNotFindData();
    } else {
      final deadline = Deadline.fromRow(deadlines.first);
      _deadlines.removeWhere((deadline) => deadline.id == id);
      _deadlines.add(deadline);
      _deadlinesStreamController.add(_deadlines);
      return deadline;
    }
  }

  Future<Project> getProject({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> projects;
    await db.transaction((txn) async {
      projects = await txn.query(
        projectTable,
        limit: 1,
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    if (projects.isEmpty) {
      throw CouldNotFindData();
    } else {
      final project = Project.fromRow(projects.first);
      _projects.removeWhere((project) => project.id == id);
      _projects.add(project);
      _projectsStreamController.add(_projects);
      return project;
    }
  }

  //

  // update specific object in db
  Future<File> updateFile({
    required int id,
    required String content,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getFile(id: id);

    // update DB
    late final int updatesCount;
    await db.transaction((txn) async {
      updatesCount = await txn.update(
        fileTable,
        {
          contentColumn: content,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateData();
    } else {
      final updatedFile = await getFile(id: id);
      _files.removeWhere((file) => file.id == updatedFile.id);
      _files.add(updatedFile);
      _filesStreamController.add(_files);
      return updatedFile;
    }
  }

  Future<File> updateCloudIdFile({
    required int id,
    required String cloudId,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getFile(id: id);

    // update DB
    late final int updatesCount;
    await db.transaction((txn) async {
      updatesCount = await txn.update(
        fileTable,
        {
          cloudIdColumn: cloudId,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateData();
    } else {
      final updatedFile = await getFile(id: id);
      _files.removeWhere((file) => file.id == updatedFile.id);
      _files.add(updatedFile);
      _filesStreamController.add(_files);
      return updatedFile;
    }
  }

  Future<Task> updateTask({
    required int id,
    required bool isCompleted,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getTask(id: id);

    // update DB
    late final int updatesCount;
    await db.transaction((txn) async {
      updatesCount = await txn.update(
        taskTable,
        {
          isCompletedColumn: isCompleted,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });

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

  Future<Task> updateProject({
    required int id,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getProject(id: id);

    final String startDateString = startDate.toIso8601String();
    final String endDateString = endDate.toIso8601String();

    // update DB
    late final int updatesCount;
    await db.transaction((txn) async {
      updatesCount = await txn.update(
        projectTable,
        {
          titleColumn: title,
          startDateColumn: startDateString,
          endDateColumn: endDateString,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });

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

  //

  // delete all data from specific table
  Future<int> deleteAllFiles() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final int numberOfDeletions;
    await db.transaction((txn) async {
      numberOfDeletions = await txn.delete(fileTable);
    });

    _files = [];
    _filesStreamController.add(_files);
    return numberOfDeletions;
  }

  Future<int> deleteAllTasks() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final int numberOfDeletions;
    await db.transaction((txn) async {
      numberOfDeletions = await txn.delete(taskTable);
    });

    _tasks = [];
    _tasksStreamController.add(_tasks);
    return numberOfDeletions;
  }

  Future<int> deleteAllDeadlines() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final int numberOfDeletions;
    await db.transaction((txn) async {
      numberOfDeletions = await txn.delete(deadlineTable);
    });

    _deadlines = [];
    _deadlinesStreamController.add(_deadlines);
    return numberOfDeletions;
  }

  Future<int> deleteAllProjects() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final int numberOfDeletions;
    await db.transaction((txn) async {
      numberOfDeletions = await txn.delete(projectTable);
    });

    _projects = [];
    _projectsStreamController.add(_projects);
    return numberOfDeletions;
  }

  //

  // delete specific object from db
  Future<void> deleteFile({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final int deletedCount;
    await db.transaction((txn) async {
      deletedCount = await txn.delete(
        fileTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    if (deletedCount == 0) {
      throw CouldNotDeleteData();
    } else {
      _files.removeWhere((file) => file.id == id);
      _filesStreamController.add(_files);
    }
  }

  Future<void> deleteTask({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final int deletedCount;
    await db.transaction((txn) async {
      deletedCount = await txn.delete(
        taskTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    if (deletedCount == 0) {
      throw CouldNotDeleteData();
    } else {
      _tasks.removeWhere((task) => task.id == id);
      _tasksStreamController.add(_tasks);
    }
  }

  Future<void> deleteDeadline({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final int deletedCount;
    await db.transaction((txn) async {
      deletedCount = await txn.delete(
        deadlineTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    if (deletedCount == 0) {
      throw CouldNotDeleteData();
    } else {
      _deadlines.removeWhere((deadline) => deadline.id == id);
      _deadlinesStreamController.add(_deadlines);
    }
  }

  Future<void> deleteProject({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final int deletedCount;
    await db.transaction((txn) async {
      deletedCount = await txn.delete(
        projectTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    if (deletedCount == 0) {
      throw CouldNotDeleteData();
    } else {
      _projects.removeWhere((project) => project.id == id);
      _projectsStreamController.add(_projects);
    }
  }

  //

  // create specific object in db
  Future<File> createFile({
    required DatabaseUser owner,
    required String title,
    required String subject,
    String? description,
    required String content,
    required String type,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    final lastOpened = DateTime.now();

    // create the file
    late final int fileId;
    await db.transaction((txn) async {
      fileId = await txn.insert(fileTable, {
        userIdColumn: owner.id,
        titleColumn: title,
        subjectColumn: subject,
        descriptionColumn: description,
        contentColumn: content,
        typeColumn: type,
        lastOpenedColumn: lastOpened.toIso8601String(),
      });
    });

    final file = File(
      id: fileId,
      userId: owner.id,
      title: title,
      subject: subject,
      description: description!,
      content: content,
      type: type,
      lastOpened: lastOpened,
    );

    _files.add(file);
    _filesStreamController.add(_files);

    return file;
  }

  Future<Task> createTask({
    required DatabaseUser owner,
    required String title,
    DateTime? dueDate,
    required bool isCompleted,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    final String dueDateString = dueDate!.toIso8601String();

    // create the task
    late final int taskId;
    await db.transaction((txn) async {
      taskId = await txn.insert(taskTable, {
        userIdColumn: owner.id,
        titleColumn: title,
        dueDateColumn: dueDateString,
        isCompletedColumn: isCompleted ? 1 : 0,
      });
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

  Future<Deadline> createDeadline({
    required DatabaseUser owner,
    required String title,
    required DateTime date,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    final String dateString = date.toIso8601String();

    // create the deadline
    late final int deadlineId;
    await db.transaction((txn) async {
      deadlineId = await txn.insert(deadlineTable, {
        userIdColumn: owner.id,
        titleColumn: title,
        dateColumn: dateString,
      });
    });

    final deadline = Deadline(
      id: deadlineId,
      userId: owner.id,
      title: title,
      date: date,
    );

    _deadlines.add(deadline);
    _deadlinesStreamController.add(_deadlines);

    return deadline;
  }

  Future<Project> createProject({
    required DatabaseUser owner,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    final String startDateString = startDate.toIso8601String();
    final String endDateString = endDate.toIso8601String();

    // create the project
    late final int projectId;
    await db.transaction((txn) async {
      projectId = await txn.insert(projectTable, {
        userIdColumn: owner.id,
        titleColumn: title,
        startDateColumn: startDateString,
        endDateColumn: endDateString,
      });
    });

    final project = Project(
      id: projectId,
      userId: owner.id,
      title: title,
      startDate: startDate,
      endDate: endDate,
    );

    _projects.add(project);
    _projectsStreamController.add(_projects);

    return project;
  }

  //

  // user crud
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> results;
    await db.transaction((txn) async {
      results = await txn.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
    });

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Haal de huidige gebruiker op vanuit Firebase Auth
    final firebaseUser = AuthService.firebase().currentUser;
    if (firebaseUser == null) {
      throw UserNotLoggedIn(); // Definieer deze fout indien nodig
    }

    final firebaseUserId = firebaseUser.id;

    // Controleer of de gebruiker al in de SQLite-tabel bestaat
    late final List<Map<String, dynamic>> results;
    await db.transaction((txn) async {
      results = await txn.query(
        userTable,
        limit: 1,
        where: '$idColumn = ?',
        whereArgs: [firebaseUserId],
      );
    });

    if (results.isNotEmpty) {
      throw UserAlreadyExists(); // Definieer deze fout indien nodig
    }

    // Voeg de gebruiker toe aan de SQLite-tabel
    await db.transaction((txn) async {
      await txn.insert(userTable, {
        idColumn: firebaseUserId,
        emailColumn: email.toLowerCase(),
        usernameColumn: 'anonymous',
        experienceColumn: 0,
        openTimeColumn: DateTime.now().toIso8601String(),
        streakColumn: 0,
        sessionsColumn: 0,
      });
    });

    return DatabaseUser(
      id: firebaseUserId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final int deletedCount;
    await db.transaction((txn) async {
      deletedCount = await txn.delete(
        userTable,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      if (deletedCount != 1) {
        throw CouldNotDeleteUser();
      }
    });
  }

  Future<Map<String, dynamic>> fetchUserData({required String userId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> user;
    await db.transaction((txn) async {
      user = await txn.query(
        userTable,
        where: '$idColumn = ?',
        whereArgs: [userId],
        limit: 1,
      );
    });

    return user.first;
  }

  Future<void> changeUsername(String id, String username) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> user;
    await db.transaction((txn) async {
      user = await txn.query(
        userTable,
        where: '$idColumn = ?',
        whereArgs: [id],
        limit: 1,
      );
    });

    if (user.isEmpty) {
      throw Exception('User not found');
    }
    await db.transaction((txn) async {
      await txn.update(
        userTable,
        {
          usernameColumn: username,
        },
        where: '$idColumn = ?',
        whereArgs: [id],
      );
    });
  }

  //

  // function when user completed learning a file
  Future<void> completedFile(String id, int addedXP) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    late final List<Map<String, dynamic>> user;
    await db.transaction((txn) async {
      user = await txn.query(
        userTable,
        where: '$idColumn = ?',
        whereArgs: [id],
        limit: 1,
      );
    });

    if (user.isEmpty) {
      throw Exception('User not found');
    }

    final currentUser = user.first;

    // Haal bestaande waarden op
    final currentXP = currentUser[experienceColumn] as int? ?? 0;
    final currentStreak = currentUser[streakColumn] as int? ?? 0;
    final lastOpenedString = currentUser[openTimeColumn] as String;
    final lastOpened = DateTime.parse(lastOpenedString);

    // Bereken XP en streak
    final now = DateTime.now();
    int updatedStreak = currentStreak;

    // Controleer of de gebruiker gisteren actief was
    if (now.difference(lastOpened).inDays == 1) {
      updatedStreak += 1;
    } else if (now.difference(lastOpened).inDays > 1) {
      updatedStreak = 1; // Reset streak
    }

    // Werk XP en andere velden bij
    final updatedXP = currentXP + addedXP;

    // Werk de gebruiker bij in de database
    await db.transaction((txn) async {
      await txn.update(
        userTable,
        {
          experienceColumn: updatedXP,
          streakColumn: updatedStreak,
          openTimeColumn: now.toIso8601String(),
        },
        where: '$idColumn = ?',
        whereArgs: [id],
      );
    });
  }

  //

  // db functions
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // create the tables
      await db.transaction((txn) async {
        await txn.execute(createUserTable);
        await txn.execute(createFileTable);
        await txn.execute(createTaskTable);
        await txn.execute(createTagsTable);
        await txn.execute(createDeadlineTable);
        await txn.execute(createProjectTable);
      });

      await _cacheFiles();
      await _cacheTasks();
      await _cacheDeadlines();
      await _cacheProjects();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

//

// class for database user
@immutable
class DatabaseUser {
  final String id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as String,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
