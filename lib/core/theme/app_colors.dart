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

  /// **Kechki zal** — dark, mahsulotning default temasi (P4 redesign).
  ///
  /// Qiymatlar `packages/ustoz_ui` dan (`UstozColors.dark`) — prototipdan
  /// 1:1 olingan. Bu yerda faqat **nom ko'prigi**: mavjud 15k satr UI
  /// `context.colors.bg0` deb yozadi, `ustoz_ui` esa `bg` deydi.
  /// Shu ko'prik tufayli barcha ekran bitta fayl orqali yangi dizaynga
  /// o'tdi — har biriga alohida tegilmadi (P1.6).
  ///
  /// Yangi kod TO'G'RIDAN-TO'G'RI `context.uColors` ishlatadi.
  static const AppColors dark = AppColors(
    bg0: Color(0xFF0E1116),
    bg1: Color(0xFF171B22),
    // Eski "glass" yarim shaffof oq edi; yangi tizimda sirtlar qattiq.
    glass: Color(0xFF171B22),
    glassHi: Color(0xFF1F242E),
    ink: Color(0xFFEDEFF3),
    soft: Color(0xFF98A1AE),
    // Kontrast AA ga ko'tarilgan (prototip #6A7280 = 3.9:1).
    dim: Color(0xFF7B8390),
    anor: Color(0xFFE5484D),
    anor2: Color(0xFFFF6B6B),
    anorGlow: Color(0x4DE5484D),
    // Ring gradienti endi brend gradienti bilan BIR XIL (eski D104 bekor:
    // ikkita turli qizil gradient brendni bo'lardi).
    ringStart: Color(0xFFE5484D),
    ringEnd: Color(0xFFFF6B6B),
    ok: Color(0xFF2FBF87),
    okSoft: Color(0x212FBF87),
    warn: Color(0xFFE3A64A),
    warnSoft: Color(0x21E3A64A),
    debt: Color(0xFFE23E63),
    debtSoft: Color(0x24E23E63),
    line: Color(0x12FFFFFF),
    sheet: Color(0xFF171B22),
    toast: Color(0xFF1F242E),
    scrim: Color(0x9E06080B),
    tabBar: Color(0xBD171B22),
    avatarFrom: Color(0xFF262C37),
    avatarTo: Color(0xFF262C37),
  );

  /// **Gips** — light tema (P4 redesign). Issiq qog'oz foni.
  ///
  /// Eski D208 navy/emerald palitrasi BEKOR: prototip anor aksentini
  /// talab qiladi va brend ikkala temada bir xil bo'lishi kerak.
  static const AppColors light = AppColors(
    bg0: Color(0xFFF7F5F2),
    bg1: Color(0xFFFFFFFF),
    glass: Color(0xFFFFFFFF),
    glassHi: Color(0xFFEFEAE4),
    ink: Color(0xFF16181D),
    soft: Color(0xFF62666F),
    // Kontrast AA ga ko'tarilgan (prototip #8E939C = 2.7:1).
    dim: Color(0xFF6B7079),
    anor: Color(0xFFE5484D),
    anor2: Color(0xFFE5484D),
    anorGlow: Color(0x33E5484D),
    ringStart: Color(0xFFE5484D),
    ringEnd: Color(0xFFFF6B6B),
    ok: Color(0xFF12855C),
    okSoft: Color(0xFFE3F5EC),
    warn: Color(0xFF9C6712),
    warnSoft: Color(0xFFFAF0DC),
    debt: Color(0xFFC6314F),
    debtSoft: Color(0xFFFBE9ED),
    line: Color(0x1714100C),
    sheet: Color(0xFFFFFFFF),
    // Toast light'da ham to'q — kontrast uchun.
    toast: Color(0xFF1F242E),
    scrim: Color(0x571C1610),
    tabBar: Color(0xCCFFFFFF),
    avatarFrom: Color(0xFFF1ECE6),
    avatarTo: Color(0xFFF1ECE6),
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

  /// Tugma / chip / FAB gradienti: `linear-gradient(135deg, #E5484D, #FF6B6B)`.
  /// Ikkala temada BIR XIL — brend rangi tema bilan o'zgarmaydi.
  ///
  /// CSS `135deg` = yuqori-chapdan pastki-o'ngga.
  LinearGradient get anorGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFE5484D), Color(0xFFFF6B6B)],
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
