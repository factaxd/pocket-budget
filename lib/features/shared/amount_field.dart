import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/l10n/l10n.dart';

/// Text field for lira amounts, accepting both `1250,50` and `1.250` style input.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    this.label,
    this.emptyError,
    this.autofocus = false,
    this.large = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? label;

  /// Error shown when the field is left empty.
  final String? emptyError;
  final bool autofocus;

  /// Shows the amount in the display font, for forms where it is the main input.
  final bool large;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final style = large
        ? theme.textTheme.headlineMedium
        : theme.textTheme.titleMedium;

    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      style: style,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: '0',
        suffixText: '₺',
        suffixStyle: style?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return emptyError ?? l10n.amountRequired;
        final amount = Money.parse(value);
        if (amount == null || amount <= 0) return l10n.amountInvalid;
        return null;
      },
    );
  }
}
