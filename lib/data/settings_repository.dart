import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:pocket_budget/core/dates.dart';
import 'package:pocket_budget/domain/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final Database _db;

  static const _table = 'settings';
  static const _userName = 'user_name';
  static const _monthlySalary = 'monthly_salary';
  static const _payday = 'payday';
  static const _themeMode = 'theme_mode';
  static const _startedOn = 'started_on';

  Future<AppSettings> load() async {
    final rows = await _db.query(_table);
    final values = {for (final row in rows) row['key'] as String: row['value'] as String};
    const defaults = AppSettings();

    return AppSettings(
      userName: values[_userName] ?? defaults.userName,
      monthlySalary: int.tryParse(values[_monthlySalary] ?? '') ?? defaults.monthlySalary,
      payday: int.tryParse(values[_payday] ?? '') ?? defaults.payday,
      themeMode: ThemeMode.values.asNameMap()[values[_themeMode]] ?? defaults.themeMode,
      startedOn: values[_startedOn] == null ? null : parseIsoDate(values[_startedOn]!),
    );
  }

  Future<void> save(AppSettings settings) async {
    final values = {
      _userName: settings.userName,
      _monthlySalary: '${settings.monthlySalary}',
      _payday: '${settings.payday}',
      _themeMode: settings.themeMode.name,
      if (settings.startedOn != null) _startedOn: toIsoDate(settings.startedOn!),
    };

    final batch = _db.batch();
    values.forEach((key, value) {
      batch.insert(
        _table,
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }
}
