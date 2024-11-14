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
  final DateTime startDate;
  final DateTime endDate;

  Project({
    required this.title,
    required this.startDate,
    required this.endDate,
  });
}
