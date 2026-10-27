import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/core/theme/cuzdan_colors.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/income.dart';
import 'package:pocket_budget/domain/ledger_entry.dart';
import 'package:pocket_budget/features/calendar/month_grid.dart';
import 'package:pocket_budget/features/shared/date_labels.dart';
import 'package:pocket_budget/features/shared/entry_list.dart';
import 'package:pocket_budget/features/shared/section_header.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  static final _monthTitle = DateFormat('MMMM y', 'tr');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final selection = ref.read(selectedDayProvider.notifier);
    final month = DateTime(selectedDay.year, selectedDay.month);

    final expenses = switch (ref.watch(monthExpensesProvider(month))) {
      AsyncValue(:final value?) => value,
      _ => const <Expense>[],
    };
    final incomes = switch (ref.watch(monthIncomesProvider(month))) {
      AsyncValue(:final value?) => value,
      _ => const <Income>[],
    };
    final earliest = switch (ref.watch(earliestPeriodProvider)) {
      AsyncValue(:final value?) => value.start,
      _ => today,
    };
    final canGoBack = month.isAfter(DateTime(earliest.year, earliest.month));
    final canGoForward = month.isBefore(DateTime(today.year, today.month));

    final dayEntries = <LedgerEntry>[
      for (final expense in expenses)
        if (expense.spentOn == selectedDay) expense,
      for (final income in incomes)
        if (income.receivedOn == selectedDay) income,
    ]..sort(compareNewestFirst);
    final daySpent = dayEntries
        .whereType<Expense>()
        .fold(0, (sum, expense) => sum + expense.amount);
    final dayIncome = dayEntries
        .whereType<Income>()
        .fold(0, (sum, income) => sum + income.amount);
    final totalStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l10n.tabCalendar, style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                tooltip: l10n.previousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: canGoBack
                    ? () => selection.showMonth(DateTime(month.year, month.month - 1))
                    : null,
              ),
              Expanded(
                child: Text(
                  _capitalize(_monthTitle.format(month)),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l10n.nextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: canGoForward
                    ? () => selection.showMonth(DateTime(month.year, month.month + 1))
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Material(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: MonthGrid(
                month: month,
                expenses: expenses,
                incomes: incomes,
                selectedDay: selectedDay,
                today: today,
                onDaySelected: selection.select,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: formatDayLabel(selectedDay, l10n, today: today),
            action: dayEntries.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [
                        if (dayIncome > 0)
                          Text(
                            '+${Money.format(dayIncome)}',
                            style: totalStyle?.copyWith(color: context.cuzdanColors.positive),
                          ),
                        if (daySpent > 0) Text(Money.format(daySpent), style: totalStyle),
                      ],
                    ),
                  )
                : null,
          ),
          if (dayEntries.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Text(
                l10n.noEntriesOnDay,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            EntryList(entries: dayEntries),
        ],
      ),
    );
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
