import 'package:flutter/material.dart';
import 'package:todo_app_2a_figueroa/handlers/sqlite_handeler.dart';
import 'package:todo_app_2a_figueroa/util/dialog_box.dart';
import 'package:todo_app_2a_figueroa/util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text controller
  final _controller = TextEditingController();

  SqliteHandler mSqliteHandler = SqliteHandler();

  // List of todo task
  List toDoList = [];

  @override
  void initState() {
    super.initState();
    getTask(); // Cargar las tareas al iniciar la app
  }

  // Checkbox was tapped
  void checkBoxChanged(bool? value, int index) async {
    var db = await mSqliteHandler.getDb();
    await db.update(
      'tasks',
      {'completed': value! ? 1 : 0},
      where: 'idx = ?',
      whereArgs: [mTasks[index]['idx']],
    );

    getTask(); // Recargar las tareas después de actualizar
  }

  // Save new task
  void saveNewTask() async {
    // Guarda en SQLite
    var db = await mSqliteHandler.getDb();
    await db.insert('tasks', {
      'idx': DateTime.now().millisecondsSinceEpoch.toString(), // ID único
      'task_description': _controller.text,
    });

    // Luego de guardar, actualiza la lista y limpia el controlador
    _controller.clear();

    // Verifica si el widget sigue montado antes de usar el contexto
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Recarga las tareas
    getTask();
  }

  // Create a new task
  void createNewTask() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onSave: saveNewTask,
            onCancel: () => Navigator.of(context).pop,
          );
        });
  }

  // Delete task
  void deleteTask(int index) async {
    var db = await mSqliteHandler.getDb();
    await db.delete(
      'tasks',
      where: 'idx = ?',
      whereArgs: [mTasks[index]['idx']],
    );

    getTask(); // Recargar tareas después de eliminar
  }

  List<dynamic> mTasks = [];

  getTask() async {
    var db = await mSqliteHandler.getDb();
    var mResult = await db.query('tasks');

    setState(() {
      mTasks = mResult
          .map((e) => {
                'idx': e['idx'],
                'task_description': e['task_description'],
                'completed': e['completed'] == 1, // Convierte 0/1 en bool
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        title: Text("TO DO"),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: mTasks.length, // Debe usar mTasks en lugar de toDoList
        itemBuilder: (context, index) {
          return ToDoTile(
            taskName: mTasks[index]['task_description'],
            taskComplete: mTasks[index]['completed'],
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
    );
  }
}
