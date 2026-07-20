import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/widgets/avatar.dart';

void main() {
  group('Avatar.initialsOf', () {
    test('ikki so\'zli ismdan ikki initsial', () {
      expect(Avatar.initialsOf('Aziz Karimov'), 'AK');
      expect(Avatar.initialsOf('Dilnoza Mirzayeva'), 'DM');
    });

    test('bitta so\'zdan bitta initsial', () {
      expect(Avatar.initialsOf('Aziz'), 'A');
    });

    test('uchinchi so\'z e\'tiborga olinmaydi', () {
      expect(Avatar.initialsOf("Jasur To'lqin o'g'li"), 'JT');
    });

    test('ortiqcha probellar tozalanadi', () {
      expect(Avatar.initialsOf('  Aziz   Karimov  '), 'AK');
      expect(Avatar.initialsOf('Aziz\tKarimov'), 'AK');
    });

    test('bo\'sh ism crash qilmaydi', () {
      expect(Avatar.initialsOf(''), '?');
      expect(Avatar.initialsOf('   '), '?');
    });

    test('kirill va o\'zbek harflari to\'g\'ri katta harfga o\'tadi', () {
      expect(Avatar.initialsOf('дилноза мирзаева'), 'ДМ');
      // Apostrof ikkinchi belgi — initsial faqat birinchi harfni oladi.
      expect(Avatar.initialsOf("o'ktam sobirov"), 'OS');
    });
  });
}
