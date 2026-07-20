// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  studentId: json['student_id'] as String,
  amount: (json['amount'] as num).toInt(),
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  paidAt: const DateOnlyConverter().fromJson(json['paid_at'] as String),
  createdAt: const UtcDateTimeConverter().fromJson(
    json['created_at'] as String,
  ),
  periodFrom: const DateOnlyNullableConverter().fromJson(
    json['period_from'] as String?,
  ),
  periodTo: const DateOnlyNullableConverter().fromJson(
    json['period_to'] as String?,
  ),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'amount': instance.amount,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'paid_at': const DateOnlyConverter().toJson(instance.paidAt),
  'period_from': const DateOnlyNullableConverter().toJson(instance.periodFrom),
  'period_to': const DateOnlyNullableConverter().toJson(instance.periodTo),
  'created_at': const UtcDateTimeConverter().toJson(instance.createdAt),
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.payme: 'payme',
  PaymentMethod.click: 'click',
};

Map<String, dynamic> _$PaymentCreateToJson(PaymentCreate instance) =>
    <String, dynamic>{
      'student_id': instance.studentId,
      'amount': instance.amount,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'paid_at': ?const DateOnlyNullableConverter().toJson(instance.paidAt),
      'sessions_added': ?instance.sessionsAdded,
    };

PaymentCreated _$PaymentCreatedFromJson(Map<String, dynamic> json) =>
    PaymentCreated(
      payment: Payment.fromJson(json['payment'] as Map<String, dynamic>),
      student: Student.fromJson(json['student'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaymentCreatedToJson(PaymentCreated instance) =>
    <String, dynamic>{'payment': instance.payment, 'student': instance.student};

PagedPayments _$PagedPaymentsFromJson(Map<String, dynamic> json) =>
    PagedPayments(
      items: (json['items'] as List<dynamic>)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$PagedPaymentsToJson(PagedPayments instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };

TariffTemplate _$TariffTemplateFromJson(Map<String, dynamic> json) =>
    TariffTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$TariffTypeEnumMap, json['type']),
      price: (json['price'] as num).toInt(),
      isActive: json['is_active'] as bool,
      sessionsCount: (json['sessions_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TariffTemplateToJson(TariffTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$TariffTypeEnumMap[instance.type]!,
      'price': instance.price,
      'sessions_count': instance.sessionsCount,
      'is_active': instance.isActive,
    };

const _$TariffTypeEnumMap = {
  TariffType.monthly: 'monthly',
  TariffType.package: 'package',
  TariffType.single: 'single',
};

Map<String, dynamic> _$TariffCreateToJson(TariffCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$TariffTypeEnumMap[instance.type]!,
      'price': instance.price,
      'sessions_count': ?instance.sessionsCount,
    };

Map<String, dynamic> _$TariffUpdateToJson(TariffUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'price': ?instance.price,
      'is_active': ?instance.isActive,
    };

TariffList _$TariffListFromJson(Map<String, dynamic> json) => TariffList(
  items: (json['items'] as List<dynamic>)
      .map((e) => TariffTemplate.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TariffListToJson(TariffList instance) =>
    <String, dynamic>{'items': instance.items};
