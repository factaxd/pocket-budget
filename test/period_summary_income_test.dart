import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/domain/income.dart';
import 'package:pocket_budget/domain/income_category.dart';
import 'package:pocket_budget/domain/pay_period.dart';
import 'package:pocket_budget/domain/period_summary.dart';

final _period = PayPeriod.containing(DateTime(2026, 10, 27), 15);

Expense _expense(int amount, DateTime day, {int createdAt = 0}) => Expense(
      amount: amount,
      category: ExpenseCategory.food,
      spentOn: day,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );

Income _income(int amount, DateTime day, {int createdAt = 0}) => Income(
      amount: amount,
      category: IncomeCategory.bonus,
      receivedOn: day,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );

PeriodSummary _summary({
  int salary = 2000000,
  List<Expense> expenses = const [],
  List<Income> incomes = const [],
}) =>
    PeriodSummary(
      period: _period,
      salary: salary,
      expenses: expenses,
      incomes: incomes,
      today: DateTime(2026, 10, 27),
    );

void main() {
  group('PeriodSummary with extra income', () {
    test('adds extra income to what is left', () {
      final summary = _summary(
        expenses: [_expense(500000, DateTime(2026, 10, 20))],
        incomes: [_income(300000, DateTime(2026, 10, 22))],
      );
      expect(summary.extraIncome, 300000);
      expect(summary.totalIncome, 2300000);
      expect(summary.remaining, 1800000);
    });

    test('measures the remaining bar against salary plus extra income', () {
      final summary = _summary(
        salary: 1000000,
        expenses: [_expense(500000, DateTime(2026, 10, 20))],
        incomes: [_income(1000000, DateTime(2026, 10, 22))],
      );
      expect(summary.remainingRatio, 0.75);
    });

    test('extra income can bring an overspent period back above zero', () {
      final summary = _summary(
        salary: 1000000,
        expenses: [_expense(1200000, DateTime(2026, 10, 20))],
        incomes: [_income(400000, DateTime(2026, 10, 22))],
      );
      expect(summary.remaining, 200000);
    });

    test('without extra income behaves as before', () {
      final summary = _summary(expenses: [_expense(500000, DateTime(2026, 10, 20))]);
      expect(summary.extraIncome, 0);
      expect(summary.remaining, 1500000);
      expect(summary.remainingRatio, 0.75);
    });
  });

  test('entries mixes expenses and incomes, newest first', () {
    final lunch = _expense(25000, DateTime(2026, 10, 20), createdAt: 1);
    final bonus = _income(300000, DateTime(2026, 10, 22), createdAt: 1);
    final coffee = _expense(9000, DateTime(2026, 10, 22), createdAt: 2);
    final gift = _income(50000, DateTime(2026, 10, 18), createdAt: 1);

    final summary = _summary(expenses: [coffee, lunch], incomes: [bonus, gift]);
    expect(summary.entries, [coffee, bonus, lunch, gift]);
  });
}
