import 'package:duito/core/models/task.dart';
import 'package:duito/core/repositories/task_repository.dart';
import 'package:duito/data/sqlite/task_repository_sqlite.dart';
import 'package:duito/data/firebase/task_repository_firebase.dart';
import 'package:duito/data/firebase/auth_repository_firebase.dart';

class TaskRepositorySync implements TaskRepository {
  final TaskRepositorySQLite _localRepo = TaskRepositorySQLite();
  final TaskRepositoryFirebase _remoteRepo = TaskRepositoryFirebase();
  final AuthRepositoryFirebase _authRepo = AuthRepositoryFirebase();

  bool get _isOnline => _authRepo.isLoggedIn();

  @override
  Future<List<Task>> getTasks() async {
    print('🔥 Obteniendo tareas locales...');
    final localTasks = await _localRepo.getTasks();
    print('📦 Local: ${localTasks.length}');

    if (_isOnline) {
      print('🌐 Está online, obteniendo tareas de Firebase...');
      final remoteTasks = await _remoteRepo.getTasks();
      print('📡 Firebase: ${remoteTasks.length}');

      for (final remote in remoteTasks) {
        final match = localTasks.firstWhere(
          (local) => local.idx == remote.idx,
          orElse: () => Task(idx: '', description: ''),
        );

        if (match.idx == '' || remote.updatedAt.isAfter(match.updatedAt)) {
          print('📝 Insertando/actualizando ${remote.description}');
          await _localRepo.addTask(remote);
        }
      }
    }

    final result = await _localRepo.getTasks();
    print('✅ Tareas finales en SQLite: ${result.length}');
    return result;
  }

  @override
  Future<void> addTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    print('🧪 Guardando tarea: ${updatedTask.description}');
    print('🧪 Está online: $_isOnline');

    await _localRepo.addTask(updatedTask);

    if (_isOnline) {
      print('🧪 Subiendo a Firebase...');
      await _remoteRepo.addTask(updatedTask);
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _localRepo.updateTask(updatedTask);
    if (_isOnline) await _remoteRepo.updateTask(updatedTask);
  }

  @override
  Future<void> deleteTask(String idx) async {
    await _localRepo.deleteTask(idx);
    if (_isOnline) await _remoteRepo.deleteTask(idx);
  }
}
