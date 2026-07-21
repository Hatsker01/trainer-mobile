import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/providers.dart';

/// Tavsiyaga biriktirilgan mahsulot (ProductMini).
class RecProduct {
  const RecProduct({
    required this.id,
    required this.name,
    required this.price,
    this.merchantName,
    this.photo,
  });

  factory RecProduct.fromJson(Map<String, dynamic> j) => RecProduct(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? j['name_uz'] ?? '') as String,
    price: (j['price'] as num?)?.toInt() ?? 0,
    merchantName: (j['merchant_name'] ?? j['shop_name']) as String?,
    photo:
        (j['photo'] ??
                (j['photos'] is List && (j['photos'] as List).isNotEmpty
                    ? (j['photos'] as List).first
                    : null))
            as String?,
  );

  final String id;
  final String name;
  final int price;
  final String? merchantName;
  final String? photo;
}

/// Tavsiya — GET /students/{id}/recommendations dagi element.
class Recommendation {
  const Recommendation({
    required this.id,
    required this.category,
    required this.text,
    required this.isBroadcast,
    this.product,
    this.createdAt,
  });

  factory Recommendation.fromJson(Map<String, dynamic> j) => Recommendation(
    id: (j['id'] ?? '').toString(),
    category: (j['category'] ?? 'other') as String,
    text: (j['text'] ?? '') as String,
    isBroadcast: (j['is_broadcast'] as bool?) ?? false,
    product: j['product'] is Map
        ? RecProduct.fromJson((j['product'] as Map).cast<String, dynamic>())
        : null,
    createdAt: j['created_at'] == null
        ? null
        : DateTime.tryParse(j['created_at'] as String),
  );

  final String id;
  final String category;
  final String text;
  final bool isBroadcast;
  final RecProduct? product;
  final DateTime? createdAt;
}

/// Repo — dioProvider ustida (yangi shared interfeyslarga tegmaydi).
class RecommendationsRepo {
  RecommendationsRepo(this._dio);
  final Dio _dio;

  Future<List<Recommendation>> list(String studentId) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      '/students/$studentId/recommendations',
    );
    final Object? data = r.data;
    final List<dynamic> items = data is Map
        ? (data['items'] as List<dynamic>? ?? const <dynamic>[])
        : const <dynamic>[];
    return items
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> e) =>
              Recommendation.fromJson(e.cast<String, dynamic>()),
        )
        .toList();
  }

  Future<void> create(
    String studentId,
    String category,
    String text,
    String? productId,
  ) async {
    await _dio.post<dynamic>(
      '/students/$studentId/recommendations',
      data: <String, dynamic>{
        'category': category,
        'text': text,
        'product_id': ?productId,
      },
    );
  }

  Future<void> broadcast(
    String category,
    String text,
    String? productId,
  ) async {
    await _dio.post<dynamic>(
      '/recommendations/broadcast',
      data: <String, dynamic>{
        'category': category,
        'text': text,
        'product_id': ?productId,
      },
    );
  }

  Future<void> delete(String recId) async {
    await _dio.delete<dynamic>('/recommendations/$recId');
  }

  /// Mahsulot pikeri — GET /market/products?q=&category=.
  /// Backend bermasa (501/xato) — bo'sh ro'yxat.
  Future<List<RecProduct>> products({String? q, String? category}) async {
    try {
      final Response<dynamic> r = await _dio.get<dynamic>(
        '/market/products',
        queryParameters: <String, dynamic>{
          if (q != null && q.isNotEmpty) 'q': q,
          if (category != null && category.isNotEmpty) 'category': category,
          'limit': 30,
        },
      );
      final Object? data = r.data;
      final List<dynamic> items = data is Map
          ? (data['items'] as List<dynamic>? ?? const <dynamic>[])
          : (data is List ? data : const <dynamic>[]);
      return items
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> e) =>
                RecProduct.fromJson(e.cast<String, dynamic>()),
          )
          .toList();
    } on Object {
      return const <RecProduct>[];
    }
  }
}

final Provider<RecommendationsRepo> recommendationsRepoProvider =
    Provider<RecommendationsRepo>(
      (Ref ref) => RecommendationsRepo(ref.watch(dioProvider)),
    );

/// Bitta shogirdning tavsiyalari. Backend bermasa — bo'sh.
final FutureProvider<List<Recommendation>> Function(String)
recommendationsProvider = FutureProvider.family<List<Recommendation>, String>((
  Ref ref,
  String studentId,
) async {
  try {
    return await ref.read(recommendationsRepoProvider).list(studentId);
  } on Object {
    return const <Recommendation>[];
  }
});
