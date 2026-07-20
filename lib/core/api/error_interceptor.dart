import 'package:dio/dio.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';

/// Xom `DioException` → `AppException`.
///
/// Brief T2: UI hech qachon xom `DioException` ko'rmaydi. Mapping SHU YERDA,
/// bitta joyda — har repozitoriyda `try/catch` takrorlanmaydi.
///
/// Bu interceptor zanjirda OXIRGI bo'lishi kerak: `AuthInterceptor` 401 ni
/// refresh bilan hal qilishga urinib ko'rgandan KEYIN ishga tushadi.
class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: map(err),
      ),
    );
  }

  /// Testda to'g'ridan-to'g'ri chaqiriladi (jadval-testi).
  static AppException map(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const NetworkException('So\'rov bekor qilindi');
      case DioExceptionType.badCertificate:
        return const NetworkException('Server sertifikati ishonchsiz');
      case DioExceptionType.unknown:
        // Xom `error` allaqachon AppException bo'lsa (AuthInterceptor
        // qo'ygan) — qayta o'ramaymiz.
        if (err.error is AppException) {
          return err.error! as AppException;
        }
        return const NetworkException();
      case DioExceptionType.badResponse:
        return _mapStatus(err.response);
    }
  }

  static AppException _mapStatus(Response<dynamic>? response) {
    final int status = response?.statusCode ?? 0;
    final _ErrorBody body = _ErrorBody.parse(response?.data);

    return switch (status) {
      401 => UnauthorizedException(body.message ?? 'Sessiya tugadi'),
      403 => ForbiddenException(body.message ?? "Bu amalga ruxsat yo'q"),
      404 => NotFoundException(body.message ?? 'Topilmadi'),
      422 => ValidationException(
        body.message ?? "Maydonlar to'g'ri to'ldirilmagan",
        fieldErrors: body.details,
      ),
      429 => RateLimitException(
        body.message ?? 'Juda ko\'p urinish',
        retryAfter: _retryAfter(response),
      ),
      >= 500 => ServerException(body.message ?? 'Serverda xatolik'),
      >= 400 => ApiException(
        body.message ?? 'So\'rov bajarilmadi',
        statusCode: status,
        code: body.code,
      ),
      _ => const ServerException(),
    };
  }

  /// `Retry-After` sarlavhasi — sekundlarda.
  static Duration? _retryAfter(Response<dynamic>? response) {
    final String? raw = response?.headers.value('retry-after');
    final int? seconds = raw == null ? null : int.tryParse(raw.trim());
    return seconds == null ? null : Duration(seconds: seconds);
  }
}

/// `{"error": {"code": ..., "message": ..., "details": {...}}}` konverti.
class _ErrorBody {
  const _ErrorBody({this.code, this.message, this.details = const {}});

  final String? code;
  final String? message;
  final Map<String, String> details;

  /// Server har doim ham kontraktdagi konvertni qaytarmasligi mumkin
  /// (proxy 502 HTML qaytarishi mumkin) — parse hech qachon otmaydi.
  static _ErrorBody parse(dynamic data) {
    if (data is! Map) {
      return const _ErrorBody();
    }
    final dynamic error = data['error'];
    if (error is! Map) {
      return const _ErrorBody();
    }

    final dynamic rawDetails = error['details'];
    final Map<String, String> details = <String, String>{};
    if (rawDetails is Map) {
      rawDetails.forEach((dynamic k, dynamic v) {
        if (k is String && v is String) {
          details[k] = v;
        }
      });
    }

    return _ErrorBody(
      code: error['code'] is String ? error['code'] as String : null,
      message: error['message'] is String ? error['message'] as String : null,
      details: details,
    );
  }
}
