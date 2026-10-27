import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/core/theme/category_style.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/expense_category.dart';

/// A Monday-first month calendar. Days with spending show their total
/// and a dot for each category spent on (up to three).
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.expenses,
    required this.selectedDay,
    required this.today,
    required this.onDaySelected,
  });

  final DateTime month;
  final List<Expense> expenses;
  final DateTime selectedDay;
  final DateTime today;
  final ValueChanged<DateTime> onDaySelected;

  static final _weekday = DateFormat('EEE', 'tr');
  static const _maxDots = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = DateTime(month.year, month.month).weekday - 1;

    final totals = <int, int>{};
    final categories = <int, List<ExpenseCategory>>{};
    for (final expense in expenses) {
      final day = expense.spentOn.day;
      totals.update(day, (sum) => sum + expense.amount, ifAbsent: () => expense.amount);
      final dayCategories = categories.putIfAbsent(day, () => []);
      if (!dayCategories.contains(expense.category)) dayCategories.add(expense.category);
    }

    // 2026-01-05 is a Monday; used only to print weekday names.
    final weekdayNames = [
      for (var i = 0; i < 7; i++) _weekday.format(DateTime(2026, 1, 5 + i)),
    ];

    return Column(
      children: [
        Row(
          children: [
            for (final name in weekdayNames)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.82,
          children: [
            for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              _DayCell(
                date: DateTime(month.year, month.month, day),
                total: totals[day] ?? 0,
                categories: (categories[day] ?? const []).take(_maxDots).toList(),
                selected: selectedDay == DateTime(month.year, month.month, day),
                today: today,
                onTap: onDaySelected,
              ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.total,
    required this.categories,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final DateTime date;
  final int total;
  final List<ExpenseCategory> categories;
  final bool selected;
  final DateTime today;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isToday = date == today;
    final isFuture = date.isAfter(today);
    final foreground = selected
        ? scheme.onPrimary
        : isFuture
            ? scheme.onSurfaceVariant.withValues(alpha: 0.6)
            : scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: selected ? scheme.primary : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: isToday && !selected
              ? BorderSide(color: scheme.primary, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onTap: () => onTap(date),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: theme.textTheme.titleSmall?.copyWith(color: foreground),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 14,
                child: total > 0
                    ? Text(
                        Money.formatCompact(total),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final category in categories)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? scheme.onPrimary : category.chart(theme.brightness),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
