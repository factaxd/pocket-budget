import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.userName = '',
    this.monthlySalary = 0,
    this.payday = 1,
    this.themeMode = ThemeMode.system,
    this.startedOn,
  });

  /// Empty when the user did not enter a name.
  final String userName;

  /// Default salary in kuruş, applied to periods that have no salary of their own.
  final int monthlySalary;

  /// Day of the month the salary arrives (1-31).
  final int payday;
  final ThemeMode themeMode;

  /// The day onboarding was completed; null before that.
  final DateTime? startedOn;

  bool get isOnboarded => startedOn != null;

  AppSettings copyWith({
    String? userName,
    int? monthlySalary,
    int? payday,
    ThemeMode? themeMode,
    DateTime? startedOn,
  }) {
    return AppSettings(
      userName: userName ?? this.userName,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      payday: payday ?? this.payday,
      themeMode: themeMode ?? this.themeMode,
      startedOn: startedOn ?? this.startedOn,
    );
  }
}
