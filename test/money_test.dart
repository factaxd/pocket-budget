import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_budget/core/money.dart';

void main() {
  group('Money.parse', () {
    test('reads whole lira', () => expect(Money.parse('1250'), 125000));
    test('reads Turkish decimals', () => expect(Money.parse('89,90'), 8990));
    test('reads dot decimals', () => expect(Money.parse('12.5'), 1250));
    test('reads grouped thousands', () => expect(Money.parse('1.250'), 125000));
    test('reads grouped thousands with decimals', () => expect(Money.parse('1.250,75'), 125075));
    test('ignores the currency sign and spaces', () => expect(Money.parse(' 45 ₺ '), 4500));
    test('rejects empty input', () => expect(Money.parse(''), isNull));
    test('rejects more than two decimals', () => expect(Money.parse('1,234'), isNull));
    test('rejects text', () => expect(Money.parse('abc'), isNull));
  });

  group('Money.format', () {
    test('hides kuruş for whole amounts', () => expect(Money.format(125000), '1.250 ₺'));
    test('shows kuruş when present', () => expect(Money.format(125050), '1.250,50 ₺'));
    test('marks negative amounts', () => expect(Money.format(-4500), '-45 ₺'));
  });

  group('Money.formatCompact', () {
    test('keeps small amounts whole', () => expect(Money.formatCompact(18550), '186'));
    test('shortens thousands', () => expect(Money.formatCompact(217050), '2,2 B'));
    test('drops a zero decimal', () => expect(Money.formatCompact(1200000), '12 B'));
  });

  group('Money.toInput', () {
    test('round trips with parse', () {
      for (final kurus in [100, 125000, 8990, 1250, 7]) {
        expect(Money.parse(Money.toInput(kurus)), kurus);
      }
    });
  });
}
