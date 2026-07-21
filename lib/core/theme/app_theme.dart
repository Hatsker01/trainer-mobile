import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Ilova temasi. REDESIGN (D208): `light` — yangi navy/emerald tizim (aktiv).
/// `dark` — eski "KECHKI ZAL" (saqlanadi, keyin qaytishi mumkin).
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
        primary: Color(0xFF1A3D7C),
        onPrimary: Colors.white,
        secondary: Color(0xFF2ECC71),
        onSecondary: Colors.white,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF222222),
        error: Color(0xFFD63C2C),
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
        cursorColor: Color(0xFF1A3D7C),
        selectionColor: Color(0x331A3D7C),
        selectionHandleColor: Color(0xFF1A3D7C),
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
          systemNavigationBarColor: Color(0xFFFFFFFF),
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
        primary: Color(0xFFFF5340),
        onPrimary: Colors.white,
        secondary: Color(0xFFE2264B),
        onSecondary: Colors.white,
        surface: Color(0xFF17191E),
        onSurface: Color(0xFFF4F2EC),
        error: Color(0xFFFF7A6B),
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
        cursorColor: Color(0xFFFF5340),
        selectionColor: Color(0x40FF5340),
        selectionHandleColor: Color(0xFFFF5340),
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
