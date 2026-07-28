import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';

/// Tema tanlovi (TZ §3.10: "Til/Tema — dark default, light bor").
///
/// Tanlov `LocalStore` da saqlanadi: ilova qayta ochilganda foydalanuvchi
/// tanlagan tema tiklanadi. `system` — qurilma sozlamasiga ergashadi.
class ThemeModeController extends Notifier<ThemeMode> {
  static const String _key = 'theme_mode';

  @override
  ThemeMode build() {
    // Default — DARK: mahsulot "Kechki zal" bilan tanilishi kerak.
    // Saqlangan tanlov asinxron o'qiladi va kelganda holat yangilanadi.
    unawaited(_restore());
    return ThemeMode.dark;
  }

  Future<void> _restore() async {
    final Map<String, dynamic>? saved = await ref
        .read(localStoreProvider)
        .readJson(_key);
    final Object? raw = saved?['mode'];
    if (raw is String) {
      state = _parse(raw);
    }
  }

  /// Tanlovni o'zgartiradi va saqlaydi.
  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(localStoreProvider).writeJson(_key, <String, dynamic>{
      'mode': mode.name,
    });
  }

  /// Dark ↔ light almashtirgich (sozlamalardagi tugma).
  Future<void> toggle() =>
      set(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  static ThemeMode _parse(String s) => switch (s) {
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => ThemeMode.dark,
  };
}

/// `MaterialApp.themeMode` shu provayderdan o'qiydi.
final NotifierProvider<ThemeModeController, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
