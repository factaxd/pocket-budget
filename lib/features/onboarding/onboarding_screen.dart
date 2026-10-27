import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/core/money.dart';
import 'package:pocket_budget/features/shared/amount_field.dart';
import 'package:pocket_budget/features/shared/payday_picker.dart';
import 'package:pocket_budget/l10n/l10n.dart';
import 'package:pocket_budget/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();
  int _payday = 1;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickPayday() async {
    final day = await showPaydayPicker(context, initialDay: _payday);
    if (day != null) setState(() => _payday = day);
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(settingsProvider.notifier).completeOnboarding(
          userName: _nameController.text.trim(),
          monthlySalary: Money.parse(_salaryController.text)!,
          payday: _payday,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            children: [
              Text(l10n.welcomeTitle, style: theme.textTheme.displaySmall),
              const SizedBox(height: 12),
              Text(
                l10n.welcomeBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 36),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.nameLabel, hintText: l10n.nameHint),
              ),
              const SizedBox(height: 16),
              AmountField(
                controller: _salaryController,
                label: l10n.salaryLabel,
                emptyError: l10n.salaryRequired,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickPayday,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.paydayLabel,
                    helperText: l10n.paydayHelper,
                    helperMaxLines: 3,
                    suffixIcon: const Icon(Icons.calendar_month_rounded),
                  ),
                  child: Text(l10n.paydayValue(_payday), style: theme.textTheme.titleMedium),
                ),
              ),
              const SizedBox(height: 36),
              FilledButton(
                onPressed: _saving ? null : _start,
                child: Text(l10n.start),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
