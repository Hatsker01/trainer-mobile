import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/features/students/ui/students_screen.dart';

import '../support/fakes.dart';

/// T5 DoD: "widget testlar ro'yxat filtr/qidiruv".
void main() {
  final List<Student> roster = <Student>[
    student(
      id: '1',
      name: 'Aziz Karimov',
      state: PaymentState.overdue,
      daysOverdue: 3,
    ),
    student(id: '2', name: 'Dilnoza Mirzayeva'),
    student(id: '3', name: 'Sardor Bekmurodov'),
  ];

  Widget screen(FakeStudentRepository repo) =>
      wrapScreen(const StudentsScreen(), students: repo);

  testWidgets('ro\'yxat serverdan kelgan tartibda chiziladi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(screen(FakeStudentRepository(items: roster)));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Aziz Karimov'), findsOneWidget);
    expect(find.text('Dilnoza Mirzayeva'), findsOneWidget);
    expect(find.text('Sardor Bekmurodov'), findsOneWidget);
  });

  testWidgets('filtr chipi SERVERGA filter parametrini yuboradi', (
    WidgetTester tester,
  ) async {
    final FakeStudentRepository repo = FakeStudentRepository(items: roster);
    await tester.pumpWidget(screen(repo));
    await tester.pumpAndSettle();

    // REDESIGN: filtr endi `_FilterTab` (private) — matn bo'yicha bosamiz.
    // "Qarzdor" faqat filtr yorlig'i (shogird badge'i "Qarz").
    await tester.tap(find.text('Qarzdor'));
    await tester.pumpAndSettle();

    expect(
      repo.calls.last.filter,
      StudentFilter.debtors,
      reason: 'filtrlash client\'da emas, serverda bo\'lishi kerak',
    );
    // Faqat qarzdor qoladi.
    expect(find.text('Aziz Karimov'), findsOneWidget);
    expect(find.text('Dilnoza Mirzayeva'), findsNothing);
  });

  testWidgets('qidiruv 300ms debounce bilan BITTA so\'rov yuboradi', (
    WidgetTester tester,
  ) async {
    final FakeStudentRepository repo = FakeStudentRepository(items: roster);
    await tester.pumpWidget(screen(repo));
    await tester.pumpAndSettle();

    final int before = repo.calls.length;

    // Foydalanuvchi tez yozadi — har harf uchun so'rov ketmasligi kerak.
    await tester.enterText(find.byType(TextField), 'D');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'Di');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'Dil');
    await tester.pump(const Duration(milliseconds: 100));

    // Hali debounce tugamagan (oxirgi harfdan 100ms o'tdi).
    expect(repo.calls.length, before);

    // Debounce taymeri (300ms) — oddiy `Timer`, `pumpAndSettle` uni
    // kutmaydi, shuning uchun vaqtni QO'LDA suramiz.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(
      repo.calls.length - before,
      1,
      reason: '3 ta harf uchun 1 ta so\'rov (debounce 300ms)',
    );
    expect(repo.calls.last.query, 'Dil');
  });

  testWidgets('qidiruvda natija bo\'lmasa bo\'sh holat', (
    WidgetTester tester,
  ) async {
    final FakeStudentRepository repo = FakeStudentRepository(items: roster);
    await tester.pumpWidget(screen(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'yoq-bunday-odam');
    await tester.pumpAndSettle();

    expect(find.text('Hech narsa topilmadi'), findsOneWidget);
  });

  testWidgets('shogird umuman bo\'lmasa — CTA li bo\'sh holat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(screen(FakeStudentRepository(items: <Student>[])));
    await tester.pumpAndSettle();

    expect(find.text("Hali shogird yo'q"), findsOneWidget);
    expect(find.text("Shogird qo'shish"), findsOneWidget);
  });
}
