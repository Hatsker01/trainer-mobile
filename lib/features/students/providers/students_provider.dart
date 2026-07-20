import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/payment_dto.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/storage/local_store.dart';

/// Ro'yxat holati.
class StudentsState {
  const StudentsState({
    this.items = const <Student>[],
    this.filter = StudentFilter.all,
    this.query = '',
    this.page = 1,
    this.total = 0,
    this.loadingMore = false,
    this.stale = false,
  });

  final List<Student> items;
  final StudentFilter filter;
  final String query;
  final int page;
  final int total;
  final bool loadingMore;

  /// Keshdan ko'rsatilmoqda (T8).
  final bool stale;

  bool get hasMore => items.length < total;

  StudentsState copyWith({
    List<Student>? items,
    StudentFilter? filter,
    String? query,
    int? page,
    int? total,
    bool? loadingMore,
    bool? stale,
  }) => StudentsState(
    items: items ?? this.items,
    filter: filter ?? this.filter,
    query: query ?? this.query,
    page: page ?? this.page,
    total: total ?? this.total,
    loadingMore: loadingMore ?? this.loadingMore,
    stale: stale ?? this.stale,
  );
}

final AsyncNotifierProvider<StudentsNotifier, StudentsState> studentsProvider =
    AsyncNotifierProvider<StudentsNotifier, StudentsState>(
      StudentsNotifier.new,
    );

class StudentsNotifier extends AsyncNotifier<StudentsState> {
  static const String _cacheKey = 'cache_students';
  static const int _pageSize = 20;

  Timer? _debounce;

  LocalStore get _store => ref.read(localStoreProvider);

  @override
  Future<StudentsState> build() async {
    ref.onDispose(() => _debounce?.cancel());

    // T8 SWR — avval kesh (faqat filtrsiz/qidiruvsiz asosiy ro'yxat).
    final Map<String, dynamic>? cached = await _store.readJson(_cacheKey);
    if (cached != null) {
      try {
        final PagedStudents paged = PagedStudents.fromJson(cached);
        final StudentsState stale = StudentsState(
          items: paged.items,
          total: paged.total,
          stale: true,
        );
        state = AsyncData<StudentsState>(stale);
        unawaited(_load(silent: true));
        return stale;
      } on Object {
        await _store.delete(_cacheKey);
      }
    }

    return _load();
  }

  Future<StudentsState> _load({
    StudentFilter? filter,
    String? query,
    bool silent = false,
  }) async {
    final StudentsState current = state.value ?? const StudentsState();
    final StudentFilter f = filter ?? current.filter;
    final String q = query ?? current.query;

    final PagedStudents paged = await ref
        .read(studentRepositoryProvider)
        .list(filter: f, query: q, limit: _pageSize);

    // Kesh — faqat "toza" ro'yxat (filtr/qidiruvsiz), aks holda keshda
    // filtrlangan natija qolib, keyingi ochilishda chalg'itadi.
    if (f == StudentFilter.all && q.isEmpty) {
      unawaited(_store.writeJson(_cacheKey, paged.toJson()));
    }

    final StudentsState next = StudentsState(
      items: paged.items,
      filter: f,
      query: q,
      total: paged.total,
    );

    if (silent) {
      state = AsyncData<StudentsState>(next);
    }
    return next;
  }

  /// Filtr chipi bosildi.
  Future<void> setFilter(StudentFilter filter) async {
    state = await AsyncValue.guard(() => _load(filter: filter));
  }

  /// Qidiruv — 300ms debounce (server-side qidiruv).
  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      state = await AsyncValue.guard(() => _load(query: query));
    });
  }

  /// Cheksiz scroll — keyingi sahifa.
  ///
  /// **Server tartibini buzmaydi** (qarzdorlar tepada) — yangi sahifa
  /// oxiriga qo'shiladi, qayta saralanmaydi.
  Future<void> loadMore() async {
    final StudentsState? current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) {
      return;
    }

    state = AsyncData<StudentsState>(current.copyWith(loadingMore: true));

    try {
      final PagedStudents paged = await ref
          .read(studentRepositoryProvider)
          .list(
            filter: current.filter,
            query: current.query,
            page: current.page + 1,
            limit: _pageSize,
          );

      state = AsyncData<StudentsState>(
        current.copyWith(
          items: <Student>[...current.items, ...paged.items],
          page: current.page + 1,
          total: paged.total,
          loadingMore: false,
        ),
      );
    } on AppException {
      state = AsyncData<StudentsState>(current.copyWith(loadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }
}

/// Bitta shogird profili (S6).
///
/// Riverpod 3 da family notifier `FamilyAsyncNotifier` EMAS — oddiy
/// `AsyncNotifier`, argument esa konstruktor orqali keladi.
final AsyncNotifierProvider<StudentNotifier, Student> Function(String)
studentProvider =
    AsyncNotifierProvider.family<StudentNotifier, Student, String>(
      StudentNotifier.new,
    );

class StudentNotifier extends AsyncNotifier<Student> {
  StudentNotifier(this.id);

  final String id;

  @override
  Future<Student> build() => ref.read(studentRepositoryProvider).get(id);

  /// To'lov saqlangandan keyin — javobdagi shogird bilan almashtirish
  /// (qo'shimcha so'rovsiz).
  void setValue(Student student) => state = AsyncData<Student>(student);

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(studentRepositoryProvider).get(id),
    );
  }

  Future<void> archive() async {
    final Student updated = await ref
        .read(studentRepositoryProvider)
        .archive(id);
    state = AsyncData<Student>(updated);
    ref.invalidate(studentsProvider);
  }
}

/// Tarif shablonlari (forma dropdown'i va sozlamalar uchun).
final AsyncNotifierProvider<TariffsNotifier, List<TariffTemplate>>
tariffsProvider = AsyncNotifierProvider<TariffsNotifier, List<TariffTemplate>>(
  TariffsNotifier.new,
);

class TariffsNotifier extends AsyncNotifier<List<TariffTemplate>> {
  @override
  Future<List<TariffTemplate>> build() =>
      ref.read(tariffRepositoryProvider).list();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(tariffRepositoryProvider).list(),
    );
  }

  Future<TariffTemplate> create(TariffCreate body) async {
    final TariffTemplate created = await ref
        .read(tariffRepositoryProvider)
        .create(body);
    await refresh();
    return created;
  }

  Future<void> edit(String id, TariffUpdate body) async {
    await ref.read(tariffRepositoryProvider).update(id, body);
    await refresh();
  }
}
