import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BillsDatabase {
  static const _databaseName = 'bills_database.db';
  static const _databaseVersion = 1;

  BillsDatabase._privateConstructor();

  static final BillsDatabase instance = BillsDatabase._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDB();
    return _database!;
  }

  Future<Database> _initializeDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        date TEXT,
        notification INTEGER,
        recurrence INTEGER,
        paid INTEGER,
        value REAL
      )
    ''');
  }
}
