import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/providers.dart';

/// Trenerga qaratilgan bildirishnoma (to'lov muddati ogohlantirishlari).
class NotifItem {
  const NotifItem({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.daysOverdue,
    this.avatarUrl,
    this.unread = true,
    this.createdAt,
  });

  factory NotifItem.fromJson(Map<String, dynamic> j) => NotifItem(
    id: (j['id'] ?? '').toString(),
    studentId: (j['student_id'] ?? '').toString(),
    studentName: (j['student_name'] ?? '') as String,
    amount: (j['amount'] as num?)?.toInt() ?? 0,
    // 0 = bugun, >0 = kun oldin o'tgan.
    daysOverdue: (j['days_overdue'] as num?)?.toInt() ?? 0,
    avatarUrl: j['avatar_url'] as String?,
    unread: (j['unread'] as bool?) ?? true,
    createdAt: j['created_at'] == null
        ? null
        : DateTime.tryParse(j['created_at'] as String),
  );

  final String id;
  final String studentId;
  final String studentName;
  final int amount;
  final int daysOverdue;
  final String? avatarUrl;
  final bool unread;
  final DateTime? createdAt;
}

/// `GET /notifications`. Backend bermasa — bo'sh ro'yxat (empty state).
final FutureProvider<List<NotifItem>> notificationsProvider =
    FutureProvider<List<NotifItem>>((Ref ref) async {
      final Dio dio = ref.watch(dioProvider);
      try {
        final Response<dynamic> r = await dio.get<dynamic>('/notifications');
        final Object? data = r.data;
        final List<dynamic> items = data is Map
            ? (data['items'] as List<dynamic>? ?? const <dynamic>[])
            : (data is List ? data : const <dynamic>[]);
        return items
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (Map<dynamic, dynamic> e) =>
                  NotifItem.fromJson(e.cast<String, dynamic>()),
            )
            .toList();
      } on Object {
        return const <NotifItem>[];
      }
    });
