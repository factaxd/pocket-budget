import 'package:intl/intl.dart';

/// Amounts are stored as integer kuruş (1/100 lira) to avoid floating point drift.
abstract final class Money {
  static final _wholeFormat = NumberFormat('#,##0', 'tr');
  static final _fractionFormat = NumberFormat('#,##0.00', 'tr');
  static final _groupedThousands = RegExp(r'^\d{1,3}(\.\d{3})+$');
  static final _plainDecimal = RegExp(r'^\d+(\.\d{1,2})?$');

  /// Formats [kurus] for display, e.g. `1.250 ₺` or `1.250,50 ₺`.
  static String format(int kurus) {
    final abs = kurus.abs();
    final number = abs % 100 == 0
        ? _wholeFormat.format(abs ~/ 100)
        : _fractionFormat.format(abs / 100);
    return '${kurus < 0 ? '-' : ''}$number ₺';
  }

  /// Short form for tight spaces, e.g. `185` or `2,2 B` (bin, thousands).
  static String formatCompact(int kurus) {
    final lira = (kurus / 100).round();
    return lira < 1000 ? '$lira' : '${_thousandsFormat.format(lira / 1000)} B';
  }

  static final _thousandsFormat = NumberFormat('#,##0.#', 'tr');

  /// Formats [kurus] for an editable text field, e.g. `1250` or `1250,50`.
  static String toInput(int kurus) {
    final lira = kurus ~/ 100;
    final rest = kurus % 100;
    return rest == 0 ? '$lira' : '$lira,${rest.toString().padLeft(2, '0')}';
  }

  /// Parses user input such as `1250`, `1.250`, `1250,50` or `12.5` into kuruş.
  /// Returns null when the input is not a valid amount.
  static int? parse(String input) {
    var text = input.trim().replaceAll(' ', '').replaceAll('₺', '');
    if (text.isEmpty) return null;

    if (text.contains(',')) {
      // Turkish notation: dots group thousands, the comma marks decimals.
      text = text.replaceAll('.', '').replaceAll(',', '.');
    } else if (_groupedThousands.hasMatch(text)) {
      text = text.replaceAll('.', '');
    }
    if (!_plainDecimal.hasMatch(text)) return null;

    final parts = text.split('.');
    final lira = int.parse(parts[0]);
    final kurus = parts.length > 1 ? int.parse(parts[1].padRight(2, '0')) : 0;
    return lira * 100 + kurus;
  }
}
