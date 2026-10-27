import 'package:flutter/material.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/features/shared/date_labels.dart';
import 'package:pocket_budget/features/shared/entry_list.dart';
import 'package:pocket_budget/l10n/l10n.dart';

class ExpenseDay {
  const ExpenseDay({required this.date, required this.expenses});

  final DateTime date;
  final List<Expense> expenses;

  int get total => expenses.fold(0, (sum, expense) => sum + expense.amount);
}

/// Groups expenses that are already sorted newest first into one entry per day.
List<ExpenseDay> groupExpensesByDay(Iterable<Expense> expenses) {
  final days = <ExpenseDay>[];
  for (final expense in expenses) {
    if (days.isNotEmpty && days.last.date == expense.spentOn) {
      days.last.expenses.add(expense);
    } else {
      days.add(ExpenseDay(date: expense.spentOn, expenses: [expense]));
    }
  }
  return days;
}

class ExpenseDayGroup extends StatelessWidget {
  const ExpenseDayGroup({
    super.key,
    required this.day,
    required this.today,
    this.showTotal = true,
  });

  final ExpenseDay day;
  final DateTime today;

  /// Hidden when only some of the day's expenses are listed.
  final bool showTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.titleSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(formatDayLabel(day.date, context.l10n, today: today), style: mutedStyle),
              ),
              if (showTotal) Text(Money.format(day.total), style: mutedStyle),
            ],
          ),
        ),
        EntryList(entries: day.expenses),
      ],
    );
  }
}
