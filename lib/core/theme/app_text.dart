import 'package:flutter/material.dart';

/// Tipografiya — `design/ustoz-v2.1-tavsiyalar.html` dan 1:1.
///
/// Uch oila, uch rol:
/// * **Unbounded** — display / sarlavha / avatar initsiallari / ring yorliqlari
/// * **Manrope** — butun UI matni (body default)
/// * **JetBrainsMono** — FAQAT pul va raqamlar, `tnum` (tabular figures) bilan
///
/// Rang bu yerda berilmaydi — har chaqiruv joyida `.copyWith(color:)` bilan
/// qo'yiladi (bir xil o'lcham turli rangda ishlatiladi).
abstract final class AppText {
  static const String displayFamily = 'Unbounded';
  static const String bodyFamily = 'Manrope';
  static const String monoFamily = 'JetBrainsMono';

  /// Tabular figures — pul ustunlari "sakramasligi" uchun majburiy.
  static const List<FontFeature> _tnum = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  // ---------------------------------------------------------------- display

  /// Ekran sarlavhasi: "Salom, Jamshid" · "Shogirdlar" · "Statistika".
  /// Unbounded 700 / 24.
  static const TextStyle display24 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Logo / eng katta display. Unbounded 700 / 20.
  static const TextStyle h20 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  /// Shogird ismi (profil hero). Unbounded 600 / 19.
  static const TextStyle h19 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 19,
    fontWeight: FontWeight.w600,
  );

  /// Bottom sheet sarlavhasi. Unbounded 600 / 18.
  static const TextStyle h18 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// AppBar sarlavhasi ("Shogird"). Unbounded 600 / 17.
  static const TextStyle h17 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  /// Bo'lim sarlavhasi (`.sec-h .t`). Unbounded 600 / 15, letter-spacing .2.
  static const TextStyle section15 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// Avatar initsiallari (44px avatar). Unbounded 600 / 14.
  static const TextStyle avatar14 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Avatar initsiallari (38px avatar). Unbounded 600 / 12.
  static const TextStyle avatar12 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  /// Hero ring markazidagi foiz ("68%"). Unbounded 800 / 17.
  static const TextStyle ringValue17 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );

  /// Kichik ring yorlig'i ("!", "3 kun"). Unbounded 800 / 13.
  static const TextStyle ringValue13 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  // ------------------------------------------------------------------- body

  /// "so'm" qo'shimchasi. Manrope 600 / 16.
  static const TextStyle body16 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Tugma yorlig'i · StudentCard ismi. Manrope 700 / 15.
  static const TextStyle body15Bold = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  /// Kiritish maydoni / uzun matn. Manrope 400 / 14.5, line-height 1.5.
  static const TextStyle body145 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Ro'yxat qatori sarlavhasi · statusbar. Manrope 700 / 14.
  static const TextStyle body14Bold = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  /// Oddiy matn (timeline ismi, tavsiya matni). Manrope 400 / 14, lh 1.5.
  static const TextStyle body14 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Chip · streak · `.sec-h .all` · kichik tugma. Manrope 700 / 13.
  static const TextStyle body13Bold = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  /// Sana qatori ("Yakshanba, 19-iyul"). Manrope 600 / 13.
  static const TextStyle body13 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// Toast · dashed link qatori. Manrope 700 / 13.5.
  static const TextStyle body135Bold = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
  );

  /// Karta izohi ("Oylik · 400 000"). Manrope 600 / 12.5.
  static const TextStyle caption125 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
  );

  /// Metama'lumot. Manrope 400 / 12.
  static const TextStyle caption12 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// Bo'lim hisoblagichi · timeline holati. Manrope 800 / 12.
  static const TextStyle caption12Heavy = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  /// Statistika yorlig'i (UPPERCASE). Manrope 700 / 11.5.
  static const TextStyle label115 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
  );

  /// Grafik oy yorlig'i · profil stat yorlig'i. Manrope 700 / 11.
  static const TextStyle label11 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );

  /// StatusBadge. Manrope 800 / 11, letter-spacing .4.
  static const TextStyle badge11 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );

  /// Tabbar yorlig'i. Manrope 700 / 10.5.
  static const TextStyle tab105 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
  );

  /// Ring ostki yorlig'i ("KECHIKDI"). Manrope 700 / 9, letter-spacing .5.
  static const TextStyle ringSub9 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // ------------------------------------------------------------------- mono

  /// To'lov sheetidagi katta summa. Mono 600 / 40, tnum.
  static const TextStyle money40 = TextStyle(
    fontFamily: monoFamily,
    fontSize: 40,
    fontWeight: FontWeight.w600,
    fontFeatures: _tnum,
  );

  /// Hero daromad. Mono 600 / 24, tnum.
  static const TextStyle money24 = TextStyle(
    fontFamily: monoFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFeatures: _tnum,
  );

  /// Statistika KPI qiymati. Mono 600 / 21, tnum.
  static const TextStyle money21 = TextStyle(
    fontFamily: monoFamily,
    fontSize: 21,
    fontWeight: FontWeight.w600,
    fontFeatures: _tnum,
  );

  /// Profil stat plitkasi. Mono 600 / 17, tnum.
  static const TextStyle money17 = TextStyle(
    fontFamily: monoFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    fontFeatures: _tnum,
  );

  /// To'lov tarixi summasi. Mono 500 / 14, tnum.
  static const TextStyle money14 = TextStyle(
    fontFamily: monoFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFeatures: _tnum,
  );

  /// Ro'yxat qatoridagi kichik summa. Mono 600 / 12, tnum.
  static const TextStyle money12 = TextStyle(
    fontFamily: monoFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFeatures: _tnum,
  );

  /// Mahsulot narxi. Mono 500 / 11.5, tnum.
  static const TextStyle money115 = TextStyle(
    fontFamily: monoFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    fontFeatures: _tnum,
  );
}
