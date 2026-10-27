import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/pay_period.dart';

class PeriodSummary {
  const PeriodSummary({
    required this.period,
    required this.salary,
    required this.expenses,
    required this.today,
  });

  final PayPeriod period;
  final int salary;

  /// Newest first.
  final List<Expense> expenses;
  final DateTime today;

  int get spent => expenses.fold(0, (sum, expense) => sum + expense.amount);

  int get remaining => salary - spent;

  /// Share of the salary that is still left, between 0 and 1.
  double get remainingRatio => salary <= 0 ? 0 : (remaining / salary).clamp(0, 1);

  bool get isCurrent => period.contains(today);

  /// Days until the next payday, counting today.
  int get daysLeft => isCurrent ? daysBetween(today, period.end) : 0;

  /// How much can be spent per day to finish the period on budget.
  int? get dailyAllowance => isCurrent && remaining > 0 ? remaining ~/ daysLeft : null;
}
