import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` tipi Riverpod 3 da asosiy eksportda emas — `misc.dart` da.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/payment_dto.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/api/repositories.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/storage/local_store.dart';
import 'package:ustoz_trainer/core/storage/token_storage.dart';
import 'package:ustoz_trainer/core/theme/app_theme.dart';
import 'package:ustoz_trainer/features/attendance/providers/outbox.dart';

// Testlar ham `Override` dan foydalanadi — shu barreldan qayta eksport.
export 'package:flutter_riverpod/misc.dart' show Override;

/// Xotiradagi secure storage — testda platforma kanali yo'q.
class FakeSecureStorage extends FlutterSecureStorage {
  FakeSecureStorage([this.store = const <String, String>{}]) : super();

  final Map<String, String> store;

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      store.remove(key);
    } else {
      store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    store.remove(key);
  }
}

// --------------------------------------------------------------- namunalar

Student student({
  String id = 's1',
  String name = 'Aziz Karimov',
  String phone = '+998901234567',
  TariffType type = TariffType.monthly,
  int price = 400000,
  PaymentState state = PaymentState.paid,
  int? daysOverdue,
  int? sessionsTotal,
  int sessionsUsed = 0,
  StudentStatus status = StudentStatus.active,
}) => Student(
  id: id,
  name: name,
  phone: phone,
  tariffType: type,
  tariffPrice: price,
  sessionsUsed: sessionsUsed,
  sessionsTotal: sessionsTotal,
  daysOverdue: daysOverdue,
  status: status,
  paymentState: state,
  tgConnected: true,
  createdAt: DateTime(2026),
);

Me me({String name = 'Jamshid', Lang lang = Lang.uz}) => Me(
  id: 'u1',
  phone: '+998901234567',
  role: UserRole.trainer,
  name: name,
  lang: lang,
  plan: Plan.free,
  tgConnected: true,
  createdAt: DateTime(2026),
);

// ------------------------------------------------------------- soxta repolar

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.onRequest, this.onVerify});

  final Future<OtpRequestResponse> Function(String phone)? onRequest;
  final Future<TokenPair> Function(String phone, String code)? onVerify;

  final List<String> requestedPhones = <String>[];
  final List<String> verifiedCodes = <String>[];

  @override
  Future<OtpRequestResponse> requestOtp(String phone) {
    requestedPhones.add(phone);
    return onRequest?.call(phone) ??
        Future<OtpRequestResponse>.value(
          const OtpRequestResponse(
            channel: OtpChannel.tg,
            expiresIn: 300,
            retryAfter: 60,
          ),
        );
  }

  @override
  Future<TokenPair> verifyOtp({required String phone, required String code}) {
    verifiedCodes.add(code);
    return onVerify?.call(phone, code) ??
        Future<TokenPair>.value(
          const TokenPair(access: 'a', refresh: 'r', expiresIn: 900),
        );
  }
}

class FakeMeRepository implements MeRepository {
  FakeMeRepository({Me? initial}) : _me = initial ?? me();

  Me _me;

  @override
  Future<Me> getMe() async => _me;

  @override
  Future<Me> updateMe(MeUpdate update) async =>
      _me = me(name: update.name ?? _me.name, lang: update.lang ?? _me.lang);

  @override
  Future<TgLink> getTrainerTgLink() async =>
      const TgLink(link: 'https://t.me/UstozBot?start=x', token: 'x');
}

class FakeStudentRepository implements StudentRepository {
  FakeStudentRepository({List<Student>? items})
    : items = items ?? <Student>[student()];

  List<Student> items;

  /// Har `list` chaqiruvining parametrlari — filtr/qidiruv testlari uchun.
  final List<({StudentFilter filter, String? query, int page})> calls =
      <({StudentFilter filter, String? query, int page})>[];

  @override
  Future<PagedStudents> list({
    StudentFilter filter = StudentFilter.all,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    calls.add((filter: filter, query: query, page: page));

    Iterable<Student> result = items;
    if (query != null && query.isNotEmpty) {
      result = result.where(
        (Student s) => s.name.toLowerCase().contains(query.toLowerCase()),
      );
    }
    if (filter == StudentFilter.debtors) {
      result = result.where((Student s) => s.isDebtor);
    }

    final List<Student> list = result.toList();
    return PagedStudents(
      items: list,
      total: list.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Student> get(String id) async =>
      items.firstWhere((Student s) => s.id == id);

  @override
  Future<Student> create(StudentCreate body) async => student(
    id: 'new',
    name: body.name,
    phone: body.phone,
    type: body.tariffType,
    price: body.tariffPrice,
  );

  @override
  Future<Student> update(String id, StudentUpdate body) async => get(id);

  @override
  Future<Student> archive(String id) async =>
      student(id: id, status: StudentStatus.archived);

  @override
  Future<TgLink> inviteLink(String id) async =>
      const TgLink(link: 'https://t.me/UstozBot?start=inv', token: 'inv');

  @override
  Future<RemindResponse> remind(String id, {RemindRequest? body}) async =>
      const RemindResponse(
        notificationId: 'n1',
        status: NotificationStatus.queued,
      );

  @override
  Future<PagedPayments> payments(
    String id, {
    int page = 1,
    int limit = 20,
  }) async =>
      const PagedPayments(items: <Payment>[], total: 0, page: 1, limit: 20);

  @override
  Future<AttendanceList> attendance(
    String id, {
    DateTime? from,
    DateTime? to,
  }) async => const AttendanceList(items: <AttendanceDay>[]);
}

/// To'lov repozitoriysi — CHAQIRUVLARNI SANAYDI (double-tap testi uchun).
class FakePaymentRepository implements PaymentRepository {
  FakePaymentRepository({this.delay = Duration.zero});

  final Duration delay;
  int callCount = 0;
  final List<String?> idempotencyKeys = <String?>[];

  @override
  Future<PaymentCreated> create(
    PaymentCreate body, {
    String? idempotencyKey,
  }) async {
    callCount++;
    idempotencyKeys.add(idempotencyKey);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return PaymentCreated(
      payment: Payment(
        id: 'p1',
        studentId: body.studentId,
        amount: body.amount,
        method: body.method,
        paidAt: body.paidAt ?? DateTime(2026, 7, 20),
        createdAt: DateTime(2026, 7, 20),
      ),
      student: student(id: body.studentId),
    );
  }
}

class FakeAttendanceRepository implements AttendanceRepository {
  FakeAttendanceRepository({this.onMark});

  final Future<AttendanceBulkResponse> Function(AttendanceBulkRequest)? onMark;
  final List<AttendanceBulkRequest> requests = <AttendanceBulkRequest>[];

  @override
  Future<AttendanceBulkResponse> markBulk(AttendanceBulkRequest body) {
    requests.add(body);
    return onMark?.call(body) ??
        Future<AttendanceBulkResponse>.value(
          AttendanceBulkResponse(marked: body.studentIds.length, skipped: 0),
        );
  }
}

class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository({this.response});

  final DashboardResponse? response;

  @override
  Future<DashboardResponse> get() async =>
      response ??
      DashboardResponse(
        date: DateTime(2026, 7, 20),
        greetingName: 'Jamshid',
        dueToday: const <DashboardStudent>[],
        dueSoon: const <DashboardStudent>[],
        overdue: const <DashboardStudent>[],
        attendanceToday: const AttendanceToday(markedCount: 0),
      );
}

class FakeStatsRepository implements StatsRepository {
  @override
  Future<StatsResponse> get() async => const StatsResponse(
    monthRevenue: 6800000,
    prevMonthRevenue: 6000000,
    changePercent: 13.3,
    activeStudents: 23,
    debtTotal: 800000,
    debtorsCount: 2,
    series: <StatsSeriesPoint>[
      StatsSeriesPoint(month: '2026-07', revenue: 6800000),
    ],
  );
}

class FakeTariffRepository implements TariffRepository {
  FakeTariffRepository({List<TariffTemplate>? items})
    : items = items ?? <TariffTemplate>[];

  List<TariffTemplate> items;

  @override
  Future<List<TariffTemplate>> list({bool includeInactive = false}) async =>
      items;

  @override
  Future<TariffTemplate> create(TariffCreate body) async => TariffTemplate(
    id: 't1',
    name: body.name,
    type: body.type,
    price: body.price,
    isActive: true,
  );

  @override
  Future<TariffTemplate> update(String id, TariffUpdate body) async =>
      TariffTemplate(
        id: id,
        name: body.name ?? 'x',
        type: TariffType.monthly,
        price: body.price ?? 0,
        isActive: body.isActive ?? true,
      );
}

// ------------------------------------------------------------------ harness

/// Xotiradagi `LocalStore` — hech qanday dart:io async IO YO'Q.
///
/// MUHIM: haqiqiy `LocalStore` fayl/papka yaratishda ASINXRON dart:io
/// chaqiradi. Widget testda (pump/pumpAndSettle) real event loop
/// ishlamaydi — u `tester.runAsync` talab qiladi. Shu sababli haqiqiy
/// store'ni ishlatgan test "pumpAndSettle timed out" bilan yiqiladi.
/// Bu soxta versiya hamma amalni sinxron `Map` da bajaradi.
class FakeLocalStore implements LocalStore {
  final Map<String, Map<String, dynamic>> _data =
      <String, Map<String, dynamic>>{};

  @override
  Future<Map<String, dynamic>?> readJson(String key) async => _data[key];

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _data.clear();
  }
}

/// Testda ishlatiladigan standart override'lar.
List<Override> testOverrides({
  AuthRepository? auth,
  MeRepository? meRepo,
  StudentRepository? students,
  PaymentRepository? payments,
  AttendanceRepository? attendance,
  DashboardRepository? dashboard,
  StatsRepository? stats,
  TariffRepository? tariffs,
  Map<String, String>? tokens,
  LocalStore? store,
}) => <Override>[
  localStoreProvider.overrideWithValue(store ?? FakeLocalStore()),
  // Platforma `EventChannel` iga tegmaslik uchun — testda bo'sh oqim.
  connectivityStreamProvider.overrideWithValue(
    const Stream<List<ConnectivityResult>>.empty(),
  ),
  tokenStorageProvider.overrideWithValue(
    TokenStorage(FakeSecureStorage(tokens ?? <String, String>{})),
  ),
  authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
  meRepositoryProvider.overrideWithValue(meRepo ?? FakeMeRepository()),
  studentRepositoryProvider.overrideWithValue(
    students ?? FakeStudentRepository(),
  ),
  paymentRepositoryProvider.overrideWithValue(
    payments ?? FakePaymentRepository(),
  ),
  attendanceRepositoryProvider.overrideWithValue(
    attendance ?? FakeAttendanceRepository(),
  ),
  dashboardRepositoryProvider.overrideWithValue(
    dashboard ?? FakeDashboardRepository(),
  ),
  statsRepositoryProvider.overrideWithValue(stats ?? FakeStatsRepository()),
  tariffRepositoryProvider.overrideWithValue(tariffs ?? FakeTariffRepository()),
];

/// Bitta ekranni to'liq muhit bilan o'rash (router'siz).
///
/// [overrides] STANDARTNI to'g'ridan-to'g'ri almashtiradi — bitta provider
/// ikki marta override qilinmaydi (Riverpod buni taqiqlaydi). Test faqat
/// o'zi xohlagan repozitoriyni yuboradi, qolgani standart qoladi.
Widget wrapScreen(
  Widget child, {
  AuthRepository? auth,
  MeRepository? meRepo,
  StudentRepository? students,
  PaymentRepository? payments,
  AttendanceRepository? attendance,
  DashboardRepository? dashboard,
  StatsRepository? stats,
  TariffRepository? tariffs,
  Map<String, String>? tokens,
}) => ProviderScope(
  overrides: testOverrides(
    auth: auth,
    meRepo: meRepo,
    students: students,
    payments: payments,
    attendance: attendance,
    dashboard: dashboard,
    stats: stats,
    tariffs: tariffs,
    tokens: tokens,
  ),
  child: AppStringsScope(
    strings: const AppStrings(Lang.uz),
    // Ba'zi ekranlar o'z `Scaffold` iga ega emas (asosiy qismda ular
    // `AppShell` ichida yashaydi) — test uchun `Scaffold` bilan o'raymiz,
    // aks holda `TextField` "no Material ancestor" deb yiqiladi.
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    ),
  ),
);

/// Navigatsiya qiladigan ekranlar uchun (`context.push`) — minimal
/// `GoRouter`. [pushTargets] — ekran push qiladigan yo'llar (bo'sh sahifa).
Widget wrapRouted(
  Widget child, {
  AuthRepository? auth,
  StudentRepository? students,
  List<String> pushTargets = const <String>[],
}) {
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext _, GoRouterState _) => Scaffold(body: child),
      ),
      for (final String path in pushTargets)
        GoRoute(
          path: path,
          builder: (BuildContext _, GoRouterState _) =>
              const Scaffold(body: SizedBox.shrink()),
        ),
    ],
  );

  return ProviderScope(
    overrides: testOverrides(auth: auth, students: students),
    child: AppStringsScope(
      strings: const AppStrings(Lang.uz),
      child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    ),
  );
}
