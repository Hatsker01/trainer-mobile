import 'package:json_annotation/json_annotation.dart';
import 'package:ustoz_trainer/core/api/dto/converters.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';

part 'student_dto.g.dart';

/// Shogird — `GET /students/{id}`, `POST /students` javobi.
@JsonSerializable()
class Student {
  const Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.tariffType,
    required this.tariffPrice,
    required this.sessionsUsed,
    required this.status,
    required this.paymentState,
    required this.tgConnected,
    required this.createdAt,
    this.sessionsTotal,
    this.nextDueDate,
    this.daysOverdue,
    this.inviteToken,
    this.avatarUrl,
    this.balance,
    this.totalPaid,
    this.lastPaymentAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);

  final String id;
  final String name;
  final String phone;

  @JsonKey(name: 'tariff_type')
  final TariffType tariffType;

  /// So'mda BUTUN son (`Money` = int64). Hech qachon `double`.
  @JsonKey(name: 'tariff_price')
  final int tariffPrice;

  /// Faqat `package` tarifda.
  @JsonKey(name: 'sessions_total')
  final int? sessionsTotal;

  @JsonKey(name: 'sessions_used')
  final int sessionsUsed;

  /// `package` va `single` tariflarda `null`.
  @DateOnlyNullableConverter()
  @JsonKey(name: 'next_due_date')
  final DateTime? nextDueDate;

  /// Musbat bo'lsa — qarzdor.
  @JsonKey(name: 'days_overdue')
  final int? daysOverdue;

  final StudentStatus status;

  @JsonKey(name: 'payment_state')
  final PaymentState paymentState;

  @JsonKey(name: 'tg_connected')
  final bool tgConnected;

  /// `t.me/UstozBot?start=<invite_token>`.
  @JsonKey(name: 'invite_token')
  final String? inviteToken;

  // REDESIGN (root-1-11/17): kartochka boyroq ma'lumot ko'rsatadi.
  // Barchasi nullable — backend qo'shguncha `null` (UI fallback beradi).
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// Joriy balans (so'mda). Manfiy = qarz. `null` — backend hali bermaydi.
  final int? balance;

  @JsonKey(name: 'total_paid')
  final int? totalPaid;

  @DateOnlyNullableConverter()
  @JsonKey(name: 'last_payment_at')
  final DateTime? lastPaymentAt;

  @UtcDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Paketda qolgan mashg'ulotlar. `package` bo'lmasa `null`.
  int? get sessionsLeft =>
      sessionsTotal == null ? null : sessionsTotal! - sessionsUsed;

  bool get isDebtor => (daysOverdue ?? 0) > 0;
  bool get isArchived => status == StudentStatus.archived;
}

/// `POST /students` tanasi.
@JsonSerializable(createFactory: false, includeIfNull: false)
class StudentCreate {
  const StudentCreate({
    required this.name,
    required this.phone,
    required this.tariffType,
    required this.tariffPrice,
    this.sessionsTotal,
    this.startDate,
  });

  final String name;
  final String phone;

  @JsonKey(name: 'tariff_type')
  final TariffType tariffType;

  @JsonKey(name: 'tariff_price')
  final int tariffPrice;

  /// `tariff_type=package` bo'lsa MAJBURIY (server 422 qaytaradi).
  @JsonKey(name: 'sessions_total')
  final int? sessionsTotal;

  /// Berilmasa — bugun. `monthly` uchun birinchi `next_due_date` shundan.
  @DateOnlyNullableConverter()
  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  Map<String, dynamic> toJson() => _$StudentCreateToJson(this);
}

/// `PATCH /students/{id}` tanasi. `status` YO'Q — arxivlash alohida endpoint.
@JsonSerializable(createFactory: false, includeIfNull: false)
class StudentUpdate {
  const StudentUpdate({
    this.name,
    this.phone,
    this.tariffType,
    this.tariffPrice,
    this.sessionsTotal,
    this.nextDueDate,
  });

  final String? name;
  final String? phone;

  @JsonKey(name: 'tariff_type')
  final TariffType? tariffType;

  @JsonKey(name: 'tariff_price')
  final int? tariffPrice;

  @JsonKey(name: 'sessions_total')
  final int? sessionsTotal;

  @DateOnlyNullableConverter()
  @JsonKey(name: 'next_due_date')
  final DateTime? nextDueDate;

  Map<String, dynamic> toJson() => _$StudentUpdateToJson(this);
}

/// Sahifalangan shogirdlar ro'yxati.
@JsonSerializable()
class PagedStudents {
  const PagedStudents({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PagedStudents.fromJson(Map<String, dynamic> json) =>
      _$PagedStudentsFromJson(json);

  Map<String, dynamic> toJson() => _$PagedStudentsToJson(this);

  final List<Student> items;
  final int total;
  final int page;
  final int limit;

  /// Kontraktda `has_next` YO'Q — o'zimiz hisoblaymiz.
  bool get hasMore => page * limit < total;
}

/// `POST /students/{id}/remind` tanasi (ixtiyoriy).
@JsonSerializable(createFactory: false, includeIfNull: false)
class RemindRequest {
  const RemindRequest({this.templateKey, this.lang});

  @JsonKey(name: 'template_key')
  final RemindTemplate? templateKey;

  final Lang? lang;

  Map<String, dynamic> toJson() => _$RemindRequestToJson(this);
}

/// `POST /students/{id}/remind` javobi (**202**, 200 emas).
@JsonSerializable()
class RemindResponse {
  const RemindResponse({
    required this.notificationId,
    required this.status,
    this.warning,
  });

  factory RemindResponse.fromJson(Map<String, dynamic> json) =>
      _$RemindResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RemindResponseToJson(this);

  @JsonKey(name: 'notification_id')
  final String notificationId;

  final NotificationStatus status;

  /// Kuniga 3 martadan ko'p eslatilganda — bloklamaydigan ogohlantirish.
  /// UI buni toast'da ko'rsatadi (T4).
  final String? warning;
}
