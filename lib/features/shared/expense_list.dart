import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/features/expense/expense_sheet.dart';
import 'package:pocket_budget/features/shared/category_avatar.dart';
import 'package:pocket_budget/features/shared/date_labels.dart';
import 'package:pocket_budget/features/shared/expense_deleted_snack_bar.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

/// Expenses in a rounded group. Tap a row to edit it, swipe it left to delete.
class ExpenseList extends ConsumerStatefulWidget {
  const ExpenseList({super.key, required this.expenses, this.showDate = false});

  final List<Expense> expenses;

  /// Shows each expense's day under its amount, for lists that span several days.
  final bool showDate;

  @override
  ConsumerState<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends ConsumerState<ExpenseList> {
  /// Swiped rows leave the tree at once, before the database refresh arrives.
  final _dismissedIds = <int>{};

  @override
  void didUpdateWidget(ExpenseList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Once the refreshed list no longer has the row, forget it so an undo can bring it back.
    _dismissedIds.removeWhere((id) => !widget.expenses.any((expense) => expense.id == id));
  }

  void _delete(Expense expense) {
    setState(() => _dismissedIds.add(expense.id!));
    final actions = ref.read(expenseActionsProvider);
    actions.delete(expense);
    showExpenseDeletedSnackBar(
      messenger: ScaffoldMessenger.of(context),
      l10n: context.l10n,
      actions: actions,
      expense: expense,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final expense in widget.expenses)
        if (!_dismissedIds.contains(expense.id)) expense,
    ];
    if (visible.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final today = ref.watch(todayProvider);
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, expense) in visible.indexed) ...[
            if (index > 0) const Divider(indent: 72),
            Dismissible(
              key: ValueKey('expense-${expense.id}'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _delete(expense),
              background: ColoredBox(
                color: scheme.error,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Icon(Icons.delete_outline_rounded, color: scheme.onError),
                  ),
                ),
              ),
              child: ExpenseTile(expense: expense, today: widget.showDate ? today : null),
            ),
          ],
        ],
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, this.today});

  /// Row height including the divider between rows; used to fit rows on screen.
  static const height = 65.0;

  final Expense expense;

  /// When set, the expense's day is shown relative to this date.
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final categoryLabel = expense.category.label(l10n);
    final note = expense.note;

    return InkWell(
      onTap: () => showExpenseSheet(context, expense: expense, defaultDate: expense.spentOn),
      child: Container(
        height: height - 1,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CategoryAvatar(category: expense.category),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          note ?? categoryLabel,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (expense.recurringId != null) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.repeat_rounded,
                          size: 16,
                          semanticLabel: l10n.recurringBadge,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                  if (note != null)
                    Text(
                      categoryLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Money.format(expense.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (today case final today?)
                  Text(
                    formatDayLabel(expense.spentOn, l10n, today: today),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
