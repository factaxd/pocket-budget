import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:pocket_budget/app.dart';
import 'package:pocket_budget/data/app_database.dart';
import 'package:pocket_budget/data/settings_repository.dart';
import 'package:pocket_budget/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr');

  final database = await openAppDatabase();
  final settings = await SettingsRepository(database).load();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        initialSettingsProvider.overrideWithValue(settings),
      ],
      child: const CuzdanApp(),
    ),
  );
}
