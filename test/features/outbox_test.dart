import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/repositories.dart';
import 'package:ustoz_trainer/features/attendance/providers/outbox.dart';

import '../support/fakes.dart';

/// T8 DoD (davomad outbox mantig'i).
///
/// Bu test connectivity_plus platforma kanaliga tegmaydi — outbox'ning
/// SOF mantig'ini tekshiradi: navbatga qo'shish, muvaffaqiyatli flush,
/// xatoda saqlanish, idempotent qayta yuborish.
void main() {
  ProviderContainer harness({AttendanceRepository? attendance}) {
    final ProviderContainer container = ProviderContainer(
      overrides: testOverrides(attendance: attendance),
    );
    addTearDown(container.dispose);
    return container;
  }

  final AttendanceBulkRequest sample = AttendanceBulkRequest(
    date: DateTime(2026, 7, 20),
    studentIds: const <String>['a', 'b'],
  );

  test('enqueue — navbatga qo\'shadi va saqlaydi', () async {
    final ProviderContainer container = harness();
    final OutboxNotifier outbox = container.read(outboxProvider.notifier);

    await outbox.enqueue(
      OutboxEntry(date: sample.date, studentIds: sample.studentIds),
    );

    expect(container.read(outboxProvider), hasLength(1));
    expect(container.read(outboxProvider).first.studentIds, <String>['a', 'b']);
  });

  test('flush — muvaffaqiyatda navbat bo\'shaydi', () async {
    final FakeAttendanceRepository repo = FakeAttendanceRepository();
    final ProviderContainer container = harness(attendance: repo);
    final OutboxNotifier outbox = container.read(outboxProvider.notifier);

    await outbox.enqueue(
      OutboxEntry(date: sample.date, studentIds: sample.studentIds),
    );
    await outbox.flush();

    expect(container.read(outboxProvider), isEmpty);
    expect(repo.requests, hasLength(1));
    expect(repo.requests.first.studentIds, <String>['a', 'b']);
  });

  test(
    'flush — TARMOQ xatosida navbat SAQLANADI (keyin qayta urinadi)',
    () async {
      final FakeAttendanceRepository repo = FakeAttendanceRepository(
        onMark: (AttendanceBulkRequest _) =>
            Future<AttendanceBulkResponse>.error(const NetworkException()),
      );
      final ProviderContainer container = harness(attendance: repo);
      final OutboxNotifier outbox = container.read(outboxProvider.notifier);

      await outbox.enqueue(
        OutboxEntry(date: sample.date, studentIds: sample.studentIds),
      );
      await outbox.flush();

      // Tarmoq yo'q — belgi yo'qolmaydi.
      expect(container.read(outboxProvider), hasLength(1));
    },
  );

  test('flush — server RAD ETSA (422) navbatdan olib tashlanadi', () async {
    // Masalan shogird arxivlangan — qayta yuborish foydasiz.
    final FakeAttendanceRepository repo = FakeAttendanceRepository(
      onMark: (AttendanceBulkRequest _) => Future<AttendanceBulkResponse>.error(
        const ValidationException('Xato'),
      ),
    );
    final ProviderContainer container = harness(attendance: repo);
    final OutboxNotifier outbox = container.read(outboxProvider.notifier);

    await outbox.enqueue(
      OutboxEntry(date: sample.date, studentIds: sample.studentIds),
    );
    await outbox.flush();

    expect(
      container.read(outboxProvider),
      isEmpty,
      reason: 'server rad etgan belgini cheksiz qayta yuborish noto\'g\'ri',
    );
  });

  test('OutboxEntry JSON round-trip', () {
    final OutboxEntry entry = OutboxEntry(
      date: DateTime(2026, 7, 20),
      studentIds: const <String>['x', 'y', 'z'],
    );
    final OutboxEntry restored = OutboxEntry.fromJson(entry.toJson());

    expect(restored.studentIds, <String>['x', 'y', 'z']);
    expect(restored.date, DateTime(2026, 7, 20));
    // Sana TZ'siz `YYYY-MM-DD` bo'lib saqlanadi.
    expect(entry.toJson()['date'], '2026-07-20');
  });
}
