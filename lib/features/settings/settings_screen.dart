import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/domain/recurring_expense.dart';
import 'package:pocket_budget/features/export/export_expenses.dart';
import 'package:pocket_budget/features/recurring/recurring_screen.dart';
import 'package:pocket_budget/features/shared/amount_field.dart';
import 'package:pocket_budget/features/shared/payday_picker.dart';
import 'package:pocket_budget/l10n/app_localizations.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _exporting = false;

  SettingsNotifier get _settings => ref.read(settingsProvider.notifier);

  String _recurringSummary(AppLocalizations l10n) {
    final recurring = switch (ref.watch(recurringExpensesProvider)) {
      AsyncValue(:final value?) => value,
      _ => const <RecurringExpense>[],
    };
    if (recurring.isEmpty) return l10n.recurringSummaryEmpty;
    final total = recurring.fold(0, (sum, item) => sum + item.amount);
    return l10n.recurringSummary(recurring.length, Money.format(total));
  }

  Future<void> _editName(String current) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initialName: current),
    );
    if (name != null) await _settings.updateUserName(name);
  }

  Future<void> _editSalary(int current) async {
    final amount = await showDialog<int>(
      context: context,
      builder: (_) => _SalaryDialog(initialAmount: current),
    );
    if (amount != null) await _settings.updateMonthlySalary(amount);
  }

  Future<void> _editPayday(int current) async {
    final day = await showPaydayPicker(context, initialDay: current);
    if (day != null && day != current) await _settings.updatePayday(day);
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _exporting = true);
    try {
      final outcome = await exportExpensesToExcel(ref, l10n);
      final message = switch (outcome) {
        ExportOutcome.saved => l10n.exportSaved,
        ExportOutcome.empty => l10n.exportEmpty,
        ExportOutcome.cancelled => null,
      };
      if (message != null) messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text(l10n.settings, style: Theme.of(context).textTheme.headlineSmall),
          ),
          _SectionTitle(l10n.sectionProfile),
          ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: Text(l10n.nameLabel),
            subtitle: Text(settings.userName.isEmpty ? l10n.nameNotSet : settings.userName),
            onTap: () => _editName(settings.userName),
          ),
          _SectionTitle(l10n.sectionSalary),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(l10n.salaryLabel),
            subtitle: Text(Money.format(settings.monthlySalary)),
            onTap: () => _editSalary(settings.monthlySalary),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(l10n.paydayLabel),
            subtitle: Text(l10n.paydayValue(settings.payday)),
            onTap: () => _editPayday(settings.payday),
          ),
          _SectionTitle(l10n.sectionAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
                ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) => _settings.updateThemeMode(selection.single),
            ),
          ),
          _SectionTitle(l10n.expensesTitle),
          ListTile(
            leading: const Icon(Icons.repeat_rounded),
            title: Text(l10n.recurringTitle),
            subtitle: Text(_recurringSummary(l10n)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RecurringScreen()),
            ),
          ),
          _SectionTitle(l10n.sectionData),
          ListTile(
            leading: const Icon(Icons.table_view_outlined),
            title: Text(l10n.exportExcel),
            subtitle: Text(l10n.exportExcelSubtitle),
            trailing: _exporting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _exporting ? null : _export,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initialName});

  final String initialName;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.nameLabel),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: l10n.nameHint),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _SalaryDialog extends StatefulWidget {
  const _SalaryDialog({required this.initialAmount});

  final int initialAmount;

  @override
  State<_SalaryDialog> createState() => _SalaryDialogState();
}

class _SalaryDialogState extends State<_SalaryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(
    text: widget.initialAmount > 0 ? Money.toInput(widget.initialAmount) : '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(Money.parse(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.salaryLabel),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AmountField(
              controller: _controller,
              autofocus: true,
              emptyError: l10n.salaryRequired,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.salaryAppliesFromNow,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
