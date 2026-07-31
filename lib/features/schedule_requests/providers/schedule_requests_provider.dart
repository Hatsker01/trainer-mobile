import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/providers.dart';

/// «Kelolmayman» so'rovi (D122) — shogird jadval o'zgarishini so'ragan.
class ScheduleRequest {
  const ScheduleRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.status,
    this.reason,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String date;
  final String status;
  final String? reason;

  factory ScheduleRequest.fromJson(Map<String, dynamic> j) => ScheduleRequest(
    id: (j['id'] ?? '').toString(),
    studentId: (j['student_id'] ?? '').toString(),
    studentName: (j['student_name'] ?? '').toString(),
    date: (j['date'] ?? '').toString(),
    status: (j['status'] ?? 'pending').toString(),
    reason: j['reason'] as String?,
  );
}

/// Repo — dioProvider ustida (recommendations pattern).
class ScheduleRequestsRepo {
  ScheduleRequestsRepo(this._dio);
  final Dio _dio;

  Future<List<ScheduleRequest>> pending() async {
    final Response<dynamic> r =
        await _dio.get<dynamic>('/schedule-requests');
    final data = r.data;
    if (data is! List) return const <ScheduleRequest>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ScheduleRequest.fromJson)
        .toList();
  }

  /// action: approve | reject | reschedule ('reschedule' uchun proposedTime).
  Future<void> respond(
    String id,
    String action, {
    String? note,
    String? proposedTime,
  }) async {
    await _dio.post<dynamic>(
      '/schedule-requests/$id/respond',
      data: <String, dynamic>{
        'action': action,
        if (note != null && note.isNotEmpty) 'note': note,
        if (proposedTime != null && proposedTime.isNotEmpty)
          'proposed_time': proposedTime,
      },
    );
  }
}

final Provider<ScheduleRequestsRepo> scheduleRequestsRepoProvider =
    Provider<ScheduleRequestsRepo>(
  (Ref ref) => ScheduleRequestsRepo(ref.watch(dioProvider)),
);

/// Kutilayotgan so'rovlar — dashboard kartasi. Pull-to-refresh + SSE'siz
/// hozircha qo'lda invalidate (trener ekrani ochilганда yangilanadi).
final FutureProvider<List<ScheduleRequest>> pendingScheduleRequestsProvider =
    FutureProvider<List<ScheduleRequest>>(
  (Ref ref) => ref.watch(scheduleRequestsRepoProvider).pending(),
);
