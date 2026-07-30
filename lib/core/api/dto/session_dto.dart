import 'package:json_annotation/json_annotation.dart';
import 'package:ustoz_trainer/core/api/dto/converters.dart';

part 'session_dto.g.dart';

/// Mashg'ulot sloti (`GET /sessions`) — dashboard "Bugungi lenta" va Jadval.
@JsonSerializable(createToJson: false)
class SessionDto {
  const SessionDto({
    required this.id,
    required this.startsAt,
    required this.durationMin,
    required this.kind,
    required this.status,
    required this.conflict,
    this.studentId,
    this.studentName,
    this.title,
  });

  factory SessionDto.fromJson(Map<String, dynamic> json) =>
      _$SessionDtoFromJson(json);

  final String id;

  @JsonKey(name: 'student_id')
  final String? studentId;

  @JsonKey(name: 'student_name')
  final String? studentName;

  /// Guruh mashg'uloti nomi (student_id null bo'lganda).
  final String? title;

  @UtcDateTimeConverter()
  @JsonKey(name: 'starts_at')
  final DateTime startsAt;

  @JsonKey(name: 'duration_min')
  final int durationMin;

  /// `individual` | `group`.
  final String kind;

  /// `scheduled` | `done` | `cancelled`.
  final String status;

  /// Vaqti boshqa slot bilan kesishadi.
  final bool conflict;

  /// Ko'rsatiladigan nom — shogird yoki guruh nomi.
  String get displayName => studentName ?? title ?? '—';
}
