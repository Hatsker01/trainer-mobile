// Qarang: `auth_interceptor.dart` — yopiq maydon + nomlangan parametr.
// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:ustoz_trainer/core/api/auth_interceptor.dart';
import 'package:ustoz_trainer/core/api/error_interceptor.dart';
import 'package:ustoz_trainer/core/api/log_interceptor.dart';
import 'package:ustoz_trainer/core/env.dart';
import 'package:ustoz_trainer/core/storage/token_storage.dart';

/// Sozlangan Dio. Repozitoriylar SHUNI oladi, `Dio` ni o'zi yaratmaydi.
class ApiClient {
  ApiClient({
    required TokenStorage storage,
    required Future<void> Function() onSessionExpired,
    String? baseUrl,
    HttpClientAdapter? adapter,
  }) : _storage = storage {
    final String url = baseUrl ?? Env.apiUrl;

    dio = _bare(url);
    _refreshClient = _bare(url);
    final Dio retryClient = _bare(url);

    if (adapter != null) {
      // Testda `MockAdapter` — hamma uchun bir xil bo'lishi shart,
      // aks holda retry/refresh haqiqiy tarmoqqa chiqib ketadi.
      dio.httpClientAdapter = adapter;
      _refreshClient.httpClientAdapter = adapter;
      retryClient.httpClientAdapter = adapter;
    }

    dio.interceptors.addAll(<Interceptor>[
      AuthInterceptor(
        storage: _storage,
        refreshClient: _refreshClient,
        retryClient: retryClient,
        onSessionExpired: onSessionExpired,
      ),
      // Zanjirda OXIRGI: Auth 401 ni hal qilishga urinib ko'rgandan keyin
      // qolgan hamma narsa AppException'ga aylanadi.
      if (Env.logHttp) const HttpLogInterceptor(),
      const ErrorInterceptor(),
    ]);
  }

  late final Dio dio;
  late final Dio _refreshClient;
  final TokenStorage _storage;

  static Dio _bare(String baseUrl) => Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      sendTimeout: Env.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      // 4xx/5xx ni Dio o'zi xatoga aylantirsin — `ErrorInterceptor`
      // ularni bir joyda mapping qiladi.
      validateStatus: (int? status) => status != null && status < 400,
    ),
  );

  /// Til o'zgarganda — server `Error.message` ni shu bo'yicha lokalizatsiya
  /// qiladi (kontrakt: "`Error.message` `Accept-Language` bo'yicha").
  void setLanguage(String langCode) {
    for (final Dio client in <Dio>[dio, _refreshClient]) {
      client.options.headers['Accept-Language'] = langCode;
    }
  }
}
