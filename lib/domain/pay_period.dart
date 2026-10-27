import 'dart:math';

import 'package:pocket_budget/core/dates.dart';

/// A pay period runs from one payday (inclusive) to the next payday (exclusive).
class PayPeriod {
  const PayPeriod({required this.start, required this.end});

  /// Returns the period that [date] falls into for the given [payday] (1-31).
  factory PayPeriod.containing(DateTime date, int payday) {
    final day = dateOnly(date);
    final paydayThisMonth = paydayIn(day.year, day.month, payday);
    final start = day.isBefore(paydayThisMonth)
        ? paydayIn(day.year, day.month - 1, payday)
        : paydayThisMonth;
    return PayPeriod.startingIn(start.year, start.month, payday);
  }

  /// Returns the period whose start falls in the given month.
  factory PayPeriod.startingIn(int year, int month, int payday) {
    final start = paydayIn(year, month, payday);
    return PayPeriod(start: start, end: paydayIn(start.year, start.month + 1, payday));
  }

  final DateTime start;

  /// First day of the next period.
  final DateTime end;

  DateTime get lastDay => addDays(end, -1);

  /// Identifies the period by the month it starts in, so stored data such as the
  /// salary stays attached to the right period even if the payday changes.
  String get key => '${start.year}-${start.month.toString().padLeft(2, '0')}';

  bool contains(DateTime date) {
    final day = dateOnly(date);
    return !day.isBefore(start) && day.isBefore(end);
  }

  PayPeriod shift(int periods, int payday) =>
      PayPeriod.startingIn(start.year, start.month + periods, payday);

  @override
  bool operator ==(Object other) =>
      other is PayPeriod && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// The payday in the given month, moved to the last day when the month is shorter.
DateTime paydayIn(int year, int month, int payday) {
  final normalized = DateTime(year, month);
  final daysInMonth = DateTime(normalized.year, normalized.month + 1, 0).day;
  return DateTime(normalized.year, normalized.month, min(payday, daysInMonth));
}
