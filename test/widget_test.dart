import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/main.dart';

void main() {
  testWidgets('ilova ishga tushadi va splash ekranini ko\'rsatadi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UstozApp());
    await tester.pumpAndSettle();

    expect(find.text('USTOZ'), findsOneWidget);
  });
}
