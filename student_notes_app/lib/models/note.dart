class Note {
  String title;
  String content;
  String category;
  DateTime createdAt;

  Note({
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      content: map['content'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
