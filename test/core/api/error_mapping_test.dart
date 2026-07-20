import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/error_interceptor.dart';

/// T2 DoD: "xato mapping jadval-testi".
void main() {
  final RequestOptions options = RequestOptions(path: '/students');

  DioException http(
    int status, {
    dynamic body,
    Map<String, List<String>>? headers,
  }) => DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: body,
      headers: headers == null ? null : Headers.fromMap(headers),
    ),
  );

  /// Kontraktdagi xato konverti.
  Map<String, dynamic> envelope(
    String code,
    String message, {
    Map<String, String>? details,
  }) => <String, dynamic>{
    'error': <String, dynamic>{
      'code': code,
      'message': message,
      'details': ?details,
    },
  };

  group('Transport xatolari', () {
    final Map<DioExceptionType, Type> table = <DioExceptionType, Type>{
      DioExceptionType.connectionTimeout: TimeoutException,
      DioExceptionType.sendTimeout: TimeoutException,
      DioExceptionType.receiveTimeout: TimeoutException,
      DioExceptionType.connectionError: NetworkException,
      DioExceptionType.badCertificate: NetworkException,
      DioExceptionType.cancel: NetworkException,
      DioExceptionType.unknown: NetworkException,
    };

    table.forEach((DioExceptionType type, Type expected) {
      test('${type.name} → $expected', () {
        final AppException e = ErrorInterceptor.map(
          DioException(requestOptions: options, type: type),
        );
        expect(e.runtimeType, expected);
        expect(e.message, isNotEmpty);
      });
    });

    test('xom error allaqachon AppException bo\'lsa qayta o\'ralmaydi', () {
      const UnauthorizedException original = UnauthorizedException('maxsus');
      final AppException mapped = ErrorInterceptor.map(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: original,
        ),
      );
      expect(mapped, same(original));
    });
  });

  group('HTTP status mapping', () {
    test('401 → UnauthorizedException', () {
      expect(ErrorInterceptor.map(http(401)), isA<UnauthorizedException>());
    });

    test('403 → ForbiddenException', () {
      expect(ErrorInterceptor.map(http(403)), isA<ForbiddenException>());
    });

    test('404 → NotFoundException', () {
      expect(ErrorInterceptor.map(http(404)), isA<NotFoundException>());
    });

    test('500/502/503 → ServerException', () {
      for (final int s in <int>[500, 502, 503]) {
        expect(
          ErrorInterceptor.map(http(s)),
          isA<ServerException>(),
          reason: 'status $s',
        );
      }
    });

    test('400 → ApiException (kod bilan)', () {
      final AppException e = ErrorInterceptor.map(
        http(400, body: envelope('bad_request', "So'rov formati noto'g'ri")),
      );
      expect(e, isA<ApiException>());
      final ApiException api = e as ApiException;
      expect(api.statusCode, 400);
      expect(api.code, 'bad_request');
      expect(api.message, "So'rov formati noto'g'ri");
    });

    test('401 otp_invalid — server matni saqlanadi', () {
      final AppException e = ErrorInterceptor.map(
        http(401, body: envelope('otp_invalid', "Kod noto'g'ri")),
      );
      expect(e.message, "Kod noto'g'ri");
    });
  });

  group('422 — maydon xatolari', () {
    test('details maydonlarga taqsimlanadi', () {
      final AppException e = ErrorInterceptor.map(
        http(
          422,
          body: envelope(
            'validation_failed',
            "Maydonlar to'g'ri to'ldirilmagan",
            details: <String, String>{
              'phone': 'Telefon formati xato',
              'tariff_price': 'Summa 0 dan katta bo\'lishi kerak',
            },
          ),
        ),
      );

      expect(e, isA<ValidationException>());
      final ValidationException v = e as ValidationException;
      expect(v.fieldErrors, hasLength(2));
      expect(v.forField('phone'), 'Telefon formati xato');
      expect(v.forField('tariff_price'), isNotNull);
      expect(v.forField('mavjud_emas'), isNull);
    });

    test('details bo\'lmasa ham crash qilmaydi', () {
      final AppException e = ErrorInterceptor.map(
        http(422, body: envelope('validation_failed', 'Xato')),
      );
      expect((e as ValidationException).fieldErrors, isEmpty);
    });

    test('details ichida string bo\'lmagan qiymat tashlab yuboriladi', () {
      final AppException e = ErrorInterceptor.map(
        http(
          422,
          body: <String, dynamic>{
            'error': <String, dynamic>{
              'code': 'validation_failed',
              'message': 'Xato',
              'details': <String, dynamic>{'phone': 'ok', 'age': 42},
            },
          },
        ),
      );
      final ValidationException v = e as ValidationException;
      expect(v.fieldErrors, <String, String>{'phone': 'ok'});
    });
  });

  group('429 — rate limit', () {
    test('Retry-After sarlavhasi o\'qiladi', () {
      final AppException e = ErrorInterceptor.map(
        http(
          429,
          body: envelope('rate_limited', 'Juda ko\'p urinish'),
          headers: <String, List<String>>{
            'retry-after': <String>['60'],
          },
        ),
      );

      expect(e, isA<RateLimitException>());
      expect((e as RateLimitException).retryAfter, const Duration(seconds: 60));
    });

    test('Retry-After bo\'lmasa null', () {
      final AppException e = ErrorInterceptor.map(http(429));
      expect((e as RateLimitException).retryAfter, isNull);
    });

    test('Retry-After noto\'g\'ri formatda bo\'lsa null (crash emas)', () {
      final AppException e = ErrorInterceptor.map(
        http(
          429,
          headers: <String, List<String>>{
            'retry-after': <String>['Wed, 21 Oct 2026 07:28:00 GMT'],
          },
        ),
      );
      expect((e as RateLimitException).retryAfter, isNull);
    });
  });

  group('Buzuq javob tanasi', () {
    test('HTML/matn qaytsa ham mapping ishlaydi', () {
      final AppException e = ErrorInterceptor.map(
        http(502, body: '<html>Bad Gateway</html>'),
      );
      expect(e, isA<ServerException>());
      expect(e.message, isNotEmpty);
    });

    test('error kaliti Map bo\'lmasa default matn', () {
      final AppException e = ErrorInterceptor.map(
        http(404, body: <String, dynamic>{'error': 'topilmadi'}),
      );
      expect(e, isA<NotFoundException>());
      expect(e.message, 'Topilmadi');
    });
  });
}
