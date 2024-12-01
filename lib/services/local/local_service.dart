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
import 'dart:developer' as devtools show log;

class LocalService {
  Database? _db;
  DatabaseUser? _user;

  List<File> _files = [];
  List<Task> _tasks = [];
  List<Tag> _tags = [];
  List<Deadline> _deadlines = [];
  List<Project> _projects = [];

  static final LocalService _shared = LocalService._sharedInstance();
  LocalService._sharedInstance() {
    _initStreams();
  }
  factory LocalService() => _shared;

  late final StreamController<List<File>> _filesStreamController;
  late final StreamController<List<Task>> _tasksStreamController;
  late final StreamController<List<Deadline>> _deadlinesStreamController;
  late final StreamController<List<Project>> _projectsStreamController;

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

  // cache functions
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

  Future<void> _cacheTags() async {
    final allTags = await getAllTags();
    _tags = allTags.toList();
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

  Future<Iterable<File>> getAllFiles() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final files = await db.query(fileTable);

    return files.map((fileRow) => File.fromRow(fileRow));
  }

  Future<Iterable<Task>> getAllTasks() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final tasks = await db.query(taskTable);

    return tasks.map((taskRow) => Task.fromRow(taskRow));
  }

  Future<Iterable<Tag>> getAllTags() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final tags = await db.query(tagsTable);

    return tags.map((tagRow) => Tag.fromRow(tagRow));
  }

  Future<Iterable<Deadline>> getAllDeadlines() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deadlines = await db.query(deadlineTable);

    return deadlines.map((deadlineRow) => Deadline.fromRow(deadlineRow));
  }

  Future<Iterable<Project>> getAllProjects() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final projects = await db.query(projectTable);

    return projects.map((projectRow) => Project.fromRow(projectRow));
  }

  Future<File> getFile({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Haal het bestand op uit de database
    final files = await db.query(
      fileTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (files.isEmpty) {
      throw CouldNotFindData();
    } else {
      // Update de laatst geopende tijd
      final now = DateTime.now();
      await db.update(
        fileTable,
        {
          lastOpenedColumn: now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

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

  Future<Deadline> getDeadline({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deadlines = await db.query(
      deadlineTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

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
    final projects = await db.query(
      projectTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

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

  Future<File> updateFile({
    required int id,
    required String content,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getFile(id: id);

    // update DB
    final updatesCount = await db.update(
      fileTable,
      {
        contentColumn: content,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

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
    devtools.log("TESTETET");

    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getFile(id: id);

    // update DB
    final updatesCount = await db.update(
      fileTable,
      {
        cloudIdColumn: cloudId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    devtools.log(updatesCount.toString());

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
    final updatesCount = await db.update(
      projectTable,
      {
        titleColumn: title,
        startDateColumn: startDateString,
        endDateColumn: endDateString,
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

  Future<int> deleteAllFiles() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(fileTable);
    _files = [];
    _filesStreamController.add(_files);
    return numberOfDeletions;
  }

  Future<int> deleteAllTasks() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(taskTable);
    _tasks = [];
    _tasksStreamController.add(_tasks);
    return numberOfDeletions;
  }

  Future<int> deleteAllDeadlines() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(deadlineTable);
    _deadlines = [];
    _deadlinesStreamController.add(_deadlines);
    return numberOfDeletions;
  }

  Future<int> deleteAllProjects() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(projectTable);
    _projects = [];
    _projectsStreamController.add(_projects);
    return numberOfDeletions;
  }

  Future<void> deleteFile({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      fileTable,
      where: 'id = ?',
      whereArgs: [id],
    );
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

  Future<void> deleteDeadline({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      deadlineTable,
      where: 'id = ?',
      whereArgs: [id],
    );
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
    final deletedCount = await db.delete(
      projectTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteData();
    } else {
      _projects.removeWhere((project) => project.id == id);
      _projectsStreamController.add(_projects);
    }
  }

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
    final fileId = await db.insert(fileTable, {
      userIdColumn: owner.id,
      titleColumn: title,
      subjectColumn: subject,
      descriptionColumn: description,
      contentColumn: content,
      typeColumn: type,
      lastOpenedColumn: lastOpened.toIso8601String(),
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
    final deadlineId = await db.insert(deadlineTable, {
      userIdColumn: owner.id,
      titleColumn: title,
      dateColumn: dateString,
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
    final projectId = await db.insert(projectTable, {
      userIdColumn: owner.id,
      titleColumn: title,
      startDateColumn: startDateString,
      endDateColumn: endDateString,
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

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

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
    final results = await db.query(
      userTable,
      limit: 1,
      where: '$idColumn = ?',
      whereArgs: [firebaseUserId],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExists(); // Definieer deze fout indien nodig
    }

    // Voeg de gebruiker toe aan de SQLite-tabel
    await db.insert(userTable, {
      idColumn: firebaseUserId,
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: firebaseUserId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

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
      await db.execute(createUserTable);
      await db.execute(createFileTable);
      await db.execute(createTaskTable);
      await db.execute(createTagsTable);
      await db.execute(createDeadlineTable);
      await db.execute(createProjectTable);

      await _cacheFiles();
      await _cacheTasks();
      await _cacheTags();
      await _cacheDeadlines();
      await _cacheProjects();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

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
