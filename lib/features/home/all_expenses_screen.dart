import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/features/home/widgets/category_breakdown.dart';
import 'package:pocket_budget/features/home/widgets/expense_day_group.dart';
import 'package:pocket_budget/features/shared/date_labels.dart';
import 'package:pocket_budget/features/shared/section_header.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

/// The period shown on the home screen in full: spending per category,
/// then every expense grouped by day.
class AllExpensesScreen extends ConsumerWidget {
  const AllExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = switch (ref.watch(periodSummaryProvider)) {
      AsyncValue(:final value?) => value,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          summary == null ? '' : formatPeriodRange(summary.period, today: summary.today),
        ),
      ),
      body: summary == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                if (summary.expenses.isNotEmpty) ...[
                  SectionHeader(title: context.l10n.categoriesTitle),
                  CategoryBreakdown(expenses: summary.expenses),
                  const SizedBox(height: 16),
                  SectionHeader(title: context.l10n.expensesTitle),
                ],
                for (final day in groupExpensesByDay(summary.expenses))
                  ExpenseDayGroup(day: day, today: summary.today),
                if (summary.expenses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Text(context.l10n.emptyExpensesTitle, textAlign: TextAlign.center),
                  ),
              ],
            ),
    );
  }
}
