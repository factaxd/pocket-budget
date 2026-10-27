import 'package:flutter/material.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/core/theme/cuzdan_colors.dart';
import 'package:pocket_budget/domain/period_summary.dart';
import 'package:pocket_budget/l10n/l10n.dart';

/// The remaining money of the period, with a bar that drains as money is spent.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.summary});

  final PeriodSummary summary;

  static const _animationDuration = Duration(milliseconds: 550);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = context.cuzdanColors;
    final duration =
        MediaQuery.disableAnimationsOf(context) ? Duration.zero : _animationDuration;
    final overBudget = summary.remaining < 0;

    final amountStyle = theme.textTheme.displayMedium?.copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 44,
      height: 1.15,
      letterSpacing: -1.5,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: overBudget ? colors.heroNegative : colors.heroForeground,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
      decoration: BoxDecoration(
        color: colors.heroBackground,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            overBudget ? l10n.statusOverBudget : l10n.remaining,
            style: theme.textTheme.titleMedium?.copyWith(
              color: overBudget ? colors.heroNegative : colors.heroMuted,
            ),
          ),
          const SizedBox(height: 2),
          TweenAnimationBuilder<double>(
            // When over budget the label says so, and the amount shows by how much.
            tween: Tween(end: summary.remaining.abs().toDouble()),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(Money.format(value.round()), style: amountStyle, maxLines: 1),
            ),
          ),
          const SizedBox(height: 16),
          _RemainingBar(ratio: summary.remainingRatio, duration: duration, colors: colors),
          const SizedBox(height: 18),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _Stat(
                  label: l10n.statSpent,
                  value: Money.format(summary.spent),
                  colors: colors,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: l10n.statSalary,
                  value: Money.format(summary.salary),
                  colors: colors,
                ),
              ),
              // Only shown when there is some, so the card stays simple otherwise.
              if (summary.extraIncome > 0)
                Expanded(
                  child: _Stat(
                    label: l10n.statExtraIncome,
                    value: '+${Money.format(summary.extraIncome)}',
                    valueColor: colors.heroPositive,
                    colors: colors,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.valueColor,
    required this.colors,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final CuzdanColors colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(color: colors.heroMuted)),
        const SizedBox(height: 2),
        // Three stats share the row when there is extra income, so large amounts shrink to fit.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? colors.heroForeground,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _RemainingBar extends StatelessWidget {
  const _RemainingBar({required this.ratio, required this.duration, required this.colors});

  final double ratio;
  final Duration duration;
  final CuzdanColors colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child: ColoredBox(
          color: colors.heroTrack,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: ratio),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.heroFill,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
