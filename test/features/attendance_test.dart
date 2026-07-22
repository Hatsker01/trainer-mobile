import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/features/attendance/ui/attendance_sheet.dart';

import '../support/fakes.dart';

/// H2 — davomad oqimi: sheet OCHILADI (showAttendanceSheet wiring) →
/// shogird tanlanadi → bulk yuboriladi → repo to'g'ri so'rov bilan chaqiriladi.
void main() {
  testWidgets('davomad: sheet ochiladi → tanlash → Saqlash → markBulk', (
    WidgetTester tester,
  ) async {
    final FakeAttendanceRepository att = FakeAttendanceRepository();
    await tester.pumpWidget(
      wrapScreen(
        Builder(
          builder: (BuildContext ctx) => Center(
            child: TextButton(
              onPressed: () => showAttendanceSheet(ctx),
              child: const Text('OPEN'),
            ),
          ),
        ),
        students: FakeStudentRepository(
          items: <Student>[student(id: 's1', name: 'Aziz Karimov')],
        ),
        attendance: att,
      ),
    );

    // Sheetni ochamiz (dashboard "Davomad" tugmasi shu funksiyani chaqiradi).
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    expect(find.text('Aziz Karimov'), findsOneWidget);
    expect(find.textContaining('(0)'), findsOneWidget);

    // Belgilaymiz.
    await tester.tap(find.text('Aziz Karimov'));
    await tester.pumpAndSettle();
    expect(find.textContaining('(1)'), findsOneWidget);

    // Saqlaymiz → bulk so'rov.
    await tester.tap(find.textContaining('Saqlash'));
    await tester.pumpAndSettle();

    expect(att.requests, isNotEmpty);
    expect(att.requests.first.studentIds, contains('s1'));

    // AppToast avtomatik yopilishini kutamiz (osilib qolgan Timer'ni tozalash).
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
