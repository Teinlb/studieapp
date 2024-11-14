// Models
class Task {
  String title;
  DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.title,
    this.dueDate,
    this.isCompleted = false,
  });
}

class Deadline {
  String title;
  DateTime date;

  Deadline({
    required this.title,
    required this.date,
  });
}

class Project {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int completedTasks;
  final int totalTasks;

  Project({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.completedTasks = 0,
    this.totalTasks = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  static Project fromMap(Map<String, dynamic> map) {
    return Project(
      title: map['title'],
      description: map['description'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
    );
  }
}
