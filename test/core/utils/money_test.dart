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

  // G1 (DECISIONS D057): qisqartma millionlar uchun `mln`, million ostida
  // to'liq (probel ajratgich). Eski `K/M` sxemasi bekor qilindi.
  group('Money.compact — millionlar "mln", million ostida to\'liq', () {
    test('million qisqartmasi', () {
      expect(Money.compact(6800000), '6.8${nb}mln');
      expect(Money.compact(1200000), '1.2${nb}mln');
      expect(Money.compact(950), '950');
      expect(Money.compact(0), '0');
    });

    test('butun million — ortiqcha nol yo\'q', () {
      expect(Money.compact(7000000), '7${nb}mln');
      expect(Money.compact(10000000), '10${nb}mln');
    });

    test('million ostida to\'liq (K ISHLATILMAYDI)', () {
      expect(Money.compact(999), '999');
      expect(Money.compact(1000), '1${nb}000');
      expect(Money.compact(800000), '800${nb}000');
      expect(Money.compact(999999), '999${nb}999');
      expect(Money.compact(1000000), '1${nb}mln');
    });

    test('manfiy qiymat', () {
      expect(Money.compact(-6800000), '-6.8${nb}mln');
    });
  });
}
