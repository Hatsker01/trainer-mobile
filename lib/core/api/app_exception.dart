/// UI ko'radigan YAGONA xato tipi.
///
/// Brief T2: "UI hech qachon xom `DioException` ko'rmaydi". Mapping
/// `ErrorInterceptor` da bir joyda qilinadi.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Foydalanuvchiga ko'rsatiladigan matn.
  ///
  /// Server `Accept-Language` bo'yicha lokalizatsiya qiladi (`Error.message`),
  /// shuning uchun server bergan matn bo'lsa — o'sha ishlatiladi. Aks holda
  /// (tarmoq/timeout) lokal matn.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Internet yo'q / DNS / ulanish uzildi.
class NetworkException extends AppException {
  const NetworkException([
    super.message = "Internet aloqasi yo'q. Ulanishni tekshiring",
  ]);
}

/// Connect / receive timeout.
class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'Server javob bermadi. Qayta urinib ko\'ring',
  ]);
}

/// 401 — token yaroqsiz va refresh ham o'ldi. Router login'ga otadi.
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Sessiya tugadi. Qaytadan kiring',
  ]);
}

/// 403 — RBAC. Trener boshqa trenerning shogirdiga tegmoqchi bo'ldi.
class ForbiddenException extends AppException {
  const ForbiddenException([super.message = "Bu amalga ruxsat yo'q"]);
}

/// 404.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Topilmadi']);
}

/// 422 — maydon validatsiyasi.
///
/// `fieldErrors` UI da forma maydonlariga taqsimlanadi (T5: "422 field
/// xatolarini maydonlarga taqsimlash").
class ValidationException extends AppException {
  const ValidationException(super.message, {this.fieldErrors = const {}});

  /// `{"phone": "Telefon +998... formatda bo'lishi kerak"}`.
  final Map<String, String> fieldErrors;

  /// Maydonga tegishli xato bormi?
  String? forField(String field) => fieldErrors[field];
}

/// 429 — rate limit. `retryAfter` — `Retry-After` sarlavhasidan (sekund).
class RateLimitException extends AppException {
  const RateLimitException(super.message, {this.retryAfter});

  final Duration? retryAfter;
}

/// 4xx — kontraktda alohida ko'rsatilmagan mijoz xatosi.
///
/// `code` — serverning `error.code` maydoni (masalan `otp_invalid`,
/// `student_not_connected`). UI shu kod bo'yicha maxsus muomala qiladi.
class ApiException extends AppException {
  const ApiException(super.message, {required this.statusCode, this.code});

  final int statusCode;
  final String? code;
}

/// 5xx yoki kutilmagan javob.
class ServerException extends AppException {
  const ServerException([
    super.message = 'Serverda xatolik. Birozdan keyin urinib ko\'ring',
  ]);
}

/// Javobni parse qilib bo'lmadi — kontrakt buzilgan.
///
/// Bu **bizning xatomiz** (DTO kontraktga mos emas), foydalanuvchiniki emas —
/// shuning uchun alohida tip: debug'da ko'rinsin, release'da umumiy matn.
class ParseException extends AppException {
  const ParseException(this.detail) : super("Ma'lumotni o'qib bo'lmadi");

  final String detail;

  @override
  String toString() => 'ParseException: $detail';
}
