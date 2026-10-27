import 'package:flutter/material.dart';

import 'package:pocket_budget/domain/entry_category.dart';

/// Where extra money came from. All shades are green, so income reads as
/// money coming in at a glance, next to the multicolored expense categories.
enum IncomeCategory implements EntryCategory {
  sideJob(Icons.work_rounded, Color(0xFF2E9E6A)),
  bonus(Icons.emoji_events_rounded, Color(0xFF4FA14A)),
  gift(Icons.redeem_rounded, Color(0xFF7FA82B)),
  refund(Icons.undo_rounded, Color(0xFF21A598)),
  sale(Icons.sell_rounded, Color(0xFF3C9A80)),
  investment(Icons.trending_up_rounded, Color(0xFF1F8F5F)),
  other(Icons.more_horiz_rounded, Color(0xFF6E9C7D));

  const IncomeCategory(this.icon, this.color);

  @override
  final IconData icon;

  @override
  final Color color;

  static IncomeCategory fromName(String name) =>
      values.firstWhere((category) => category.name == name, orElse: () => other);
}
