import 'package:studieapp/services/local/crud_constants.dart';

class File {
  final int id;
  final int userId;
  final String title;
  final String subject;
  final String description;
  final String content;
  final String type;

  File({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.description,
    required this.content,
    required this.type,
  });

  File.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        title = map[titleColumn] as String,
        subject = map[titleColumn] as String,
        description = map[titleColumn] as String,
        content = map[titleColumn] as String,
        type = map[titleColumn] as String;
}
