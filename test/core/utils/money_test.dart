import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/utils/money.dart';

void main() {
  // Ajratgich — uzilmas probel (U+00A0), oddiy probel EMAS.
  const String nb = ' ';

  group('Money.format', () {
    test('minglik ajratgichni to\'g\'ri qo\'yadi', () {
      expect(Money.format(0), '0');
      expect(Money.format(1), '1');
      expect(Money.format(100), '100');
      expect(Money.format(1000), '1${nb}000');
      expect(Money.format(400000), '400${nb}000');
      expect(Money.format(6800000), '6${nb}800${nb}000');
      expect(Money.format(123456789), '123${nb}456${nb}789');
    });

    test('aynan 3 xonali chegaralarda ortiqcha ajratgich qo\'ymaydi', () {
      expect(Money.format(999), '999');
      expect(Money.format(1000000), '1${nb}000${nb}000');
    });

    test('manfiy summani belgisi bilan formatlaydi', () {
      expect(Money.format(-400000), '-400${nb}000');
      expect(Money.format(-1), '-1');
    });

    test('so\'m qo\'shimchasi bilan', () {
      expect(Money.withUnit(400000), "400${nb}000${nb}so'm");
    });
  });

  group('Money.compact', () {
    test('million va ming qisqartmalari', () {
      expect(Money.compact(6800000), '6.8M');
      expect(Money.compact(800000), '800K');
      expect(Money.compact(950), '950');
      expect(Money.compact(0), '0');
    });

    test('butun qiymatlarda ortiqcha nol ko\'rsatilmaydi', () {
      expect(Money.compact(7000000), '7M');
      expect(Money.compact(2000), '2K');
    });

    test('chegara qiymatlari', () {
      expect(Money.compact(999), '999');
      expect(Money.compact(1000), '1K');
      expect(Money.compact(999999), '1000K');
      expect(Money.compact(1000000), '1M');
    });

    test('manfiy qiymat', () {
      expect(Money.compact(-6800000), '-6.8M');
    });
  });
}
