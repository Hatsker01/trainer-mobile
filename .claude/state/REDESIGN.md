# REDESIGN — R0 study & gap analysis (new design → current app)

> Sessiya: **redesign-1** · Sana: 2026-07-21 · Bosqich: **R0 (tahlil — kod O'ZGARMAYDI)**
> Yangi dizayn manbasi: `Jamshidbek Ikromov's team library/` (42 PNG frame, Figma eksport,
> 2026-07-21 qo'shilgan). Avvalgi etalon `design/ustoz-v2.1-tavsiyalar.html` — endi TARIXIY.
> Mahsulot haqiqat manbasi: `docs/ustoz-mvp-spec.md` + `docs/openapi.yaml` (kontrakt).

---

## 0. Muhim: bu sessiya nega faqat R0

Bu redesign sessiyasi **bulutli sandbox**da ishlaydi; foydalanuvchi Mac'iga faqat fayl
ko'prigi (stage/commit) orqali ulanadi. Bulutdan `flutter run`, Android emulyator,
`go`/backend, APK build **ishga tushirib bo'lmaydi** (device_bash — tarmoqsiz Linux VM,
Mac'ning native toolchain'i emas). Oldingi sessiyalar Mac'da lokal ishlagan (`~/flutter`,
Android SDK lokal). Shu sabab:

- **R0 (tahlil, kod o'zgarmaydi)** — to'liq bajarildi (bu hujjat + STATUS reja). Protokol
  bo'yicha aynan birinchi ochiq vazifa shu.
- **R2–R7 (token/komponent/ekran qurish, backend, emulyatorda run + skrinshot + trace)** —
  build/run darvozalari (`flutter analyze`, `flutter test`, emulyator) Mac'da bajarilishi
  shart. Ularni tekshirilmasdan commit qilish protokol sifat darvozasini buzadi va "o'lik kod"
  qoldiradi. Shu bois bu sessiya **hech qanday ilova kodini o'zgartirmaydi** (R0 talabi:
  "change nothing yet") — implementatsiya keyingi, Mac'dagi rounddga to'liq rejalashtirilgan.

---

## 1. Yangi yo'nalishning bir qatorli xulosasi

Yangi dizayn — **yorug' (light) rejim**, **navy (#1A3D7C) birlamchi + emerald (#2ECC71) ikkilamchi**
tizim. Bu joriy ilovaning "KECHKI ZAL" **qorong'i (dark-only) + anor (#FF5340→#E2264B)** tilidan
tubdan farq qiladi. Yorug' rejim aslida **spec'ga MOSROQ** (spec §: dark mode MVP'dan chiqarilgan;
joriy dark-only build aslida chetlanish edi). Navy+green anor'ni **atayin almashtiradi** — bu mening
qaroram (brend bo'limiga qarang). Plate-ring motivi KPI kartalar bilan almashtirilgan.

Ayni paytda yangi dizayn spec'ning **uchta qat'iy chizig'iga ziqiladi** (R1 va DECISIONS'da hal qilingan):
1. **Parol/email auth** (Login/Ro'yxatdan o'tish/Parolni tiklash/o'zgartirish) — spec S2: *"Parol YO'Q — faqat OTP"*.
2. **Premium obuna billing** (tarif almashtirish, to'lovlar tarixi) — spec S12: paywall *6-oydan keyin, MVP'da yashirin flag*; §9: online to'lov MVP'dan tashqarida.
3. **Davomad (attendance)** yangi dizaynda ko'rinmaydi — spec S6 asosiy xususiyati; yo'qotib bo'lmaydi.

---

## 2. Ekran inventari (yangi dizayn → mavjud ilova ekranlari)

Belgilar: **[SAME]** vizual o'zgarishsiz · **[RESTYLED]** o'sha logika, yangi ko'rinish ·
**[NEW SCREEN]** yangi UI, mavjud ma'lumot · **[NEW LOGIC]** yangi ma'lumot/endpoint kerak.

| # | Yangi dizayn ekrani (frame'lar) | Mavjud ilova | Turi | Izoh |
|---|---|---|---|---|
| A1 | Onboarding uz — 3 slayd (O'quvchilaringizni boshqaring / To'lovlarni nazorat qiling / Biznesingizni rivojlantiring) + "Bepul boshlang" | `auth/ui/onboarding_screen.dart` | **[RESTYLED]** | Illyustratsiyalar yangi (yorug'), matn/oqim bir xil. So'nggi slayd + "Bepul boshlang / Keyinroq obuna bo'lish" yangi CTA |
| A2 | Login "Добро пожаловать" (Email/Telefon/Login + Parol + Войти + Забыли пароль + Создайте аккаунт) | `auth/ui/phone_screen.dart` (+`otp_screen`) | **[NEW LOGIC → RESOLVED: RESTYLE]** | Dizayn parol-auth ko'rsatadi; spec S2 = OTP-only. **QAROR D201:** parol qurilmaydi; OTP telefon+kod oqimi yangi tilda qayta bo'yaladi |
| A3 | Ro'yxatdan o'tish "Создайте аккаунт" (Ism, Email/Login, Parol, Tasdiq) | `auth/ui/profile_setup_screen.dart` | **[NEW LOGIC → RESOLVED: RESTYLE]** | Xuddi shu — profil sozlash (ism) OTP'dan keyin, parolsiz. D201 |
| A4 | "Parolni o'zgartirish" (Joriy/Yangi/Tasdiq parol) | — | **[CUT]** | Parol yo'q → ekran tushiriladi. D201 |
| S4 | Dashboard "Salom, Aziz!" (Oylik daromad · Jami qarzdorlik · Faol o'quvchilar 12 · Tezkor amallar · So'nggi faoliyat) | `dashboard/ui/dashboard_screen.dart` | **[NEW LOGIC]** | KPI qatori + **So'nggi faoliyat feed** = yangi aggregatlar. Hierarxiya o'zgargan (R1-F2). Ring→KPI kartalar |
| S5 | Shogirdlar "Shogirdlar" (qidiruv, filtr chiplar Hammasi/Qarzdorlar/Qisman/To'la, avatar+ism+summa qatorlar) | `students/ui/students_screen.dart` | **[RESTYLED]** | Avatar (foto) yangi. Qidiruv/filtr/scroll logika bor |
| S6 | Shogird profili "Shogird profili" (foto+ism+Qarz badge · Oylik to'lov/Jami to'langan · Joriy balans −300k qizil · To'lov qo'shish/edit · To'lovlar tarixi) | `students/ui/student_profile_screen.dart` | **[RESTYLED + NEW LOGIC]** | **Joriy balans (balance)** — yangi hisob-maydon. **Davomad/Eslatmalar tablari** dizaynda ko'rinmaydi → SAQLANADI (D204). Avatar → NEW LOGIC (foto) |
| S8 | To'lov sheet "To'lov qo'shish" (Summa · Oy · Sana · Saqlash) | `payments/ui/payment_sheet.dart` | **[RESTYLED + NEW LOGIC]** | **Oy (qaysi oy uchun)** selektori yangi UI. Method (naqd/karta) sheet'da ko'rinmaydi — default/yashirin (D205) |
| S5b | Shogird qo'shish/tahrirlash sheet (Rasm · Ism · Familiya · Oylik to'lov) | `students/ui/student_form_screen.dart` | **[RESTYLED + NEW LOGIC]** | **Ism/Familiya bo'linishi** + **avatar** + **telefon ko'rinmaydi** (ixtiyoriy). D206 |
| S10 | Statistika | `stats/ui/stats_screen.dart` | **[RESTYLED / MERGE]** | KPI'lar dashboardga ko'chdi. Chuqur grafik (6-oy seriya, tarif kesimi) alohida qoladi yoki dashboarddan ochiladi (D207) |
| S11 | Sozlamalar "Sozlamalar" (Profil+edit · Til uz/ru · **Obuna** Premium karta+Tarifni o'zgartirish+To'lovlar tarixi · Chiqish) | `settings/ui/settings_screen.dart` | **[RESTYLED + NEW LOGIC]** | Obuna **status** kartasi = spec'ga mos (S11). Tarif almashtirish + billing tarixi = S12 paywall → **feature-flag ostida** quriladi (D202) |
| N1 | **Kalendar** "Kalendar" (oy grid + kun ranglari yashil/amber/qizil · filtr tablari · kun bosilganda To'lovlar sheet) | — (splash-only edi) | **[NEW SCREEN + NEW LOGIC]** | To'liq yangi. To'lov kalendar aggregat endpoint kerak. "Rejalashtirilgan" = kutilayotgan to'lovlar (next_due_date proyeksiyasi) |
| N2 | **Bildirishnomalar** "Bildirishnomalar" (ro'yxat + "Bildirishnoma tafsilotlari" modal: shogird+summa+muddat+tez amallar) | — | **[NEW SCREEN + NEW LOGIC]** | Trener uchun notification markazi. Trenerga qaratilgan `GET /notifications` yo'q (faqat admin log) |
| N3 | **Tarif rejasini tanlash** modal (Bepul 0/oy · Premium 50k/oy — xususiyat ro'yxati) | — | **[NEW SCREEN + NEW LOGIC]** | S12 paywall. Feature-flag ostida (D202). Bepul limit ziddiyati (R1-F1) |
| N4 | **Obuna to'lovlar tarixi** "To'lovlar tarixi" (obuna invoyslari, −50k, Muvaffaqiyatli/Bekor) | — | **[NEW SCREEN + NEW LOGIC]** | S12 paywall. Feature-flag ostida (D202) |
| M1 | "Profilni tahrirlash" modal (foto + To'liq ism) | settings ichida | **[RESTYLED + NEW LOGIC]** | Avatar upload yangi |
| M2 | "Chiqishni tasdiqlang" dialog (qizil Chiqish) | settings ichida | **[RESTYLED]** | Bor logika |
| M3 | "Bildirishnoma tafsilotlari" modal (tez amallar: To'lov qo'shish / To'langan deb belgilash / Profilni ko'rish) | — | **[NEW SCREEN + NEW LOGIC]** | N2 bilan |
| — | Splash | `splash/ui/splash_screen.dart` | **[RESTYLED]** | Yangi logotip/rang |

**Pastki navigatsiya o'zgardi:** eski (Dashboard · Shogirdlar · [+] · Stats · Sozlamalar) →
yangi **4 tab: Bosh sahifa · Shogirdlar · Kalendar · Sozlamalar** (markaziy [+] FAB yo'q; Stats
dashboardga qo'shildi). "Qo'shish" amallari endi Dashboard "Tezkor amallar" + ekran ichidagi
tugmalar orqali (D203).

---

## 3. Token diff (aniq qiymatlar — pikseldan namuna olingan)

### 3.1 Ranglar

| Rol | Joriy (dark "KECHKI ZAL") | Yangi (light) | O'zgarish |
|---|---|---|---|
| Ekran foni | `#0C0D10` bg0 | `#FDFDFD` | dark→light (butun tizim) |
| Sirt / karta | `rgba(255,255,255,.055)` glass | `#FFFFFF` (subtle `#FBFBFB`/`#F6F7F7`) | shisha→qattiq oq karta |
| Asosiy matn (ink) | `#F4F2EC` chalk | `#222222` | teskari |
| Yumshoq matn | `#9C9FA8` | `#6B7179` (≈`#6C757D`) | — |
| **Brend / birlamchi** | anor `#FF5340`→`#E2264B` gradient | **navy `#1A3D7C`** (hi `#244C8E`) | **anor → navy** (D208) |
| Ikkilamchi / muvaffaqiyat | ok `#3DD68C` | **emerald `#2ECC71`** | yaqin, standartlashtirildi |
| Qarz / xato | debt `#FF7A6B` | **qizil `#E74C3C`** (kichik matnga `#D63C2C`, R1-F3) | anor emas endi — sof qizil |
| Ogohlantirish / qisman | warn `#FFC24D` | amber `#E4AA25` (matnga `#8A6D0B`, R1-F3) | — |
| Chegara / chiziq | `rgba(255,255,255,.08)` | `#EDEEEF` / `#E8E8E8` | — |
| Avatar | gradient plitalar | **haqiqiy foto** (fallback: navy tint + initsial) | NEW LOGIC |

### 3.2 Tipografiya
- Joriy: lokal font (`assets/fonts`), chalk ink, katta display sarlavhalar, `google_fonts` YO'Q.
- Yangi: bo'lim sarlavhalari **navy bold** (~18–20sp), ekran sarlavhalari navy bold (~22sp),
  tan raqamlar (summa) og'ir bold ink/qizil, yordamchi matn 13–14sp muted. Font oilasi
  saqlanadi (paket qo'shilmaydi — SYSTEM §2). Katta-sarlavha (large-title) pattern
  saqlanadi (R2).

### 3.3 Spacing / radius / shadow
- **Spacing:** yangi dizayn 4/8/12/16/20/24 shkalasiga mos (kartalar orasi ~12–16, ekran padding ~16–20,
  karta ichi ~16–20). Joriy `AppSpacing` (baza 2, screenH=20) mos keladi — kichik normalizatsiya (R1-F0).
- **Radius:** kartalar ~**16**, tugmalar ~**14**, pill/chip **to'liq yumaloq**, sheet yuqori **~24–28**,
  navy dumaloq icon-tugmalar to'liq doira. Joriy `AppRadius` (card=20, button=18, sheet=32) —
  **kamaytiriladi** yangi tizimga (card 16, button 14, sheet 24). Davomiy (continuous/squircle)
  burchak saqlanadi (R2).
- **Shadow/blur:** joriy — deyarli shadowsiz, blur faqat tabbar (D105). Yangi — **yumshoq soya**
  oq kartalarda (light rejimda ajratish uchun; y≈2–8, past alfa), blur statik barlar/sheet uchun
  (R2, scroll ichida EMAS).

---

## 4. Komponent diff

**Saqlanadi (restyle):** `app_button` (navy/green/outline/danger variantlari), `app_field`,
`app_chip` (filtr tablari), `app_bottom_sheet`, `student_card`, `list_row`, `section_header`,
`status_badge` (Tўlangan/Qisman/Qarz), `avatar` (→ foto), `empty_state`, `skeleton`, `app_toast`,
`glass_card` (→ `surface_card` oq+soya), `press_scale`, `timeline_tile` (→ so'nggi faoliyat/tarix).

**Yangi komponentlar:** `payment_calendar` (oy grid + kun-nuqtalari), `calendar_day_cell`,
`kpi_card` (dashboard), `activity_row` (so'nggi faoliyat), `notification_row` + `notification_detail_sheet`,
`plan_card`/`plan_picker_sheet` (paywall), `subscription_card` (obuna status), `balance_card`
(joriy balans −), `segmented_tabs` (kalendar filtr), `avatar_uploader`.

**O'ladi (o'chiriladi):** `plita_ring` (KPI kartalar almashtirdi — LEKIN motiv ixtiyoriy qaytishi mumkin, D208),
`heatmap` (agar Davomad tab saqlansa — QOLADI; agar kalendar davomadni ham qamrasa — ko'chiriladi, D204),
`mini_bar_chart` (stats dashboardga ko'chsa qoladi, D207). "O'lik kod" R5'da tozalanadi.

---

## 5. DATA GAP LIST (yangi dizayn talab qiladi, kontrakt bermaydi)

Har biri: taklif etilgan `openapi.yaml` o'zgarishi. **Kontraktsiz endpoint yozilmaydi** (CLAUDE.md §4).

| # | Ehtiyoj (dizayn) | Kontraktda holat | Taklif |
|---|---|---|---|
| G1 | **Dashboard KPI + So'nggi faoliyat feed** | `/dashboard` due/overdue beradi; oylik daromad/faol soni `/stats`da; **faoliyat feed YO'Q** | `/dashboard`ga `month_revenue`, `active_students`, `debt_total` qo'shish (bitta chaqiruv) + `recent_activity[]{type,student_id,student_name,amount,at}` (yangi event log) |
| G2 | **Kalendar oy aggregat** | YO'Q | `GET /calendar?month=YYYY-MM` → `days[]{date, paid_count, partial_count, planned_count, paid_amount}`; kun sheet uchun `GET /payments?date=` (yoki `/calendar/{date}`). "Rejalashtirilgan" = shogird `next_due_date` proyeksiyasi |
| G3 | **Trenerga qaratilgan bildirishnomalar** | `Notification` sxema bor, lekin trener `GET /notifications` YO'Q (faqat `/admin/logs/...`) | `GET /notifications` (o'z shogirdlari haqidagi to'lov-muddat ogohlantirishlari, boyroq payload: student_name, amount, oylik to'lov, muddat) + `POST /notifications/{id}/read` |
| G4 | **Shogird avatar (foto)** | `Student`da `avatar_url` YO'Q | `Student.avatar_url` (nullable) + `POST /students/{id}/avatar` (yoki presigned upload). Xuddi shu trener: `Me.avatar_url` + upload |
| G5 | **Ism/Familiya bo'linishi** | `Student.name` (yagona) | `first_name`/`last_name` qo'shish (name'ni derived qoldirish, orqaga-mos) yoki UI'da bo'lib, `name`ga birlashtirib yuborish (kamroq o'zgarish) — **D206'da tanlanadi** |
| G6 | **Joriy balans (student)** | `days_overdue` bor; **balance (so'mda qarz/oldindan)** YO'Q | `Student.balance` (int, manfiy=qarz) qo'shish yoki `dashboard/profile`da hisoblab berish |
| G7 | **To'lov "Oy uchun" (period)** | `PaymentCreate` server period hisoblaydi; UI oy tanlashi yo'q edi | `PaymentCreate.period_month` (YYYY-MM, ixtiyoriy) qo'shish yoki mavjud `period_from` orqali. Kichik |
| G8 | **Obuna status + billing (S12 paywall)** | `Me.plan(free/pro)`+`plan_until` bor; billing/plan-change YO'Q | `GET /me/subscription`{plan,price,renews_at,days_left,limits}; `POST /me/subscription/change`; `GET /me/subscription/invoices`. **Feature-flag ostida** (D202) |
| G9 | **Email (auth)** | YO'Q (OTP-only) | **QURILMAYDI** — D201 (spec S2 parolsiz). Kontrakt o'zgarmaydi |

> G9 bundan mustasno, backend ishlari R4'da kontrakt-birinchi qilinadi (openapi.yaml → DECISIONS →
> migratsiya → handler → RBAC → test → seed) va yangilangan `openapi.yaml` bu repoga ko'chiriladi.

---

## 6. DESIGN FLAW LIST (R1 — dizaynning o'z kamchiliklari + tuzatish)

Tuzatishlar **jarrohlik** (minimal). Eski dizaynga qaytish yoki uchinchisini o'ylab topish YO'Q.

- **F0 · Shkala normalizatsiyasi.** Figma eksportda bir nechta bir martalik radius/spacing bo'lishi mumkin.
  → Bitta shkala majburlanadi: spacing 4/8/12/16/20/24/32; radius {chip:full, button:14, card:16, sheet:24}.

- **F1 · Bepul limit ZIDDIYATI.** Onboarding "Bepul boshlang" = *"5 tagacha o'quvchi bepul"*, lekin
  "Tarif rejasini tanlang" modal = *"10 tagacha shogird"*. → Bitta qiymat (standart: **10**, batafsil
  plan-karta bilan mos). Baribir S12 flag ostida — mahsulot tasdig'igacha `AppConfig.freeStudentLimit`
  bitta joyda. (Bu paywall raqami, foydalanuvchidan so'ralmaydi — autonom rejim, D202.)

- **F2 · Dashboard hierarxiyasi "kim qarzdor"ni ko'madi.** Yangi dashboard **Oylik daromad**ni
  (vanity metrika) birinchi qo'yadi; trener #1 savoli "bugun kim to'laydi / kim qarzdor" pastda.
  R1 mezoni buni ko'tarishni talab qiladi. → KPI qatori saqlanadi, LEKIN **"Jami qarzdorlik"**
  vizual dominant (qizil urg'u) + darhol ostida **amaliy "Bugun to'lov" ro'yxati** (due_today,
  har birida "To'lov qo'shish"). Oylik daromad — ikkilamchi. Ring motivi ixtiyoriy qaytishi mumkin (D208).

- **F3 · Kontrast (WCAG AA) — o'lchangan:**
  - Navy `#1A3D7C` oq'da **10.49:1** ✓ · ink `#222` **15.9:1** ✓ · muted `#6B7179` **4.93:1** ✓ (normal AA o'tadi).
  - **Emerald `#2ECC71` + oq matn = 2.1:1 — YIQILADI.** Yashil tugma (Foydalanishni boshlash / To'langan deb belgilash) oq matn bilan o'qilmaydi. → Matnli yashil yuzada matn **navy/ink** yoki yashil **#0E8C45**gacha qorayadi (oq matn ≥4.5). Badge'da: och-yashil fon + **to'q yashil matn**.
  - **Qarz qizil `#E74C3C` kichik matnda = 3.82:1 — normal AA yiqiladi** (katta bold summa 3:1 large-AA o'tadi). → Kichik qatorlar (−50,000) uchun **#D63C2C (4.62:1)**.
  - **Amber `#E4AA25` matn = 2.08:1 — YIQILADI.** → Qisman badge matni **#8A6D0B** yoki to'q matn amber-tint fonda.

- **F4 · Teginish nishoni ≥44×44.** Kalendar kun kataklari (7-ustun ~360dp da ~44dp — chegarada, katak
  butun tap-zona), til UZ/RU chip, filtr tablari, dumaloq icon-tugmalar — hammasi **≥44** ga majburlanadi.

- **F5 · Holat to'liqligi.** Barcha frame'lar faqat "happy state". → Har ekran uchun **skeleton / empty /
  error+retry / offline** bir xil vizual tilda aniqlanadi (matritsa quyida). Ayniqsa: bo'sh shogirdlar,
  bo'sh kalendar-kun, bo'sh bildirishnomalar, bo'sh billing tarixi, offline banner (bor).

- **F6 · Auth modeli ziddiyati (eng katta).** Dizayn email/parol/tiklash ko'rsatadi; spec S2 = *parolsiz OTP*.
  → **D201:** parol qurilmaydi; OTP oqimi yangi tilda qayta bo'yaladi; "Parolni o'zgartirish" tushiriladi.

- **F7 · Eskirgan mock sanalar.** Obuna "Keyingi to'lov 15 Yanvar **2025**" (mahsulot 2026'da). → Haqiqiy
  sanalar (seed/real ma'lumot).

- **F8 · Til aralashligi.** Frame'lar aralash uz/ru (Bosh oqim uz, ba'zi auth ru). Ilova uz/ru bilingual —
  ikkovi ham to'g'ri, LEKIN oqim yagona i18n kalitlari orqali izchil bo'ladi (hardcode YO'Q, SYSTEM §5).

- **F9 · Davomad (attendance) regressiyasi.** Yangi dizayn davomad belgilashni ko'rsatmaydi; spec S6
  asosiy xususiyat. → **D204:** Davomad Shogird profilida tab sifatida saqlanadi (restyle); ixtiyoriy
  ravishda kalendarga davomad qatlam qo'shiladi. Jimgina yo'qotilmaydi.

---

## 7. Brend qarori (D208 — hujjatlashtirilgan)

Brief: anor + plate-ring + realistik uzbek kontent — yangi yo'nalish "kuchliroq narsa bilan atayin
almashtirmagan bo'lsa" saqlanadi (mening qarorim). Yangi dizayn **anor'ni navy+green bilan atayin
almashtiradi** — bu izchil, yetuk light tizim; anor qaytarilmaydi (aks holda ikki brend to'qnashadi).
**Plate-ring** KPI kartalar bilan almashtirilgan; motivni ikkilamchi urg'u sifatida (masalan dashboard
yoki profil progress halqasi navy/green'da) **ixtiyoriy** qaytarish mumkin, lekin KPI-birinchi bosh ekran
yangi yo'nalish. **Realistik uzbek kontent** to'liq saqlanadi (Alisher Karimov, Madina Yusupova, so'm).

---

## 8. Holat matritsasi (F5 — har ekran shu 4 holatsiz "done" emas)

| Ekran | Skeleton | Empty | Error+retry | Offline |
|---|---|---|---|---|
| Dashboard | KPI + ro'yxat pulse | "Hali shogird yo'q → Qo'shish" | banner+qayta | keshdan, offline banner |
| Shogirdlar | qator pulse | bo'sh/qidiruv topilmadi | qayta | keshdan |
| Shogird profili | blok pulse | (tarix bo'sh) "To'lov yo'q" | qayta | keshdan |
| Kalendar | grid pulse | oy bo'sh (nuqtasiz) | qayta | keshdan |
| Bildirishnomalar | qator pulse | "Bildirishnoma yo'q" | qayta | keshdan |
| Sozlamalar/Obuna | karta pulse | — | qayta | keshdan |
| Billing tarixi | qator pulse | "Invoys yo'q" | qayta | keshdan |
| To'lov/Davomad sheet | — | — | inline xato | to'lov offline QILINMAYDI (D110); davomad outbox |

---

## 9. Ijro rejasi (STATUS.md ga ko'chiriladi)

Tartib (bog'liqlik bo'yicha): **R3 tokenlar/komponentlar → R4 backend gaplar → R5 ekranlar → R6 run → R7 hisobot.**

R5 ekran tartibi: Dashboard → Shogirdlar → Shogird profili → To'lov sheet → Davomad sheet →
Kalendar (yangi) → Bildirishnomalar (yangi) → Auth/Onboarding (restyle) → Sozlamalar/Obuna → Stats(merge).

Backend (R4, kontrakt-birinchi, `trainer-back`): G1 dashboard aggregat+faoliyat · G2 kalendar · G3
bildirishnomalar · G4 avatar · G5 ism/familiya · G6 balans · G7 to'lov-oy · G8 obuna (flag ostida).
G9 (email/parol) QURILMAYDI.

> **DIQQAT:** R3–R7 build/run darvozalari Mac'da bajarilishi shart (§0). Bulutli sessiya ularni
> tekshira olmaydi. Keyingi round foydalanuvchi mashinasida (desktop app "On your computer") yoki
> lokal terminalda davom etadi.
