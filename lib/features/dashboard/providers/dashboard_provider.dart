import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/storage/local_store.dart';

/// Dashboard holati — ma'lumot + u keshdanmi.
class DashboardData {
  const DashboardData({required this.value, this.stale = false});

  final DashboardResponse value;

  /// `true` — bu keshdagi eski nusxa, tarmoqdan yangilanish ketmoqda
  /// yoki tarmoq yo'q (T8: stale-while-revalidate).
  final bool stale;
}

final AsyncNotifierProvider<DashboardNotifier, DashboardData>
dashboardProvider = AsyncNotifierProvider<DashboardNotifier, DashboardData>(
  DashboardNotifier.new,
);

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  static const String _cacheKey = 'cache_dashboard';

  LocalStore get _store => ref.read(localStoreProvider);

  @override
  Future<DashboardData> build() async {
    // T8 stale-while-revalidate: avval kesh (bo'lsa) darhol ko'rsatiladi,
    // keyin tarmoq. Kesh bo'lmasa oddiy loading.
    final Map<String, dynamic>? cached = await _store.readJson(_cacheKey);

    if (cached != null) {
      try {
        final DashboardData stale = DashboardData(
          value: DashboardResponse.fromJson(cached),
          stale: true,
        );
        // Keshni darhol chiqaramiz, tarmoqni fonda so'raymiz.
        state = AsyncData<DashboardData>(stale);
        unawaited(_fetchAndStore(silent: true));
        return stale;
      } on Object {
        // Kesh eski sxemada — tashlaymiz.
        await _store.delete(_cacheKey);
      }
    }

    return _fetchAndStore();
  }

  Future<DashboardData> _fetchAndStore({bool silent = false}) async {
    try {
      final DashboardResponse fresh = await ref
          .read(dashboardRepositoryProvider)
          .get();

      // Kesh — keyingi ochilish uchun. `toJson` generatsiya qilingan,
      // ya'ni round-trip kontraktga aynan mos (qo'lda yig'ish emas).
      unawaited(_store.writeJson(_cacheKey, fresh.toJson()));

      final DashboardData data = DashboardData(value: fresh);
      if (silent) {
        state = AsyncData<DashboardData>(data);
      }
      return data;
    } on AppException catch (e, st) {
      if (silent) {
        // Keshdagi ma'lumot ekranda turibdi — uni xato bilan
        // ALMASHTIRMAYMIZ. Foydalanuvchi eski ma'lumotni ko'rib
        // turgani yo'qdan yaxshi (T8).
        final DashboardData? current = state.value;
        if (current != null) {
          state = AsyncData<DashboardData>(
            DashboardData(value: current.value, stale: true),
          );
          return current;
        }
      }
      Error.throwWithStackTrace(e, st);
    }
  }

  /// Pull-to-refresh.
  ///
  /// `AsyncLoading` ATAYIN qo'yilmaydi: holat tegilmasa UI eski
  /// ma'lumotni ko'rsatib turaveradi va `RefreshIndicator` o'zi
  /// aylanadi — skeletga sakrash ko'zni qamashtiradi.
  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetchAndStore);
  }

  /// To'lov/davomad saqlangandan keyin — jimgina yangilash.
  Future<void> invalidateQuietly() => _fetchAndStore(silent: true);
}
