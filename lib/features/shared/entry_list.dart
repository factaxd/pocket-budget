import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/core/theme/cuzdan_colors.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/income.dart';
import 'package:pocket_budget/domain/ledger_entry.dart';
import 'package:pocket_budget/features/entry/entry_sheet.dart';
import 'package:pocket_budget/features/shared/category_avatar.dart';
import 'package:pocket_budget/features/shared/date_labels.dart';
import 'package:pocket_budget/features/shared/entry_deleted_snack_bar.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

/// Expenses and incomes in a rounded group. Tap a row to edit it, swipe it left to delete.
class EntryList extends ConsumerStatefulWidget {
  const EntryList({super.key, required this.entries, this.showDate = false});

  final List<LedgerEntry> entries;

  /// Shows each entry's day under its amount, for lists that span several days.
  final bool showDate;

  @override
  ConsumerState<EntryList> createState() => _EntryListState();
}

/// Expenses and incomes live in separate tables, so ids alone can collide.
(bool, int?) _keyOf(LedgerEntry entry) => (entry is Income, entry.id);

class _EntryListState extends ConsumerState<EntryList> {
  /// Swiped rows leave the tree at once, before the database refresh arrives.
  final _dismissed = <(bool, int?)>{};

  @override
  void didUpdateWidget(EntryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Once the refreshed list no longer has the row, forget it so an undo can bring it back.
    _dismissed.removeWhere((key) => !widget.entries.any((entry) => _keyOf(entry) == key));
  }

  void _delete(LedgerEntry entry) {
    setState(() => _dismissed.add(_keyOf(entry)));
    final actions = ref.read(entryActionsProvider);
    actions.delete(entry);
    showEntryDeletedSnackBar(
      messenger: ScaffoldMessenger.of(context),
      l10n: context.l10n,
      actions: actions,
      entry: entry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final entry in widget.entries)
        if (!_dismissed.contains(_keyOf(entry))) entry,
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
          for (final (index, entry) in visible.indexed) ...[
            if (index > 0) const Divider(indent: 72),
            Dismissible(
              key: ValueKey(_keyOf(entry)),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _delete(entry),
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
              child: EntryTile(entry: entry, today: widget.showDate ? today : null),
            ),
          ],
        ],
      ),
    );
  }
}

class EntryTile extends StatelessWidget {
  const EntryTile({super.key, required this.entry, this.today});

  /// Row height including the divider between rows; used to fit rows on screen.
  static const height = 65.0;

  final LedgerEntry entry;

  /// When set, the entry's day is shown relative to this date.
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final categoryLabel = entry.category.label(l10n);
    final note = entry.note;
    final isIncome = entry is Income;
    final isRecurring = switch (entry) {
      Expense(:final recurringId) => recurringId != null,
      _ => false,
    };

    return InkWell(
      onTap: () => showEntrySheet(context, entry: entry, defaultDate: entry.date),
      child: Container(
        height: height - 1,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CategoryAvatar(category: entry.category),
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
                      if (isRecurring) ...[
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
                  // Incomes carry a plus sign and the positive color, so money
                  // coming in never looks like another expense.
                  isIncome ? '+${Money.format(entry.amount)}' : Money.format(entry.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isIncome ? context.cuzdanColors.positive : null,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (today case final today?)
                  Text(
                    formatDayLabel(entry.date, l10n, today: today),
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
