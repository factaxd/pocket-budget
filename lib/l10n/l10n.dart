import 'package:flutter/widgets.dart';

import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/l10n/app_localizations.dart';

extension LocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension ExpenseCategoryLabel on ExpenseCategory {
  String label(AppLocalizations l10n) => switch (this) {
        ExpenseCategory.food => l10n.categoryFood,
        ExpenseCategory.coffee => l10n.categoryCoffee,
        ExpenseCategory.groceries => l10n.categoryGroceries,
        ExpenseCategory.shopping => l10n.categoryShopping,
        ExpenseCategory.beauty => l10n.categoryBeauty,
        ExpenseCategory.transport => l10n.categoryTransport,
        ExpenseCategory.bills => l10n.categoryBills,
        ExpenseCategory.rent => l10n.categoryRent,
        ExpenseCategory.health => l10n.categoryHealth,
        ExpenseCategory.entertainment => l10n.categoryEntertainment,
        ExpenseCategory.gift => l10n.categoryGift,
        ExpenseCategory.other => l10n.categoryOther,
      };
}
