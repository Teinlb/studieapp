import 'package:studieapp/services/local/crud_constants.dart';

class File {
  final int id;
  final int userId;
  final String title;
  final String subject;
  final String description;
  final String content;
  final String type;
  DateTime lastOpened;

  File({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.description,
    required this.content,
    required this.type,
    required this.lastOpened,
  });

  /// Factory constructor to create a File object from a database row
  File.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        title = map[titleColumn] as String,
        subject = map[subjectColumn] as String,
        description = map[descriptionColumn] as String,
        content = map[contentColumn] as String,
        type = map[typeColumn] as String,
        lastOpened = DateTime.parse(map[lastOpenedColumn] as String);

  /// Create a new File instance with updated fields
  File copyWith({
    int? id,
    int? userId,
    String? title,
    String? subject,
    String? description,
    String? content,
    String? type,
    DateTime? lastOpened,
  }) {
    return File(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      content: content ?? this.content,
      type: type ?? this.type,
      lastOpened: lastOpened ?? this.lastOpened,
    );
  }
}
