import 'package:flutter/material.dart';

import 'package:pocket_budget/l10n/l10n.dart';

/// Shows the days of a month as a calendar-like grid and returns the chosen day.
Future<int?> showPaydayPicker(
  BuildContext context, {
  required int initialDay,
  String? title,
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _PaydayPickerDialog(initialDay: initialDay, title: title),
  );
}

class _PaydayPickerDialog extends StatelessWidget {
  const _PaydayPickerDialog({required this.initialDay, this.title});

  final int initialDay;

  /// Defaults to asking for the payday.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(title ?? l10n.paydayPickerTitle),
      content: SizedBox(
        width: 320,
        child: GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          children: [
            for (var day = 1; day <= 31; day++)
              _DayButton(
                day: day,
                selected: day == initialDay,
                scheme: scheme,
                onTap: () => Navigator.of(context).pop(day),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
      ],
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.day,
    required this.selected,
    required this.scheme,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerLowest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Center(
          child: Text(
            '$day',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}
