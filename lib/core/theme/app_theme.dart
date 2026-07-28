import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Ilova temasi (P4 redesign).
///
/// Rang qiymatlari `packages/ustoz_ui` dan keladi — `AppColors` faqat
/// **nom ko'prigi** (eski maydon nomlari saqlanadi, qiymatlar yangi).
/// Default tema — **dark "Kechki zal"** (TZ §3: "dark-first").
///
/// Yangi ekranlar `UstozTheme` + `context.uColors` bilan yoziladi;
/// bu fayl mavjud ekranlar migratsiya qilinguncha turadi.
abstract final class AppTheme {
  /// REDESIGN — aktiv tema. Barcha token `AppColors.light` dan.
  static ThemeData get light {
    const AppColors c = AppColors.light;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: c.bg0,
      canvasColor: c.bg0,
      fontFamily: AppText.bodyFamily,
      extensions: const <ThemeExtension<dynamic>>[c],

      colorScheme: const ColorScheme.light(
        primary: Color(0xFFE5484D),
        onPrimary: Colors.white,
        secondary: Color(0xFFFF6B6B),
        onSecondary: Colors.white,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF16181D),
        error: Color(0xFFC6314F),
        onError: Colors.white,
      ),

      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,

      textTheme: const TextTheme(
        displayLarge: AppText.display24,
        headlineMedium: AppText.h20,
        titleLarge: AppText.h18,
        titleMedium: AppText.section15,
        bodyLarge: AppText.body15Bold,
        bodyMedium: AppText.body14,
        bodySmall: AppText.caption12,
        labelSmall: AppText.badge11,
      ).apply(bodyColor: c.ink, displayColor: c.ink),

      // Kursor / tanlash — navy.
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFFE5484D),
        selectionColor: Color(0x33E5484D),
        selectionHandleColor: Color(0xFFE5484D),
      ),

      // Light rejim: status bar ikonlari QORA (yorug' fon ustida).
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFFF7F5F2),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
    );
  }

  static ThemeData get dark {
    const AppColors c = AppColors.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: c.bg0,
      canvasColor: c.bg0,
      fontFamily: AppText.bodyFamily,
      extensions: const <ThemeExtension<dynamic>>[c],

      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE5484D),
        onPrimary: Colors.white,
        secondary: Color(0xFFFF6B6B),
        onSecondary: Colors.white,
        surface: Color(0xFF171B22),
        onSurface: Color(0xFFEDEFF3),
        error: Color(0xFFE23E63),
        onError: Colors.white,
      ),

      // Dizaynda Material "ripple" YO'Q — bosilish `scale(.97)` bilan beriladi.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,

      textTheme: const TextTheme(
        displayLarge: AppText.display24,
        headlineMedium: AppText.h20,
        titleLarge: AppText.h18,
        titleMedium: AppText.section15,
        bodyLarge: AppText.body15Bold,
        bodyMedium: AppText.body14,
        bodySmall: AppText.caption12,
        labelSmall: AppText.badge11,
      ).apply(bodyColor: c.ink, displayColor: c.ink),

      // Kursor / tanlash — anor.
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFFE5484D),
        selectionColor: Color(0x40E5484D),
        selectionHandleColor: Color(0xFFE5484D),
      ),

      // Ekran ostidagi tizim panellari shaffof — dizayn "to'liq ekran".
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFF0C0D10),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
    );
  }
}
