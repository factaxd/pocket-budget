import 'package:sqflite/sqflite.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/domain/income.dart';
import 'package:pocket_budget/domain/income_category.dart';

class IncomeRepository {
  IncomeRepository(this._db);

  final Database _db;

  static const _table = 'incomes';

  /// Incomes dated from [start] (inclusive) to [end] (exclusive), newest first.
  Future<List<Income>> inRange(DateTime start, DateTime end) async {
    final rows = await _db.query(
      _table,
      where: 'received_on >= ? AND received_on < ?',
      whereArgs: [toIsoDate(start), toIsoDate(end)],
      orderBy: 'received_on DESC, created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  /// All incomes, oldest first.
  Future<List<Income>> all() async {
    final rows = await _db.query(_table, orderBy: 'received_on ASC, created_at ASC');
    return rows.map(_fromRow).toList();
  }

  Future<DateTime?> earliestDate() async {
    final rows = await _db.rawQuery('SELECT MIN(received_on) AS earliest FROM $_table');
    final value = rows.first['earliest'] as String?;
    return value == null ? null : parseIsoDate(value);
  }

  /// Inserts the income, keeping its id and creation time when present
  /// (used to restore a deleted income).
  Future<void> insert(Income income) async {
    await _db.insert(_table, {
      if (income.id != null) 'id': income.id,
      ..._toRow(income),
      'created_at': (income.createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    });
  }

  Future<void> update(Income income) async {
    await _db.update(_table, _toRow(income), where: 'id = ?', whereArgs: [income.id]);
  }

  Future<void> delete(int id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _toRow(Income income) => {
        'amount': income.amount,
        'category': income.category.name,
        'note': income.note,
        'received_on': toIsoDate(income.receivedOn),
      };

  Income _fromRow(Map<String, Object?> row) => Income(
        id: row['id'] as int,
        amount: row['amount'] as int,
        category: IncomeCategory.fromName(row['category'] as String),
        note: row['note'] as String?,
        receivedOn: parseIsoDate(row['received_on'] as String),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );
}
