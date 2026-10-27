import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/domain/recurring_expense.dart';
import 'package:pocket_budget/features/shared/amount_field.dart';
import 'package:pocket_budget/features/shared/category_picker.dart';
import 'package:pocket_budget/features/shared/payday_picker.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

/// Opens the form for a new recurring expense, or for editing [recurring].
Future<void> showRecurringSheet(BuildContext context, {RecurringExpense? recurring}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _RecurringSheet(recurring: recurring),
  );
}

class _RecurringSheet extends ConsumerStatefulWidget {
  const _RecurringSheet({this.recurring});

  final RecurringExpense? recurring;

  @override
  ConsumerState<_RecurringSheet> createState() => _RecurringSheetState();
}

class _RecurringSheetState extends ConsumerState<_RecurringSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  ExpenseCategory? _category;
  late int _dayOfMonth;
  bool _showCategoryError = false;
  bool _saving = false;

  bool get _isEditing => widget.recurring != null;

  @override
  void initState() {
    super.initState();
    final recurring = widget.recurring;
    _amountController = TextEditingController(
      text: recurring == null ? '' : Money.toInput(recurring.amount),
    );
    _noteController = TextEditingController(text: recurring?.note ?? '');
    _category = recurring?.category;
    _dayOfMonth = recurring?.dayOfMonth ?? ref.read(todayProvider).day;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final day = await showPaydayPicker(
      context,
      initialDay: _dayOfMonth,
      title: context.l10n.recurringDayPickerTitle,
    );
    if (day != null) setState(() => _dayOfMonth = day);
  }

  Future<void> _save() async {
    final amountIsValid = _formKey.currentState!.validate();
    setState(() => _showCategoryError = _category == null);
    if (!amountIsValid || _category == null) return;

    setState(() => _saving = true);
    final note = _noteController.text.trim();
    // A new one also covers its day in the current period if that day has passed.
    final generatedThrough = widget.recurring?.generatedThrough ??
        addDays(ref.read(currentPeriodProvider).start, -1);
    await ref.read(expenseActionsProvider).saveRecurring(RecurringExpense(
          id: widget.recurring?.id,
          amount: Money.parse(_amountController.text)!,
          category: _category!,
          note: note.isEmpty ? null : note,
          dayOfMonth: _dayOfMonth,
          generatedThrough: generatedThrough,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecurringTitle),
        content: Text(l10n.deleteRecurringBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(expenseActionsProvider).deleteRecurring(widget.recurring!);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

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
                      _isEditing ? l10n.editRecurring : l10n.newRecurring,
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
              InkWell(
                onTap: _pickDay,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.recurringDayLabel,
                    suffixIcon: const Icon(Icons.calendar_month_rounded),
                  ),
                  child: Text(l10n.paydayValue(_dayOfMonth), style: theme.textTheme.titleMedium),
                ),
              ),
              const SizedBox(height: 24),
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
