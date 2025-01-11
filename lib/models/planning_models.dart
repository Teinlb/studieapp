import 'package:studieapp/services/local/local_constants.dart';

class Task {
  final int id;
  final String userId;
  final String title;
  final DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.dueDate,
    this.isCompleted = false,
  });

  Task.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as String,
        title = map[titleColumn] as String,
        dueDate = map[dueDateColumn] != null
            ? DateTime.parse(map[dueDateColumn] as String)
            : null,
        isCompleted = (map[isCompletedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Task, ID = $id, userId = $userId, title = $title, date = $dueDate';
}

class Tag {
  final int id;
  final String userId;
  final String title;

  Tag({
    required this.id,
    required this.userId,
    required this.title,
  });

  Tag.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as String,
        title = map[titleColumn] as String;

  @override
  String toString() => 'Tag, ID = $id, userId = $userId, title = $title';
}

class Deadline {
  final int id;
  final String userId;
  final String title;
  final DateTime date;

  Deadline({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
  });

  Deadline.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as String,
        title = map[titleColumn] as String,
        date = DateTime.parse(map[dateColumn] as String);
}

class Project {
  final int id;
  final String userId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;

  Project({
    required this.id,
    required this.userId,
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  Project.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as String,
        title = map[titleColumn] as String,
        startDate = DateTime.parse(map[startDateColumn] as String),
        endDate = DateTime.parse(map[endDateColumn] as String);
}
