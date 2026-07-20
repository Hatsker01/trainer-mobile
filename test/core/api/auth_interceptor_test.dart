import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustoz_trainer/core/api/api_client.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/storage/token_storage.dart';

/// Xotiradagi soxta secure storage — testda platforma kanali yo'q.
class _FakeSecureStorage extends FlutterSecureStorage {
  _FakeSecureStorage() : super();

  final Map<String, String> store = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      store.remove(key);
    } else {
      store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    store.remove(key);
  }
}

/// Skriptlangan adapter — har yo'l uchun javob va chaqiruvlar hisobi.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<String> calls = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    calls.add('${options.method} ${options.path}');
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, String body) => ResponseBody.fromString(
  body,
  status,
  headers: <String, List<String>>{
    Headers.contentTypeHeader: <String>[Headers.jsonContentType],
  },
);

void main() {
  late _FakeSecureStorage secure;
  late TokenStorage storage;

  setUp(() async {
    secure = _FakeSecureStorage();
    storage = TokenStorage(secure);
    await storage.save(
      const Tokens(access: 'eski-access', refresh: 'yaxshi-refresh'),
    );
  });

  ApiClient client(
    _ScriptedAdapter adapter, {
    Future<void> Function()? onExpired,
  }) => ApiClient(
    storage: storage,
    baseUrl: 'https://test.local/api/v1',
    adapter: adapter,
    onSessionExpired: onExpired ?? () async {},
  );

  test('401 → refresh → asl so\'rov qayta yuboriladi', () async {
    bool refreshed = false;
    final _ScriptedAdapter adapter = _ScriptedAdapter((RequestOptions o) async {
      if (o.path == '/auth/refresh') {
        refreshed = true;
        return _json(
          200,
          '{"access":"yangi-access","refresh":"yangi-refresh",'
          '"expires_in":900}',
        );
      }
      // Yangi token bilan kelgan so'rov o'tadi, eskisi 401.
      final String? auth = o.headers['Authorization'] as String?;
      if (auth == 'Bearer yangi-access') {
        return _json(200, '{"ok":true}');
      }
      return _json(401, '{"error":{"code":"unauthorized","message":"x"}}');
    });

    final Response<dynamic> r = await client(adapter).dio.get<dynamic>('/me');

    expect(refreshed, isTrue);
    expect(r.statusCode, 200);
    // Saqlangan tokenlar yangilandi.
    final Tokens? saved = await storage.read();
    expect(saved!.access, 'yangi-access');
    expect(saved.refresh, 'yangi-refresh');
  });

  test(
    'parallel 401 lar FAQAT BITTA refresh chaqiradi (Completer qulfi)',
    () async {
      int refreshCount = 0;
      final _ScriptedAdapter adapter = _ScriptedAdapter((
        RequestOptions o,
      ) async {
        if (o.path == '/auth/refresh') {
          refreshCount++;
          // Sekin refresh — parallel so'rovlar navbatga tushishi uchun.
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return _json(
            200,
            '{"access":"yangi-access","refresh":"yangi-refresh",'
            '"expires_in":900}',
          );
        }
        final String? auth = o.headers['Authorization'] as String?;
        if (auth == 'Bearer yangi-access') {
          return _json(200, '{"ok":true}');
        }
        return _json(401, '{"error":{"code":"unauthorized","message":"x"}}');
      });

      final Dio dio = client(adapter).dio;

      // Dashboard ochilishidagi kabi — 4 so'rov bir vaqtda.
      final List<Response<dynamic>> results =
          await Future.wait<Response<dynamic>>(<Future<Response<dynamic>>>[
            dio.get<dynamic>('/me'),
            dio.get<dynamic>('/dashboard'),
            dio.get<dynamic>('/students'),
            dio.get<dynamic>('/stats'),
          ]);

      expect(
        results.every((Response<dynamic> r) => r.statusCode == 200),
        isTrue,
      );
      expect(
        refreshCount,
        1,
        reason: 'refresh token bir necha marta ishlatilmasligi kerak',
      );
    },
  );

  test(
    'refresh 401 qaytarsa — sessiya tozalanadi va callback chaqiriladi',
    () async {
      bool expired = false;
      final _ScriptedAdapter adapter = _ScriptedAdapter((
        RequestOptions o,
      ) async {
        if (o.path == '/auth/refresh') {
          return _json(401, '{"error":{"code":"unauthorized","message":"x"}}');
        }
        return _json(401, '{"error":{"code":"unauthorized","message":"x"}}');
      });

      final Dio dio = client(
        adapter,
        onExpired: () async => expired = true,
      ).dio;

      await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));

      expect(expired, isTrue);
      expect(
        await storage.read(),
        isNull,
        reason: 'tokenlar tozalanishi kerak',
      );
    },
  );

  test('refresh paytida TARMOQ yo\'q bo\'lsa — sessiya SAQLANADI', () async {
    bool expired = false;
    final _ScriptedAdapter adapter = _ScriptedAdapter((RequestOptions o) async {
      if (o.path == '/auth/refresh') {
        throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        );
      }
      return _json(401, '{"error":{"code":"unauthorized","message":"x"}}');
    });

    final Dio dio = client(adapter, onExpired: () async => expired = true).dio;

    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));

    // Internetsiz qolgan foydalanuvchi tizimdan chiqarilmaydi (T8).
    expect(expired, isFalse);
    expect(await storage.read(), isNotNull);
  });

  test('bir so\'rov FAQAT bir marta qayta urinadi', () async {
    int meCalls = 0;
    final _ScriptedAdapter adapter = _ScriptedAdapter((RequestOptions o) async {
      if (o.path == '/auth/refresh') {
        return _json(
          200,
          '{"access":"yangi-access","refresh":"yangi-refresh",'
          '"expires_in":900}',
        );
      }
      meCalls++;
      // Token yangilangandan keyin ham 401 — cheksiz sikl bo'lmasligi kerak.
      return _json(401, '{"error":{"code":"unauthorized","message":"x"}}');
    });

    await expectLater(
      client(adapter).dio.get<dynamic>('/me'),
      throwsA(isA<DioException>()),
    );

    expect(meCalls, 2, reason: 'asl + bitta qayta urinish');
  });

  test(
    'auth endpointlariga token qo\'shilmaydi va refresh qilinmaydi',
    () async {
      int refreshCount = 0;
      final _ScriptedAdapter adapter = _ScriptedAdapter((
        RequestOptions o,
      ) async {
        if (o.path == '/auth/refresh') {
          refreshCount++;
          return _json(200, '{}');
        }
        expect(o.headers.containsKey('Authorization'), isFalse);
        return _json(401, '{"error":{"code":"otp_invalid","message":"x"}}');
      });

      await expectLater(
        client(adapter).dio.post<dynamic>(
          '/auth/otp/verify',
          data: <String, dynamic>{'phone': '+998901234567', 'code': '000000'},
        ),
        throwsA(isA<DioException>()),
      );

      expect(refreshCount, 0);
    },
  );

  test('xatolar UI ga AppException sifatida yetadi', () async {
    final _ScriptedAdapter adapter = _ScriptedAdapter(
      (RequestOptions o) async => _json(
        422,
        '{"error":{"code":"validation_failed","message":"Xato",'
        '"details":{"phone":"format"}}}',
      ),
    );

    try {
      await client(adapter).dio.post<dynamic>('/students');
      fail('xato kutilgan edi');
    } on DioException catch (e) {
      expect(e.error, isA<ValidationException>());
      expect((e.error! as ValidationException).forField('phone'), 'format');
    }
  });
}
