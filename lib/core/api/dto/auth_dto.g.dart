// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$OtpRequestToJson(OtpRequest instance) =>
    <String, dynamic>{'phone': instance.phone};

OtpRequestResponse _$OtpRequestResponseFromJson(Map<String, dynamic> json) =>
    OtpRequestResponse(
      channel: $enumDecode(_$OtpChannelEnumMap, json['channel']),
      expiresIn: (json['expires_in'] as num).toInt(),
      retryAfter: (json['retry_after'] as num?)?.toInt(),
    );

const _$OtpChannelEnumMap = {OtpChannel.tg: 'tg', OtpChannel.sms: 'sms'};

Map<String, dynamic> _$OtpVerifyRequestToJson(OtpVerifyRequest instance) =>
    <String, dynamic>{'phone': instance.phone, 'code': instance.code};

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) =>
    <String, dynamic>{'refresh': instance.refresh};

TokenPair _$TokenPairFromJson(Map<String, dynamic> json) => TokenPair(
  access: json['access'] as String,
  refresh: json['refresh'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
  isNewUser: json['is_new_user'] as bool?,
);

TgLink _$TgLinkFromJson(Map<String, dynamic> json) =>
    TgLink(link: json['link'] as String, token: json['token'] as String);

Me _$MeFromJson(Map<String, dynamic> json) => Me(
  id: json['id'] as String,
  phone: json['phone'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  name: json['name'] as String,
  lang: $enumDecode(_$LangEnumMap, json['lang']),
  plan: $enumDecode(_$PlanEnumMap, json['plan']),
  tgConnected: json['tg_connected'] as bool,
  createdAt: const UtcDateTimeConverter().fromJson(
    json['created_at'] as String,
  ),
  gymName: json['gym_name'] as String?,
  remindTime: json['remind_time'] as String?,
  planUntil: const DateOnlyNullableConverter().fromJson(
    json['plan_until'] as String?,
  ),
);

const _$UserRoleEnumMap = {
  UserRole.trainer: 'trainer',
  UserRole.merchant: 'merchant',
  UserRole.admin: 'admin',
};

const _$LangEnumMap = {Lang.uz: 'uz', Lang.ru: 'ru'};

const _$PlanEnumMap = {Plan.free: 'free', Plan.pro: 'pro'};

Map<String, dynamic> _$MeUpdateToJson(MeUpdate instance) => <String, dynamic>{
  'name': ?instance.name,
  'gym_name': ?instance.gymName,
  'lang': ?_$LangEnumMap[instance.lang],
  'remind_time': ?instance.remindTime,
};
