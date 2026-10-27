import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/core/theme/category_style.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/features/shared/category_avatar.dart';
import 'package:pocket_budget/l10n/l10n.dart';

/// Share of spending per category: one proportional bar, then a row per category.
class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key, required this.expenses});

  final List<Expense> expenses;

  static final _percent = NumberFormat.percentPattern('tr');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    final totals = <ExpenseCategory, int>{};
    for (final expense in expenses) {
      totals.update(expense.category, (sum) => sum + expense.amount, ifAbsent: () => expense.amount);
    }
    final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0, (sum, entry) => sum + entry.value);

    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, entry) in entries.indexed) ...[
                      if (index > 0) const SizedBox(width: 3),
                      Expanded(
                        flex: entry.value,
                        child: ColoredBox(color: entry.key.chart(brightness)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CategoryAvatar(category: entry.key, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(entry.key.label(l10n), style: theme.textTheme.bodyLarge),
                    ),
                    Text(
                      _percent.format(entry.value / total),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 104,
                      child: Text(
                        Money.format(entry.value),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
