class File {
  final int id;
  final String title;
  final String subject;
  final String description;
  final String content;
  final String type;
  final String userId;

  File({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.content,
    required this.type,
    required this.userId,
  });

  factory File.fromMap(Map<String, dynamic> map) {
    return File(
      id: map['id'] != null ? map['id'] as int : 0,
      title: map['title'] ?? 'Untitled',
      subject: map['subject'] ?? 'Unknown',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'unknown',
      userId: map['userId'] ?? 'unknown',
    );
  }
}
