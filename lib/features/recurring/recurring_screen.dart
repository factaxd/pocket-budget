import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/domain/recurring_expense.dart';
import 'package:pocket_budget/features/recurring/recurring_sheet.dart';
import 'package:pocket_budget/features/shared/category_avatar.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final recurring = switch (ref.watch(recurringExpensesProvider)) {
      AsyncValue(:final value?) => value,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showRecurringSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addRecurring),
      ),
      body: switch (recurring) {
        null => const Center(child: CircularProgressIndicator()),
        [] => Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 96),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.repeat_rounded, size: 40, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(l10n.recurringEmptyTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    l10n.recurringEmptyBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        final items => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
            children: [
              Material(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (index, item) in items.indexed) ...[
                      if (index > 0) const Divider(indent: 72),
                      _RecurringTile(recurring: item),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(l10n.recurringMonthlyTotal, style: theme.textTheme.titleMedium),
                    ),
                    Text(
                      Money.format(items.fold(0, (sum, item) => sum + item.amount)),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
      },
    );
  }
}

class _RecurringTile extends StatelessWidget {
  const _RecurringTile({required this.recurring});

  final RecurringExpense recurring;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => showRecurringSheet(context, recurring: recurring),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CategoryAvatar(category: recurring.category),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recurring.note ?? recurring.category.label(l10n),
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    l10n.paydayValue(recurring.dayOfMonth),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              Money.format(recurring.amount),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
