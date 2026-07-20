import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/api_client.dart';
import 'package:ustoz_trainer/core/api/repositories.dart';
import 'package:ustoz_trainer/core/storage/token_storage.dart';

/// Ilova darajasidagi yagona nusxalar (singleton'lar).
///
/// Repozitoriylar INTERFEYS tipida e'lon qilinadi — testda
/// `overrideWithValue(FakeStudentRepository())` bilan almashtiriladi.

final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>(
  (Ref ref) => TokenStorage(),
);

/// Sessiya tugaganda (refresh o'lgan) chaqiriladigan signal.
///
/// `ApiClient` router'ga to'g'ridan-to'g'ri bog'lanmaydi — u shunchaki
/// shu bayroqni ko'taradi, router esa uni kuzatadi. Aks holda tarmoq
/// qatlami navigatsiyani biladigan bo'lib qoladi.
final NotifierProvider<SessionExpiredNotifier, bool> sessionExpiredProvider =
    NotifierProvider<SessionExpiredNotifier, bool>(SessionExpiredNotifier.new);

class SessionExpiredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void trigger() => state = true;
  void reset() => state = false;
}

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  return ApiClient(
    storage: ref.watch(tokenStorageProvider),
    onSessionExpired: () async =>
        ref.read(sessionExpiredProvider.notifier).trigger(),
  );
});

final Provider<Dio> dioProvider = Provider<Dio>(
  (Ref ref) => ref.watch(apiClientProvider).dio,
);

// ------------------------------------------------------------ repozitoriylar

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (Ref ref) => AuthRepositoryImpl(ref.watch(dioProvider)),
    );

final Provider<MeRepository> meRepositoryProvider = Provider<MeRepository>(
  (Ref ref) => MeRepositoryImpl(ref.watch(dioProvider)),
);

final Provider<StudentRepository> studentRepositoryProvider =
    Provider<StudentRepository>(
      (Ref ref) => StudentRepositoryImpl(ref.watch(dioProvider)),
    );

final Provider<PaymentRepository> paymentRepositoryProvider =
    Provider<PaymentRepository>(
      (Ref ref) => PaymentRepositoryImpl(ref.watch(dioProvider)),
    );

final Provider<AttendanceRepository> attendanceRepositoryProvider =
    Provider<AttendanceRepository>(
      (Ref ref) => AttendanceRepositoryImpl(ref.watch(dioProvider)),
    );

final Provider<DashboardRepository> dashboardRepositoryProvider =
    Provider<DashboardRepository>(
      (Ref ref) => DashboardRepositoryImpl(ref.watch(dioProvider)),
    );

final Provider<StatsRepository> statsRepositoryProvider =
    Provider<StatsRepository>(
      (Ref ref) => StatsRepositoryImpl(ref.watch(dioProvider)),
    );

final Provider<TariffRepository> tariffRepositoryProvider =
    Provider<TariffRepository>(
      (Ref ref) => TariffRepositoryImpl(ref.watch(dioProvider)),
    );
