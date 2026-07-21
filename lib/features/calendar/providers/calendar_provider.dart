import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/providers.dart';

/// Kun/shogird to'lov holati (G3). Kun rangi shu holatlardan chiqadi.
enum CalStatus { paid, partial, unpaid, planned, none }

CalStatus _statusFrom(String? raw) => switch (raw) {
  'paid' => CalStatus.paid,
  'partial' => CalStatus.partial,
  'unpaid' => CalStatus.unpaid,
  'planned' => CalStatus.planned,
  _ => CalStatus.none,
};

/// Kun ichidagi bitta shogird yozuvi (kun sheetida ko'rsatiladi).
class CalEntry {
  const CalEntry({
    required this.studentId,
    required this.name,
    required this.expected,
    required this.paid,
    required this.status,
  });

  final String studentId;
  final String name;

  /// Tarif narxi (kutilgan summa).
  final int expected;

  /// Shu davr uchun to'langan summa.
  final int paid;
  final CalStatus status;

  /// Qoldiq — kun sheetidagi "To'lov qo'shish" shu summa bilan prefill bo'ladi.
  int get remainder => (expected - paid).clamp(0, expected);
}

/// Bir kun: kun-darajali holat + shogird yozuvlari + sonlar.
class CalDay {
  const CalDay({
    this.status = CalStatus.none,
    this.entries = const <CalEntry>[],
    this.paidCount = 0,
    this.partialCount = 0,
    this.plannedCount = 0,
    this.unpaidCount = 0,
  });

  final CalStatus status;
  final List<CalEntry> entries;
  final int paidCount;
  final int partialCount;
  final int plannedCount;
  final int unpaidCount;

  bool get isEmpty => entries.isEmpty;
}

/// Oy aggregati: kun (1..31) → CalDay + oy xulosasi.
class CalMonth {
  const CalMonth({
    this.days = const <int, CalDay>{},
    this.paid = 0,
    this.partial = 0,
    this.planned = 0,
    this.unpaid = 0,
  });

  final Map<int, CalDay> days;
  final int paid;
  final int partial;
  final int planned;
  final int unpaid;
}

/// `GET /calendar?month=YYYY-MM` (G3). Endpoint yo'q/xato bo'lsa — bo'sh oy
/// (kalendar baribir chiziladi, nuqtasiz).
final FutureProvider<CalMonth> Function(String) calendarMonthProvider =
    FutureProvider.family<CalMonth, String>((Ref ref, String month) async {
      final Dio dio = ref.watch(dioProvider);
      try {
        final Response<dynamic> r = await dio.get<dynamic>(
          '/calendar',
          queryParameters: <String, dynamic>{'month': month},
        );
        final Object? data = r.data;
        if (data is! Map) {
          return const CalMonth();
        }
        final List<dynamic> days =
            (data['days'] as List<dynamic>?) ?? const <dynamic>[];
        final Map<int, CalDay> out = <int, CalDay>{};
        for (final dynamic d in days) {
          if (d is! Map) {
            continue;
          }
          final String? dateStr = d['date'] as String?;
          if (dateStr == null) {
            continue;
          }
          final DateTime date = DateTime.parse(dateStr);
          final List<CalEntry> entries = <CalEntry>[
            for (final dynamic e
                in (d['entries'] as List<dynamic>?) ?? const <dynamic>[])
              if (e is Map)
                CalEntry(
                  studentId: (e['student_id'] as String?) ?? '',
                  name: (e['name'] as String?) ?? '',
                  expected: (e['expected'] as num?)?.toInt() ?? 0,
                  paid: (e['paid'] as num?)?.toInt() ?? 0,
                  status: _statusFrom(e['status'] as String?),
                ),
          ];
          out[date.day] = CalDay(
            status: _statusFrom(d['status'] as String?),
            entries: entries,
            paidCount: (d['paid_count'] as num?)?.toInt() ?? 0,
            partialCount: (d['partial_count'] as num?)?.toInt() ?? 0,
            plannedCount: (d['planned_count'] as num?)?.toInt() ?? 0,
            unpaidCount: (d['unpaid_count'] as num?)?.toInt() ?? 0,
          );
        }
        final Map<String, dynamic> sum =
            (data['summary'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        return CalMonth(
          days: out,
          paid: (sum['paid'] as num?)?.toInt() ?? 0,
          partial: (sum['partial'] as num?)?.toInt() ?? 0,
          planned: (sum['planned'] as num?)?.toInt() ?? 0,
          unpaid: (sum['unpaid'] as num?)?.toInt() ?? 0,
        );
      } on Object {
        return const CalMonth();
      }
    });
