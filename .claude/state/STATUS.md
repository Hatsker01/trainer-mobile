# STATUS — mobile (USTOZ trener ilovasi)

Oqim: **mobile** · Repo: `trainer-mobile` · Versiya: 0.1.0+1

Belgilar: `[ ]` boshlanmagan · `[~]` ishlanmoqda · `[x]` tugallangan · `[!]` bloklangan

---

## AKTIV: REAL-QURILMA FIX (G1–G7) — sessiya: fix-1 (2026-07-21)

Foydalanuvchi real telefonda sinab uch muammo topdi: (A) hamma narsa HADDAN KATTA
(zichlik yo'q), (B) kalendar ishlamayapti + to'lov holatlari kerak, (C) motivatsiya yo'q.
So'ralgan: **G1, G2, G3, G5, G6** (+G4 dan faqat maqsad ringi G2 hero uchun).

| # | Vazifa | Holat | Izoh |
|---|---|---|---|
| G1 | Zichlik + tipografiya (token darajasi) + pul util test | `[x]` | dense tokenlar (screenEdge16/cardPadDense14/sectionGapDense18), `money20/15`, `MoneyText` (so'm ~57% suffiks), stale `money_test` mln'ga fix (edi RED) |
| G2 | Dashboard qayta kompozitsiya (zich, hero+ring, BUGUN, tezkor 3, faoliyat) | `[x]` | screenshot: `screenshots/density/dashboard.png`. 1-4 bo'lim 393×852 scroll'siz (test) |
| G3 | Kalendar fix + to'lov holatlari + BACKEND `/calendar` | `[x]` | kun rangi (3 rang+today), kun sheet+qoldiq-prefill, oy xulosasi. screenshot: `calendar.png`. Backend D057 |
| G4 | (talab qilinmagan) — maqsad ringi + goal-set + yig'im% + milestone | `[x]*` | ring+goal-set+yig'im% qurildi. Milestone toast OLIB TASHLANDI (test-fragil, D213). streak/digest QURILMADI (D213) |
| G5 | Chuqur dizayn-audit (DESIGN_AUDIT3.md) + `grep ","` = 0 | `[x]` | `DESIGN_AUDIT3.md`. settings `50,000`→`Money.format` [FIXED]. Vergulli pul 0 ta |
| G6 | Yakuniy tekshiruv: analyze+test yashil, screenshot, hisobot | `[x]` | `flutter analyze` 0; `flutter test` 120/120 (+2 capture); 360/393/430 × 1.0/1.3 overflow 0; screenshotlar |

**BACKEND TOUCHED (fix-1, sub-agent):** `/calendar` endpoint (D057), qisman-to'lov `next_due_date` bug FIX (D058), `/me` `monthly_goal` (D059), dashboard `collected/expected_this_month` (D060). `go build` ok, `go test` 237/237 (real PG), `gofmt` toza.

---

## OLD-AKTIV: REDESIGN (yangi dizayn → light/navy tizim)

Yangi dizayn manbasi: `Jamshidbek Ikromov's team library/` (Figma eksport, 42 frame).
To'liq tahlil: **`.claude/state/REDESIGN.md`**. Qarorlar: DECISIONS D201–D208.

| # | Bosqich | Holat | Izoh |
|---|---|---|---|
| R0 | Study & gap analysis (kod o'zgarmaydi) | `[x]` | sessiya: redesign-1 — REDESIGN.md yozildi (inventar, token/komponent/data-gap/flaw). Kod tegilmadi |
| R1 | Design QA — dizayn kamchiliklari (qog'ozda) | `[x]` | REDESIGN.md §6, F0–F9. Kontrast o'lchandi, auth/paywall/attendance ziddiyatlari hal qilindi |
| R3 | Tokenlar + komponent kutubxona rebuild | `[ ]` | `core/theme` light/navy ThemeExtension; komponentlar (REDESIGN §4); gallery yangilanadi. **Mac'da build/analyze kerak** |
| R4 | Backend gaplar (`trainer-back`, kontrakt-birinchi) | `[ ]` | G1–G8 (REDESIGN §5). G9 email/parol QURILMAYDI (D201). openapi→DECISIONS→migratsiya→handler→RBAC→test→seed |
| R5 | Ekran-ma-ekran migratsiya | `[ ]` | Tartib: Dashboard→Shogirdlar→Profil→To'lov→Davomad→Kalendar(yangi)→Bildirishnomalar(yangi)→Auth restyle→Sozlamalar/Obuna→Stats merge. Har ekran 4 holat + real backend |
| R6 | Run & verify (emulyator + proof) | `[ ]` | backend up + seed + emulyator + `make dev-android`; qo'lda stsenariy; perf (cold<2s, jank, APK<20MB); analyze+test yashil. **Mac talab qiladi** |
| R7 | Yakuniy hisobot | `[ ]` | R0–R7 jadval, flaw'lar, chetlanishlar, backend qo'shimchalar, skrinshot indeksi, perf, testlar |

> **MUHIM (redesign-1 topdi):** R3–R7 build/run darvozalari (`flutter analyze`, `flutter test`,
> emulyator, APK) foydalanuvchi Mac'ida bajarilishi shart. Bulutli sessiya ularni tekshira
> olmaydi (device_bash — tarmoqsiz Linux VM). Shu bois redesign-1 R0 (tahlil) bilan cheklandi
> va **hech qanday ilova kodini o'zgartirmadi** (R0 talabi). Keyingi round Mac'da (desktop app
> "On your computer" yoki lokal terminal) davom etadi. Sabab: REDESIGN.md §0.

---

## Oldingi round — MVP dizayn (T0–T9) · HAMMASI `[x]`

| # | Vazifa | Holat | Izoh |
|---|---|---|---|
| T0 | Loyiha poydevori | `[x]` | Flutter loyiha, paket siyosati, fontlar, Env, splash |
| T1 | Design system (eski HTML'dan) | `[x]` | Tokenlar + 16 komponent + galereya |
| T2 | API qatlam + auth infra | `[x]` | DTO 1:1, Dio+interceptorlar, refresh single-flight |
| T3 | Auth + onboarding | `[x]` | onboarding, telefon/OTP, profil, router redirect |
| T4 | Dashboard (S4) | `[x]` | hero ring, bugungi to'lov, skeleton, SWR |
| T5 | Shogirdlar (S5/S6/S7) | `[x]` | ro'yxat, profil, qo'shish+invite |
| T6 | To'lov + davomad sheetlari (S8/S9) | `[x]` | Idempotency, davomad bulk |
| T7 | Statistika + sozlamalar (S10/S11) | `[x]` | KPI+grafik, til/tarif CRUD |
| T8 | Offline-tolerantlik | `[x]` | SWR kesh + outbox + banner |
| T9 | Sifat, testlar, release | `[x]` | APK arm64 18.4MB, 97 test, adaptivlik |

---

## BLOKERLAR

| # | Bloker | Ta'sir | Kim hal qiladi |
|---|---|---|---|
| B2 | **Xcode yo'q** (faqat CLT) | iOS release build tasdiqlanmagan | Foydalanuvchi — App Store'dan Xcode |
| B5 | **Redesign build/run bulutdan mumkin emas** | R3–R7 Mac'da bajariladi | Foydalanuvchi — lokal/desktop "On your computer" round |

---

## Cross-stream so'rovlar (mobile → backend, redesign R4)

| # | So'rov | Holat |
|---|---|---|
| X2 | `/dashboard` aggregat + `recent_activity[]` (G1) | `[ ]` R4 |
| X3 | `GET /calendar?month=` oy aggregati + kun to'lovlari (G2) | `[ ]` R4 |
| X4 | `GET /notifications` trenerga qaratilgan + `read` (G3) | `[ ]` R4 |
| X5 | `Student.avatar_url` + `POST /students/{id}/avatar`; `Me.avatar_url` (G4) | `[ ]` R4 |
| X6 | `Student.first_name`/`last_name` (G5) | `[ ]` R4 |
| X7 | `Student.balance` (G6) | `[ ]` R4 |
| X8 | `PaymentCreate.period_month` (G7) | `[ ]` R4 |
| X9 | `GET/POST /me/subscription*` obuna+billing — **feature-flag ostida** (G8, D202) | `[ ]` R4 |

---

## Keyingi sessiya nimadan boshlaydi

**R3 — tokenlar + komponent rebuild (Mac'da).**

1. `export PATH="$HOME/flutter/bin:$PATH"` + JAVA_HOME/ANDROID_SDK_ROOT (SYSTEM §7).
2. `.claude/state/REDESIGN.md` ni o'qi — §3 token qiymatlari (navy #1A3D7C, green #2ECC71,
   qarz #E74C3C→kichik #D63C2C, amber matn #8A6D0B, bg #FDFDFD, ink #222), §4 komponentlar,
   §6 flaw tuzatishlari (kontrast, ≥44 nishon, 4 holat).
3. `core/theme` — light/navy `AppColors` ThemeExtension (dark arxitekturasini yenglashtir,
   lekin light-birinchi). `AppRadius` kamaytir (card 16, button 14, sheet 24).
4. Komponentlarni yangi tilga ko'chir; `dev/gallery.dart` yangila (vizual regressiya vositasi).
5. Har qadamda `dart format` + `flutter analyze` + `flutter test` yashil (DoD).
