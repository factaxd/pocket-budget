import 'package:flutter/widgets.dart';

import 'package:pocket_budget/domain/entry_category.dart';
import 'package:pocket_budget/domain/expense_category.dart';
import 'package:pocket_budget/domain/income_category.dart';
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

extension IncomeCategoryLabel on IncomeCategory {
  String label(AppLocalizations l10n) => switch (this) {
        IncomeCategory.sideJob => l10n.incomeCategorySideJob,
        IncomeCategory.bonus => l10n.incomeCategoryBonus,
        IncomeCategory.gift => l10n.incomeCategoryGift,
        IncomeCategory.refund => l10n.incomeCategoryRefund,
        IncomeCategory.sale => l10n.incomeCategorySale,
        IncomeCategory.investment => l10n.incomeCategoryInvestment,
        IncomeCategory.other => l10n.incomeCategoryOther,
      };
}

/// Labels a category whose type is only known at runtime, such as in a mixed list.
extension EntryCategoryLabel on EntryCategory {
  String label(AppLocalizations l10n) {
    final category = this;
    return category is ExpenseCategory
        ? category.label(l10n)
        : (category as IncomeCategory).label(l10n);
  }
}
