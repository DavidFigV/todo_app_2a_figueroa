class Task {
  final String idx;
  final String description;
  final bool completed;

  Task({required this.idx, required this.description, this.completed = false});

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        idx: map['idx'],
        description: map['task_description'],
        completed: map['completed'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'idx': idx,
        'task_description': description,
        'completed': completed ? 1 : 0,
      };
}