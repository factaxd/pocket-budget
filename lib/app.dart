import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_budget/core/theme/app_theme.dart';
import 'package:pocket_budget/features/onboarding/onboarding_screen.dart';
import 'package:pocket_budget/features/shell/app_shell.dart';
import 'package:pocket_budget/l10n/app_localizations.dart';
import 'package:pocket_budget/providers.dart';

class CuzdanApp extends ConsumerStatefulWidget {
  const CuzdanApp({super.key});

  @override
  ConsumerState<CuzdanApp> createState() => _CuzdanAppState();
}

class _CuzdanAppState extends ConsumerState<CuzdanApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => ref.invalidate(todayProvider),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(settingsProvider.select((settings) => settings.themeMode));
    final isOnboarded = ref.watch(settingsProvider.select((settings) => settings.isOnboarded));

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: const Locale('tr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: isOnboarded ? const AppShell() : const OnboardingScreen(),
    );
  }
}
