import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/storage/local_store.dart';

/// Yuborilmagan davomad belgisi.
class OutboxEntry {
  const OutboxEntry({required this.date, required this.studentIds});

  factory OutboxEntry.fromJson(Map<String, dynamic> json) => OutboxEntry(
    date: DateTime.parse(json['date'] as String),
    studentIds: (json['student_ids'] as List<dynamic>).cast<String>(),
  );

  final DateTime date;
  final List<String> studentIds;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date':
        '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}',
    'student_ids': studentIds,
  };
}

/// Davomad outbox'i (T8).
///
/// **FAQAT davomad uchun.** To'lov offline qilinmaydi (D110) — pul
/// operatsiyasi faqat jonli.
///
/// Xavfsizlik: `POST /attendance/bulk` idempotent
/// (`UNIQUE(student_id, date)`), shuning uchun navbatni qayta yuborish
/// dublikat yaratmaydi — server `skipped` deb qaytaradi.
final NotifierProvider<OutboxNotifier, List<OutboxEntry>> outboxProvider =
    NotifierProvider<OutboxNotifier, List<OutboxEntry>>(OutboxNotifier.new);

class OutboxNotifier extends Notifier<List<OutboxEntry>> {
  static const String _key = 'outbox_attendance';

  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _flushing = false;

  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<OutboxEntry> build() {
    unawaited(_restore());

    // Tarmoq qaytganda avtomatik yuborish.
    _sub = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      final bool online = result.any(
        (ConnectivityResult r) => r != ConnectivityResult.none,
      );
      if (online) {
        unawaited(flush());
      }
    });
    ref.onDispose(() => _sub?.cancel());

    return const <OutboxEntry>[];
  }

  Future<void> _restore() async {
    final Map<String, dynamic>? saved = await _store.readJson(_key);
    final List<dynamic>? items = saved?['items'] as List<dynamic>?;
    if (items == null) {
      return;
    }
    try {
      state = items
          .map((dynamic e) => OutboxEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      unawaited(flush());
    } on Object {
      await _store.delete(_key);
    }
  }

  Future<void> _persist() => _store.writeJson(_key, <String, dynamic>{
    'items': state.map((OutboxEntry e) => e.toJson()).toList(),
  });

  /// Tarmoq yo'qda — navbatga qo'shish.
  Future<void> enqueue(OutboxEntry entry) async {
    state = <OutboxEntry>[...state, entry];
    await _persist();
  }

  /// Navbatni yuborishga urinish. Xato bo'lsa navbat SAQLANADI.
  Future<void> flush() async {
    if (_flushing || state.isEmpty) {
      return;
    }
    _flushing = true;

    try {
      final List<OutboxEntry> pending = <OutboxEntry>[...state];
      final List<OutboxEntry> failed = <OutboxEntry>[];

      for (final OutboxEntry entry in pending) {
        try {
          await ref
              .read(attendanceRepositoryProvider)
              .markBulk(
                AttendanceBulkRequest(
                  date: entry.date,
                  studentIds: entry.studentIds,
                ),
              );
        } on ValidationException {
          // Server ma'lumotni rad etdi (masalan shogird arxivlangan) —
          // qayta yuborish foydasiz, navbatdan olib tashlaymiz.
          continue;
        } on ForbiddenException {
          continue;
        } on NotFoundException {
          continue;
        } on AppException {
          // Tarmoq/server — keyinroq qayta urinamiz.
          failed.add(entry);
        }
      }

      state = failed;
      await _persist();
    } finally {
      _flushing = false;
    }
  }
}

/// Hozir tarmoq bormi?
final FutureProvider<bool> isOnlineProvider = FutureProvider<bool>((
  Ref ref,
) async {
  final List<ConnectivityResult> result = await Connectivity()
      .checkConnectivity();
  return result.any((ConnectivityResult r) => r != ConnectivityResult.none);
});
