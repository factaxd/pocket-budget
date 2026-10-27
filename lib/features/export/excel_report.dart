import 'package:excel/excel.dart';

import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/income.dart';
import 'package:pocket_budget/domain/ledger_entry.dart';
import 'package:pocket_budget/l10n/app_localizations.dart';
import 'package:pocket_budget/l10n/l10n.dart';

class PeriodRow {
  const PeriodRow({
    required this.label,
    required this.salary,
    required this.extraIncome,
    required this.spent,
  });

  final String label;

  /// In kuruş.
  final int salary;
  final int extraIncome;
  final int spent;

  int get remaining => salary + extraIncome - spent;
}

/// Builds an .xlsx workbook with a sheet of expenses, a sheet of extra incomes
/// and a sheet of period totals.
class ExcelReport {
  ExcelReport(this._l10n);

  final AppLocalizations _l10n;

  static final _headerStyle = CellStyle(bold: true);
  static final _amountStyle = CellStyle(numberFormat: NumFormat.standard_4);
  static final _dateStyle =
      CellStyle(numberFormat: const CustomDateTimeNumFormat(formatCode: 'dd.mm.yyyy'));

  List<int> build({
    required List<Expense> expenses,
    required List<Income> incomes,
    required List<PeriodRow> periods,
  }) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet()!;
    excel.rename(defaultSheet, _l10n.sheetExpenses);

    _writeEntries(excel[_l10n.sheetExpenses], expenses);
    _writeEntries(excel[_l10n.sheetIncomes], incomes);

    final summarySheet = excel[_l10n.sheetSummary];
    _writeHeader(summarySheet, [
      _l10n.columnPeriod,
      _l10n.columnSalary,
      _l10n.columnExtraIncome,
      _l10n.columnSpent,
      _l10n.columnRemaining,
    ]);
    for (final (index, period) in periods.indexed) {
      final row = index + 1;
      _set(summarySheet, 0, row, TextCellValue(period.label));
      _set(summarySheet, 1, row, _lira(period.salary), _amountStyle);
      _set(summarySheet, 2, row, _lira(period.extraIncome), _amountStyle);
      _set(summarySheet, 3, row, _lira(period.spent), _amountStyle);
      _set(summarySheet, 4, row, _lira(period.remaining), _amountStyle);
    }
    _setWidths(summarySheet, [30, 14, 14, 14, 14]);

    excel.setDefaultSheet(_l10n.sheetExpenses);
    return excel.encode()!;
  }

  void _writeEntries(Sheet sheet, List<LedgerEntry> entries) {
    _writeHeader(sheet, [
      _l10n.columnDate,
      _l10n.columnCategory,
      _l10n.columnNote,
      _l10n.columnAmount,
    ]);
    for (final (index, entry) in entries.indexed) {
      final row = index + 1;
      _set(sheet, 0, row, DateCellValue.fromDateTime(entry.date), _dateStyle);
      _set(sheet, 1, row, TextCellValue(entry.category.label(_l10n)));
      _set(sheet, 2, row, TextCellValue(entry.note ?? ''));
      _set(sheet, 3, row, _lira(entry.amount), _amountStyle);
    }
    _setWidths(sheet, [14, 16, 32, 14]);
  }

  DoubleCellValue _lira(int kurus) => DoubleCellValue(kurus / 100);

  void _writeHeader(Sheet sheet, List<String> titles) {
    for (final (column, title) in titles.indexed) {
      _set(sheet, column, 0, TextCellValue(title), _headerStyle);
    }
  }

  void _set(Sheet sheet, int column, int row, CellValue value, [CellStyle? style]) {
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
      value,
      cellStyle: style,
    );
  }

  void _setWidths(Sheet sheet, List<double> widths) {
    for (final (column, width) in widths.indexed) {
      sheet.setColumnWidth(column, width);
    }
  }
}
