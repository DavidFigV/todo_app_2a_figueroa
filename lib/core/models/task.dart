class Task {
  final String idx;
  final String description;
  final bool completed;
  final DateTime updatedAt;

  Task({
    required this.idx,
    required this.description,
    this.completed = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        idx: map['idx'],
        description: map['task_description'],
        completed: map['completed'] == 1 || map['completed'] == true,
        updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'idx': idx,
        'task_description': description,
        'completed': completed ? 1 : 0,
        'updated_at': updatedAt.toIso8601String(),
      };
  Task copyWith({
    String? idx,
    String? description,
    bool? completed,
    DateTime? updatedAt,
  }) {
    return Task(
      idx: idx ?? this.idx,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
