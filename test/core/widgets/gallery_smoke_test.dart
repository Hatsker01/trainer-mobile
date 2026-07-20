import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/theme/app_theme.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/heatmap.dart';
import 'package:ustoz_trainer/core/widgets/mini_bar_chart.dart';
import 'package:ustoz_trainer/core/widgets/plita_ring.dart';
import 'package:ustoz_trainer/core/widgets/status_badge.dart';
import 'package:ustoz_trainer/core/widgets/timeline_tile.dart';
import 'package:ustoz_trainer/dev/gallery.dart';

/// Galereya — T1 ning qabul mezoni.
///
/// Galereya `ListView` — ekrandan tashqaridagi bolalar UMUMAN qurilmaydi.
/// Shuning uchun har test ro'yxatni oxirigacha aylantiradi: shundagina
/// hamma komponent haqiqatan chiziladi va overflow tekshiruvi ma'noga ega.
void main() {
  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.dark, home: child);

  /// Ro'yxatni oxirigacha aylantirib, yo'lda uchragan komponentlarni yig'adi.
  Future<Set<Type>> scrollThrough(WidgetTester tester) async {
    final Set<Type> seen = <Type>{};
    const List<Type> watched = <Type>[
      GradientButton,
      GhostButton,
      StatusBadge,
      PlitaRing,
      Timeline,
      Heatmap,
      MiniBarChart,
    ];

    void record() {
      for (final Type t in watched) {
        if (find.byType(t).evaluate().isNotEmpty) {
          seen.add(t);
        }
      }
    }

    record();
    // 40 qadam × 400px — galereyaning to'liq balandligidan ortiq.
    for (int i = 0; i < 40; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();
      record();
    }
    await tester.pumpAndSettle();
    return seen;
  }

  group('Gallery', () {
    testWidgets('barcha komponentlar chiziladi', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const GalleryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Gallery'), findsOneWidget);

      final Set<Type> seen = await scrollThrough(tester);

      // Har bir design-system komponenti hech bo'lmasa bir marta chizildi.
      expect(
        seen,
        containsAll(<Type>[
          GradientButton,
          GhostButton,
          StatusBadge,
          PlitaRing,
          Timeline,
          Heatmap,
          MiniBarChart,
        ]),
      );
    });

    // T9 adaptivlik matritsasi: 360×640 (eng tor), 393×852, 430×932.
    for (final (double w, double h) in <(double, double)>[
      (360, 640),
      (393, 852),
      (430, 932),
    ]) {
      for (final double scale in <double>[1.0, 1.3]) {
        testWidgets('${w.toInt()}×${h.toInt()} @ ${scale}x — overflow yo\'q', (
          WidgetTester tester,
        ) async {
          tester.view.physicalSize = Size(w, h);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(
                size: Size(w, h),
                textScaler: TextScaler.linear(scale),
              ),
              child: wrap(const GalleryScreen()),
            ),
          );
          await tester.pumpAndSettle();

          await scrollThrough(tester);

          // Overflow `FlutterError` sifatida qayd etiladi — bu yerda
          // kutilayotgani NULL, ya'ni hech qanday overflow bo'lmagan.
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
