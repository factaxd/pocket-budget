import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/data/expense_repository.dart';
import 'package:pocket_budget/data/income_repository.dart';
import 'package:pocket_budget/data/recurring_repository.dart';
import 'package:pocket_budget/data/salary_repository.dart';
import 'package:pocket_budget/data/settings_repository.dart';
import 'package:pocket_budget/domain/app_settings.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/income.dart';
import 'package:pocket_budget/domain/ledger_entry.dart';
import 'package:pocket_budget/domain/pay_period.dart';
import 'package:pocket_budget/domain/period_summary.dart';
import 'package:pocket_budget/domain/recurring_expense.dart';

final databaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

/// Settings read from the database before the first frame.
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final settingsRepositoryProvider =
    Provider((ref) => SettingsRepository(ref.watch(databaseProvider)));
final expenseRepositoryProvider =
    Provider((ref) => ExpenseRepository(ref.watch(databaseProvider)));
final incomeRepositoryProvider =
    Provider((ref) => IncomeRepository(ref.watch(databaseProvider)));
final salaryRepositoryProvider =
    Provider((ref) => SalaryRepository(ref.watch(databaseProvider)));
final recurringRepositoryProvider =
    Provider((ref) => RecurringRepository(ref.watch(databaseProvider)));

/// Refreshed when the app returns to the foreground, so the current period
/// moves on after midnight.
final todayProvider = Provider<DateTime>((ref) => dateOnly(DateTime.now()));

/// Adds recurring expenses that have come due. Expense lists wait for it,
/// so they always include the automatic entries up to today.
final recurringSyncProvider = FutureProvider<void>((ref) async {
  final today = ref.watch(todayProvider);
  final recurringExpenses = ref.watch(recurringRepositoryProvider);
  final expenses = ref.watch(expenseRepositoryProvider);

  for (final recurring in await recurringExpenses.all()) {
    final dueDates = recurring.dueDates(today);
    if (dueDates.isEmpty) continue;
    for (final date in dueDates) {
      await expenses.insert(Expense(
        amount: recurring.amount,
        category: recurring.category,
        note: recurring.note,
        spentOn: date,
        recurringId: recurring.id,
      ));
    }
    await recurringExpenses.update(recurring.copyWith(generatedThrough: today));
  }
});

final recurringExpensesProvider = FutureProvider<List<RecurringExpense>>(
  (ref) => ref.watch(recurringRepositoryProvider).all(),
);

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  Future<void> completeOnboarding({
    required String userName,
    required int monthlySalary,
    required int payday,
  }) async {
    final today = ref.read(todayProvider);
    await _save(state.copyWith(
      userName: userName,
      monthlySalary: monthlySalary,
      payday: payday,
      startedOn: today,
    ));
    await _setCurrentPeriodSalary(monthlySalary);
  }

  Future<void> updateUserName(String userName) => _save(state.copyWith(userName: userName));

  /// Changes the salary of the current period and every later one.
  Future<void> updateMonthlySalary(int amount) async {
    await _save(state.copyWith(monthlySalary: amount));
    await _setCurrentPeriodSalary(amount);
    ref.invalidate(periodSummaryProvider);
  }

  Future<void> updatePayday(int payday) async {
    await _save(state.copyWith(payday: payday));
    ref.read(periodOffsetProvider.notifier).reset();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) =>
      _save(state.copyWith(themeMode: themeMode));

  Future<void> _setCurrentPeriodSalary(int amount) {
    final period = PayPeriod.containing(ref.read(todayProvider), state.payday);
    return ref.read(salaryRepositoryProvider).setForPeriod(period.key, amount);
  }

  Future<void> _save(AppSettings settings) async {
    await ref.read(settingsRepositoryProvider).save(settings);
    state = settings;
  }
}

/// How many periods before the current one the home screen shows (0 is current).
final periodOffsetProvider =
    NotifierProvider<PeriodOffsetNotifier, int>(PeriodOffsetNotifier.new);

class PeriodOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void previous() => state = state - 1;

  void next() {
    if (state < 0) state = state + 1;
  }

  void reset() => state = 0;
}

final currentPeriodProvider = Provider<PayPeriod>((ref) {
  final payday = ref.watch(settingsProvider.select((settings) => settings.payday));
  return PayPeriod.containing(ref.watch(todayProvider), payday);
});

final selectedPeriodProvider = Provider<PayPeriod>((ref) {
  final payday = ref.watch(settingsProvider.select((settings) => settings.payday));
  return ref.watch(currentPeriodProvider).shift(ref.watch(periodOffsetProvider), payday);
});

/// The oldest period that has data, which limits how far back the user can go.
final earliestPeriodProvider = FutureProvider<PayPeriod>((ref) async {
  final settings = ref.watch(settingsProvider);
  final today = ref.watch(todayProvider);
  final firstExpense = await ref.watch(expenseRepositoryProvider).earliestDate();
  final firstIncome = await ref.watch(incomeRepositoryProvider).earliestDate();

  var earliest = settings.startedOn ?? today;
  for (final date in [firstExpense, firstIncome]) {
    if (date != null && date.isBefore(earliest)) earliest = date;
  }
  return PayPeriod.containing(earliest, settings.payday);
});

final periodSummaryProvider =
    AsyncNotifierProvider<PeriodSummaryNotifier, PeriodSummary>(PeriodSummaryNotifier.new);

class PeriodSummaryNotifier extends AsyncNotifier<PeriodSummary> {
  @override
  Future<PeriodSummary> build() async {
    final period = ref.watch(selectedPeriodProvider);
    final today = ref.watch(todayProvider);
    final defaultSalary =
        ref.watch(settingsProvider.select((settings) => settings.monthlySalary));
    final salaries = ref.watch(salaryRepositoryProvider);

    await ref.watch(recurringSyncProvider.future);
    var salary = await salaries.forPeriod(period.key);
    if (salary == null) {
      salary = defaultSalary;
      // Freeze the salary once a period begins, so later changes don't rewrite it.
      if (period.contains(today)) await salaries.setForPeriod(period.key, salary);
    }

    final expenses = await ref.watch(expenseRepositoryProvider).inRange(period.start, period.end);
    final incomes = await ref.watch(incomeRepositoryProvider).inRange(period.start, period.end);
    return PeriodSummary(
      period: period,
      salary: salary,
      expenses: expenses,
      incomes: incomes,
      today: today,
    );
  }
}

/// Expenses of a calendar month, keyed by the first day of that month.
final monthExpensesProvider =
    FutureProvider.family<List<Expense>, DateTime>((ref, month) async {
  await ref.watch(recurringSyncProvider.future);
  return ref
      .watch(expenseRepositoryProvider)
      .inRange(month, DateTime(month.year, month.month + 1));
});

/// Extra incomes of a calendar month, keyed by the first day of that month.
final monthIncomesProvider = FutureProvider.family<List<Income>, DateTime>(
  (ref, month) => ref
      .watch(incomeRepositoryProvider)
      .inRange(month, DateTime(month.year, month.month + 1)),
);

/// The day picked on the calendar tab; its month is the month on screen.
final selectedDayProvider =
    NotifierProvider<SelectedDayNotifier, DateTime>(SelectedDayNotifier.new);

class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => ref.watch(todayProvider);

  void select(DateTime day) => state = dateOnly(day);

  /// Moves to [month], selecting today when it is the current month.
  void showMonth(DateTime month) {
    final today = ref.read(todayProvider);
    final isCurrentMonth = month.year == today.year && month.month == today.month;
    state = isCurrentMonth ? today : DateTime(month.year, month.month);
  }
}

final entryActionsProvider = Provider(EntryActions.new);

/// Saves and removes expenses and incomes, and refreshes everything that shows them.
class EntryActions {
  EntryActions(this._ref);

  final Ref _ref;

  ExpenseRepository get _repository => _ref.read(expenseRepositoryProvider);
  IncomeRepository get _incomes => _ref.read(incomeRepositoryProvider);

  /// Saves [expense] and starts, updates or stops its monthly repetition.
  Future<void> save(Expense expense, {required bool repeatMonthly}) async {
    int? recurringId;
    if (repeatMonthly) {
      recurringId = await _saveRecurringFor(expense);
    } else if (expense.recurringId != null) {
      await _recurring.delete(expense.recurringId!);
    }

    final saved = Expense(
      id: expense.id,
      amount: expense.amount,
      category: expense.category,
      note: expense.note,
      spentOn: expense.spentOn,
      createdAt: expense.createdAt,
      recurringId: recurringId,
    );
    if (saved.id == null) {
      await _repository.insert(saved);
    } else {
      await _repository.update(saved);
    }
    _refresh();
  }

  Future<void> saveIncome(Income income) async {
    if (income.id == null) {
      await _incomes.insert(income);
    } else {
      await _incomes.update(income);
    }
    _refresh();
  }

  Future<void> delete(LedgerEntry entry) async {
    switch (entry) {
      case Expense():
        await _repository.delete(entry.id!);
      case Income():
        await _incomes.delete(entry.id!);
    }
    _refresh();
  }

  /// Puts back an entry removed by [delete], with its original id.
  Future<void> restore(LedgerEntry entry) async {
    switch (entry) {
      case final Expense expense:
        await _repository.insert(expense);
      case final Income income:
        await _incomes.insert(income);
    }
    _refresh();
  }

  /// Creates or updates the recurring expense that repeats [expense] on its
  /// day every month, and returns its id.
  Future<int> _saveRecurringFor(Expense expense) async {
    final today = _ref.read(todayProvider);
    final existing =
        expense.recurringId == null ? null : await _recurring.byId(expense.recurringId!);

    // The expense itself is this month's occurrence, so new ones start after it.
    var generatedThrough = expense.spentOn.isAfter(today) ? expense.spentOn : today;
    if (existing != null && existing.generatedThrough.isAfter(generatedThrough)) {
      generatedThrough = existing.generatedThrough;
    }
    final recurring = RecurringExpense(
      id: existing?.id,
      amount: expense.amount,
      category: expense.category,
      note: expense.note,
      dayOfMonth: expense.spentOn.day,
      generatedThrough: generatedThrough,
    );
    if (existing == null) return _recurring.insert(recurring);
    await _recurring.update(recurring);
    return existing.id!;
  }

  Future<void> updateRecurring(RecurringExpense recurring) async {
    await _recurring.update(recurring);
    _refresh();
  }

  /// Stops a recurring expense; the expenses it already added stay as regular ones.
  Future<void> deleteRecurring(RecurringExpense recurring) async {
    await _recurring.delete(recurring.id!);
    _refresh();
  }

  RecurringRepository get _recurring => _ref.read(recurringRepositoryProvider);

  void _refresh() {
    _ref.invalidate(recurringSyncProvider);
    _ref.invalidate(recurringExpensesProvider);
    _ref.invalidate(periodSummaryProvider);
    _ref.invalidate(monthExpensesProvider);
    _ref.invalidate(monthIncomesProvider);
    _ref.invalidate(earliestPeriodProvider);
  }
}
