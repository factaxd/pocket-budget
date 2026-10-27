import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/domain/ledger_entry.dart';
import 'package:pocket_budget/domain/pay_period.dart';
import 'package:pocket_budget/features/export/excel_report.dart';
import 'package:pocket_budget/features/shared/date_labels.dart';
import 'package:pocket_budget/l10n/app_localizations.dart';
import 'package:pocket_budget/providers.dart';

enum ExportOutcome { saved, cancelled, empty }

const _xlsxMimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

/// Writes every expense and extra income to an .xlsx file at a location the user picks.
Future<ExportOutcome> exportExpensesToExcel(WidgetRef ref, AppLocalizations l10n) async {
  final expenses = await ref.read(expenseRepositoryProvider).all();
  final incomes = await ref.read(incomeRepositoryProvider).all();
  if (expenses.isEmpty && incomes.isEmpty) return ExportOutcome.empty;

  final settings = ref.read(settingsProvider);
  final salaries = ref.read(salaryRepositoryProvider);
  final today = ref.read(todayProvider);
  final payday = settings.payday;

  var firstDay = today;
  for (final date in [
    if (expenses.isNotEmpty) expenses.first.spentOn,
    if (incomes.isNotEmpty) incomes.first.receivedOn,
    ?settings.startedOn,
  ]) {
    if (date.isBefore(firstDay)) firstDay = date;
  }

  final current = PayPeriod.containing(today, payday);
  final periods = <PeriodRow>[];
  for (var period = PayPeriod.containing(firstDay, payday);
      !period.start.isAfter(current.start);
      period = period.shift(1, payday)) {
    int totalIn(Iterable<LedgerEntry> entries) => entries
        .where((entry) => period.contains(entry.date))
        .fold(0, (sum, entry) => sum + entry.amount);
    periods.add(PeriodRow(
      label: formatPeriodRange(period, today: today),
      salary: await salaries.forPeriod(period.key) ?? settings.monthlySalary,
      extraIncome: totalIn(incomes),
      spent: totalIn(expenses),
    ));
  }

  final bytes =
      ExcelReport(l10n).build(expenses: expenses, incomes: incomes, periods: periods);
  final savedTo = await FilePicker.saveFile(
    dialogTitle: l10n.exportExcel,
    fileName: '${l10n.exportFileName}-${toIsoDate(today)}.xlsx',
    bytes: Uint8List.fromList(bytes),
    mimeType: _xlsxMimeType,
  );
  return savedTo == null ? ExportOutcome.cancelled : ExportOutcome.saved;
}
