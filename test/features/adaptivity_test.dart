import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/features/dashboard/ui/dashboard_screen.dart';
import 'package:ustoz_trainer/features/settings/ui/settings_screen.dart';
import 'package:ustoz_trainer/features/stats/ui/stats_screen.dart';
import 'package:ustoz_trainer/features/students/ui/students_screen.dart';

import '../support/fakes.dart';

/// T9 ADAPTIVLIK MATRITSASI.
///
/// Har asosiy ekran uch o'lchamda (360×640 eng tor, 393×852, 430×932) va
/// ikki textScale da (1.0, 1.3) OVERFLOW'SIZ chizilishi shart. Overflow
/// debug'da `FlutterError` beradi — bu yerda uni AVTOMATIK ovlaymiz.
void main() {
  // Ma'lumotli dashboard — bo'sh emas, chunki bo'sh ekran overflow bermaydi.
  DashboardResponse richDashboard() => DashboardResponse(
    date: DateTime(2026, 7, 20),
    greetingName: 'Jamshid',
    dueToday: <DashboardStudent>[
      const DashboardStudent(
        id: '1',
        name: 'Dilnoza Mirzayeva',
        tariffPrice: 400000,
        paymentState: PaymentState.dueToday,
      ),
    ],
    dueSoon: const <DashboardStudent>[],
    overdue: <DashboardStudent>[
      const DashboardStudent(
        id: '2',
        name: 'Aziz Karimov',
        tariffPrice: 400000,
        daysOverdue: 3,
        paymentState: PaymentState.overdue,
      ),
    ],
    totals: const DashboardTotals(
      dueTodayAmount: 400000,
      overdueAmount: 800000,
    ),
    attendanceToday: const AttendanceToday(markedCount: 3),
  );

  final List<(String, Widget)> screens = <(String, Widget)>[
    (
      'Dashboard',
      wrapScreen(
        const DashboardScreen(),
        dashboard: FakeDashboardRepository(response: richDashboard()),
      ),
    ),
    ('Shogirdlar', wrapScreen(const StudentsScreen())),
    ('Statistika', wrapScreen(const StatsScreen())),
    ('Sozlamalar', wrapScreen(const SettingsScreen())),
  ];

  const List<(double, double)> sizes = <(double, double)>[
    (360, 640),
    (393, 852),
    (430, 932),
  ];

  for (final (String name, Widget screen) in screens) {
    for (final (double w, double h) in sizes) {
      for (final double scale in <double>[1.0, 1.3]) {
        testWidgets(
          '$name ${w.toInt()}×${h.toInt()} @ ${scale}x — overflow yo\'q',
          (WidgetTester tester) async {
            // Overflow chizmasi (qizil chiziq) `FlutterError` tashlaydi —
            // uni yig'ib olamiz.
            final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
            final FlutterExceptionHandler? prev = FlutterError.onError;
            FlutterError.onError = errors.add;
            addTearDown(() => FlutterError.onError = prev);

            tester.view.physicalSize = Size(w, h);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);

            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(
                  size: Size(w, h),
                  textScaler: TextScaler.linear(scale),
                ),
                child: screen,
              ),
            );
            // Skeletlar cheksiz pulse — pumpAndSettle o'rniga bir necha kadr.
            await tester.pump();
            await tester.pump(const Duration(seconds: 1));

            final Iterable<FlutterErrorDetails> overflows = errors.where(
              (FlutterErrorDetails e) =>
                  e.exceptionAsString().contains('overflowed'),
            );
            expect(
              overflows,
              isEmpty,
              reason: overflows
                  .map((FlutterErrorDetails e) => e.exceptionAsString())
                  .join('\n'),
            );
          },
        );
      }
    }
  }
}
