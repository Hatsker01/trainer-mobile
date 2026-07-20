import 'package:json_annotation/json_annotation.dart';
import 'package:ustoz_trainer/core/api/dto/converters.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';

part 'auth_dto.g.dart';

/// `POST /auth/otp/request` tanasi.
@JsonSerializable(createFactory: false)
class OtpRequest {
  const OtpRequest({required this.phone});

  /// `+998XXXXXXXXX` — 13 belgi, probelsiz.
  final String phone;

  Map<String, dynamic> toJson() => _$OtpRequestToJson(this);
}

/// OTP qaysi kanal orqali yuborildi.
enum OtpChannel {
  @JsonValue('tg')
  tg,
  @JsonValue('sms')
  sms,
}

/// `POST /auth/otp/request` javobi (200).
@JsonSerializable()
class OtpRequestResponse {
  const OtpRequestResponse({
    required this.channel,
    required this.expiresIn,
    this.retryAfter,
  });

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OtpRequestResponseToJson(this);

  final OtpChannel channel;

  /// Kod amal qilish muddati (sekund, masalan 300).
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  /// Qayta yuborishgacha qolgan vaqt (sekund, masalan 60).
  /// Server bermasa — UI 60s default taymer qo'yadi.
  @JsonKey(name: 'retry_after')
  final int? retryAfter;

  Duration get expiresAfter => Duration(seconds: expiresIn);
  Duration? get resendAfter =>
      retryAfter == null ? null : Duration(seconds: retryAfter!);
}

/// `POST /auth/otp/verify` tanasi.
@JsonSerializable(createFactory: false)
class OtpVerifyRequest {
  const OtpVerifyRequest({required this.phone, required this.code});

  final String phone;

  /// **String**, int emas — boshida nol bo'lishi mumkin (`^[0-9]{6}$`).
  final String code;

  Map<String, dynamic> toJson() => _$OtpVerifyRequestToJson(this);
}

/// `POST /auth/refresh` tanasi.
@JsonSerializable(createFactory: false)
class RefreshRequest {
  const RefreshRequest({required this.refresh});

  final String refresh;

  Map<String, dynamic> toJson() => _$RefreshRequestToJson(this);
}

/// Token juftligi. Access 15 daqiqa, refresh 30 kun.
@JsonSerializable()
class TokenPair {
  const TokenPair({
    required this.access,
    required this.refresh,
    required this.expiresIn,
    this.isNewUser,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);

  Map<String, dynamic> toJson() => _$TokenPairToJson(this);

  final String access;
  final String refresh;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  /// `true` bo'lsa — profil sozlash ekraniga (S3), aks holda dashboard'ga.
  /// `/auth/refresh` javobida bo'lmaydi.
  @JsonKey(name: 'is_new_user')
  final bool? isNewUser;
}

/// Trener yoki shogird uchun Telegram havolasi.
@JsonSerializable()
class TgLink {
  const TgLink({required this.link, required this.token});

  factory TgLink.fromJson(Map<String, dynamic> json) => _$TgLinkFromJson(json);

  Map<String, dynamic> toJson() => _$TgLinkToJson(this);

  /// `https://t.me/UstozBot?start=inv_8f3a9c2b1d`
  final String link;
  final String token;
}

/// `GET /me` javobi.
@JsonSerializable()
class Me {
  const Me({
    required this.id,
    required this.phone,
    required this.role,
    required this.name,
    required this.lang,
    required this.plan,
    required this.tgConnected,
    required this.createdAt,
    this.gymName,
    this.remindTime,
    this.planUntil,
  });

  /// Salomlashish uchun faqat ism (`greeting_name` kabi).
  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);

  Map<String, dynamic> toJson() => _$MeToJson(this);

  final String id;
  final String phone;
  final UserRole role;
  final String name;
  final Lang lang;
  final Plan plan;

  @JsonKey(name: 'gym_name')
  final String? gymName;

  /// `HH:MM` (Asia/Tashkent) — kunlik eslatma vaqti. Sana EMAS.
  @JsonKey(name: 'remind_time')
  final String? remindTime;

  /// `format: date` — obuna tugash sanasi.
  @DateOnlyNullableConverter()
  @JsonKey(name: 'plan_until')
  final DateTime? planUntil;

  @JsonKey(name: 'tg_connected')
  final bool tgConnected;

  /// `format: date-time` (RFC3339 UTC).
  @UtcDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
}

/// `PATCH /me` tanasi. `minProperties: 1` — faqat o'zgargan maydon yuboriladi.
///
/// `includeIfNull: false` — `null` maydon JSON'ga umuman tushmaydi.
/// Cheklov: `gym_name` ni `null` qilib TOZALAB bo'lmaydi (kontraktda u
/// nullable). MVP da zal nomini o'chirish stsenariysi yo'q — kerak bo'lsa
/// alohida `clearGymName` bayrog'i qo'shiladi.
@JsonSerializable(createFactory: false, includeIfNull: false)
class MeUpdate {
  const MeUpdate({this.name, this.gymName, this.lang, this.remindTime});

  final String? name;

  @JsonKey(name: 'gym_name')
  final String? gymName;

  final Lang? lang;

  @JsonKey(name: 'remind_time')
  final String? remindTime;

  Map<String, dynamic> toJson() => _$MeUpdateToJson(this);
}
