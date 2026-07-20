import 'package:flutter/material.dart';

/// USTOZ v2 — "KECHKI ZAL" (dark iron · chalk · anor glow).
///
/// Barcha qiymatlar `design/ustoz-v2.1-tavsiyalar.html` dan 1:1 ko'chirilgan.
/// O'zingdan rang o'ylab topilmaydi — yangi rang kerak bo'lsa avval dizaynda
/// bo'lishi shart.
///
/// `ThemeExtension` sifatida berilgan: hozir faqat dark mavjud, lekin light
/// qo'shilishi uchun tayyor (MVP scope'da light YO'Q — CLAUDE.md §Scope).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg0,
    required this.bg1,
    required this.glass,
    required this.glassHi,
    required this.ink,
    required this.soft,
    required this.dim,
    required this.anor,
    required this.anor2,
    required this.anorGlow,
    required this.ringStart,
    required this.ringEnd,
    required this.ok,
    required this.okSoft,
    required this.warn,
    required this.warnSoft,
    required this.debt,
    required this.debtSoft,
    required this.line,
    required this.sheet,
    required this.toast,
    required this.scrim,
    required this.tabBar,
    required this.avatarFrom,
    required this.avatarTo,
  });

  /// Dizayndagi yagona mavjud tema.
  static const AppColors dark = AppColors(
    // --bg0: chuqur temir. Ekran foni, ring markazidagi "plita teshigi".
    bg0: Color(0xFF0C0D10),
    // --bg1: ikkilamchi sirt. Tabbar shu rangning 72% shaffofi.
    bg1: Color(0xFF131519),
    // --glass / --glass-hi: shisha sirtlar.
    glass: Color.fromRGBO(255, 255, 255, 0.055),
    glassHi: Color.fromRGBO(255, 255, 255, 0.09),
    // --ink: mel (chalk). Asosiy matn.
    ink: Color(0xFFF4F2EC),
    soft: Color(0xFF9C9FA8),
    dim: Color(0xFF5E626C),
    // --anor: anor. Brend rangi, tugma gradienti boshlanishi.
    anor: Color(0xFFFF5340),
    anor2: Color(0xFFE2264B),
    anorGlow: Color.fromRGBO(255, 83, 64, 0.35),
    // Ring gradienti tugma gradientidan FARQ QILADI (D104) — dizaynda shunday.
    ringStart: Color(0xFFFF6A3D),
    ringEnd: Color(0xFFE2264B),
    ok: Color(0xFF3DD68C),
    okSoft: Color.fromRGBO(61, 214, 140, 0.14),
    warn: Color(0xFFFFC24D),
    warnSoft: Color.fromRGBO(255, 194, 77, 0.14),
    // Qarz rangi dizaynda o'zgaruvchi emas edi — token sifatida rasmiylashtirildi (D103).
    debt: Color(0xFFFF7A6B),
    debtSoft: Color.fromRGBO(255, 83, 64, 0.14),
    line: Color.fromRGBO(255, 255, 255, 0.08),
    sheet: Color(0xFF17191E),
    toast: Color(0xFF1E2126),
    scrim: Color.fromRGBO(0, 0, 0, 0.55),
    tabBar: Color.fromRGBO(19, 21, 25, 0.72),
    avatarFrom: Color(0xFF23262D),
    avatarTo: Color(0xFF17191E),
  );

  final Color bg0;
  final Color bg1;
  final Color glass;
  final Color glassHi;
  final Color ink;
  final Color soft;
  final Color dim;
  final Color anor;
  final Color anor2;
  final Color anorGlow;
  final Color ringStart;
  final Color ringEnd;
  final Color ok;
  final Color okSoft;
  final Color warn;
  final Color warnSoft;
  final Color debt;
  final Color debtSoft;
  final Color line;
  final Color sheet;
  final Color toast;
  final Color scrim;
  final Color tabBar;
  final Color avatarFrom;
  final Color avatarTo;

  /// Tugma / chip / FAB gradienti: `linear-gradient(135deg, #FF5340, #E2264B)`.
  ///
  /// CSS `135deg` = yuqori-chapdan pastki-o'ngga.
  LinearGradient get anorGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[anor, anor2],
  );

  /// Ring yoyi gradienti: SVG `linearGradient#ag` (x1,y1=0,0 → x2,y2=1,1).
  LinearGradient get ringGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[ringStart, ringEnd],
  );

  /// Avatar foni: `linear-gradient(145deg, #23262D, #17191E)`.
  LinearGradient get avatarGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[avatarFrom, avatarTo],
  );

  @override
  AppColors copyWith({
    Color? bg0,
    Color? bg1,
    Color? glass,
    Color? glassHi,
    Color? ink,
    Color? soft,
    Color? dim,
    Color? anor,
    Color? anor2,
    Color? anorGlow,
    Color? ringStart,
    Color? ringEnd,
    Color? ok,
    Color? okSoft,
    Color? warn,
    Color? warnSoft,
    Color? debt,
    Color? debtSoft,
    Color? line,
    Color? sheet,
    Color? toast,
    Color? scrim,
    Color? tabBar,
    Color? avatarFrom,
    Color? avatarTo,
  }) {
    return AppColors(
      bg0: bg0 ?? this.bg0,
      bg1: bg1 ?? this.bg1,
      glass: glass ?? this.glass,
      glassHi: glassHi ?? this.glassHi,
      ink: ink ?? this.ink,
      soft: soft ?? this.soft,
      dim: dim ?? this.dim,
      anor: anor ?? this.anor,
      anor2: anor2 ?? this.anor2,
      anorGlow: anorGlow ?? this.anorGlow,
      ringStart: ringStart ?? this.ringStart,
      ringEnd: ringEnd ?? this.ringEnd,
      ok: ok ?? this.ok,
      okSoft: okSoft ?? this.okSoft,
      warn: warn ?? this.warn,
      warnSoft: warnSoft ?? this.warnSoft,
      debt: debt ?? this.debt,
      debtSoft: debtSoft ?? this.debtSoft,
      line: line ?? this.line,
      sheet: sheet ?? this.sheet,
      toast: toast ?? this.toast,
      scrim: scrim ?? this.scrim,
      tabBar: tabBar ?? this.tabBar,
      avatarFrom: avatarFrom ?? this.avatarFrom,
      avatarTo: avatarTo ?? this.avatarTo,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppColors(
      bg0: Color.lerp(bg0, other.bg0, t)!,
      bg1: Color.lerp(bg1, other.bg1, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassHi: Color.lerp(glassHi, other.glassHi, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      soft: Color.lerp(soft, other.soft, t)!,
      dim: Color.lerp(dim, other.dim, t)!,
      anor: Color.lerp(anor, other.anor, t)!,
      anor2: Color.lerp(anor2, other.anor2, t)!,
      anorGlow: Color.lerp(anorGlow, other.anorGlow, t)!,
      ringStart: Color.lerp(ringStart, other.ringStart, t)!,
      ringEnd: Color.lerp(ringEnd, other.ringEnd, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      okSoft: Color.lerp(okSoft, other.okSoft, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnSoft: Color.lerp(warnSoft, other.warnSoft, t)!,
      debt: Color.lerp(debt, other.debt, t)!,
      debtSoft: Color.lerp(debtSoft, other.debtSoft, t)!,
      line: Color.lerp(line, other.line, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      toast: Color.lerp(toast, other.toast, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      tabBar: Color.lerp(tabBar, other.tabBar, t)!,
      avatarFrom: Color.lerp(avatarFrom, other.avatarFrom, t)!,
      avatarTo: Color.lerp(avatarTo, other.avatarTo, t)!,
    );
  }
}

/// `context.colors` — har widget'da `Theme.of(context).extension<AppColors>()!`
/// yozmaslik uchun.
extension AppColorsX on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.dark;
}
