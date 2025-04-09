import 'package:duito/data/firebase/task_repository_firebase.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duito/core/models/task.dart';
import 'package:duito/core/repositories/task_repository.dart';
import 'package:duito/core/repositories/task_repository_sync.dart';
import 'package:duito/data/firebase/auth_repository_firebase.dart';
import 'package:duito/util/dialog_box.dart';
import 'package:duito/util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final TaskRepository _taskRepository = TaskRepositorySync();
  List<Task> tasks = [];

  bool logueado = false;
  bool modoLocal = false;

  @override
  void initState() {
    super.initState();
    _cargarEstado();
    loadTasks();
  }

  void _cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      logueado = prefs.getBool('logueado') ?? false;
      modoLocal = prefs.getBool('modo_local') ?? false;
    });
  }

  void loadTasks() async {
    tasks = await _taskRepository.getTasks();
    setState(() {});
  }

  void saveNewTask() async {
    final newTask = Task(
      idx: DateTime.now().millisecondsSinceEpoch.toString(),
      description: _controller.text,
    );

    await _taskRepository.addTask(newTask);
    _controller.clear();
    if (mounted) Navigator.pop(context);
    loadTasks();
  }

  void updateTaskCompletion(bool? value, int index) async {
    final updatedTask = Task(
      idx: tasks[index].idx,
      description: tasks[index].description,
      completed: value!,
    );

    await _taskRepository.updateTask(updatedTask);
    loadTasks();
  }

  void deleteTask(int index) async {
    await _taskRepository.deleteTask(tasks[index].idx);
    loadTasks();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _logout() async {
    final authRepo = AuthRepositoryFirebase();
    await authRepo.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logueado', false);
    await prefs.setBool('modo_local', true);

    setState(() {
      logueado = false;
      modoLocal = true;
    });
  }

  void _loginAndSync() async {
    final authRepo = AuthRepositoryFirebase();
    final ok = await authRepo.signInWithGoogle();

    if (!mounted) return;

    if (ok) {
      // Obtener tareas locales
      final localTasks = await _taskRepository.getTasks();

      // Subirlas a Firebase
      final firebaseRepo = TaskRepositoryFirebase();
      await firebaseRepo.syncFromLocal(localTasks);

      // Guardar estado
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logueado', true);
      await prefs.setBool('modo_local', false);

      if (!mounted) return;
      setState(() {
        logueado = true;
        modoLocal = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tareas sincronizadas con Firebase")),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo iniciar sesión")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        title: const Text("TO DO"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(logueado ? Icons.logout : Icons.login),
            tooltip:
                logueado ? 'Cerrar sesión' : 'Iniciar sesión y sincronizar',
            onPressed: logueado ? _logout : _loginAndSync,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) => ToDoTile(
          taskName: tasks[index].description,
          taskComplete: tasks[index].completed,
          onChanged: (value) => updateTaskCompletion(value, index),
          deleteFunction: (context) => deleteTask(index),
        ),
      ),
    );
  }
}
