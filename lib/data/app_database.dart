import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

const _fileName = 'cuzdan.db';
const _schemaVersion = 2;

Future<Database> openAppDatabase() async {
  final directory = await getDatabasesPath();
  return openDatabase(
    p.join(directory, _fileName),
    version: _schemaVersion,
    onCreate: (db, version) async {
      await _createV1(db);
      await _upgradeToV2(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) await _upgradeToV2(db);
    },
  );
}

Future<void> _createV1(Database db) async {
  final batch = db.batch()
    ..execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        spent_on TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''')
    ..execute('CREATE INDEX idx_expenses_spent_on ON expenses (spent_on)')
    ..execute('''
      CREATE TABLE period_salaries (
        period_key TEXT PRIMARY KEY,
        amount INTEGER NOT NULL
      )
    ''')
    ..execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  await batch.commit(noResult: true);
}

/// Adds monthly recurring expenses.
Future<void> _upgradeToV2(Database db) async {
  final batch = db.batch()
    ..execute('''
      CREATE TABLE recurring_expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        day_of_month INTEGER NOT NULL,
        generated_through TEXT NOT NULL
      )
    ''')
    ..execute('ALTER TABLE expenses ADD COLUMN recurring_id INTEGER');
  await batch.commit(noResult: true);
}
