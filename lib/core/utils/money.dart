/// Pul formatlash — YAGONA manba (G1). Butun app shu util orqali formatlaydi.
///
/// CLAUDE.md: pul — `BIGINT`, so'mda BUTUN son, hech qachon `float`. Tiyin yo'q.
///
/// QOIDALAR (DECISIONS D057):
///  · minglik ajratgich — PROBEL (no-break): `550 000`. VERGUL ISHLATILMAYDI.
///  · suffiks — ` so'm` (probel bilan): `550 000 so'm`; nol → `0 so'm`.
///  · qisqartma (KPI/hero/ro'yxat) — millionlar `mln`: `6.8 mln`, `10 mln`;
///    million ostida to'liq: `800 000`.
///  · `intl` NumberFormat ISHLATILMAYDI — u lokalga qarab vergul/nuqta qo'yadi.
abstract final class Money {
  /// No-break probel — raqam qatordan qatorga bo'linib ketmasin.
  static const String _nb = ' ';

  /// "so'm" — i18n qatlamiga ko'chsa shu yerdan.
  static const String unit = "so'm";

  /// `550000` → `550 000`. Manfiy son ham to'g'ri.
  static String format(int amount) {
    final bool negative = amount < 0;
    final String digits = amount.abs().toString();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final int fromRight = digits.length - i;
      if (i > 0 && fromRight % 3 == 0) {
        out.write(_nb);
      }
      out.write(digits[i]);
    }
    return negative ? '-$out' : out.toString();
  }

  /// `550000` → `550 000 so'm`; `0` → `0 so'm`.
  static String withUnit(int amount) => '${format(amount)}$_nb$unit';

  /// Qisqa: `6800000` → `6.8 mln`, `10000000` → `10 mln`;
  /// million ostida to'liq: `800000` → `800 000`.
  static String compact(int amount) {
    final int abs = amount.abs();
    if (abs >= 1000000) {
      final String sign = amount < 0 ? '-' : '';
      return '$sign${_trim(abs / 1000000)}${_nb}mln';
    }
    return format(amount);
  }

  /// Qisqa + suffiks: `6800000` → `6.8 mln so'm`.
  static String compactWithUnit(int amount) => '${compact(amount)}$_nb$unit';

  /// `6.8` → `6.8`, `7.0` → `7` (ortiqcha nol yo'q).
  static String _trim(double v) {
    final String s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}
