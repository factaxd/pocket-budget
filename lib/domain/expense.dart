import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/domain/ledger_entry.dart';

class Expense implements LedgerEntry {
  const Expense({
    this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.spentOn,
    this.createdAt,
    this.recurringId,
  });

  @override
  final int? id;

  @override
  final int amount;

  @override
  final ExpenseCategory category;

  @override
  final String? note;

  final DateTime spentOn;

  @override
  final DateTime? createdAt;

  /// The recurring expense that added this one, if any.
  final int? recurringId;

  @override
  DateTime get date => spentOn;
}
