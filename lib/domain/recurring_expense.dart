import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/domain/pay_period.dart';

/// An expense that is added automatically on the same day every month,
/// such as rent or a subscription.
class RecurringExpense {
  const RecurringExpense({
    this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.dayOfMonth,
    required this.generatedThrough,
  });

  final int? id;

  /// Amount in kuruş.
  final int amount;
  final ExpenseCategory category;
  final String? note;

  /// 1-31; moved to the last day in shorter months.
  final int dayOfMonth;

  /// Occurrences up to and including this date have already been added.
  final DateTime generatedThrough;

  /// Dates after [generatedThrough], up to and including [today], on which
  /// the expense is due.
  List<DateTime> dueDates(DateTime today) {
    final from = addDays(generatedThrough, 1);
    final dates = <DateTime>[];
    for (var month = DateTime(from.year, from.month);
        !month.isAfter(today);
        month = DateTime(month.year, month.month + 1)) {
      final date = paydayIn(month.year, month.month, dayOfMonth);
      if (!date.isBefore(from) && !date.isAfter(today)) dates.add(date);
    }
    return dates;
  }

  RecurringExpense copyWith({DateTime? generatedThrough}) => RecurringExpense(
        id: id,
        amount: amount,
        category: category,
        note: note,
        dayOfMonth: dayOfMonth,
        generatedThrough: generatedThrough ?? this.generatedThrough,
      );
}
