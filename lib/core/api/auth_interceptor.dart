// `prefer_initializing_formals` bu yerda YOLG'ON POZITIV: maydonlar yopiq
// (`_storage`), nomlangan parametr esa yopiq bo'la olmaydi (`{required
// this._storage}` — kompilyatsiya xatosi). Ya'ni initializer'dan boshqa
// yo'l yo'q.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/storage/token_storage.dart';

/// Access token qo'shadi va 401 da BITTA refresh urinishini boshqaradi.
///
/// **Parallel so'rovlar muammosi.** Dashboard ochilishida 3-4 so'rov bir
/// vaqtda ketadi. Access eskirgan bo'lsa hammasi 401 qaytaradi. Har biri
/// alohida refresh qilsa — refresh token bir necha marta ishlatiladi va
/// server rotatsiya qilsa ikkinchisi o'ladi.
///
/// Yechim: `Completer` qulfi. Birinchi 401 refresh boshlaydi, qolganlari
/// SHU completer'ni kutadi va tayyor token bilan qayta urinadi.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage storage,
    required Dio refreshClient,
    required Dio retryClient,
    required Future<void> Function() onSessionExpired,
  }) : _storage = storage,
       _refreshClient = refreshClient,
       _retryClient = retryClient,
       _onSessionExpired = onSessionExpired;

  final TokenStorage _storage;

  /// Refresh uchun ALOHIDA Dio — interceptor'siz. Aks holda refresh
  /// so'rovining o'zi 401 da yana refresh chaqirib, cheksiz rekursiya.
  final Dio _refreshClient;

  /// Muvaffaqiyatli refresh'dan keyin asl so'rovni qayta yuborish uchun.
  final Dio _retryClient;

  final Future<void> Function() _onSessionExpired;

  /// Bir vaqtda faqat bitta refresh. `null` — hozir refresh ketmayapti.
  Completer<String?>? _refreshing;

  /// Auth endpointlariga token qo'shilmaydi va ular 401 da refresh qilmaydi.
  static bool _isAuthPath(String path) =>
      path.contains('/auth/otp/') || path.contains('/auth/refresh');

  /// Bir so'rov faqat BIR marta qayta urinadi — 401 qaytaraveradigan
  /// endpoint cheksiz siklga tushmasin.
  static const String _retriedFlag = 'x-retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAuthPath(options.path)) {
      return handler.next(options);
    }

    final Tokens? tokens = await _storage.read();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.access}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions request = err.requestOptions;
    final bool retryable =
        err.response?.statusCode == 401 &&
        !_isAuthPath(request.path) &&
        request.extra[_retriedFlag] != true;

    if (!retryable) {
      return handler.next(err);
    }

    final String? access = await _refreshOnce();
    if (access == null) {
      // Refresh o'ldi — sessiya tugadi, login'ga.
      return handler.reject(
        DioException(
          requestOptions: request,
          response: err.response,
          error: const UnauthorizedException(),
        ),
      );
    }

    try {
      request.extra[_retriedFlag] = true;
      request.headers['Authorization'] = 'Bearer $access';
      final Response<dynamic> response = await _retryClient.fetch<dynamic>(
        request,
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Refresh — bir vaqtda bitta. Qaytaradi: yangi access, yoki `null`
  /// (refresh o'lgan / token yo'q).
  Future<String?> _refreshOnce() {
    // Allaqachon ketayotgan bo'lsa — shuni kutamiz.
    final Completer<String?>? inFlight = _refreshing;
    if (inFlight != null) {
      return inFlight.future;
    }

    final Completer<String?> completer = Completer<String?>();
    _refreshing = completer;

    unawaited(
      _doRefresh().then(completer.complete).whenComplete(() {
        _refreshing = null;
      }),
    );

    return completer.future;
  }

  /// Hech qachon otmaydi — muvaffaqiyatsizlikda sessiyani tozalab `null`
  /// qaytaradi. Shu sababli `_refreshOnce` da `catchError` kerak emas
  /// (u xatoni yutib, tozalashni o'tkazib yuborardi).
  Future<String?> _doRefresh() async {
    try {
      final Tokens? tokens = await _storage.read();
      if (tokens == null) {
        return null;
      }

      final Response<dynamic> response = await _refreshClient.post<dynamic>(
        '/auth/refresh',
        data: <String, dynamic>{'refresh': tokens.refresh},
      );

      final dynamic body = response.data;
      if (body is! Map ||
          body['access'] is! String ||
          body['refresh'] is! String) {
        await _expire();
        return null;
      }

      final String access = body['access'] as String;
      await _storage.save(
        Tokens(access: access, refresh: body['refresh'] as String),
      );
      return access;
    } on DioException catch (e) {
      // MUHIM: sessiya FAQAT server refresh'ni rad etganda tozalanadi.
      // Tarmoq yo'qligi / timeout — bu vaqtinchalik holat, foydalanuvchi
      // internetsiz qolgani uchun tizimdan chiqarilmasligi kerak
      // (T8 offline-tolerantlik).
      final int? status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _expire();
      }
      return null;
    } on Object {
      return null;
    }
  }

  Future<void> _expire() async {
    await _storage.clear();
    await _onSessionExpired();
  }
}
