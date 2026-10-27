import 'package:flutter/material.dart';

enum ExpenseCategory {
  food(Icons.restaurant_rounded, Color(0xFFE5484D)),
  coffee(Icons.local_cafe_rounded, Color(0xFF8D6248)),
  groceries(Icons.shopping_basket_rounded, Color(0xFF5BA34F)),
  shopping(Icons.shopping_bag_rounded, Color(0xFFD6479B)),
  beauty(Icons.spa_rounded, Color(0xFF9B59D0)),
  transport(Icons.directions_bus_rounded, Color(0xFF2F86D6)),
  bills(Icons.receipt_long_rounded, Color(0xFFD9A21B)),
  rent(Icons.home_rounded, Color(0xFF5B6BD8)),
  health(Icons.medical_services_rounded, Color(0xFF21A598)),
  entertainment(Icons.local_activity_rounded, Color(0xFFF2994A)),
  gift(Icons.card_giftcard_rounded, Color(0xFF9AAE2B)),
  other(Icons.more_horiz_rounded, Color(0xFF8A8296));

  const ExpenseCategory(this.icon, this.color);

  final IconData icon;

  /// Base hue of the category; see `ExpenseCategoryStyle` for theme-aware shades.
  final Color color;

  static ExpenseCategory fromName(String name) =>
      values.firstWhere((category) => category.name == name, orElse: () => other);
}
