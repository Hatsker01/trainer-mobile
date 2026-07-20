import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/storage/local_store.dart';

final Provider<LocalStore> localStoreProvider = Provider<LocalStore>(
  (Ref ref) => LocalStore(),
);

/// Interfeys tili.
///
/// Lokal saqlanadi, chunki ilova `GET /me` dan OLDIN ham (login ekrani)
/// to'g'ri tilda ochilishi kerak. Server bilan sinxron: `PATCH /me` da
/// `lang` yuboriladi, `GET /me` javobi kelganda lokal qiymat yangilanadi.
final NotifierProvider<LangNotifier, Lang> langProvider =
    NotifierProvider<LangNotifier, Lang>(LangNotifier.new);

class LangNotifier extends Notifier<Lang> {
  static const String _key = 'settings';
  static const String _field = 'lang';

  @override
  Lang build() {
    // Fayldan o'qish asinxron — birinchi kadr `uz` bilan chiziladi,
    // keyin (agar boshqacha bo'lsa) yangilanadi. Splash ekranida bu
    // ko'zga tashlanmaydi.
    unawaited(_restore());
    return Lang.uz;
  }

  LocalStore get _store => ref.read(localStoreProvider);

  Future<void> _restore() async {
    final Map<String, dynamic>? saved = await _store.readJson(_key);
    final Object? code = saved?[_field];
    if (code == 'ru') {
      state = Lang.ru;
    }
  }

  /// Sozlamalarda til almashtirilganda — darhol UI, keyin server.
  Future<void> set(Lang lang) async {
    if (state == lang) {
      return;
    }
    state = lang;
    ref.read(apiClientProvider).setLanguage(lang.code);
    await _store.writeJson(_key, <String, dynamic>{_field: lang.code});
  }

  /// `GET /me` javobidan kelgan tilni lokalga singdirish (server ustun).
  Future<void> syncFromServer(Lang lang) => set(lang);
}

/// Joriy tildagi matnlar.
final Provider<AppStrings> stringsProvider = Provider<AppStrings>(
  (Ref ref) => AppStrings(ref.watch(langProvider)),
);
