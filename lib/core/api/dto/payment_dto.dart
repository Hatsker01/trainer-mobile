import 'package:json_annotation/json_annotation.dart';
import 'package:ustoz_trainer/core/api/dto/converters.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';

part 'payment_dto.g.dart';

/// To'lov yozuvi.
@JsonSerializable()
class Payment {
  const Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.method,
    required this.paidAt,
    required this.createdAt,
    this.periodFrom,
    this.periodTo,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  final String id;

  @JsonKey(name: 'student_id')
  final String studentId;

  /// So'mda butun son.
  final int amount;

  final PaymentMethod method;

  @DateOnlyConverter()
  @JsonKey(name: 'paid_at')
  final DateTime paidAt;

  @DateOnlyNullableConverter()
  @JsonKey(name: 'period_from')
  final DateTime? periodFrom;

  /// `monthly` uchun keyingi `next_due_date` = `period_to` + 1 kun.
  @DateOnlyNullableConverter()
  @JsonKey(name: 'period_to')
  final DateTime? periodTo;

  @UtcDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
}

/// `POST /payments` tanasi.
///
/// `period_from` / `period_to` YO'Q — ularni SERVER hisoblaydi.
@JsonSerializable(createFactory: false, includeIfNull: false)
class PaymentCreate {
  const PaymentCreate({
    required this.studentId,
    required this.amount,
    required this.method,
    this.paidAt,
    this.sessionsAdded,
  });

  @JsonKey(name: 'student_id')
  final String studentId;

  final int amount;
  final PaymentMethod method;

  /// Berilmasa — bugun (Asia/Tashkent).
  @DateOnlyNullableConverter()
  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;

  /// `package` tarifda qo'shiladigan mashg'ulotlar soni.
  @JsonKey(name: 'sessions_added')
  final int? sessionsAdded;

  Map<String, dynamic> toJson() => _$PaymentCreateToJson(this);
}

/// `POST /payments` javobi (201).
///
/// `student` qayta hisoblangan holda qaytadi — UI darhol yangilanadi
/// (qo'shimcha `GET /students/{id}` kerak emas).
@JsonSerializable()
class PaymentCreated {
  const PaymentCreated({required this.payment, required this.student});

  factory PaymentCreated.fromJson(Map<String, dynamic> json) =>
      _$PaymentCreatedFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentCreatedToJson(this);

  final Payment payment;
  final Student student;
}

/// Sahifalangan to'lovlar.
@JsonSerializable()
class PagedPayments {
  const PagedPayments({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PagedPayments.fromJson(Map<String, dynamic> json) =>
      _$PagedPaymentsFromJson(json);

  Map<String, dynamic> toJson() => _$PagedPaymentsToJson(this);

  final List<Payment> items;
  final int total;
  final int page;
  final int limit;

  bool get hasMore => page * limit < total;
}

/// Tarif shabloni.
@JsonSerializable()
class TariffTemplate {
  const TariffTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.isActive,
    this.sessionsCount,
  });

  factory TariffTemplate.fromJson(Map<String, dynamic> json) =>
      _$TariffTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$TariffTemplateToJson(this);

  final String id;
  final String name;
  final TariffType type;
  final int price;

  /// Faqat `package` uchun.
  @JsonKey(name: 'sessions_count')
  final int? sessionsCount;

  @JsonKey(name: 'is_active')
  final bool isActive;
}

/// `POST /tariffs` tanasi.
@JsonSerializable(createFactory: false, includeIfNull: false)
class TariffCreate {
  const TariffCreate({
    required this.name,
    required this.type,
    required this.price,
    this.sessionsCount,
  });

  final String name;
  final TariffType type;
  final int price;

  @JsonKey(name: 'sessions_count')
  final int? sessionsCount;

  Map<String, dynamic> toJson() => _$TariffCreateToJson(this);
}

/// `PATCH /tariffs/{id}` tanasi. `type` va `sessions_count` O'ZGARTIRILMAYDI.
@JsonSerializable(createFactory: false, includeIfNull: false)
class TariffUpdate {
  const TariffUpdate({this.name, this.price, this.isActive});

  final String? name;
  final int? price;

  @JsonKey(name: 'is_active')
  final bool? isActive;

  Map<String, dynamic> toJson() => _$TariffUpdateToJson(this);
}

/// `GET /tariffs` javobi — sahifalanmagan.
@JsonSerializable()
class TariffList {
  const TariffList({required this.items});

  factory TariffList.fromJson(Map<String, dynamic> json) =>
      _$TariffListFromJson(json);

  Map<String, dynamic> toJson() => _$TariffListToJson(this);

  final List<TariffTemplate> items;
}
