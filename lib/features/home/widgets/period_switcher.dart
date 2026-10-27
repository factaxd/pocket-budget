import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/domain/period_summary.dart';
import 'package:pocket_budget/features/shared/date_labels.dart';
import 'package:pocket_budget/l10n/app_localizations.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

/// Period dates with the time left until payday, and arrows to move between periods.
class PeriodSwitcher extends ConsumerWidget {
  const PeriodSwitcher({super.key, required this.summary});

  final PeriodSummary summary;

  String _timeLeft(AppLocalizations l10n) {
    if (!summary.isCurrent) return l10n.statusPeriodClosed;
    return summary.daysLeft == 1
        ? l10n.statusPaydayTomorrow
        : l10n.statusDaysLeft(summary.daysLeft);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final period = summary.period;
    final offset = ref.watch(periodOffsetProvider);
    final offsetNotifier = ref.read(periodOffsetProvider.notifier);
    final earliest = switch (ref.watch(earliestPeriodProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final canGoBack = earliest != null && period.start.isAfter(earliest.start);

    return Row(
      children: [
        IconButton(
          tooltip: l10n.previousPeriod,
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: canGoBack ? offsetNotifier.previous : null,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                formatPeriodRange(period, today: summary.today),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    _timeLeft(l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.nextPeriod,
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: offset < 0 ? offsetNotifier.next : null,
        ),
      ],
    );
  }
}
