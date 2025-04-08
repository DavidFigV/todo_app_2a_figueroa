import 'package:flutter/material.dart';
import 'package:duito/core/models/task.dart';
import 'package:duito/core/repositories/task_repository.dart';
import 'package:duito/data/sqlite/task_repository_sqlite.dart';
import 'package:duito/util/dialog_box.dart';
import 'package:duito/util/todo_tile.dart';
import 'package:duito/data/firebase/auth_repository_firebase.dart';
import 'package:duito/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final TaskRepository _taskRepository = TaskRepositorySQLite();
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
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

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
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
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
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
