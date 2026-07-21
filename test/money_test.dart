import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/utils/money.dart';

/// G1 pul formatteri — table-driven. "550,000,so'm" REGRESSIYA testi.
void main() {
  const String nb = ' ';

  group('Money.format — probel ajratgich, vergul YO\'Q', () {
    final Map<int, String> cases = <int, String>{
      0: '0',
      5: '5',
      42: '42',
      999: '999',
      1000: '1${nb}000',
      550000: '550${nb}000',
      6800000: '6${nb}800${nb}000',
      12345678: '12${nb}345${nb}678',
      -550000: '-550${nb}000',
    };
    cases.forEach((int input, String want) {
      test('format($input) = "$want"', () {
        expect(Money.format(input), want);
      });
    });
    test('hech qachon vergul yo\'q', () {
      for (final int v in <int>[1234, 550000, 6800000, 999999999]) {
        expect(Money.format(v).contains(','), isFalse, reason: 'v=$v');
      }
    });
  });

  group('Money.withUnit — suffiks probel bilan, nol = "0 so\'m"', () {
    test('550000 → "550 000 so\'m"', () {
      expect(Money.withUnit(550000), '550${nb}000${nb}so\'m');
    });
    test('0 → "0 so\'m"', () {
      expect(Money.withUnit(0), '0${nb}so\'m');
    });
    test('REGRESSIYA: "550,000,so\'m" ko\'rinishi butunlay yo\'q', () {
      final String s = Money.withUnit(550000);
      expect(s.contains(','), isFalse);
      expect(s.contains(",so'm"), isFalse);
      expect(s, contains("so'm"));
    });
  });

  group('Money.compact — millionlar "mln"', () {
    final Map<int, String> cases = <int, String>{
      6800000: '6.8${nb}mln',
      10000000: '10${nb}mln',
      1200000: '1.2${nb}mln',
      1000000: '1${nb}mln',
      999999: '999${nb}999',
      800000: '800${nb}000',
      0: '0',
    };
    cases.forEach((int input, String want) {
      test('compact($input) = "$want"', () {
        expect(Money.compact(input), want);
      });
    });
  });
}
