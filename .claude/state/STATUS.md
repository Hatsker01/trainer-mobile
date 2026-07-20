# STATUS — mobile (USTOZ trener ilovasi)

Oqim: **mobile** · Repo: `trainer-mobile` · Versiya: 0.1.0+1

Belgilar: `[ ]` boshlanmagan · `[~]` ishlanmoqda · `[x]` tugallangan · `[!]` bloklangan

---

## Vazifalar (T0–T9)

| # | Vazifa | Holat | Izoh |
|---|---|---|---|
| T0 | Loyiha poydevori | `[x]` | Flutter loyiha, paket siyosati, fontlar, analysis_options, Env, splash |
| T1 | Design system (HTML'dan 1:1) | `[x]` | Tokenlar + 16 komponent + galereya. 22 test yashil, analyze toza |
| T2 | API qatlam + auth infra | `[x]` | DTO 1:1, Dio+interceptorlar, refresh single-flight |
| T3 | Auth + onboarding ekranlari | `[x]` | onboarding, telefon/OTP, profil, router redirect |
| T4 | Dashboard (S4) | `[x]` | hero ring, bugungi to'lov, skeleton, SWR kesh |
| T5 | Shogirdlar moduli (S5/S6/S7) | `[x]` | ro'yxat (debounce/scroll), profil, qo'shish+invite |
| T6 | To'lov + davomad sheetlari (S8/S9) | `[x]` | Idempotency+double-tap, davomad bulk |
| T7 | Statistika + sozlamalar (S10/S11) | `[x]` | KPI+grafik, til/tarif CRUD/remind_time |
| T8 | Offline-tolerantlik | `[x]` | SWR kesh + davomad outbox + offline banner |
| T9 | Sifat, testlar, release | `[x]` | APK arm64 18.4MB<20, 97 test, adaptivlik matritsasi |

---

## BLOKERLAR

| # | Bloker | Ta'sir | Kim hal qiladi |
|---|---|---|---|
| B1 | ~~Flutter SDK yo'q edi~~ | — | **HAL QILINDI** — `~/flutter` (3.44.6 stable, Dart 3.12.2), D101 |
| B2 | **Xcode yo'q** (faqat Command Line Tools) | iOS RELEASE build tasdiqlanmagan (Dart/engine qismi kompilyatsiya bo'ldi, Xcode app build qismi qoldi) | **Foydalanuvchi** — App Store'dan Xcode (~15GB). Kod tayyor |
| B3 | ~~JDK + Android SDK yo'q~~ | — | **HAL QILINDI** — Homebrew OpenJDK 17 + android-commandlinetools (SDK 36). APK muvaffaqiyatli qurildi |
| B4 | **`POST /payments/preview` backendda YO'Q** | T6: to'lov sheetidagi "Keyingi to'lov: X" | **YECHIM O'ZGARDI:** `PaymentCreated.student.next_due_date` serverdan kelgani uchun preview to'lovni saqlagach ko'rsatiladi (toast). Alohida endpoint SHART EMAS — D102 ni ko'r |

---

## Cross-stream so'rovlar (mobile → backend)

| # | So'rov | Holat |
|---|---|---|
| X1 | `POST /payments/preview` — to'lovni saqlamasdan `next_due_date` ni hisoblab qaytarish. Sabab: sana hisoblash mantig'i client'da takrorlanmasligi kerak (yagona haqiqat manbai — backend). | `[ ]` yuborilmagan |

---

## Keyingi sessiya nimadan boshlaydi

**T2 — API qatlami + auth infra.**

1. `PATH` ga SDK: `export PATH="$HOME/flutter/bin:$PATH"` (yoki `~/.zshrc` ga).
2. DTO'lar (`json_serializable`) — openapi sxemalaridan 1:1. Diqqat:
   `Money` = `int`, `format: date` va `format: date-time` FARQLI parse,
   `change_percent` — yagona `double?`.
3. Dio client + interceptorlar: auth (401 → bitta refresh, parallel
   so'rovlar uchun `Completer` qulfi), xato → `AppException` mapping.
4. Testlar: refresh oqimi (mock adapter), xato mapping jadval-testi.
</content>
