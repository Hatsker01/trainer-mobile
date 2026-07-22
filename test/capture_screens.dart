import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_theme.dart';
import 'package:ustoz_trainer/features/attendance/ui/attendance_sheet.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';
import 'package:ustoz_trainer/features/auth/ui/onboarding_screen.dart';
import 'package:ustoz_trainer/features/auth/ui/phone_screen.dart';
import 'package:ustoz_trainer/features/calendar/providers/calendar_provider.dart';
import 'package:ustoz_trainer/features/calendar/ui/calendar_screen.dart';
import 'package:ustoz_trainer/features/dashboard/ui/dashboard_screen.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';
import 'package:ustoz_trainer/features/settings/ui/settings_screen.dart';
import 'package:ustoz_trainer/features/stats/ui/stats_screen.dart';
import 'package:ustoz_trainer/features/students/ui/student_profile_screen.dart';
import 'package:ustoz_trainer/features/students/ui/students_screen.dart';

import 'support/fakes.dart';

/// H1/H3 — real-font screenshot artefaktlari (`screenshots/audit/`).
/// Emulyator yo'q → widget-render PNG. Yuqorida 44px status-bar zonasi
/// simulyatsiya qilinadi (Samsung); qizil chiziq = xavfsiz chegara.
/// Kontent chiziqdan PASTDA bo'lishi = H1 tuzatilgan.

const double kStatusBar = 44;

Future<void> _loadFonts() async {
  for (final (String family, String path) in <(String, String)>[
    ('Unbounded', 'assets/fonts/Unbounded-Variable.ttf'),
    ('Manrope', 'assets/fonts/Manrope-Variable.ttf'),
    ('JetBrainsMono', 'assets/fonts/JetBrainsMono-Variable.ttf'),
  ]) {
    final Uint8List bytes = await File(path).readAsBytes();
    final FontLoader loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
}

Future<void> _capture(WidgetTester tester, String name) async {
  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(const ValueKey<String>('shot')))
          as RenderRepaintBoundary;
  final ByteData? png = await tester.runAsync<ByteData?>(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    return image.toByteData(format: ui.ImageByteFormat.png);
  });
  final Directory dir = Directory('screenshots/audit');
  dir.createSync(recursive: true);
  File('${dir.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
}

/// Ekranni 44px status-bar insetli MediaQuery + chegara chizig'i bilan o'raydi.
/// [shell] — AppShell kabi SafeArea(top) qo'shadi (AppBar'siz ekranlar uchun).
Widget _framed(Widget child, {required bool shell}) {
  const AppColors c = AppColors.light;
  // Shell ekranlar (AppShell'da Scaffold ostida) — TextField uchun Material
  // ajdodi + SafeArea (H1) kerak.
  final Widget body = shell
      ? Material(
          color: Colors.transparent,
          child: SafeArea(bottom: false, child: child),
        )
      : child;
  return RepaintBoundary(
    key: const ValueKey<String>('shot'),
    child: MediaQuery(
      data: const MediaQueryData(
        size: Size(393, 852),
        padding: EdgeInsets.only(top: kStatusBar, bottom: 24),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: ColoredBox(color: c.bg0)),
          Positioned.fill(child: body),
          // Status-bar zonasi (yarim shaffof) + xavfsiz chegara chizig'i.
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: kStatusBar,
            child: ColoredBox(color: Color(0x11000000)),
          ),
          const Positioned(
            top: kStatusBar,
            left: 0,
            right: 0,
            height: 1,
            child: ColoredBox(color: Color(0xFFE5484D)),
          ),
          const Positioned(
            top: 12,
            left: 16,
            child: Text(
              '9:41',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _app(Widget framed, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: AppStringsScope(
    strings: const AppStrings(Lang.uz),
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: framed,
    ),
  ),
);

DashboardStudent _ds(
  String id,
  String name,
  int price,
  PaymentState st, {
  int? overdue,
}) => DashboardStudent(
  id: id,
  name: name,
  tariffPrice: price,
  paymentState: st,
  nextDueDate: DateTime(2026, 7, 21),
  daysOverdue: overdue,
);

Student _st(String id, String name, int price, PaymentState st, {int? od}) =>
    student(id: id, name: name, price: price, state: st, daysOverdue: od);

/// Davomad kunlari bo'lgan repo (heatmap ko'rinishi uchun).
class _AttFakeRepo extends FakeStudentRepository {
  _AttFakeRepo(List<Student> items) : super(items: items);

  @override
  Future<AttendanceList> attendance(
    String id, {
    DateTime? from,
    DateTime? to,
  }) async {
    final DateTime now = DateTime(2026, 7, 21);
    return AttendanceList(
      items: <AttendanceDay>[
        for (final int d in <int>[1, 3, 4, 8, 10, 11, 15, 17, 18, 20])
          AttendanceDay(date: now.subtract(Duration(days: d))),
      ],
    );
  }
}

void main() {
  final DateTime now = DateTime.now();
  final String monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

  setUpAll(_loadFonts);

  void setSize(WidgetTester t) {
    t.view.devicePixelRatio = 1.0;
    t.view.physicalSize = const Size(393, 852);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
  }

  final Me trainer = Me(
    id: 'u1',
    phone: '+998901234567',
    role: UserRole.trainer,
    name: 'Jamshid',
    lang: Lang.uz,
    plan: Plan.free,
    tgConnected: true,
    createdAt: DateTime(2026),
    monthlyGoal: 10000000,
  );

  testWidgets('audit dashboard', (WidgetTester t) async {
    setSize(t);
    final DashboardResponse d = DashboardResponse(
      date: DateTime(2026, 7, 21),
      greetingName: 'Jamshid',
      dueToday: <DashboardStudent>[
        _ds('s1', 'Ali Valiev', 550000, PaymentState.dueToday),
      ],
      dueSoon: const <DashboardStudent>[],
      overdue: <DashboardStudent>[
        _ds('s2', 'Aziz Karimov', 400000, PaymentState.overdue, overdue: 3),
      ],
      attendanceToday: const AttendanceToday(markedCount: 0),
      collectedThisMonth: 6800000,
      expectedThisMonth: 8300000,
    );
    await t.pumpWidget(
      _app(
        _framed(const DashboardScreen(), shell: true),
        testOverrides(dashboard: FakeDashboardRepository(response: d)),
      ),
    );
    final ProviderContainer c = ProviderScope.containerOf(
      t.element(find.byType(DashboardScreen)),
    );
    c.read(sessionProvider.notifier).setMe(trainer);
    await t.pumpAndSettle();
    // H1: sarlavha status-bar chizig'idan pastda.
    expect(
      t.getTopLeft(find.textContaining('Salom')).dy,
      greaterThanOrEqualTo(kStatusBar),
    );
    await _capture(t, 'dashboard');
  });

  testWidgets('audit students', (WidgetTester t) async {
    setSize(t);
    final List<Student> roster = <Student>[
      _st('s2', 'Aziz Karimov', 400000, PaymentState.overdue, od: 3),
      _st('s1', 'Ali Valiev', 550000, PaymentState.dueToday),
      _st('s3', 'Dilnoza Mirzayeva', 300000, PaymentState.paid),
      _st('s4', 'Bekzod Toshmatov', 500000, PaymentState.dueSoon),
    ];
    await t.pumpWidget(
      _app(
        _framed(const StudentsScreen(), shell: true),
        testOverrides(students: FakeStudentRepository(items: roster)),
      ),
    );
    await t.pumpAndSettle();
    expect(
      t.getTopLeft(find.text('Shogirdlar')).dy,
      greaterThanOrEqualTo(kStatusBar),
    );
    await _capture(t, 'students');
  });

  testWidgets('audit profile payments', (WidgetTester t) async {
    setSize(t);
    final List<Student> roster = <Student>[
      _st('s2', 'Aziz Karimov', 400000, PaymentState.overdue, od: 3),
    ];
    await t.pumpWidget(
      _app(
        _framed(const StudentProfileScreen(id: 's2'), shell: false),
        testOverrides(students: _AttFakeRepo(<Student>[...roster])),
      ),
    );
    await t.pumpAndSettle();
    await _capture(t, 'profile_payments');
    // Davomad tabiga o'tamiz.
    await t.tap(find.text(const AppStrings(Lang.uz).attendance));
    await t.pumpAndSettle();
    await _capture(t, 'profile_attendance');
  });

  testWidgets('audit calendar', (WidgetTester t) async {
    setSize(t);
    const CalMonth month = CalMonth(
      days: <int, CalDay>{
        3: CalDay(status: CalStatus.paid, paidCount: 1),
        8: CalDay(status: CalStatus.partial, partialCount: 1),
        15: CalDay(status: CalStatus.unpaid, unpaidCount: 1),
        22: CalDay(status: CalStatus.planned, plannedCount: 1),
      },
      paid: 12,
      partial: 2,
      planned: 3,
      unpaid: 1,
    );
    await t.pumpWidget(
      _app(_framed(const CalendarScreen(), shell: true), <Override>[
        ...testOverrides(),
        calendarMonthProvider(monthKey).overrideWith((Ref ref) async => month),
      ]),
    );
    await t.pumpAndSettle();
    await _capture(t, 'calendar');
  });

  testWidgets('audit stats', (WidgetTester t) async {
    setSize(t);
    await t.pumpWidget(
      _app(_framed(const StatsScreen(), shell: true), testOverrides()),
    );
    await t.pumpAndSettle();
    await _capture(t, 'stats');
  });

  testWidgets('audit settings', (WidgetTester t) async {
    setSize(t);
    await t.pumpWidget(
      _app(_framed(const SettingsScreen(), shell: true), testOverrides()),
    );
    final ProviderContainer c = ProviderScope.containerOf(
      t.element(find.byType(SettingsScreen)),
    );
    c.read(sessionProvider.notifier).setMe(trainer);
    await t.pumpAndSettle();
    expect(
      t.getTopLeft(find.text('Sozlamalar')).dy,
      greaterThanOrEqualTo(kStatusBar),
    );
    await _capture(t, 'settings');
  });

  testWidgets('audit attendance sheet', (WidgetTester t) async {
    setSize(t);
    final List<Student> roster = <Student>[
      _st('s1', 'Ali Valiev', 550000, PaymentState.paid),
      _st('s2', 'Aziz Karimov', 400000, PaymentState.paid),
      _st('s3', 'Dilnoza Mirzayeva', 300000, PaymentState.paid),
    ];
    await t.pumpWidget(
      _app(
        _framed(
          const Padding(
            padding: EdgeInsets.all(16),
            child: Material(color: Color(0xFFFFFFFF), child: AttendanceSheet()),
          ),
          shell: true,
        ),
        testOverrides(students: FakeStudentRepository(items: roster)),
      ),
    );
    await t.pumpAndSettle();
    await _capture(t, 'attendance_sheet');
  });

  testWidgets('audit payment sheet', (WidgetTester t) async {
    setSize(t);
    await t.pumpWidget(
      _app(
        _framed(
          const Padding(
            padding: EdgeInsets.all(16),
            child: Material(
              color: Color(0xFFFFFFFF),
              child: PaymentSheet(
                studentId: 's1',
                studentName: 'Ali Valiev',
                amount: 550000,
                tariffType: TariffType.monthly,
              ),
            ),
          ),
          shell: true,
        ),
        testOverrides(),
      ),
    );
    await t.pumpAndSettle();
    await _capture(t, 'payment_sheet');
  });

  testWidgets('audit onboarding', (WidgetTester t) async {
    setSize(t);
    await t.pumpWidget(
      _app(_framed(const OnboardingScreen(), shell: false), testOverrides()),
    );
    await t.pumpAndSettle();
    await _capture(t, 'onboarding');
  });

  testWidgets('audit phone', (WidgetTester t) async {
    setSize(t);
    await t.pumpWidget(
      _app(_framed(const PhoneScreen(), shell: false), testOverrides()),
    );
    await t.pumpAndSettle();
    await _capture(t, 'phone');
  });
}
