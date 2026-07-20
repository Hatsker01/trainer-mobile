// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStudent _$DashboardStudentFromJson(Map<String, dynamic> json) =>
    DashboardStudent(
      id: json['id'] as String,
      name: json['name'] as String,
      tariffPrice: (json['tariff_price'] as num).toInt(),
      paymentState: $enumDecode(_$PaymentStateEnumMap, json['payment_state']),
      phone: json['phone'] as String?,
      nextDueDate: const DateOnlyNullableConverter().fromJson(
        json['next_due_date'] as String?,
      ),
      daysOverdue: (json['days_overdue'] as num?)?.toInt(),
      tgConnected: json['tg_connected'] as bool?,
    );

const _$PaymentStateEnumMap = {
  PaymentState.paid: 'paid',
  PaymentState.dueSoon: 'due_soon',
  PaymentState.dueToday: 'due_today',
  PaymentState.overdue: 'overdue',
  PaymentState.none: 'none',
};

DashboardTotals _$DashboardTotalsFromJson(Map<String, dynamic> json) =>
    DashboardTotals(
      dueTodayAmount: (json['due_today_amount'] as num?)?.toInt(),
      overdueAmount: (json['overdue_amount'] as num?)?.toInt(),
    );

AttendanceToday _$AttendanceTodayFromJson(Map<String, dynamic> json) =>
    AttendanceToday(markedCount: (json['marked_count'] as num).toInt());

DashboardResponse _$DashboardResponseFromJson(Map<String, dynamic> json) =>
    DashboardResponse(
      date: const DateOnlyConverter().fromJson(json['date'] as String),
      greetingName: json['greeting_name'] as String,
      dueToday: (json['due_today'] as List<dynamic>)
          .map((e) => DashboardStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
      dueSoon: (json['due_soon'] as List<dynamic>)
          .map((e) => DashboardStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
      overdue: (json['overdue'] as List<dynamic>)
          .map((e) => DashboardStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
      attendanceToday: AttendanceToday.fromJson(
        json['attendance_today'] as Map<String, dynamic>,
      ),
      totals: json['totals'] == null
          ? null
          : DashboardTotals.fromJson(json['totals'] as Map<String, dynamic>),
    );

StatsSeriesPoint _$StatsSeriesPointFromJson(Map<String, dynamic> json) =>
    StatsSeriesPoint(
      month: json['month'] as String,
      revenue: (json['revenue'] as num).toInt(),
    );

StatsByTariff _$StatsByTariffFromJson(Map<String, dynamic> json) =>
    StatsByTariff(
      tariffType: $enumDecode(_$TariffTypeEnumMap, json['tariff_type']),
      students: (json['students'] as num).toInt(),
      revenue: (json['revenue'] as num).toInt(),
    );

const _$TariffTypeEnumMap = {
  TariffType.monthly: 'monthly',
  TariffType.package: 'package',
  TariffType.single: 'single',
};

StatsResponse _$StatsResponseFromJson(Map<String, dynamic> json) =>
    StatsResponse(
      monthRevenue: (json['month_revenue'] as num).toInt(),
      prevMonthRevenue: (json['prev_month_revenue'] as num).toInt(),
      activeStudents: (json['active_students'] as num).toInt(),
      debtTotal: (json['debt_total'] as num).toInt(),
      series: (json['series'] as List<dynamic>)
          .map((e) => StatsSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      changePercent: (json['change_percent'] as num?)?.toDouble(),
      debtorsCount: (json['debtors_count'] as num?)?.toInt(),
      byTariff: (json['by_tariff'] as List<dynamic>?)
          ?.map((e) => StatsByTariff.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AttendanceBulkRequestToJson(
  AttendanceBulkRequest instance,
) => <String, dynamic>{
  'date': const DateOnlyConverter().toJson(instance.date),
  'student_ids': instance.studentIds,
};

LowSession _$LowSessionFromJson(Map<String, dynamic> json) => LowSession(
  studentId: json['student_id'] as String,
  sessionsLeft: (json['sessions_left'] as num).toInt(),
);

AttendanceBulkResponse _$AttendanceBulkResponseFromJson(
  Map<String, dynamic> json,
) => AttendanceBulkResponse(
  marked: (json['marked'] as num).toInt(),
  skipped: (json['skipped'] as num).toInt(),
  lowSessions: (json['low_sessions'] as List<dynamic>?)
      ?.map((e) => LowSession.fromJson(e as Map<String, dynamic>))
      .toList(),
);

AttendanceDay _$AttendanceDayFromJson(Map<String, dynamic> json) =>
    AttendanceDay(
      date: const DateOnlyConverter().fromJson(json['date'] as String),
    );

AttendanceList _$AttendanceListFromJson(Map<String, dynamic> json) =>
    AttendanceList(
      items: (json['items'] as List<dynamic>)
          .map((e) => AttendanceDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
