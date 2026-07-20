import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/repositories.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/storage/token_storage.dart';

/// Sessiya holati — router shu asosda qayerga yo'naltirishni hal qiladi.
sealed class SessionState {
  const SessionState();
}

/// Splash: tokenlar hali tekshirilmagan.
class SessionUnknown extends SessionState {
  const SessionUnknown();
}

/// Token yo'q yoki sessiya tugagan → auth oqimi.
class SessionSignedOut extends SessionState {
  const SessionSignedOut();
}

/// Kirilgan. [me] `null` bo'lsa — profil hali to'ldirilmagan (`is_new_user`).
class SessionActive extends SessionState {
  const SessionActive({required this.me, this.needsProfile = false});

  final Me me;

  /// `true` — S3 profil sozlash ekraniga.
  final bool needsProfile;
}

final NotifierProvider<SessionNotifier, SessionState> sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    // `ApiClient` refresh o'lganda shu bayroqni ko'taradi.
    ref.listen<bool>(sessionExpiredProvider, (bool? _, bool expired) {
      if (expired) {
        state = const SessionSignedOut();
        ref.read(sessionExpiredProvider.notifier).reset();
      }
    });
    return const SessionUnknown();
  }

  TokenStorage get _storage => ref.read(tokenStorageProvider);
  MeRepository get _me => ref.read(meRepositoryProvider);

  /// Splash'da chaqiriladi: token bormi, va u hali ishlaydimi?
  Future<void> restore() async {
    final Tokens? tokens = await _storage.read();
    if (tokens == null) {
      state = const SessionSignedOut();
      return;
    }

    try {
      final Me me = await _me.getMe();
      state = SessionActive(me: me);
    } on UnauthorizedException {
      // Access ham, refresh ham o'lgan.
      await _storage.clear();
      state = const SessionSignedOut();
    } on AppException {
      // Tarmoq yo'q — tokenni O'CHIRMAYMIZ. Offline holatda ilova
      // keshdan ishlashi kerak (T8), login'ga otish noto'g'ri bo'lardi.
      // `me` hali yo'q, shuning uchun signed-out emas, unknown qoladi
      // va UI qayta urinish beradi.
      rethrow;
    }
  }

  /// OTP tasdiqlangandan keyin.
  Future<void> signIn(TokenPair tokens) async {
    await _storage.save(Tokens(access: tokens.access, refresh: tokens.refresh));

    final Me me = await _me.getMe();
    state = SessionActive(me: me, needsProfile: tokens.isNewUser ?? false);
  }

  /// Profil sozlash tugagach (S3) yoki sozlamalarda o'zgargach.
  void setMe(Me me) => state = SessionActive(me: me);

  /// Chiqish. Kontraktda logout endpoint YO'Q — faqat lokal tozalash.
  Future<void> signOut() async {
    await _storage.clear();
    state = const SessionSignedOut();
  }
}
