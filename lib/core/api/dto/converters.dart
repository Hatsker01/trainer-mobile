import 'package:json_annotation/json_annotation.dart';

/// `format: date` (`YYYY-MM-DD`, TZ'siz) ↔ `DateTime`.
///
/// CLAUDE.md: `paid_at`, `next_due_date`, `attendance.date` — `DATE` tipi.
/// Bularni `DateTime.parse` bilan o'qish xavfsiz (vaqt 00:00 lokal bo'ladi),
/// lekin **serializatsiyada `toIso8601String()` ISHLATIB BO'LMAYDI** —
/// u `2026-07-20T00:00:00.000` beradi, server esa `2026-07-20` kutadi.
class DateOnlyConverter implements JsonConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime date) => formatDate(date);

  /// `DateTime` → `YYYY-MM-DD`. Vaqt zonasi qo'shilmaydi.
  static String formatDate(DateTime d) {
    final String m = d.month.toString().padLeft(2, '0');
    final String day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}

/// Nullable variant — `next_due_date` (paket/single tariflarda `null`).
class DateOnlyNullableConverter implements JsonConverter<DateTime?, String?> {
  const DateOnlyNullableConverter();

  @override
  DateTime? fromJson(String? json) =>
      json == null ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? date) =>
      date == null ? null : DateOnlyConverter.formatDate(date);
}

/// `format: date-time` (RFC3339 UTC) ↔ `DateTime`.
///
/// Server UTC yuboradi; lokalga o'tkazamiz, chunki biznes-logika
/// `Asia/Tashkent` da ko'rsatiladi.
class UtcDateTimeConverter implements JsonConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toLocal();

  @override
  String toJson(DateTime date) => date.toUtc().toIso8601String();
}

/// Nullable `date-time` (`sent_at`, `last_active_at`).
class UtcDateTimeNullableConverter
    implements JsonConverter<DateTime?, String?> {
  const UtcDateTimeNullableConverter();

  @override
  DateTime? fromJson(String? json) =>
      json == null ? null : DateTime.parse(json).toLocal();

  @override
  String? toJson(DateTime? date) => date?.toUtc().toIso8601String();
}
