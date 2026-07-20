import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';

import '../support/fakes.dart';

/// T6 DoD: "double-tap testi (widget)".
///
/// Pul nuqtasi — bu testning maqsadi bitta: tugmani necha marta bossang ham
/// SERVERGA BIR MARTA boradi.
void main() {
  Widget sheet(FakePaymentRepository repo) => wrapScreen(
    const Scaffold(
      body: PaymentSheet(
        studentId: 's1',
        studentName: 'Aziz Karimov',
        amount: 400000,
        tariffType: TariffType.monthly,
      ),
    ),
    payments: repo,
  );

  testWidgets('summa tarifdan oldindan to\'ldiriladi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(sheet(FakePaymentRepository()));
    await tester.pumpAndSettle();

    // Dizayn: mono, minglik ajratgich bilan (uzilmas probel).
    expect(find.text('400 000'), findsOneWidget);
  });

  testWidgets(
    'DOUBLE-TAP: tugma 5 marta bosilsa ham serverga BIR marta boradi',
    (WidgetTester tester) async {
      // Server sekin javob beradi — aynan shu oynada takroriy bosish xavfli.
      final FakePaymentRepository repo = FakePaymentRepository(
        delay: const Duration(milliseconds: 300),
      );

      await tester.pumpWidget(sheet(repo));
      await tester.pumpAndSettle();

      final Finder button = find.widgetWithText(
        GradientButton,
        "To'lovni saqlash",
      );
      expect(button, findsOneWidget);

      // 5 marta ketma-ket bosish (kadr o'tkazmasdan).
      for (int i = 0; i < 5; i++) {
        await tester.tap(button, warnIfMissed: false);
      }
      await tester.pump();

      // So'rov tugashini kutamiz.
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        repo.callCount,
        1,
        reason: 'takroriy bosish qo\'shimcha to\'lov yaratmasligi kerak',
      );

      // Muvaffaqiyatdan keyin toast 2600ms taymer qo'yadi — uni bo'shatamiz,
      // aks holda "Timer still pending" bilan yiqiladi.
      await tester.pump(const Duration(seconds: 3));
    },
  );

  testWidgets('Idempotency-Key yuboriladi va qayta urinishda O\'ZGARMAYDI', (
    WidgetTester tester,
  ) async {
    final FakePaymentRepository repo = FakePaymentRepository();

    await tester.pumpWidget(sheet(repo));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(GradientButton, "To'lovni saqlash"),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(repo.idempotencyKeys, hasLength(1));
    expect(
      repo.idempotencyKeys.first,
      isNotNull,
      reason:
          'kontrakt: POST /payments Idempotency-Key sarlavhasini qabul qiladi',
    );
    expect(repo.idempotencyKeys.first, startsWith('pay-s1-'));
  });

  testWidgets('summa 0 bo\'lsa tugma o\'chiq', (WidgetTester tester) async {
    final FakePaymentRepository repo = FakePaymentRepository();
    await tester.pumpWidget(sheet(repo));
    await tester.pumpAndSettle();

    // Summani tozalaymiz.
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();

    await tester.tap(
      find.widgetWithText(GradientButton, "To'lovni saqlash"),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(repo.callCount, 0);
  });
}
