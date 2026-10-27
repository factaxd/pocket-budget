import 'package:intl/intl.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/domain/pay_period.dart';
import 'package:pocket_budget/l10n/app_localizations.dart';

final _dayMonth = DateFormat('d MMMM', 'tr');
final _dayMonthYear = DateFormat('d MMMM y', 'tr');
final _dayMonthWeekday = DateFormat('d MMMM EEEE', 'tr');

/// For example `15 Ekim – 14 Kasım`, with years shown when they are not obvious.
String formatPeriodRange(PayPeriod period, {required DateTime today}) {
  final start = period.start;
  final last = period.lastDay;
  if (start.year != last.year) {
    return '${_dayMonthYear.format(start)} – ${_dayMonthYear.format(last)}';
  }
  final end = last.year == today.year ? _dayMonth.format(last) : _dayMonthYear.format(last);
  return '${_dayMonth.format(start)} – $end';
}

/// `Bugün`, `Dün`, or a date such as `12 Ekim Pazartesi`.
String formatDayLabel(DateTime day, AppLocalizations l10n, {required DateTime today}) {
  final difference = daysBetween(day, today);
  if (difference == 0) return l10n.today;
  if (difference == 1) return l10n.yesterday;
  return day.year == today.year ? _dayMonthWeekday.format(day) : _dayMonthYear.format(day);
}
