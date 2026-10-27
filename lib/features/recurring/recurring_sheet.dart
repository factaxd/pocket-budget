import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/domain/recurring_expense.dart';
import 'package:pocket_budget/features/shared/amount_field.dart';
import 'package:pocket_budget/features/shared/category_picker.dart';
import 'package:pocket_budget/features/shared/payday_picker.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

/// Opens the form for editing or stopping [recurring]. New recurring
/// expenses are created from the expense form.
Future<void> showRecurringSheet(BuildContext context, {required RecurringExpense recurring}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _RecurringSheet(recurring: recurring),
  );
}

class _RecurringSheet extends ConsumerStatefulWidget {
  const _RecurringSheet({required this.recurring});

  final RecurringExpense recurring;

  @override
  ConsumerState<_RecurringSheet> createState() => _RecurringSheetState();
}

class _RecurringSheetState extends ConsumerState<_RecurringSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController =
      TextEditingController(text: Money.toInput(widget.recurring.amount));
  late final _noteController = TextEditingController(text: widget.recurring.note ?? '');
  late ExpenseCategory _category = widget.recurring.category;
  late int _dayOfMonth = widget.recurring.dayOfMonth;
  bool _saving = false;

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final note = _noteController.text.trim();
    await ref.read(entryActionsProvider).updateRecurring(RecurringExpense(
          id: widget.recurring.id,
          amount: Money.parse(_amountController.text)!,
          category: _category,
          note: note.isEmpty ? null : note,
          dayOfMonth: _dayOfMonth,
          generatedThrough: widget.recurring.generatedThrough,
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
    await ref.read(entryActionsProvider).deleteRecurring(widget.recurring);
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
                    child: Text(l10n.editRecurring, style: theme.textTheme.headlineSmall),
                  ),
                  IconButton(
                    tooltip: l10n.delete,
                    icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                    onPressed: _saving ? null : _delete,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AmountField(controller: _amountController, large: true),
              const SizedBox(height: 20),
              Text(l10n.categoryLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              CategoryPicker<ExpenseCategory>(
                categories: ExpenseCategory.values,
                selected: _category,
                onSelected: (category) => setState(() => _category = category),
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
