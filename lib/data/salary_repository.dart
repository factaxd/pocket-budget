import 'package:sqflite/sqflite.dart';

/// Stores the salary of each pay period, so changing the salary later
/// does not rewrite the history of earlier periods.
class SalaryRepository {
  SalaryRepository(this._db);

  final Database _db;

  static const _table = 'period_salaries';

  Future<int?> forPeriod(String periodKey) async {
    final rows = await _db.query(
      _table,
      columns: ['amount'],
      where: 'period_key = ?',
      whereArgs: [periodKey],
    );
    return rows.isEmpty ? null : rows.first['amount'] as int;
  }

  Future<void> setForPeriod(String periodKey, int amount) async {
    await _db.insert(
      _table,
      {'period_key': periodKey, 'amount': amount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
