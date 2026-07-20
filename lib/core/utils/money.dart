/// Pul formatlash.
///
/// CLAUDE.md: pul — `BIGINT`, so'mda BUTUN son, hech qachon `float`.
/// Tiyin ishlatilmaydi. Shuning uchun hamma joyda `int`.
///
/// Dizaynda ajratgich — oddiy probel: `400 000`, `6 800 000`.
/// `intl` ning `NumberFormat` i lokalga qarab vergul/nuqta qo'yadi, bu esa
/// dizayndan chetga chiqadi — shuning uchun qo'lda formatlanadi.
abstract final class Money {
  /// Ajratgich sifatida **uzilmas probel** (U+00A0) ishlatiladi: `400 000`
  /// hech qachon qatordan qatorga bo'linib ketmasin.
  static const String _sep = ' ';

  /// `400000` → `400 000`. Manfiy son ham to'g'ri ishlaydi.
  static String format(int amount) {
    final bool negative = amount < 0;
    final String digits = amount.abs().toString();
    final StringBuffer out = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      // Chapdan o'ngga yozamiz — har 3 xonadan oldin ajratgich.
      final int fromRight = digits.length - i;
      if (i > 0 && fromRight % 3 == 0) {
        out.write(_sep);
      }
      out.write(digits[i]);
    }

    return negative ? '-$out' : out.toString();
  }

  /// `400000` → `400 000 so'm`.
  static String withUnit(int amount) => '${format(amount)}$_sep$unit';

  /// Statistika kartalari uchun qisqa shakl: `6800000` → `6.8M`,
  /// `800000` → `800K`, `950` → `950`.
  ///
  /// Dizayndagi S10 KPI kartalari aynan shu ko'rinishda (`6.8M`, `800K`).
  static String compact(int amount) {
    final int abs = amount.abs();
    final String sign = amount < 0 ? '-' : '';

    if (abs >= 1000000) {
      return '$sign${_trim(abs / 1000000)}M';
    }
    if (abs >= 1000) {
      return '$sign${_trim(abs / 1000)}K';
    }
    return '$sign$abs';
  }

  /// `6.8` → `6.8`, `7.0` → `7` (ortiqcha nol ko'rsatilmaydi).
  static String _trim(double v) {
    final String s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  /// "so'm" — i18n qatlamiga ko'chirilishi kerak bo'lsa shu yerdan olinadi.
  static const String unit = "so'm";
}
