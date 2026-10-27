import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/data/expense_repository.dart';
import 'package:pocket_budget/data/recurring_repository.dart';
import 'package:pocket_budget/data/salary_repository.dart';
import 'package:pocket_budget/data/settings_repository.dart';
import 'package:pocket_budget/domain/app_settings.dart';
import 'package:pocket_budget/domain/expense.dart';
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

  var earliest = settings.startedOn ?? today;
  if (firstExpense != null && firstExpense.isBefore(earliest)) earliest = firstExpense;
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
    return PeriodSummary(period: period, salary: salary, expenses: expenses, today: today);
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

final expenseActionsProvider = Provider(ExpenseActions.new);

class ExpenseActions {
  ExpenseActions(this._ref);

  final Ref _ref;

  ExpenseRepository get _repository => _ref.read(expenseRepositoryProvider);

  Future<void> save(Expense expense) async {
    if (expense.id == null) {
      await _repository.insert(expense);
    } else {
      await _repository.update(expense);
    }
    _refresh();
  }

  Future<void> delete(Expense expense) async {
    await _repository.delete(expense.id!);
    _refresh();
  }

  /// Puts back an expense removed by [delete], with its original id.
  Future<void> restore(Expense expense) async {
    await _repository.insert(expense);
    _refresh();
  }

  /// Saves a new [expense] and repeats it on the same day every month.
  Future<void> saveRepeating(Expense expense) async {
    final today = _ref.read(todayProvider);
    final recurringId = await _recurring.insert(RecurringExpense(
      amount: expense.amount,
      category: expense.category,
      note: expense.note,
      dayOfMonth: expense.spentOn.day,
      // This month's occurrence is the expense itself.
      generatedThrough: expense.spentOn.isAfter(today) ? expense.spentOn : today,
    ));
    await _repository.insert(Expense(
      amount: expense.amount,
      category: expense.category,
      note: expense.note,
      spentOn: expense.spentOn,
      recurringId: recurringId,
    ));
    _refresh();
  }

  /// Creates or updates a recurring expense. Occurrences after its
  /// `generatedThrough` date are added by the sync that the refresh triggers.
  Future<void> saveRecurring(RecurringExpense recurring) async {
    if (recurring.id == null) {
      await _recurring.insert(recurring);
    } else {
      await _recurring.update(recurring);
    }
    _refresh();
  }

  /// Stops a recurring expense; the expenses it already added stay.
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
    _ref.invalidate(earliestPeriodProvider);
  }
}
