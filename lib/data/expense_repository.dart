import 'package:sqflite/sqflite.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/expense_category.dart';

class ExpenseRepository {
  ExpenseRepository(this._db);

  final Database _db;

  static const _table = 'expenses';

  /// Expenses dated from [start] (inclusive) to [end] (exclusive), newest first.
  Future<List<Expense>> inRange(DateTime start, DateTime end) async {
    final rows = await _db.query(
      _table,
      where: 'spent_on >= ? AND spent_on < ?',
      whereArgs: [toIsoDate(start), toIsoDate(end)],
      orderBy: 'spent_on DESC, created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  /// All expenses, oldest first.
  Future<List<Expense>> all() async {
    final rows = await _db.query(_table, orderBy: 'spent_on ASC, created_at ASC');
    return rows.map(_fromRow).toList();
  }

  Future<DateTime?> earliestDate() async {
    final rows = await _db.rawQuery('SELECT MIN(spent_on) AS earliest FROM $_table');
    final value = rows.first['earliest'] as String?;
    return value == null ? null : parseIsoDate(value);
  }

  /// Inserts the expense, keeping its id and creation time when present
  /// (used to restore a deleted expense).
  Future<void> insert(Expense expense) async {
    await _db.insert(_table, {
      if (expense.id != null) 'id': expense.id,
      ..._toRow(expense),
      'created_at': (expense.createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    });
  }

  Future<void> update(Expense expense) async {
    await _db.update(_table, _toRow(expense), where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<void> delete(int id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _toRow(Expense expense) => {
        'amount': expense.amount,
        'category': expense.category.name,
        'note': expense.note,
        'spent_on': toIsoDate(expense.spentOn),
        'recurring_id': expense.recurringId,
      };

  Expense _fromRow(Map<String, Object?> row) => Expense(
        id: row['id'] as int,
        amount: row['amount'] as int,
        category: ExpenseCategory.fromName(row['category'] as String),
        note: row['note'] as String?,
        spentOn: parseIsoDate(row['spent_on'] as String),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
        recurringId: row['recurring_id'] as int?,
      );
}
