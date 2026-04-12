// Data model representing a single task in the app.
class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final List<Map<String, dynamic>> subtasks;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.subtasks = const [],
    required this.createdAt,
  });

  // Serialize this task to a Map for Firestore writes
  Map<String, dynamic> toMap() => {
        'title': title,
        'isCompleted': isCompleted,
        'subtasks': subtasks,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Deserialize a Firestore document snapshot into a [Task].
  factory Task.fromMap(String id, Map<String, dynamic> data) => Task(
        id: id,
        title: data['title'] ?? '',
        isCompleted: data['isCompleted'] ?? false,
        subtasks: List<Map<String, dynamic>>.from(data['subtasks'] ?? []),
        createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      );

  // Create a copy of this task with selectively overridden fields.
  Task copyWith({
    String? title,
    bool? isCompleted,
    List<Map<String, dynamic>>? subtasks,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
        subtasks: subtasks ?? this.subtasks,
        createdAt: createdAt,
      );

  @override
  String toString() => 'Task(id: $id, title: $title, done: $isCompleted)';
}
