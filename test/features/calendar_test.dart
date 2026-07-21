import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/features/calendar/providers/calendar_provider.dart';
import 'package:ustoz_trainer/features/calendar/ui/calendar_screen.dart';

import '../support/fakes.dart';

/// G3 — kalendar to'lov holatlari: rang-kodli kunlar, kun sheeti (qoldiq),
/// oy xulosasi. Backend `calendarMonthProvider` override qilinadi.
void main() {
  final DateTime now = DateTime.now();
  final String key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  final int probeDay = now.day == 10 ? 11 : 10;

  CalMonth monthData() => CalMonth(
    days: <int, CalDay>{
      probeDay: const CalDay(
        status: CalStatus.partial,
        partialCount: 1,
        entries: <CalEntry>[
          CalEntry(
            studentId: 's1',
            name: 'Ali Valiev',
            expected: 550000,
            paid: 300000,
            status: CalStatus.partial,
          ),
        ],
      ),
    },
    paid: 12,
    partial: 2,
    planned: 3,
    unpaid: 1,
  );

  Widget buildScreen() {
    final List<Override> overrides = <Override>[
      ...testOverrides(),
      calendarMonthProvider(key).overrideWith((Ref ref) async => monthData()),
    ];
    return ProviderScope(
      overrides: overrides,
      child: const AppStringsScope(
        strings: AppStrings(Lang.uz),
        child: MaterialApp(home: Scaffold(body: CalendarScreen())),
      ),
    );
  }

  testWidgets('oy xulosasi + kun sheeti (shogird qoldig\'i) ko\'rsatiladi', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Oy xulosasi: "... 12 to'liq · 2 qisman · 3 kutilmoqda".
    expect(find.textContaining("12 to'liq"), findsOneWidget);

    // Kun katagini bosamiz → sheet ochiladi.
    await tester.tap(find.text('$probeDay').first);
    await tester.pumpAndSettle();

    // Sheetda shogird ismi va qoldiq-to'lov tugmasi.
    expect(find.text('Ali Valiev'), findsOneWidget);
    expect(find.text(const AppStrings(Lang.uz).addPayment), findsWidgets);
  });
}
