import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/income.dart';
import 'package:pocket_budget/domain/ledger_entry.dart';
import 'package:pocket_budget/domain/pay_period.dart';

class PeriodSummary {
  const PeriodSummary({
    required this.period,
    required this.salary,
    required this.expenses,
    this.incomes = const [],
    required this.today,
  });

  final PayPeriod period;
  final int salary;

  /// Newest first.
  final List<Expense> expenses;

  /// Extra income on top of the salary, newest first.
  final List<Income> incomes;
  final DateTime today;

  int get spent => expenses.fold(0, (sum, expense) => sum + expense.amount);

  int get extraIncome => incomes.fold(0, (sum, income) => sum + income.amount);

  /// Everything the period has to spend: the salary plus any extra income.
  int get totalIncome => salary + extraIncome;

  int get remaining => totalIncome - spent;

  /// Share of the total income that is still left, between 0 and 1.
  double get remainingRatio =>
      totalIncome <= 0 ? 0 : (remaining / totalIncome).clamp(0, 1);

  /// Expenses and incomes together, newest first.
  List<LedgerEntry> get entries =>
      <LedgerEntry>[...expenses, ...incomes]..sort(compareNewestFirst);

  bool get isCurrent => period.contains(today);

  /// Days until the next payday, counting today.
  int get daysLeft => isCurrent ? daysBetween(today, period.end) : 0;
}
