import 'package:flutter/material.dart';
import 'package:todo_app_2a_figueroa/core/models/task.dart';
import 'package:todo_app_2a_figueroa/core/repositories/task_repository.dart';
import 'package:todo_app_2a_figueroa/data/sqlite/task_repository_sqlite.dart';
import 'package:todo_app_2a_figueroa/util/dialog_box.dart';
import 'package:todo_app_2a_figueroa/util/todo_tile.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(title: const Text("TO DO"), centerTitle: true),
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
