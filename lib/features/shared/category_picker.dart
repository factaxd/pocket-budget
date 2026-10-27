import 'package:flutter/material.dart';

import 'package:pocket_budget/core/theme/category_style.dart';
import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/features/shared/category_avatar.dart';
import 'package:pocket_budget/l10n/l10n.dart';

/// Four-column grid of category icons; the chosen one turns solid.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({super.key, required this.selected, required this.onSelected});

  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95,
      children: [
        for (final category in ExpenseCategory.values)
          Semantics(
            selected: category == selected,
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onSelected(category),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CategoryAvatar(category: category, size: 48, filled: category == selected),
                  const SizedBox(height: 6),
                  Text(
                    category.label(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: category == selected ? FontWeight.w700 : FontWeight.w500,
                      color: category == selected
                          ? category.foreground(theme.brightness)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
