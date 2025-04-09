import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:duito/core/models/task.dart';
import 'package:duito/core/repositories/task_repository.dart';

class TaskRepositoryFirebase implements TaskRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _taskCollection {
    return _firestore.collection('users').doc(_userId).collection('tasks');
  }

  @override
  Future<List<Task>> getTasks() async {
    final snapshot = await _taskCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Task(
        idx: doc.id,
        description: data['task_description'] ?? '',
        completed: data['completed'] == 1 || data['completed'] == true,
      );
    }).toList();
  }

  @override
  Future<void> addTask(Task task) async {
    await _taskCollection.doc(task.idx).set(task.toMap());
  }

  @override
  Future<void> updateTask(Task task) async {
    await _taskCollection.doc(task.idx).update(task.toMap());
  }

  @override
  Future<void> deleteTask(String idx) async {
    await _taskCollection.doc(idx).delete();
  }

  /// Sube todas las tareas locales a Firebase
  Future<void> syncFromLocal(List<Task> localTasks) async {
    final batch = _firestore.batch();
    final colRef = _taskCollection;

    for (var task in localTasks) {
      final docRef = colRef.doc(task.idx);
      batch.set(docRef, task.toMap());
    }

    await batch.commit();
  }
}
