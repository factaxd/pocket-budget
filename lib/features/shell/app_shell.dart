import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/features/calendar/calendar_screen.dart';
import 'package:pocket_budget/features/expense/expense_sheet.dart';
import 'package:pocket_budget/features/home/home_screen.dart';
import 'package:pocket_budget/features/settings/settings_screen.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

/// Bottom navigation between the summary, calendar and settings tabs.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _summaryTab = 0;
  static const _calendarTab = 1;

  int _tab = _summaryTab;

  /// New expenses go to the day the user is looking at.
  DateTime _defaultExpenseDate() {
    final today = ref.read(todayProvider);
    if (_tab == _calendarTab) {
      final day = ref.read(selectedDayProvider);
      return day.isAfter(today) ? today : day;
    }
    final period = ref.read(selectedPeriodProvider);
    return period.contains(today) ? today : period.lastDay;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [HomeScreen(), CalendarScreen(), SettingsScreen()],
      ),
      floatingActionButton: _tab == _summaryTab || _tab == _calendarTab
          ? FloatingActionButton.extended(
              onPressed: () => showExpenseSheet(context, defaultDate: _defaultExpenseDate()),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addExpense),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (tab) => setState(() => _tab = tab),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
            label: l10n.tabSummary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: l10n.tabCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
