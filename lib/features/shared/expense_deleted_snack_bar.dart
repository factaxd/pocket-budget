import 'package:flutter/material.dart';

import 'package:pocket_budget/domain/expense.dart';
import 'package:pocket_budget/l10n/app_localizations.dart';
import 'package:pocket_budget/providers.dart';

void showExpenseDeletedSnackBar({
  required ScaffoldMessengerState messenger,
  required AppLocalizations l10n,
  required ExpenseActions actions,
  required Expense expense,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.expenseDeleted),
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => actions.restore(expense),
        ),
      ),
    );
}
