# STATUS — mobile (USTOZ trener ilovasi)

Oqim: **mobile** · Repo: `trainer-mobile` · Versiya: 0.1.0+1

Belgilar: `[ ]` boshlanmagan · `[~]` ishlanmoqda · `[x]` tugallangan · `[!]` bloklangan

---

## Vazifalar (T0–T9)

| # | Vazifa | Holat | Izoh |
|---|---|---|---|
| T0 | Loyiha poydevori | `[x]` | Flutter loyiha, paket siyosati, fontlar, analysis_options, Env, splash |
| T1 | Design system (HTML'dan 1:1) | `[x]` | Tokenlar + 16 komponent + galereya. 22 test yashil, analyze toza |
| T2 | API qatlam + auth infra | `[ ]` | DTO, Dio client, interceptorlar, secure storage, repozitoriylar |
| T3 | Auth + onboarding ekranlari | `[ ]` | Onboarding, telefon, OTP, profil sozlash |
| T4 | Dashboard (S4) | `[ ]` | Hero ring, bugungi to'lovlar, jadval, 3 kun ichida |
| T5 | Shogirdlar moduli (S5/S6/S7) | `[ ]` | Ro'yxat, profil, qo'shish |
| T6 | To'lov + davomad sheetlari (S8/S9) | `[ ]` | Pul nuqtasi — maksimal ehtiyot |
| T7 | Statistika + sozlamalar (S10/S11) | `[ ]` | KPI, grafik, til, tariflar CRUD |
| T8 | Offline-tolerantlik | `[ ]` | Kesh (SWR) + davomad outbox |
| T9 | Sifat, testlar, release | `[ ]` | Adaptivlik, performance, testlar, APK |

---

## BLOKERLAR

| # | Bloker | Ta'sir | Kim hal qiladi |
|---|---|---|---|
| B1 | ~~Flutter SDK yo'q edi~~ | — | **HAL QILINDI** — `~/flutter` (3.44.6 stable, Dart 3.12.2), D101 |
| B2 | **Xcode yo'q** (faqat Command Line Tools) | iOS build (T0 DoD, T9 DoD) MUMKIN EMAS | **Foydalanuvchi** — App Store'dan Xcode (~15GB) |
| B3 | **JDK + Android SDK yo'q** | Android APK release build (T9 DoD) mumkin emas | Hal qilinadi: `brew install --cask temurin` + cmdline-tools |
| B4 | **`POST /payments/preview` backendda YO'Q** | T6: "Keyingi to'lov: X" preview serverdan olinishi kerak | mobile → backend (BACKEND KAMCHILIGI protokoli, D102) |

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
