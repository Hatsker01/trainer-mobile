import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// HTTP loglash — **telefon raqamlar mask qilinadi** (CLAUDE.md majburiy
/// qoidasi: loglarda `+998 90 ***`).
///
/// Faqat `Env.logHttp` bo'lganda zanjirga qo'shiladi (default: debug).
class HttpLogInterceptor extends Interceptor {
  const HttpLogInterceptor();

  /// `+998901234567` → `+998 90 ***`.
  ///
  /// Faqat to'liq 13 belgili O'zbekiston raqamiga tegadi — boshqa
  /// raqamlar (summalar, ID'lar) buzilmaydi.
  static String maskPhones(String input) => input.replaceAllMapped(
    RegExp(r'\+998(\d{2})\d{7}'),
    (Match m) => '+998 ${m.group(1)} ***',
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('→ ${options.method} ${options.uri.path}${_query(options)}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      '✗ ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.method} ${err.requestOptions.uri.path}',
    );
    handler.next(err);
  }

  static String _query(RequestOptions o) =>
      o.uri.query.isEmpty ? '' : '?${o.uri.query}';

  static void _log(String message) =>
      developer.log(maskPhones(message), name: 'http');
}
