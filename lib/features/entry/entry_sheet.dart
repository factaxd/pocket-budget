import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/domain/income.dart';
import 'package:pocket_budget/domain/income_category.dart';
import 'package:pocket_budget/domain/ledger_entry.dart';
import 'package:pocket_budget/features/shared/amount_field.dart';
import 'package:pocket_budget/features/shared/category_picker.dart';
import 'package:pocket_budget/features/shared/entry_deleted_snack_bar.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

/// Opens the form for a new expense or income, or for editing [entry] when given.
Future<void> showEntrySheet(
  BuildContext context, {
  LedgerEntry? entry,
  required DateTime defaultDate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => EntrySheet(entry: entry, defaultDate: defaultDate),
  );
}

enum _EntryKind { expense, income }

class EntrySheet extends ConsumerStatefulWidget {
  const EntrySheet({super.key, this.entry, required this.defaultDate});

  final LedgerEntry? entry;
  final DateTime defaultDate;

  @override
  ConsumerState<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<EntrySheet> {
  static final _shortDate = DateFormat('d MMM', 'tr');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late _EntryKind _kind;

  // Kept apart so switching between expense and income keeps each choice.
  ExpenseCategory? _expenseCategory;
  IncomeCategory? _incomeCategory;

  late DateTime _date;
  bool _showCategoryError = false;
  late bool _repeatMonthly;
  bool _saving = false;

  bool get _isEditing => widget.entry != null;
  bool get _isIncome => _kind == _EntryKind.income;
  bool get _hasCategory => _isIncome ? _incomeCategory != null : _expenseCategory != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _amountController = TextEditingController(
      text: entry == null ? '' : Money.toInput(entry.amount),
    );
    _noteController = TextEditingController(text: entry?.note ?? '');
    _kind = entry is Income ? _EntryKind.income : _EntryKind.expense;
    _expenseCategory = entry is Expense ? entry.category : null;
    _incomeCategory = entry is Income ? entry.category : null;
    _date = entry?.date ?? widget.defaultDate;
    _repeatMonthly = entry is Expense && entry.recurringId != null;
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
    setState(() => _showCategoryError = !_hasCategory);
    if (!amountIsValid || !_hasCategory) return;

    setState(() => _saving = true);
    final actions = ref.read(entryActionsProvider);
    final amount = Money.parse(_amountController.text)!;
    final noteText = _noteController.text.trim();
    final note = noteText.isEmpty ? null : noteText;

    if (_isIncome) {
      await actions.saveIncome(Income(
        id: widget.entry?.id,
        amount: amount,
        category: _incomeCategory!,
        note: note,
        receivedOn: _date,
        createdAt: widget.entry?.createdAt,
      ));
    } else {
      final expense = widget.entry as Expense?;
      await actions.save(
        Expense(
          id: expense?.id,
          amount: amount,
          category: _expenseCategory!,
          note: note,
          spentOn: _date,
          createdAt: expense?.createdAt,
          recurringId: expense?.recurringId,
        ),
        repeatMonthly: _repeatMonthly,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final entry = widget.entry!;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final actions = ref.read(entryActionsProvider);
    final navigator = Navigator.of(context);

    await actions.delete(entry);
    navigator.pop();
    showEntryDeletedSnackBar(
      messenger: messenger,
      l10n: l10n,
      actions: actions,
      entry: entry,
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
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isIncome ? l10n.editIncome : l10n.editExpense,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.delete,
                      icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                      onPressed: _saving ? null : _delete,
                    ),
                  ],
                )
              else
                // An existing entry keeps its kind, since the two live in separate tables.
                SegmentedButton<_EntryKind>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: _EntryKind.expense,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      label: Text(l10n.entryKindExpense),
                    ),
                    ButtonSegment(
                      value: _EntryKind.income,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: Text(l10n.entryKindIncome),
                    ),
                  ],
                  selected: {_kind},
                  onSelectionChanged: (selection) => setState(() {
                    _kind = selection.single;
                    _showCategoryError = false;
                  }),
                ),
              if (_isIncome)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                  child: Text(
                    l10n.incomeHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
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
              if (_isIncome)
                CategoryPicker<IncomeCategory>(
                  categories: IncomeCategory.values,
                  selected: _incomeCategory,
                  onSelected: (category) => setState(() {
                    _incomeCategory = category;
                    _showCategoryError = false;
                  }),
                )
              else
                CategoryPicker<ExpenseCategory>(
                  categories: ExpenseCategory.values,
                  selected: _expenseCategory,
                  onSelected: (category) => setState(() {
                    _expenseCategory = category;
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
              if (!_isIncome) ...[
                const SizedBox(height: 16),
                Text(l10n.repeatLabel, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.repeatOnce),
                      selected: !_repeatMonthly,
                      onSelected: (_) => setState(() => _repeatMonthly = false),
                    ),
                    ChoiceChip(
                      avatar: Icon(
                        Icons.repeat_rounded,
                        size: 18,
                        color:
                            _repeatMonthly ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                      ),
                      label: Text(l10n.repeatMonthly),
                      selected: _repeatMonthly,
                      onSelected: (_) => setState(() => _repeatMonthly = true),
                    ),
                  ],
                ),
                if (_repeatMonthly)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                    child: Text(
                      l10n.repeatMonthlySubtitle(_date.day),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
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
