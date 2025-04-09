import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteHandler {
  Future<Database> getDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'database_sqlite.db');

    // Abre o crea la base de datos
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Método para crear las tablas
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        idx TEXT PRIMARY KEY,
        task_description TEXT,
        completed INTEGER DEFAULT 0, 
        updated_at TEXT
      );
    ''');
  }
}
