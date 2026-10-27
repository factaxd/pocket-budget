import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_budget/domain/pay_period.dart';
import 'package:pocket_budget/domain/period_summary.dart';

void main() {
  group('PayPeriod.containing', () {
    test('starts on the payday when the date is on or after it', () {
      final period = PayPeriod.containing(DateTime(2026, 10, 27), 15);
      expect(period.start, DateTime(2026, 10, 15));
      expect(period.end, DateTime(2026, 11, 15));
      expect(period.lastDay, DateTime(2026, 11, 14));
    });

    test('belongs to the previous month before the payday', () {
      final period = PayPeriod.containing(DateTime(2026, 10, 3), 15);
      expect(period.start, DateTime(2026, 9, 15));
      expect(period.end, DateTime(2026, 10, 15));
    });

    test('the payday itself opens a new period', () {
      final period = PayPeriod.containing(DateTime(2026, 10, 15), 15);
      expect(period.start, DateTime(2026, 10, 15));
    });

    test('payday 1 matches calendar months', () {
      final period = PayPeriod.containing(DateTime(2026, 2, 10), 1);
      expect(period.start, DateTime(2026, 2, 1));
      expect(period.end, DateTime(2026, 3, 1));
    });

    test('moves a late payday to the end of short months', () {
      final period = PayPeriod.containing(DateTime(2026, 3, 5), 31);
      expect(period.start, DateTime(2026, 2, 28));
      expect(period.end, DateTime(2026, 3, 31));
    });

    test('crosses the year boundary', () {
      final period = PayPeriod.containing(DateTime(2027, 1, 4), 20);
      expect(period.start, DateTime(2026, 12, 20));
      expect(period.end, DateTime(2027, 1, 20));
      expect(period.key, '2026-12');
    });
  });

  test('shift moves by whole periods', () {
    final period = PayPeriod.containing(DateTime(2026, 10, 27), 15);
    expect(period.shift(-1, 15).start, DateTime(2026, 9, 15));
    expect(period.shift(-10, 15).start, DateTime(2025, 12, 15));
  });

  group('PeriodSummary', () {
    final period = PayPeriod.containing(DateTime(2026, 10, 27), 15);

    test('counts the days left until payday, including today', () {
      final summary = PeriodSummary(
        period: period,
        salary: 2000000,
        expenses: const [],
        today: DateTime(2026, 11, 5),
      );
      expect(summary.daysLeft, 10);
    });

    test('has no days left once the period is over', () {
      final summary = PeriodSummary(
        period: period,
        salary: 2000000,
        expenses: const [],
        today: DateTime(2026, 12, 1),
      );
      expect(summary.isCurrent, isFalse);
      expect(summary.daysLeft, 0);
    });
  });
}
