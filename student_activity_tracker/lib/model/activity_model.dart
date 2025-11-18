class Activity {
  String name;
  double duration;
  bool isCompleted;   // <-- ganti dari isDone
  String notes;       // <-- catatan tambahan
  String category;

  Activity({
    required this.name,
    required this.duration,
    required this.isCompleted,
    required this.notes,
    required this.category,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'duration': duration,
      'isCompleted': isCompleted,
      'notes': notes,
      'category': category,
    };
  }

  // Convert from Map
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      name: map['name'],
      duration: map['duration'],
      isCompleted: map['isCompleted'] ?? false,
      notes: map['notes'] ?? "",
      category: map['category'] ?? "Umum",
    );
  }
}
