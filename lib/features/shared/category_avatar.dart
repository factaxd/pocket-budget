import 'package:flutter/material.dart';

import 'package:pocket_budget/core/theme/category_style.dart';
import 'package:pocket_budget/domain/expense_category.dart';

/// The category icon in a tinted circle, or a solid one when [filled].
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.category,
    this.size = 40,
    this.filled = false,
  });

  final ExpenseCategory category;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final foreground = category.foreground(brightness);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? foreground : category.background(brightness),
        shape: BoxShape.circle,
      ),
      child: Icon(
        category.icon,
        size: size * 0.5,
        color: filled ? theme.colorScheme.surface : foreground,
      ),
    );
  }
}
