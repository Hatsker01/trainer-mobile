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

Map<String, dynamic> _$DashboardStudentToJson(DashboardStudent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'tariff_price': instance.tariffPrice,
      'next_due_date': const DateOnlyNullableConverter().toJson(
        instance.nextDueDate,
      ),
      'days_overdue': instance.daysOverdue,
      'payment_state': _$PaymentStateEnumMap[instance.paymentState]!,
      'tg_connected': instance.tgConnected,
    };

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

Map<String, dynamic> _$DashboardTotalsToJson(DashboardTotals instance) =>
    <String, dynamic>{
      'due_today_amount': instance.dueTodayAmount,
      'overdue_amount': instance.overdueAmount,
    };

AttendanceToday _$AttendanceTodayFromJson(Map<String, dynamic> json) =>
    AttendanceToday(markedCount: (json['marked_count'] as num).toInt());

Map<String, dynamic> _$AttendanceTodayToJson(AttendanceToday instance) =>
    <String, dynamic>{'marked_count': instance.markedCount};

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
      collectedThisMonth: (json['collected_this_month'] as num?)?.toInt(),
      expectedThisMonth: (json['expected_this_month'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DashboardResponseToJson(DashboardResponse instance) =>
    <String, dynamic>{
      'date': const DateOnlyConverter().toJson(instance.date),
      'greeting_name': instance.greetingName,
      'due_today': instance.dueToday,
      'due_soon': instance.dueSoon,
      'overdue': instance.overdue,
      'totals': instance.totals,
      'collected_this_month': instance.collectedThisMonth,
      'expected_this_month': instance.expectedThisMonth,
      'attendance_today': instance.attendanceToday,
    };

StatsSeriesPoint _$StatsSeriesPointFromJson(Map<String, dynamic> json) =>
    StatsSeriesPoint(
      month: json['month'] as String,
      revenue: (json['revenue'] as num).toInt(),
    );

Map<String, dynamic> _$StatsSeriesPointToJson(StatsSeriesPoint instance) =>
    <String, dynamic>{'month': instance.month, 'revenue': instance.revenue};

StatsByTariff _$StatsByTariffFromJson(Map<String, dynamic> json) =>
    StatsByTariff(
      tariffType: $enumDecode(_$TariffTypeEnumMap, json['tariff_type']),
      students: (json['students'] as num).toInt(),
      revenue: (json['revenue'] as num).toInt(),
    );

Map<String, dynamic> _$StatsByTariffToJson(StatsByTariff instance) =>
    <String, dynamic>{
      'tariff_type': _$TariffTypeEnumMap[instance.tariffType]!,
      'students': instance.students,
      'revenue': instance.revenue,
    };

const _$TariffTypeEnumMap = {
  TariffType.monthly: 'monthly',
  TariffType.package: 'package',
  TariffType.single: 'single',
};

ChurnCard _$ChurnCardFromJson(Map<String, dynamic> json) => ChurnCard(
  studentId: json['student_id'] as String,
  name: json['name'] as String,
  reason: json['reason'] as String,
);

Map<String, dynamic> _$ChurnCardToJson(ChurnCard instance) => <String, dynamic>{
  'student_id': instance.studentId,
  'name': instance.name,
  'reason': instance.reason,
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
      churn: (json['churn'] as List<dynamic>?)
          ?.map((e) => ChurnCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StatsResponseToJson(StatsResponse instance) =>
    <String, dynamic>{
      'month_revenue': instance.monthRevenue,
      'prev_month_revenue': instance.prevMonthRevenue,
      'change_percent': instance.changePercent,
      'active_students': instance.activeStudents,
      'debtors_count': instance.debtorsCount,
      'debt_total': instance.debtTotal,
      'series': instance.series,
      'by_tariff': instance.byTariff,
      'churn': instance.churn,
    };

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

Map<String, dynamic> _$LowSessionToJson(LowSession instance) =>
    <String, dynamic>{
      'student_id': instance.studentId,
      'sessions_left': instance.sessionsLeft,
    };

AttendanceBulkResponse _$AttendanceBulkResponseFromJson(
  Map<String, dynamic> json,
) => AttendanceBulkResponse(
  marked: (json['marked'] as num).toInt(),
  skipped: (json['skipped'] as num).toInt(),
  lowSessions: (json['low_sessions'] as List<dynamic>?)
      ?.map((e) => LowSession.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AttendanceBulkResponseToJson(
  AttendanceBulkResponse instance,
) => <String, dynamic>{
  'marked': instance.marked,
  'skipped': instance.skipped,
  'low_sessions': instance.lowSessions,
};

AttendanceDay _$AttendanceDayFromJson(Map<String, dynamic> json) =>
    AttendanceDay(
      date: const DateOnlyConverter().fromJson(json['date'] as String),
    );

Map<String, dynamic> _$AttendanceDayToJson(AttendanceDay instance) =>
    <String, dynamic>{'date': const DateOnlyConverter().toJson(instance.date)};

AttendanceList _$AttendanceListFromJson(Map<String, dynamic> json) =>
    AttendanceList(
      items: (json['items'] as List<dynamic>)
          .map((e) => AttendanceDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AttendanceListToJson(AttendanceList instance) =>
    <String, dynamic>{'items': instance.items};
