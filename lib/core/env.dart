/// Markazlashgan konfiguratsiya. Flavor YO'Q — hammasi `--dart-define` orqali.
///
/// Ishga tushirish:
///   flutter run --dart-define=API_URL=http://10.0.2.2:8080/api/v1
///
/// Prism mock (backend kerak emas, SYSTEM.md §1):
///   flutter run --dart-define=API_URL=http://10.0.2.2:4010
library;

class Env {
  const Env._();

  /// API ildizi. Android emulyatorda `localhost` xost mashinaga tegishli emas —
  /// shuning uchun default `10.0.2.2`.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  /// `true` bo'lsa dev-only ekranlar (komponent galereyasi) ochiladi.
  /// Release buildda `kDebugMode` bilan birga tekshiriladi.
  static const bool devTools = bool.fromEnvironment(
    'DEV_TOOLS',
    defaultValue: true,
  );

  static const Duration connectTimeout = Duration(seconds: 8);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Biznes-logika vaqt zonasi (CLAUDE.md: DB'da UTC, hisob Tashkentda).
  static const String businessTimeZone = 'Asia/Tashkent';
}
