import 'package:pocket_budget/domain/expense_category.dart';

class Expense {
  const Expense({
    this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.spentOn,
    this.createdAt,
    this.recurringId,
  });

  final int? id;

  /// Amount in kuruş.
  final int amount;
  final ExpenseCategory category;
  final String? note;

  /// Calendar date of the expense, without a time component.
  final DateTime spentOn;

  /// Set by the database; used to keep the order of expenses within a day stable.
  final DateTime? createdAt;

  /// The recurring expense that added this one, if any.
  final int? recurringId;
}
