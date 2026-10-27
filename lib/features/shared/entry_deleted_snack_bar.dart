import 'package:flutter/material.dart';

import 'package:pocket_budget/domain/income.dart';
import 'package:pocket_budget/domain/ledger_entry.dart';
import 'package:pocket_budget/l10n/app_localizations.dart';
import 'package:pocket_budget/providers.dart';

void showEntryDeletedSnackBar({
  required ScaffoldMessengerState messenger,
  required AppLocalizations l10n,
  required EntryActions actions,
  required LedgerEntry entry,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(entry is Income ? l10n.incomeDeleted : l10n.expenseDeleted),
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => actions.restore(entry),
        ),
      ),
    );
}
