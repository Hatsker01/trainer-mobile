import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/providers.dart';

/// Inbound bog'lanish so'rovi (D122 sync) — shogird kod kiritib trenerni
/// tanladi; trener tasdiqlaydi yoki rad etadi.
class LinkRequest {
  const LinkRequest({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
  });

  final String id;
  final String name;
  final String phone;
  final String status;

  /// Log qoidasi: telefon mask bilan (`+998 90 ***`).
  String get phoneMasked {
    final p = phone.replaceAll(' ', '');
    if (p.length < 7) return phone;
    return '${p.substring(0, 6)} ***';
  }

  factory LinkRequest.fromJson(Map<String, dynamic> j) => LinkRequest(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    phone: (j['phone'] ?? '').toString(),
    status: (j['status'] ?? 'pending').toString(),
  );
}

class LinkRequestsRepo {
  LinkRequestsRepo(this._dio);
  final Dio _dio;

  Future<List<LinkRequest>> pending() async {
    final Response<dynamic> r =
        await _dio.get<dynamic>('/trainer/link-requests');
    final data = r.data;
    final List<dynamic> items = data is Map<String, dynamic>
        ? (data['items'] as List<dynamic>? ?? const <dynamic>[])
        : const <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(LinkRequest.fromJson)
        .where((LinkRequest x) => x.status == 'pending')
        .toList();
  }

  Future<void> approve(String id) async {
    await _dio.post<dynamic>('/trainer/link-requests/$id/approve');
  }

  Future<void> reject(String id, {String? note}) async {
    await _dio.post<dynamic>(
      '/trainer/link-requests/$id/reject',
      data: <String, dynamic>{if (note != null && note.isNotEmpty) 'note': note},
    );
  }
}

final Provider<LinkRequestsRepo> linkRequestsRepoProvider =
    Provider<LinkRequestsRepo>(
  (Ref ref) => LinkRequestsRepo(ref.watch(dioProvider)),
);

final FutureProvider<List<LinkRequest>> pendingLinkRequestsProvider =
    FutureProvider<List<LinkRequest>>(
  (Ref ref) => ref.watch(linkRequestsRepoProvider).pending(),
);
