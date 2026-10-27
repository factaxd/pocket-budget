import 'package:sqflite/sqflite.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/domain/recurring_expense.dart';

class RecurringRepository {
  RecurringRepository(this._db);

  final Database _db;

  static const _table = 'recurring_expenses';

  /// Ordered by the day of the month they are due.
  Future<List<RecurringExpense>> all() async {
    final rows = await _db.query(_table, orderBy: 'day_of_month ASC, id ASC');
    return rows.map(_fromRow).toList();
  }

  /// Returns the id of the new row.
  Future<int> insert(RecurringExpense recurring) => _db.insert(_table, _toRow(recurring));

  Future<void> update(RecurringExpense recurring) async {
    await _db.update(_table, _toRow(recurring), where: 'id = ?', whereArgs: [recurring.id]);
  }

  /// Removes the template; expenses it already added stay.
  Future<void> delete(int id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _toRow(RecurringExpense recurring) => {
        'amount': recurring.amount,
        'category': recurring.category.name,
        'note': recurring.note,
        'day_of_month': recurring.dayOfMonth,
        'generated_through': toIsoDate(recurring.generatedThrough),
      };

  RecurringExpense _fromRow(Map<String, Object?> row) => RecurringExpense(
        id: row['id'] as int,
        amount: row['amount'] as int,
        category: ExpenseCategory.fromName(row['category'] as String),
        note: row['note'] as String?,
        dayOfMonth: row['day_of_month'] as int,
        generatedThrough: parseIsoDate(row['generated_through'] as String),
      );
}
