# Prototip v3.0 → Trainer App: implementatsiya xaritasi

Manba: `USTOZ Trainer App prototip.html` (jonli Vue-template prototip) +
`trainer-prototip/` (TZ v3.0, 21 sahifa). **Oldingi MVP spec bekor** (TZ so'zi).
Pretty nusxa: `scratchpad/proto_pretty.html` (3565 satr).

## Tasdiqlangan: dizayn tizimi ALLAQACHON mos
- Ranglar: `#e5484d`/`#ff6b6b` (anor), `#171b22`, `#98a1ae`, `#1f242e`, `#262c37`,
  `#edeff3`; light `#f7f5f2`/`#f1ece6`; `#2fbf87`(ok)/`#e3a64a`(warn)/`#e23e63`(debt).
  → `app_colors.dart` (AppColors.dark/light) bilan 1:1.
- Shrift: **Unbounded** (display) + **Manrope** (body) — `app_text.dart` bilan mos.
- Tema nomlari "Kechki zal"/"Gips" — app bilan bir xil.
- Prototip CSS token↔app: `--tx`=ink, `--t2`=soft, `--t3`=dim, `--s1`=glass,
  `--s2`=glassHi, `--bd`=line, `--an2`=anor2, `--am`=warn(+`--amb`/`--ambd`=warnSoft),
  `--gr`=ok(+`--grb`/`--grbd`), `--rd`=debt(+`--rdb`/`--rdbd`).
- FARQ: prototip kartalari radius **20–22px** (app 16px); katta raqamlar Unbounded 24–32px.

## Prototip ekran xaritasi (proto_pretty.html satr raqamlari)
| Satr | Ekran | App holati |
|---|---|---|
| 951 | USTOZ splash/logo | splash_screen |
| 1039 | OTP `{{c.v}}` | otp_screen |
| 1179 | **Dashboard** (salom+streak+ovoz, Kassa svetofori, Bugun keldi, Retsept xaridlari, Churn radar, Bugungi lenta) | dashboard_screen — QAYTA KOMPOZITSIYA |
| 1455 | Shogirdlar ro'yxati | students_screen |
| 1612 | Shogird kartasi/profil (ini/next/streak/visits/pct/debt) | student_profile_screen |
| 1853 | Shogird qo'shish | student_form_screen |
| 1916 | QR skaner | YO'Q — yangi |
| 2028 | Jadval/slot | calendar_screen |
| 2089 | Slot yaratish | YO'Q — yangi |
| 2141 | Kassa | cash_screen |
| 2269 | To'lov kiritish | payment_sheet |
| 2360 | Tariflar | settings ichida? — tekshirish |
| 2397 | Muzlatish (freeze) | YO'Q — yangi |
| 2458 | Dastur builder | YO'Q — yangi (scope §9 tekshir) |
| 2506 | Mashq kutubxonasi | YO'Q — yangi |
| 2549 | Hisobotlar | stats bilan bog'liq |
| 2592 | Retsept yozish (marketplace tavsiya) | YO'Q — yangi (F2) |
| 2653 | Statistika (74% o'rtacha davomat) | stats_screen |
| 2700 | Churn radar | YO'Q — yangi (§3.9) |
| 2735 | Mini-sayt | YO'Q — yangi (§3.12, F2/F3) |
| 2782 | Menyu | settings_screen |
| 2894 | USTOZ PRO paywall (99 000 / 950 000) | YO'Q — yangi |
| 3000 | Ovozli kiritish | YO'Q — yangi (§3.11) |

## Dashboard — to'liq spetsifikatsiya (proto satr 1177–1448)
**Holatlar:** loading (skeleton grid), error ("Ma'lumot yuklanmadi"+retry),
empty ("Bugun hali reja yo'q" + 3-qadam checklist + progress "1/3"), content.

**Content kompozitsiyasi (yuqoridan pastga):**
1. Header row: "Assalomu alaykum, {ism}" (Unbounded 600/22, ls -.01em) + sana
   "27-iyul, dushanba" (Manrope 500/14 t2) · **streak pill** (amber, h38, radius999,
   alanga ikonka + "{n} kun" Manrope 700/13) · **ovoz tugmasi** (44×44 radius14, mic).
2. (opt) Offline banner (amber, radius16).
3. Grid 2-ustun gap12:
   - **Kassa svetofori** (span2, radius20): 3 plitka (h60 radius14):
     yashil "to'langan" {gr}, amber "yaqin" {am}, qizil "qarzdor" {rd}
     (raqamlar Unbounded 600/24, ikonka: check/clock/triangle) +
     footer "Qizillar: {n} so'm qarz" (Manrope 600/13.5 rd).
   - **"Bugun keldi"** (radius20): "{done}/{total}" (Unbounded 600/32) + progress bar.
   - **"Retsept xaridlari"** (radius20): "4" + "bu hafta · +2".
4. **Churn radar kartasi** (radius20, bg rdb): radar ikonka + "Ketish riski · {ism}"
   + tavsif + 2 tugma ["Xabar yuborish"(rd), "Radar"].
5. **"Bugungi lenta"** sarlavha + "← kelmadi · keldi →" swipe hint.
   Sessiya qatorlari (swipe bilan davomat): vaqt(Unbounded 16)+type | ism + (opt konflikt
   warn) + joy + status pill. Swipe o'ng=Keldi(gr), chap=Kelmadi(rd).
6. (opt) Konflikt banner (amber): "10:00 da ikki yozuv to'qnashadi…".

## Dashboard ma'lumot-gap (real ishlashi uchun)
| UI bo'lak | Real ma'lumot | Holat |
|---|---|---|
| Kassa svetofori (yaqin/qarzdor) | dueSoon.len / overdue.len | ✅ bor |
| Kassa svetofori (to'langan) | active − dueSoon − overdue − dueToday (proksi) yoki yangi `paid_count` | ⚠️ proksi yoki backend |
| "Qizillar so'm qarz" | totals.overdueAmount / debtTotal | ✅ bor |
| Bugun keldi {done}/{total} | attendanceToday.markedCount / **total YO'Q** | ⚠️ backend: `planned_count` qo'shish |
| Retsept xaridlari | — | ❌ backend (F2 marketplace) |
| Churn radar | — | ❌ backend (§3.9 algoritm) |
| Bugungi lenta (sessiyalar) | — dashboardda yo'q; calendar/sessions | ❌ backend/DTO |
| Streak "{n} kun" | — | ❌ backend (gamifikatsiya) |

→ Dashboard 1:1 = to'liq-stack: backend (planned_count, churn, streak, today-sessions)
→ DTO → UI. "real ishlashi kerak" → soxta ma'lumot YO'Q.

## Ish tartibi (har ekran = to'liq-stack vertikal bo'lak)
Backend kerak bo'lsa: `docs/openapi.yaml` → `DECISIONS.md` → kod → DTO → UI → analyze.
Task #3..#10 ga qarang. Boshlash: Dashboard backend gaplari (#10 ning dashboard qismi) → #3 UI.

## Muhim texnik holat
- `ustoz_ui` pubspec'dan olib tashlandi (ishlatilmagan edi) → `flutter pub get`/`analyze` toza.
- Build/verify: `export PATH="$HOME/development/flutter/bin:$PATH"` → `flutter analyze`.
  To'liq run uchun emulyator (`ustoz_pixel_api34`) + `--dart-define=API_URL=http://169.58.51.242/api/v1`.
- Server API: **port 80 (Caddy)**, `:8080` emas.

---

## Yangilanish 2026-07-30 (davom) — churn + streak to'liq-stack ULANDI
- Backend: `AssessChurn` (churn.go) + `BuildChurnCards` → `GET /stats.churn[]` (D064);
  `activityStreakDays` (streak.go) → `GET /dashboard.streak_days`. Testlar bilan.
- Mobil: StatsResponse.churn, DashboardResponse.streak_days DTO (codegen);
  dashboard churn kartasi + streak pili + statistika churn bo'limi. Hammasi REAL.
- Commitlar: backend `600bac6`,`294013f`,`43bbb81`; mobil `f4a0812`,`d9cc720`.

## Dashboard holati: ~1:1 (faqat "Bugungi lenta" qoldi)
Header+streak · Kassa svetofori · stat kartalar (Bugun keldi/Faol shogird) ·
churn kartasi · BUGUN · tezkor amallar — HAMMASI real. "Bugungi lenta" (vaqtli
sessiyalar, swipe-davomat) session-schedule quyi-tizimini kutadi (pastda).

## Keyingi katta bosqich — SESSION-SCHEDULE quyi-tizimi (yangi)
Kerak: migratsiya (`training_sessions`: trainer_id, student_id|group, starts_at,
duration_min, type, recurrence_rule, status) → CRUD service/repo/handler →
recurrence kengaytirish → `GET /sessions?date=` → openapi+DECISIONS → mobil
sessions provider/DTO → dashboard "Bugungi lenta" (swipe davomat) + kalendar
slot yaratish + konflikt aniqlash. DIQQAT: DB migratsiyasi bu yerda ishga
tushirilmaydi (DB yo'q) — ehtiyotkorlik bilan, ehtimol serverda sinaladi.
