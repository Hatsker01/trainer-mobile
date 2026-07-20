import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/features/auth/ui/otp_screen.dart';
import 'package:ustoz_trainer/features/auth/ui/phone_field.dart';
import 'package:ustoz_trainer/features/auth/ui/phone_screen.dart';

import '../support/fakes.dart';

/// T3 DoD: "widget test: telefon validatsiya, OTP flow (mock repo)".
void main() {
  group('Telefon niqobi', () {
    test('faqat raqam, 9 xona, 2-3-2-2 guruhlash', () {
      expect(PhoneInputFormatter.format('901234567'), '90 123 45 67');
      expect(PhoneInputFormatter.format('90'), '90');
      expect(PhoneInputFormatter.format('901'), '90 1');
    });

    test('kontrakt formatiga keltiradi', () {
      expect(PhoneField.toE164('90 123 45 67'), '+998901234567');
      // 13 belgi — kontrakt talabi.
      expect(PhoneField.toE164('90 123 45 67').length, 13);
    });

    test('to\'liqlik tekshiruvi', () {
      expect(PhoneField.isComplete('90 123 45 67'), isTrue);
      expect(PhoneField.isComplete('90 123 45'), isFalse);
      expect(PhoneField.isComplete(''), isFalse);
    });
  });

  group('Telefon ekrani', () {
    testWidgets('raqam to\'liq bo\'lmaguncha tugma o\'chiq', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      await tester.pumpWidget(wrapScreen(const PhoneScreen(), auth: auth));
      await tester.pumpAndSettle();

      // Chala raqam.
      await tester.enterText(find.byType(TextField), '9012345');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GradientButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(auth.requestedPhones, isEmpty);
    });

    testWidgets('to\'liq raqamda OTP so\'raladi (E.164 formatda)', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository auth = FakeAuthRepository();
      // Muvaffaqiyatda `context.push('/otp')` — router kerak.
      await tester.pumpWidget(
        wrapRouted(
          const PhoneScreen(),
          auth: auth,
          pushTargets: const <String>['/otp'],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '901234567');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GradientButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(auth.requestedPhones, <String>['+998901234567']);
    });
  });

  group('OTP ekrani', () {
    testWidgets('6 raqam kiritilganda AVTOMATIK tasdiqlanadi', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository auth = FakeAuthRepository();

      await tester.pumpWidget(wrapScreen(const OtpScreen(), auth: auth));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();

      expect(auth.verifiedCodes, <String>['123456']);
    });

    testWidgets('5 raqamda hali yuborilmaydi', (WidgetTester tester) async {
      final FakeAuthRepository auth = FakeAuthRepository();

      await tester.pumpWidget(wrapScreen(const OtpScreen(), auth: auth));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '12345');
      await tester.pumpAndSettle();

      expect(auth.verifiedCodes, isEmpty);
    });

    testWidgets('noto\'g\'ri kodda kataklar tozalanadi', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository auth = FakeAuthRepository(
        onVerify: (String _, String _) => Future<TokenPair>.error(
          const UnauthorizedException("Kod noto'g'ri"),
        ),
      );

      await tester.pumpWidget(wrapScreen(const OtpScreen(), auth: auth));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '000000');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final TextField field = tester.widget<TextField>(
        find.byType(TextField).first,
      );
      expect(
        field.controller?.text,
        isEmpty,
        reason: 'xato kodda kataklar tozalanib, qayta kiritish taklif etiladi',
      );

      // Xato toast'i 2600ms taymer qo'yadi — bo'shatamiz.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('qayta yuborish taymeri ishlaydi', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapScreen(const OtpScreen(), auth: FakeAuthRepository()),
      );
      await tester.pump();

      // Taymer ketayotganda "qayta yuborish" tugmasi YO'Q.
      expect(
        find.widgetWithText(GhostButton, 'Kodni qayta yuborish'),
        findsNothing,
      );

      // 60s dan keyin paydo bo'ladi.
      await tester.pump(const Duration(seconds: 61));
      await tester.pump();

      expect(
        find.widgetWithText(GhostButton, 'Kodni qayta yuborish'),
        findsOneWidget,
      );
    });
  });
}
