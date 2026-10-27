import 'dart:math';

import 'package:flutter/material.dart';

import 'package:pocket_budget/domain/expense_category.dart';

extension ExpenseCategoryStyle on ExpenseCategory {
  /// Category color for icons and text, kept dark enough on light surfaces
  /// and light enough on dark ones to stay readable.
  Color foreground(Brightness brightness) {
    final hsl = HSLColor.fromColor(color);
    final lightness = brightness == Brightness.light
        ? min(hsl.lightness, 0.42)
        : max(hsl.lightness, 0.70);
    return hsl.withLightness(lightness).toColor();
  }

  /// Soft tint used behind the category icon.
  Color background(Brightness brightness) => foreground(brightness)
      .withValues(alpha: brightness == Brightness.light ? 0.13 : 0.22);

  /// Color for bars and dots, where no text sits on top.
  Color chart(Brightness brightness) =>
      brightness == Brightness.light ? color : foreground(brightness);
}
