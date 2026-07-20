// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  tariffType: $enumDecode(_$TariffTypeEnumMap, json['tariff_type']),
  tariffPrice: (json['tariff_price'] as num).toInt(),
  sessionsUsed: (json['sessions_used'] as num).toInt(),
  status: $enumDecode(_$StudentStatusEnumMap, json['status']),
  paymentState: $enumDecode(_$PaymentStateEnumMap, json['payment_state']),
  tgConnected: json['tg_connected'] as bool,
  createdAt: const UtcDateTimeConverter().fromJson(
    json['created_at'] as String,
  ),
  sessionsTotal: (json['sessions_total'] as num?)?.toInt(),
  nextDueDate: const DateOnlyNullableConverter().fromJson(
    json['next_due_date'] as String?,
  ),
  daysOverdue: (json['days_overdue'] as num?)?.toInt(),
  inviteToken: json['invite_token'] as String?,
);

const _$TariffTypeEnumMap = {
  TariffType.monthly: 'monthly',
  TariffType.package: 'package',
  TariffType.single: 'single',
};

const _$StudentStatusEnumMap = {
  StudentStatus.active: 'active',
  StudentStatus.archived: 'archived',
};

const _$PaymentStateEnumMap = {
  PaymentState.paid: 'paid',
  PaymentState.dueSoon: 'due_soon',
  PaymentState.dueToday: 'due_today',
  PaymentState.overdue: 'overdue',
  PaymentState.none: 'none',
};

Map<String, dynamic> _$StudentCreateToJson(
  StudentCreate instance,
) => <String, dynamic>{
  'name': instance.name,
  'phone': instance.phone,
  'tariff_type': _$TariffTypeEnumMap[instance.tariffType]!,
  'tariff_price': instance.tariffPrice,
  'sessions_total': ?instance.sessionsTotal,
  'start_date': ?const DateOnlyNullableConverter().toJson(instance.startDate),
};

Map<String, dynamic> _$StudentUpdateToJson(StudentUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'phone': ?instance.phone,
      'tariff_type': ?_$TariffTypeEnumMap[instance.tariffType],
      'tariff_price': ?instance.tariffPrice,
      'sessions_total': ?instance.sessionsTotal,
      'next_due_date': ?const DateOnlyNullableConverter().toJson(
        instance.nextDueDate,
      ),
    };

PagedStudents _$PagedStudentsFromJson(Map<String, dynamic> json) =>
    PagedStudents(
      items: (json['items'] as List<dynamic>)
          .map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$RemindRequestToJson(RemindRequest instance) =>
    <String, dynamic>{
      'template_key': ?_$RemindTemplateEnumMap[instance.templateKey],
      'lang': ?_$LangEnumMap[instance.lang],
    };

const _$RemindTemplateEnumMap = {
  RemindTemplate.paymentDue: 'payment_due_manual',
  RemindTemplate.paymentOverdue: 'payment_overdue_manual',
  RemindTemplate.sessionsLow: 'sessions_low_manual',
};

const _$LangEnumMap = {Lang.uz: 'uz', Lang.ru: 'ru'};

RemindResponse _$RemindResponseFromJson(Map<String, dynamic> json) =>
    RemindResponse(
      notificationId: json['notification_id'] as String,
      status: $enumDecode(_$NotificationStatusEnumMap, json['status']),
      warning: json['warning'] as String?,
    );

const _$NotificationStatusEnumMap = {
  NotificationStatus.queued: 'queued',
  NotificationStatus.sent: 'sent',
  NotificationStatus.failed: 'failed',
};
