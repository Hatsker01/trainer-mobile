/// Spacing / radius / motion shkalasi — dizayn HTML'idan chiqarilgan.
///
/// HTML'da uchraydigan qiymatlar: 2 3 4 5 6 8 9 10 11 12 13 14 16 18 20 21 22
/// 26 34 40 74 110 120. Baza — 2, amaliy qadamlar quyida.
library;

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 14;
  static const double xxl = 16;
  static const double x3l = 18;
  static const double x4l = 20;
  static const double x5l = 22;
  static const double x6l = 26;
  static const double x7l = 34;

  /// Ekran gorizontal padding (`.screen { padding: 74px 20px 120px }`).
  static const double screenH = 20;

  /// G1 ZICHLIK — asosiy ekran cheti (16, zich standart). Dashboard/Kalendar
  /// shu qiymatni ishlatadi (eski 20 o'rniga).
  static const double screenEdge = 16;

  /// G1 ZICHLIK — zich karta ichki padding (14, eski 16/20 o'rniga).
  static const double cardPadDense = 14;

  /// G1 ZICHLIK — bo'limlar orasi zich variant (18, eski sectionGap 26 o'rniga).
  static const double sectionGapDense = 18;

  /// Tabbar ostidagi bo'sh joy — kontent tabbar tagida qolib ketmasligi uchun.
  /// (HTML: `padding-bottom: 120px`; tabbar 76 + pastdan 16 + nafas 28.)
  static const double screenBottom = 120;

  /// Bo'limlar orasidagi masofa (`.sec { margin-top: 26px }`).
  static const double sectionGap = 26;

  /// Bo'lim sarlavhasi ostidagi masofa (`.sec-h { margin-bottom: 12px }`).
  static const double sectionHeaderGap = 12;

  /// Ustma-ust kartalar orasi (inline `margin-bottom: 10px`).
  static const double cardGap = 10;

  /// Standart karta ichki padding (`.card { padding: 16px }`).
  static const double cardPad = 16;

  /// Hero karta ichki padding (`padding: 22px`).
  static const double heroPad = 22;
}

abstract final class AppRadius {
  /// Heatmap legendasi · sheet handle · timeline relsi.
  static const double xxs = 3;

  /// Heatmap katagi.
  static const double xs = 4;

  /// Referal chip · grafik ustuni pastki burchagi.
  static const double sm = 6;

  /// Checkbox.
  static const double chk = 7;

  /// StatusBadge.
  static const double badge = 8;

  /// Mahsulot rasmi · grafik ustuni yuqori burchagi.
  static const double md = 10;

  /// Kichik tugma · sheet yopish tugmasi.
  static const double lg = 12;

  /// Streak pill · orqaga tugmasi.
  static const double xl = 14;

  /// Qidiruv · avatar · toast · textarea.
  static const double xxl = 16;

  /// Asosiy tugma (h54).
  static const double button = 18;

  /// `--r` — standart karta radiusi. Chip ham shu (pill effekti).
  static const double card = 20;

  /// Tabbar.
  static const double tabBar = 28;

  /// Bottom sheet (faqat yuqori burchaklar).
  static const double sheet = 32;

  /// Telefon ramkasi (gallery/preview uchun).
  static const double phone = 54;
}

/// Animatsiya davomiyligi va egri chiziqlari.
///
/// Dizaynda ATIGI ikkita maxsus egri chiziq bor — ular `AppMotion` da
/// `Curves` bilan birga beriladi (`app_motion.dart`).
abstract final class AppDuration {
  /// Tugma bosilishi · chip · tab · fokus. (`transition: .15s`)
  static const Duration fast = Duration(milliseconds: 150);

  /// Scrim. (`transition: .3s`)
  static const Duration scrim = Duration(milliseconds: 300);

  /// Ekran kirishi (`sIn .32s`) va toast (`.32s`).
  static const Duration screenIn = Duration(milliseconds: 320);

  /// Bottom sheet (`.38s`).
  static const Duration sheet = Duration(milliseconds: 380);

  /// Ring progressi va grafik ustunlari (`1s`).
  static const Duration chart = Duration(seconds: 1);

  /// Toast avtomatik yopilishi (`setTimeout(..., 2600)`).
  static const Duration toast = Duration(milliseconds: 2600);
}
