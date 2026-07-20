/// Kontrakt enumlari — `docs/openapi.yaml` dan 1:1.
///
/// Har enumda `unknown` YO'Q: server kontraktda bo'lmagan qiymat yuborsa
/// parse xatosi bo'lishi KERAK — jimgina noto'g'ri holatga tushib qolgandan
/// ko'ra darhol ko'rinadigan xato afzal (pul va qarz holatlari shu enumlarga
/// bog'liq).
library;

import 'package:json_annotation/json_annotation.dart';

/// `uz` | `ru`.
enum Lang {
  @JsonValue('uz')
  uz,
  @JsonValue('ru')
  ru;

  String get code => name;
}

/// `trainer` | `merchant` | `admin`.
enum UserRole {
  @JsonValue('trainer')
  trainer,
  @JsonValue('merchant')
  merchant,
  @JsonValue('admin')
  admin,
}

/// `free` | `pro`. MVP da faqat `free` (obuna sotib olish endpoint'i yo'q).
enum Plan {
  @JsonValue('free')
  free,
  @JsonValue('pro')
  pro,
}

/// `monthly` | `package` | `single`.
enum TariffType {
  /// Oylik obuna — `next_due_date` bor.
  @JsonValue('monthly')
  monthly,

  /// Paket — `sessions_total` bor, `next_due_date` YO'Q.
  @JsonValue('package')
  package,

  /// Bir martalik — sana ham, paket ham yo'q.
  @JsonValue('single')
  single,
}

/// `active` | `archived`. Hech narsa DELETE qilinmaydi.
enum StudentStatus {
  @JsonValue('active')
  active,
  @JsonValue('archived')
  archived,
}

/// Hisoblanadigan holat — DB'da saqlanmaydi, server qaytaradi.
enum PaymentState {
  @JsonValue('paid')
  paid,
  @JsonValue('due_soon')
  dueSoon,
  @JsonValue('due_today')
  dueToday,
  @JsonValue('overdue')
  overdue,
  @JsonValue('none')
  none,
}

/// To'lov usuli — FAQAT qayd etish uchun. Online to'lov MVP da yo'q.
enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('payme')
  payme,
  @JsonValue('click')
  click;

  String get code => switch (this) {
    PaymentMethod.cash => 'cash',
    PaymentMethod.card => 'card',
    PaymentMethod.payme => 'payme',
    PaymentMethod.click => 'click',
  };
}

/// `queued` | `sent` | `failed`.
enum NotificationStatus {
  @JsonValue('queued')
  queued,
  @JsonValue('sent')
  sent,
  @JsonValue('failed')
  failed,
}

/// Shogird ro'yxati filtri (`GET /students?filter=`).
enum StudentFilter {
  @JsonValue('all')
  all,
  @JsonValue('debtors')
  debtors,
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('active')
  active,
  @JsonValue('archived')
  archived;

  String get query => switch (this) {
    StudentFilter.all => 'all',
    StudentFilter.debtors => 'debtors',
    StudentFilter.upcoming => 'upcoming',
    StudentFilter.active => 'active',
    StudentFilter.archived => 'archived',
  };
}

/// Eslatma shablonlari (`POST /students/{id}/remind`).
enum RemindTemplate {
  @JsonValue('payment_due_manual')
  paymentDue,
  @JsonValue('payment_overdue_manual')
  paymentOverdue,
  @JsonValue('sessions_low_manual')
  sessionsLow,
}
