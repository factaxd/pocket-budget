import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/domain/period_summary.dart';
import 'package:pocket_budget/features/home/all_expenses_screen.dart';
import 'package:pocket_budget/features/home/widgets/balance_card.dart';
import 'package:pocket_budget/features/home/widgets/period_switcher.dart';
import 'package:pocket_budget/features/shared/entry_list.dart';
import 'package:pocket_budget/features/shared/section_header.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

/// Fits on one screen without scrolling: balance first, then as many of the
/// latest entries as the remaining space allows.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(periodSummaryProvider);

    return SafeArea(
      bottom: false,
      child: summary.when(
        skipLoadingOnReload: true,
        data: (summary) => _HomeContent(summary: summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(context.l10n.loadFailed, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final userName = ref.watch(settingsProvider.select((settings) => settings.userName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Text(
            userName.isEmpty ? l10n.appTitle : l10n.greeting(userName),
            style: Theme.of(context).textTheme.headlineSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: PeriodSwitcher(summary: summary),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BalanceCard(summary: summary),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _RecentEntries(summary: summary),
          ),
        ),
      ],
    );
  }
}

class _RecentEntries extends StatelessWidget {
  const _RecentEntries({required this.summary});

  final PeriodSummary summary;

  static const _headerHeight = 48.0;

  /// Keeps the last row clear of the floating add button.
  static const _fabClearance = 84.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = summary.entries;

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: _fabClearance),
        child: Center(child: _EmptyEntries()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowHeight = MediaQuery.textScalerOf(context).scale(EntryTile.height);
        final available = constraints.maxHeight - _headerHeight - _fabClearance;
        final count = max(1, available ~/ rowHeight);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: l10n.recentTitle,
              action: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AllExpensesScreen()),
                ),
                child: Text(l10n.seeAll),
              ),
            ),
            // Scrolls only as a fallback, e.g. with very large system font sizes.
            Flexible(
              child: SingleChildScrollView(
                child: EntryList(entries: entries.take(count).toList(), showDate: true),
              ),
            ),
            const SizedBox(height: _fabClearance),
          ],
        );
      },
    );
  }
}

class _EmptyEntries extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.receipt_long_outlined, size: 40, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(l10n.emptyEntriesTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          l10n.emptyEntriesBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
