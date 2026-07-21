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
import 'package:ustoz_trainer/core/api/repositories.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/theme/app_theme.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';
import 'package:ustoz_trainer/features/calendar/providers/calendar_provider.dart';
import 'package:ustoz_trainer/features/calendar/ui/calendar_screen.dart';
import 'package:ustoz_trainer/features/dashboard/ui/dashboard_screen.dart';

import 'support/fakes.dart';

/// G1/G2/G3 — real-font screenshot artefaktlari (`screenshots/density/`).
/// Emulyator yo'q (Android SDK/Xcode yo'q) → widget-render PNG.
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
      tester.renderObject(find.byType(RepaintBoundary).first)
          as RenderRepaintBoundary;
  final ByteData? png = await tester.runAsync<ByteData?>(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    return image.toByteData(format: ui.ImageByteFormat.png);
  });
  final Directory dir = Directory('screenshots/density');
  dir.createSync(recursive: true);
  File('${dir.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
}

Widget _wrap(
  Widget child, {
  DashboardRepository? dash,
  List<Override> extra = const <Override>[],
}) => ProviderScope(
  overrides: <Override>[
    ...testOverrides(dashboard: dash),
    ...extra,
  ],
  child: AppStringsScope(
    strings: const AppStrings(Lang.uz),
    child: MaterialApp(
      theme: AppTheme.light,
      home: RepaintBoundary(child: Scaffold(body: child)),
    ),
  ),
);

void main() {
  final DateTime now = DateTime.now();
  final String monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

  setUpAll(() async {
    await _loadFonts();
  });

  testWidgets('capture dashboard', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final DashboardResponse d = DashboardResponse(
      date: DateTime(2026, 7, 21),
      greetingName: 'Jamshid',
      dueToday: <DashboardStudent>[
        const DashboardStudent(
          id: 's1',
          name: 'Ali Valiev',
          tariffPrice: 550000,
          paymentState: PaymentState.dueToday,
          daysOverdue: 0,
        ),
      ],
      dueSoon: const <DashboardStudent>[],
      overdue: <DashboardStudent>[
        const DashboardStudent(
          id: 's2',
          name: 'Aziz Karimov',
          tariffPrice: 400000,
          paymentState: PaymentState.overdue,
          daysOverdue: 3,
        ),
      ],
      attendanceToday: const AttendanceToday(markedCount: 0),
      collectedThisMonth: 6800000,
      expectedThisMonth: 8300000,
    );

    await tester.pumpWidget(
      _wrap(
        const DashboardScreen(),
        dash: FakeDashboardRepository(response: d),
      ),
    );
    final Element el = tester.element(find.byType(DashboardScreen));
    final ProviderContainer c = ProviderScope.containerOf(el);
    c
        .read(sessionProvider.notifier)
        .setMe(
          Me(
            id: 'u1',
            phone: '+998901234567',
            role: UserRole.trainer,
            name: 'Jamshid',
            lang: Lang.uz,
            plan: Plan.free,
            tgConnected: true,
            createdAt: DateTime(2026),
            monthlyGoal: 10000000,
          ),
        );
    await tester.pumpAndSettle();
    await _capture(tester, 'dashboard');
  });

  testWidgets('capture calendar', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    await tester.pumpWidget(
      _wrap(
        const CalendarScreen(),
        extra: <Override>[
          calendarMonthProvider(
            monthKey,
          ).overrideWith((Ref ref) async => month),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await _capture(tester, 'calendar');
  });
}
