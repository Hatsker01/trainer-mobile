import 'package:json_annotation/json_annotation.dart';
import 'package:ustoz_trainer/core/api/dto/converters.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';

part 'dashboard_dto.g.dart';

/// Dashboard'dagi qisqartirilgan shogird.
///
/// **`Student` DAN FARQLI** — `status`, `sessions_*`, `tariff_type`,
/// `invite_token`, `created_at` yo'q. Kontraktda alohida sxema.
@JsonSerializable()
class DashboardStudent {
  const DashboardStudent({
    required this.id,
    required this.name,
    required this.tariffPrice,
    required this.paymentState,
    this.phone,
    this.nextDueDate,
    this.daysOverdue,
    this.tgConnected,
  });

  factory DashboardStudent.fromJson(Map<String, dynamic> json) =>
      _$DashboardStudentFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStudentToJson(this);

  final String id;
  final String name;
  final String? phone;

  @JsonKey(name: 'tariff_price')
  final int tariffPrice;

  @DateOnlyNullableConverter()
  @JsonKey(name: 'next_due_date')
  final DateTime? nextDueDate;

  @JsonKey(name: 'days_overdue')
  final int? daysOverdue;

  @JsonKey(name: 'payment_state')
  final PaymentState paymentState;

  @JsonKey(name: 'tg_connected')
  final bool? tgConnected;

  bool get isDebtor => (daysOverdue ?? 0) > 0;
}

/// Dashboard summalari (ixtiyoriy blok).
@JsonSerializable()
class DashboardTotals {
  const DashboardTotals({this.dueTodayAmount, this.overdueAmount});

  factory DashboardTotals.fromJson(Map<String, dynamic> json) =>
      _$DashboardTotalsFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardTotalsToJson(this);

  @JsonKey(name: 'due_today_amount')
  final int? dueTodayAmount;

  @JsonKey(name: 'overdue_amount')
  final int? overdueAmount;
}

/// Bugungi davomad hisobi.
@JsonSerializable()
class AttendanceToday {
  const AttendanceToday({required this.markedCount});

  factory AttendanceToday.fromJson(Map<String, dynamic> json) =>
      _$AttendanceTodayFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceTodayToJson(this);

  @JsonKey(name: 'marked_count')
  final int markedCount;
}

/// `GET /dashboard` javobi.
@JsonSerializable()
class DashboardResponse {
  const DashboardResponse({
    required this.date,
    required this.greetingName,
    required this.dueToday,
    required this.dueSoon,
    required this.overdue,
    required this.attendanceToday,
    this.totals,
    this.collectedThisMonth,
    this.expectedThisMonth,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardResponseToJson(this);

  /// Bugun (Asia/Tashkent).
  @DateOnlyConverter()
  final DateTime date;

  /// Faqat ism ("Sardor").
  @JsonKey(name: 'greeting_name')
  final String greetingName;

  @JsonKey(name: 'due_today')
  final List<DashboardStudent> dueToday;

  /// 3 kun ichida to'lov kutilayotganlar.
  @JsonKey(name: 'due_soon')
  final List<DashboardStudent> dueSoon;

  final List<DashboardStudent> overdue;

  final DashboardTotals? totals;

  /// G4 (backend D060) — shu oy (Asia/Tashkent) yig'ilgan summa (so'm).
  @JsonKey(name: 'collected_this_month')
  final int? collectedThisMonth;

  /// G4 (backend D060) — shu oy kutilgan summa (faol oylik shogirdlar).
  @JsonKey(name: 'expected_this_month')
  final int? expectedThisMonth;

  @JsonKey(name: 'attendance_today')
  final AttendanceToday attendanceToday;

  /// Hamma blok bo'sh — "Bugun hammasi joyida 💪" holati (T4).
  bool get isAllClear => dueToday.isEmpty && dueSoon.isEmpty && overdue.isEmpty;
}

/// Statistika grafigidagi bitta oy.
@JsonSerializable()
class StatsSeriesPoint {
  const StatsSeriesPoint({required this.month, required this.revenue});

  factory StatsSeriesPoint.fromJson(Map<String, dynamic> json) =>
      _$StatsSeriesPointFromJson(json);

  Map<String, dynamic> toJson() => _$StatsSeriesPointToJson(this);

  /// `"YYYY-MM"` — oddiy string, `format` YO'Q.
  final String month;
  final int revenue;
}

/// Tarif kesimidagi qator.
@JsonSerializable()
class StatsByTariff {
  const StatsByTariff({
    required this.tariffType,
    required this.students,
    required this.revenue,
  });

  factory StatsByTariff.fromJson(Map<String, dynamic> json) =>
      _$StatsByTariffFromJson(json);

  Map<String, dynamic> toJson() => _$StatsByTariffToJson(this);

  @JsonKey(name: 'tariff_type')
  final TariffType tariffType;

  final int students;
  final int revenue;
}

/// `GET /stats` javobi. Parametrlari YO'Q.
@JsonSerializable()
class StatsResponse {
  const StatsResponse({
    required this.monthRevenue,
    required this.prevMonthRevenue,
    required this.activeStudents,
    required this.debtTotal,
    required this.series,
    this.changePercent,
    this.debtorsCount,
    this.byTariff,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) =>
      _$StatsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StatsResponseToJson(this);

  @JsonKey(name: 'month_revenue')
  final int monthRevenue;

  @JsonKey(name: 'prev_month_revenue')
  final int prevMonthRevenue;

  /// Butun kontraktdagi YAGONA suzuvchi nuqtali son.
  /// O'tgan oy 0 bo'lsa `null`.
  @JsonKey(name: 'change_percent')
  final double? changePercent;

  @JsonKey(name: 'active_students')
  final int activeStudents;

  @JsonKey(name: 'debtors_count')
  final int? debtorsCount;

  @JsonKey(name: 'debt_total')
  final int debtTotal;

  /// Oxirgi 6 oy, eskisidan yangisiga.
  final List<StatsSeriesPoint> series;

  @JsonKey(name: 'by_tariff')
  final List<StatsByTariff>? byTariff;
}

/// `POST /attendance/bulk` tanasi.
@JsonSerializable(createFactory: false)
class AttendanceBulkRequest {
  const AttendanceBulkRequest({required this.date, required this.studentIds});

  @DateOnlyConverter()
  final DateTime date;

  /// 1..200 ta UUID.
  @JsonKey(name: 'student_ids')
  final List<String> studentIds;

  Map<String, dynamic> toJson() => _$AttendanceBulkRequestToJson(this);
}

/// Paketi tugayotgan shogird.
@JsonSerializable()
class LowSession {
  const LowSession({required this.studentId, required this.sessionsLeft});

  factory LowSession.fromJson(Map<String, dynamic> json) =>
      _$LowSessionFromJson(json);

  Map<String, dynamic> toJson() => _$LowSessionToJson(this);

  @JsonKey(name: 'student_id')
  final String studentId;

  @JsonKey(name: 'sessions_left')
  final int sessionsLeft;
}

/// `POST /attendance/bulk` javobi.
@JsonSerializable()
class AttendanceBulkResponse {
  const AttendanceBulkResponse({
    required this.marked,
    required this.skipped,
    this.lowSessions,
  });

  factory AttendanceBulkResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceBulkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceBulkResponseToJson(this);

  /// Yangi belgilangan.
  final int marked;

  /// Allaqachon belgilangan (idempotent — `UNIQUE(student_id, date)`).
  final int skipped;

  /// 2 va undan kam mashg'uloti qolganlar.
  @JsonKey(name: 'low_sessions')
  final List<LowSession>? lowSessions;
}

/// Davomad kuni.
@JsonSerializable()
class AttendanceDay {
  const AttendanceDay({required this.date});

  factory AttendanceDay.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDayFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceDayToJson(this);

  @DateOnlyConverter()
  final DateTime date;
}

/// `GET /students/{id}/attendance` javobi — FAQAT kelgan kunlar.
@JsonSerializable()
class AttendanceList {
  const AttendanceList({required this.items});

  factory AttendanceList.fromJson(Map<String, dynamic> json) =>
      _$AttendanceListFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceListToJson(this);

  final List<AttendanceDay> items;

  /// Heatmap uchun kunlar to'plami.
  Set<DateTime> get days => items
      .map((AttendanceDay d) => DateTime(d.date.year, d.date.month, d.date.day))
      .toSet();
}
