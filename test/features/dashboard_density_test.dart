import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/money_text.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';
import 'package:ustoz_trainer/features/dashboard/ui/dashboard_screen.dart';

import '../support/fakes.dart';

/// G1/G2 — ZICHLIK isbotlari:
///  * pul KO'RSATISHI vergulsiz, kichik "so'm" suffiksli (MoneyText);
///  * KPI qiymatlari 18-24px oralig'ida (Display o'lchamda EMAS);
///  * dashboard 1-4 bo'limlari 393×852 da scroll'siz sig'adi.
void main() {
  Me meGoal({int? goal = 10000000}) => Me(
    id: 'u1',
    phone: '+998901234567',
    role: UserRole.trainer,
    name: 'Jamshid',
    lang: Lang.uz,
    plan: Plan.free,
    tgConnected: true,
    createdAt: DateTime(2026),
    monthlyGoal: goal,
  );

  DashboardStudent stu(String id, String name, {int? overdue}) =>
      DashboardStudent(
        id: id,
        name: name,
        tariffPrice: 550000,
        paymentState: overdue == null
            ? PaymentState.dueToday
            : PaymentState.overdue,
        nextDueDate: DateTime(2026, 7, 21),
        daysOverdue: overdue,
      );

  DashboardResponse mkDash() => DashboardResponse(
    date: DateTime(2026, 7, 21),
    greetingName: 'Jamshid',
    dueToday: <DashboardStudent>[stu('s1', 'Ali Valiev')],
    dueSoon: const <DashboardStudent>[],
    overdue: <DashboardStudent>[stu('s2', 'Aziz Karimov', overdue: 3)],
    attendanceToday: const AttendanceToday(markedCount: 0),
    collectedThisMonth: 6800000,
    expectedThisMonth: 8300000,
  );

  group('MoneyText — G1 pul komponenti', () {
    testWidgets('vergulsiz raqam + kichik soft "so\'m" suffiks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapScreen(
          const Center(child: MoneyText(550000, style: AppText.money24)),
        ),
      );

      // Raqam probel bilan, vergulsiz.
      expect(find.textContaining('550'), findsWidgets);
      // "so'm" alohida span sifatida chiqadi (kichik).
      final Finder rich = find.byType(RichText);
      expect(rich, findsWidgets);
      // Butun matnda vergul YO'Q.
      final Text mt = tester.widget<Text>(
        find.descendant(
          of: find.byType(MoneyText),
          matching: find.byType(Text),
        ),
      );
      final String plain = mt.textSpan!.toPlainText();
      expect(plain.contains(','), isFalse);
      expect(plain.contains("so'm"), isTrue);
    });
  });

  group('Dashboard — G2 zichlik', () {
    testWidgets('KPI money 18-24px, 1-4 bo\'limlar 393×852 da sig\'adi', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapScreen(
          const DashboardScreen(),
          dashboard: FakeDashboardRepository(response: mkDash()),
        ),
      );

      // Sessiyani maqsad bilan faollashtiramiz (hero ringi ko'rinsin).
      final Element el = tester.element(find.byType(DashboardScreen));
      final ProviderContainer c = ProviderScope.containerOf(el);
      c.read(sessionProvider.notifier).setMe(meGoal());
      await tester.pumpAndSettle();

      // Kontent joyida.
      expect(find.textContaining('Jamshid'), findsWidgets);
      expect(find.text('BUGUN'), findsOneWidget);
      expect(find.text('Ali Valiev'), findsWidgets);
      expect(find.text('Davomad'), findsOneWidget); // tezkor amal

      // Pul KPI o'lchami — hero daromadi money24 (24px), Display (>=40) EMAS.
      final Iterable<MoneyText> monies = tester.widgetList<MoneyText>(
        find.byType(MoneyText),
      );
      expect(monies, isNotEmpty);
      for (final MoneyText m in monies) {
        expect(
          m.style.fontSize,
          lessThanOrEqualTo(24),
          reason: 'KPI/hero puli 24px dan oshmasligi kerak (zichlik)',
        );
      }

      // "1-4 bo'limlar scroll'siz": tezkor amallar qatori (4-bo'lim) pastki
      // navigatsiya zonasidan (852 - ~90) yuqorida bo'lishi kerak.
      final Rect qa = tester.getRect(find.text('Davomad'));
      expect(
        qa.bottom,
        lessThan(762),
        reason:
            'Tezkor amallar 393×852 ko\'rinishida sig\'adi (bottom=${qa.bottom})',
      );
    });
  });
}
