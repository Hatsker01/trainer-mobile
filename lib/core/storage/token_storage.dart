import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT juftligi.
class Tokens {
  const Tokens({required this.access, required this.refresh});

  final String access;
  final String refresh;
}

/// Tokenlarni xavfsiz saqlash (iOS Keychain / Android EncryptedSharedPrefs).
///
/// `SharedPreferences` ISHLATILMAYDI — u oddiy XML/plist, root qilingan
/// qurilmada ochiq o'qiladi.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  static const String _kAccess = 'auth.access';
  static const String _kRefresh = 'auth.refresh';

  /// Xotiradagi nusxa — har so'rovda Keychain'ga borish qimmat
  /// (interceptor HAR so'rovda o'qiydi).
  Tokens? _cached;

  Future<Tokens?> read() async {
    if (_cached != null) {
      return _cached;
    }
    final String? access = await _storage.read(key: _kAccess);
    final String? refresh = await _storage.read(key: _kRefresh);
    if (access == null || refresh == null) {
      return null;
    }
    return _cached = Tokens(access: access, refresh: refresh);
  }

  Future<void> save(Tokens tokens) async {
    _cached = tokens;
    await _storage.write(key: _kAccess, value: tokens.access);
    await _storage.write(key: _kRefresh, value: tokens.refresh);
  }

  /// Chiqish / refresh o'lgani. Kontraktda logout endpoint YO'Q —
  /// chiqish faqat lokal tozalash.
  Future<void> clear() async {
    _cached = null;
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }

  bool get hasCached => _cached != null;
}
