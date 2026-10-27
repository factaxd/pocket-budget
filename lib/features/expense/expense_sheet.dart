import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/features/shared/amount_field.dart';
import 'package:pocket_budget/features/shared/category_picker.dart';
import 'package:pocket_budget/features/shared/expense_deleted_snack_bar.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

/// Opens the form for a new expense, or for editing [expense] when given.
Future<void> showExpenseSheet(
  BuildContext context, {
  Expense? expense,
  required DateTime defaultDate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ExpenseSheet(expense: expense, defaultDate: defaultDate),
  );
}

class ExpenseSheet extends ConsumerStatefulWidget {
  const ExpenseSheet({super.key, this.expense, required this.defaultDate});

  final Expense? expense;
  final DateTime defaultDate;

  @override
  ConsumerState<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends ConsumerState<ExpenseSheet> {
  static final _shortDate = DateFormat('d MMM', 'tr');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  ExpenseCategory? _category;
  late DateTime _date;
  bool _showCategoryError = false;
  bool _repeatMonthly = false;
  bool _saving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _amountController = TextEditingController(
      text: expense == null ? '' : Money.toInput(expense.amount),
    );
    _noteController = TextEditingController(text: expense?.note ?? '');
    _category = expense?.category;
    _date = expense?.spentOn ?? widget.defaultDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final lastDate = ref.read(currentPeriodProvider).lastDay;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(lastDate) ? lastDate : _date,
      firstDate: DateTime(lastDate.year - 5),
      lastDate: lastDate,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amountIsValid = _formKey.currentState!.validate();
    setState(() => _showCategoryError = _category == null);
    if (!amountIsValid || _category == null) return;

    setState(() => _saving = true);
    final note = _noteController.text.trim();
    final expense = Expense(
      id: widget.expense?.id,
      amount: Money.parse(_amountController.text)!,
      category: _category!,
      note: note.isEmpty ? null : note,
      spentOn: _date,
      createdAt: widget.expense?.createdAt,
      recurringId: widget.expense?.recurringId,
    );
    final actions = ref.read(expenseActionsProvider);
    await (_repeatMonthly ? actions.saveRepeating(expense) : actions.save(expense));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final expense = widget.expense!;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final actions = ref.read(expenseActionsProvider);
    final navigator = Navigator.of(context);

    await actions.delete(expense);
    navigator.pop();
    showExpenseDeletedSnackBar(
      messenger: messenger,
      l10n: l10n,
      actions: actions,
      expense: expense,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider);
    final yesterday = addDays(today, -1);
    final isOtherDay = _date != today && _date != yesterday;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? l10n.editExpense : l10n.newExpense,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  if (_isEditing)
                    IconButton(
                      tooltip: l10n.delete,
                      icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                      onPressed: _saving ? null : _delete,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AmountField(
                controller: _amountController,
                autofocus: !_isEditing,
                large: true,
              ),
              const SizedBox(height: 20),
              Text(l10n.categoryLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              CategoryPicker(
                selected: _category,
                onSelected: (category) => setState(() {
                  _category = category;
                  _showCategoryError = false;
                }),
              ),
              if (_showCategoryError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    l10n.categoryRequired,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                decoration: InputDecoration(labelText: l10n.noteLabel, counterText: ''),
              ),
              const SizedBox(height: 16),
              Text(l10n.dateLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.today),
                    selected: _date == today,
                    onSelected: (_) => setState(() => _date = today),
                  ),
                  ChoiceChip(
                    label: Text(l10n.yesterday),
                    selected: _date == yesterday,
                    onSelected: (_) => setState(() => _date = yesterday),
                  ),
                  ChoiceChip(
                    avatar: Icon(
                      Icons.event_rounded,
                      size: 18,
                      color: isOtherDay ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                    ),
                    label: Text(isOtherDay ? _shortDate.format(_date) : l10n.otherDay),
                    selected: isOtherDay,
                    onSelected: (_) => _pickDate(),
                  ),
                ],
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  secondary: Icon(Icons.repeat_rounded, color: theme.colorScheme.primary),
                  title: Text(l10n.repeatMonthly),
                  subtitle: Text(l10n.repeatMonthlySubtitle(_date.day)),
                  value: _repeatMonthly,
                  onChanged: (value) => setState(() => _repeatMonthly = value),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
