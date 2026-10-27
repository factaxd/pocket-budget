import 'package:pocket_budget/domain/income_category.dart';
import 'package:pocket_budget/domain/ledger_entry.dart';

/// Money received on top of the salary, such as a bonus or a side job.
class Income implements LedgerEntry {
  const Income({
    this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.receivedOn,
    this.createdAt,
  });

  @override
  final int? id;

  @override
  final int amount;

  @override
  final IncomeCategory category;

  @override
  final String? note;

  final DateTime receivedOn;

  @override
  final DateTime? createdAt;

  @override
  DateTime get date => receivedOn;
}
