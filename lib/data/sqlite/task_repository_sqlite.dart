import 'package:duito/core/models/task.dart';
import 'package:duito/core/repositories/task_repository.dart';
import 'package:duito/handlers/sqlite_handeler.dart';

class TaskRepositorySQLite implements TaskRepository {
  final SqliteHandler _sqliteHandler = SqliteHandler();

  @override
  Future<List<Task>> getTasks() async {
    final db = await _sqliteHandler.getDb();
    final result = await db.query('tasks');
    return result.map((e) => Task.fromMap(e)).toList();
  }

  @override
  Future<void> addTask(Task task) async {
    final db = await _sqliteHandler.getDb();
    await db.insert('tasks', task.toMap());
  }

  @override
  Future<void> updateTask(Task task) async {
    final db = await _sqliteHandler.getDb();
    await db
        .update('tasks', task.toMap(), where: 'idx = ?', whereArgs: [task.idx]);
  }

  @override
  Future<void> deleteTask(String idx) async {
    final db = await _sqliteHandler.getDb();
    await db.delete('tasks', where: 'idx = ?', whereArgs: [idx]);
  }
}
