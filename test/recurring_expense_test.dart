import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/domain/recurring_expense.dart';

RecurringExpense _recurring({required int day, required DateTime generatedThrough}) =>
    RecurringExpense(
      amount: 1500000,
      category: ExpenseCategory.rent,
      dayOfMonth: day,
      generatedThrough: generatedThrough,
    );

void main() {
  group('RecurringExpense.dueDates', () {
    test('is empty before the day comes', () {
      final rent = _recurring(day: 5, generatedThrough: DateTime(2026, 10, 27));
      expect(rent.dueDates(DateTime(2026, 11, 4)), isEmpty);
    });

    test('includes the day itself', () {
      final rent = _recurring(day: 5, generatedThrough: DateTime(2026, 10, 27));
      expect(rent.dueDates(DateTime(2026, 11, 5)), [DateTime(2026, 11, 5)]);
    });

    test('catches up on months the app was not opened', () {
      final rent = _recurring(day: 5, generatedThrough: DateTime(2026, 10, 27));
      expect(rent.dueDates(DateTime(2027, 1, 10)), [
        DateTime(2026, 11, 5),
        DateTime(2026, 12, 5),
        DateTime(2027, 1, 5),
      ]);
    });

    test('does not repeat dates already added', () {
      final rent = _recurring(day: 5, generatedThrough: DateTime(2026, 11, 5));
      expect(rent.dueDates(DateTime(2026, 11, 20)), isEmpty);
    });

    test('moves a late day to the end of short months', () {
      final rent = _recurring(day: 31, generatedThrough: DateTime(2027, 1, 31));
      expect(rent.dueDates(DateTime(2027, 3, 1)), [DateTime(2027, 2, 28)]);
    });

    test('covers a day already passed in the current month', () {
      // A new recurring expense starts just before the current period.
      final bill = _recurring(day: 20, generatedThrough: DateTime(2026, 10, 14));
      expect(bill.dueDates(DateTime(2026, 10, 27)), [DateTime(2026, 10, 20)]);
    });
  });
}
