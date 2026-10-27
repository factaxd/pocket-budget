import 'package:pocket_budget/domain/entry_category.dart';

/// A dated amount in a period: an expense or an extra income.
abstract interface class LedgerEntry {
  int? get id;

  /// Amount in kuruş, always positive; the entry type tells the direction.
  int get amount;
  EntryCategory get category;
  String? get note;

  /// Calendar date of the entry, without a time component.
  DateTime get date;

  /// Set by the database; used to keep the order of entries within a day stable.
  DateTime? get createdAt;
}

/// Sorts entries newest first, the way every list in the app shows them.
int compareNewestFirst(LedgerEntry a, LedgerEntry b) {
  final byDate = b.date.compareTo(a.date);
  if (byDate != 0) return byDate;
  final aCreated = a.createdAt?.millisecondsSinceEpoch ?? 0;
  final bCreated = b.createdAt?.millisecondsSinceEpoch ?? 0;
  return bCreated.compareTo(aCreated);
}
