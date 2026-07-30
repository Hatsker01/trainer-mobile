// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionDto _$SessionDtoFromJson(Map<String, dynamic> json) => SessionDto(
  id: json['id'] as String,
  startsAt: const UtcDateTimeConverter().fromJson(json['starts_at'] as String),
  durationMin: (json['duration_min'] as num).toInt(),
  kind: json['kind'] as String,
  status: json['status'] as String,
  conflict: json['conflict'] as bool,
  studentId: json['student_id'] as String?,
  studentName: json['student_name'] as String?,
  title: json['title'] as String?,
);
