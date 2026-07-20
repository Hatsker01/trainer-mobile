# USTOZ — MVP Spesifikatsiya v1.0

> Trenerlar uchun shogird va to'lov boshqaruvi + sport nutrition marketplace.
> Working title: **USTOZ** (alternativlar: Shogird, Trenerim, Zarb). Nom keyin almashtirilsa, hech narsa o'zgarmaydi.
> Bu hujjat — yagona haqiqat manbai (single source of truth). Har bir modul alohida chatda shu hujjatdagi bo'lim asosida implement qilinadi.

---

## 0. Mahsulot printsiplari (har qanday qarorda shu 5 ta qoidaga qaytamiz)

1. **5 daqiqa qoidasi** — trener ro'yxatdan o'tib, birinchi shogirdini qo'shib, birinchi eslatmani sozlashi 5 daqiqadan oshmasin. Har bir ekran shu maqsadga xizmat qiladi.
2. **Telegram — birinchi kanal** — push notification qo'shimcha, Telegram bot asosiy yetkazish kanali. Shogird hech qachon app yuklamaydi (MVP da).
3. **Offline-tolerant** — zalda internet yomon bo'lishi mumkin. Davomad belgilash va shogird ko'rish lokal keshdan ishlaydi, sync keyin.
4. **Pul — markaziy obyekt** — har bir ekranda trener "kim qarzdor, kim to'lagan" ni 2 soniyada ko'ra olishi kerak.
5. **Ikki til** — UZ (lotin) default, RU to'liq qo'llab-quvvatlanadi. Barcha matnlar i18n kalitlar orqali, hardcode yo'q.

## 0.1 Rollar

| Rol | Platforma | MVP da? |
|---|---|---|
| Trener | Mobile app (iOS/Android) | ✅ Asosiy |
| Shogird | Telegram bot | ✅ |
| Merchant (sport pit sotuvchi) | Web panel | ✅ (soddalashtirilgan) |
| Admin (biz) | Web panel | ✅ |
| Xaridor (marketplace) | Mobile app ichida bo'lim | 🔶 Fase 1.5 |

---

# 1. DESIGN SYSTEM

## 1.1 Yo'nalish

Zal dunyosi: temir, mel (magneziya), ter, natija. Dizayn "fitness-neon shtamp" (qora fon + kislotali yashil) EMAS — bu hamma qiladigan default. Bizniki: **och "gips" fon + qora temir matn + anor rangli aksent**. Anor — O'zbekona, energiya beradi, va to'lov/ogohlantirish semantikasiga tabiiy mos.

## 1.2 Ranglar (design tokens)

```
--color-bg:          #F6F4EF   // "Gips" — och, iliq fon
--color-surface:     #FFFFFF   // Kartalar
--color-ink:         #1C1E22   // "Temir" — asosiy matn
--color-ink-soft:    #5A5E66   // Ikkilamchi matn
--color-anor:        #D63A2F   // Aksent: CTA, qarzdorlik, brend
--color-anor-soft:   #FBE9E7   // Anor fon (badge, highlight)
--color-ok:          #1F7A4D   // To'langan / muvaffaqiyat
--color-ok-soft:     #E3F2EA
--color-warn:        #B8860B   // Muddat yaqin (3 kun)
--color-warn-soft:   #FFF6DC
--color-line:        #E5E1D8   // Chiziqlar, dividerlar
```

Dark mode — MVP da YO'Q (scope kesish). Token arxitektura tayyor, keyin qo'shiladi.

## 1.3 Tipografika

Kirill + lotin qo'llab-quvvatlashi MAJBURIY (uz/ru).

- **Display / raqamlar:** `Unbounded` (600, 700) — sarlavhalar, katta summalar. Kirillni to'liq qo'llaydi, sportcha kuchli xarakter beradi.
- **Body:** `Manrope` (400, 500, 700) — barcha matn, kirill a'lo.
- **Raqamli data (jadval, summa ro'yxati):** `JetBrains Mono` (500) — pul summalar ustunlarda tekis turadi.

Type scale: 32 / 24 / 20 / 16 / 14 / 12. Line-height 1.4 body, 1.1 display.

## 1.4 Imzo element (signature)

**"Plita" (weight plate) progress ring** — har bir shogird kartasida shtanga plitasi shaklidagi halqa: to'lov davri qancha qolganini ko'rsatadi. To'liq yashil halqa = yangi to'langan, kamayib boradi, qizarib "yonadi" = muddat o'tdi. Bu app'ning yodda qoladigan vizual identiteti — trener bir qarashda butun ro'yxat holatini ko'radi.

## 1.5 Komponentlar (asosiylari)

- **StudentCard** — avatar (ism bosh harflari), ism, tarif, plita-ring, keyingi to'lov sanasi, qarz badge
- **MoneyText** — summa har doim `1 200 000 so'm` formatida, mono shrift, minglik probel bilan
- **StatusBadge** — `TO'LANGAN` (ok) / `3 KUN QOLDI` (warn) / `QARZDOR · 5 KUN` (anor)
- **BigButton** — bitta ekranda bitta asosiy CTA, to'liq kenglik, 52px balandlik
- **EmptyState** — har bo'sh ekran harakatga chaqiradi: "Birinchi shogirdingizni qo'shing →"
- **BottomSheet** — barcha tez amallar (to'lov qo'shish, davomad) modal sheet'da, sahifa almashtirmasdan

## 1.6 Ohang (copy tone)

Oddiy, do'stona, professional. "Siz" bilan. Xatolar aybламaydi: "Internet yo'q — o'zgarishlar saqlanadi va keyin yuboriladi". Har CTA aniq fe'l: "To'lov qo'shish", "Eslatma yuborish" ("Yuborish"/"OK" emas).

---

# 2. MOBILE APP — TRENER (asosiy mahsulot)

**Stack tavsiyasi:** Flutter (bitta kodbaza iOS+Android, kirill/lotin bilan muammosiz, tez MVP). Alternativ: React Native. State: Riverpod/Bloc. Lokal kesh: Drift (SQLite).

## 2.1 Navigatsiya

Bottom tab bar — 4 tab:

```
[ Asosiy ]  [ Shogirdlar ]  [ + ]  [ Statistika ]  [ Profil ]
```

`+` — markaziy tugma, bottom sheet ochadi: "Shogird qo'shish / To'lov qo'shish / Davomad belgilash".

## 2.2 Ekranlar ro'yxati

| # | Ekran | Maqsad |
|---|---|---|
| S1 | Onboarding (3 slayd) | Qiymatni 15 soniyada tushuntirish |
| S2 | Auth: telefon + OTP | Kirish. Parol YO'Q — faqat SMS/Telegram OTP |
| S3 | Profil sozlash (1-marta) | Ism, zal nomi (ixtiyoriy), til |
| S4 | Asosiy (Dashboard) | Bugungi holat: kim to'lashi kerak, bugungi mashg'ulotlar |
| S5 | Shogirdlar ro'yxati | Barcha shogirdlar, filtr, qidiruv |
| S6 | Shogird profili | Bitta shogirdning to'liq tarixi |
| S7 | Shogird qo'shish | Forma (3 qadam emas — bitta ekran) |
| S8 | To'lov qo'shish (sheet) | Summa, sana, davr |
| S9 | Davomad (sheet) | Bugungi kelganlarni belgilash |
| S10 | Statistika | Oylik daromad, aktiv/qarzdor, churn |
| S11 | Profil / Sozlamalar | Til, tariflar shabloni, Telegram ulash, obuna |
| S12 | Paywall | Pro obuna (6-oydan keyin yoqiladi, MVP da yashirin flag) |

## 2.3 Ekran detallari

### S2 — Auth
- Telefon (+998 prefiks qotirilgan) → OTP 6 raqam.
- OTP kanali: 1) agar Telegram ulangan bo'lsa — bot orqali (bepul), 2) fallback SMS (Eskiz.uz).
- Muvaffaqiyatda JWT (access 15 min + refresh 30 kun, secure storage).

### S4 — Asosiy (Dashboard) — eng muhim ekran
Yuqoridan pastga:
1. Salomlashuv + bugungi sana
2. **"Bugun to'lov" bloki** — bugun/o'tib ketgan to'lovlar ro'yxati (StudentCard mini). Har birida ikki tugma: `✓ To'landi` va `🔔 Eslatish` (bot orqali shogirdga xabar).
3. **"3 kun ichida" bloki** — yaqinlashayotgan to'lovlar.
4. Bugungi davomad shortcut: "Bugun 5 shogird keldi · Belgilash →"
5. Hammasi bo'sh bo'lsa: "Bugun hammasi joyida 💪" empty state.

### S5 — Shogirdlar ro'yxati
- Qidiruv (ism/telefon), filtr chiplari: `Hammasi / Qarzdor / Muddati yaqin / Aktiv / Arxiv`
- Saralash: qarzdorlar doim tepada (default)
- Har karta — StudentCard (plita-ring bilan)
- Swipe amallari: chapga → "To'lov qo'shish", o'ngga → "Davomad"

### S6 — Shogird profili
- Header: ism, telefon (bosilsa qo'ng'iroq/Telegram), tarif, plita-ring katta
- Tablar: **To'lovlar** (tarix ro'yxati, har biri: sana, summa, davr) / **Davomad** (kalendar heatmap — qaysi kunlar kelgan) / **Eslatmalar** (yuborilgan xabarlar logi)
- Amallar: To'lov qo'shish, Tarifni o'zgartirish, Arxivlash (o'chirish YO'Q — faqat arxiv, data yo'qolmaydi)
- "Telegram ulash" statusi: shogird botga ulangan/ulanmagan. Ulanmagan bo'lsa — "Taklif havolasini yuborish" tugmasi (deep link: `t.me/UstozBot?start=<invite_token>`)

### S7 — Shogird qo'shish
Bitta ekran, minimal majburiy maydonlar:
- Ism* · Telefon* · Tarif* (dropdown: trenerning shablonlaridan yoki "yangi tarif")
- Tarif turlari: `Oylik` (summa + har oy sanasi) / `Mashg'ulotlar paketi` (masalan 12 ta, summa) / `Bir martalik`
- Boshlanish sanasi (default: bugun)
- Saqlagach → darhol "Taklif havolasini Telegram orqali yuborish?" prompt.

### S8 — To'lov qo'shish (bottom sheet)
- Shogird (agar kontekstdan kelmasa — tanlash), Summa (tarif summasi prefill), Sana (default bugun), To'lov usuli chip: `Naqd / Karta / Payme / Click` (faqat yozuv uchun, integratsiya emas)
- Saqlangach: keyingi to'lov sanasi avtomatik hisoblanadi (oylik: +1 oy; paket: paket tugaguncha sanasiz, davomad hisobidan)
- Shogirdga bot orqali chek-xabar: "✅ 400 000 so'm to'lovingiz qabul qilindi. Keyingi to'lov: 15-avgust"

### S9 — Davomad (bottom sheet)
- Bugungi sana, shogirdlar ro'yxati checkbox bilan, "belgilanganlar" paket hisobidan -1
- Paketli shogirdda qolgan mashg'ulot ko'rsatiladi: "12 dan 4 qoldi". 2 ta qolganda trener + shogirdga avtomatik eslatma.

### S10 — Statistika
MVP da 4 ta karta, chuqur analytics YO'Q:
- Shu oy daromad (o'tgan oyga % taqqoslash)
- Aktiv shogirdlar soni
- Qarzdorlik jami (so'm)
- Oxirgi 6 oy daromad — oddiy bar chart

### S11 — Sozlamalar
- Til (uz/ru), Tarif shablonlari CRUD, Telegram bot ulash (trener o'zi ham botga ulanadi — unga ham eslatmalar keladi), Eslatma vaqti (default 09:00), Obuna holati, Chiqish.

## 2.4 Notification logikasi (mahsulot qoidalari)

| Trigger | Kimga | Kanal | Matn (uz) |
|---|---|---|---|
| To'lovga 3 kun | Shogird | Bot | "Salom {ism}! {trener} bilan mashg'ulot to'lovi {sana}da — {summa}." |
| To'lov kuni | Shogird + Trener | Bot | Shogird: "Bugun to'lov kuni..." · Trener: "Bugun 3 shogird to'lashi kerak: ..." |
| Muddat o'tdi (1, 3, 7-kun) | Trener | Bot + Push | "{ism} to'lovi {n} kun kechikdi" |
| Paketda 2 mashg'ulot qoldi | Shogird + Trener | Bot | "Paketingizda 2 mashg'ulot qoldi" |
| Qo'lda "Eslatish" | Shogird | Bot | Trener tanlagan shablon |

Qoida: shogirdga bir kunda maksimum 1 avtomatik xabar (spam emas). Trener qo'lda cheklovsiz, lekin kuniga 3 tadan ortiq bo'lsa UI ogohlantiradi.

---

# 3. TELEGRAM BOT — @UstozBot

Bitta bot, ikki auditoriya (trener va shogird) — rol invite token orqali aniqlanadi.

## 3.1 Shogird flow

```
/start <invite_token>
 → "Salom! Siz {trener} ning shogirdi sifatida ulandingiz ✅"
 → Asosiy menyu (reply keyboard):
    [ 💳 To'lov holatim ]  [ 📅 Qolgan mashg'ulotlar ]
    [ ✍️ Trenerga yozish ]  [ ⚙️ Til ]
```

- **To'lov holatim** — keyingi to'lov sanasi, summa, oxirgi 3 to'lov tarixi
- **Qolgan mashg'ulotlar** — paketli bo'lsa: "12 dan 4 qoldi", oylik bo'lsa: "Obuna 15-avgustgacha aktiv"
- **Trenerga yozish** — shunchaki trenerning telegram username'iga link (bot orqali chat MVP da YO'Q — scope)
- Tokensiz `/start` → "Trener yuborgan havola orqali kiring yoki trenerdan so'rang"

## 3.2 Trener flow

- App'dagi "Telegram ulash" → deep link `t.me/UstozBot?start=trainer_<token>` → hisob bog'lanadi
- Trener botda oladi: kunlik digest (09:00): "Bugun: 2 to'lov kutilmoqda, 1 qarzdor", real-time: to'lov muddati o'tganlar
- Buyruqlar: `/bugun` — bugungi holat, `/qarzdorlar` — ro'yxat

## 3.3 Texnik

- Go: `go-telegram/bot` yoki `telebot.v3` kutubxonasi
- Webhook rejimi (polling emas) — bitta endpoint `/tg/webhook`, secret token bilan
- Xabar yuborish — backend'dagi `notifier` moduli orqali, to'g'ridan-to'g'ri handler'dan EMAS (retry/queue uchun)
- Rate limit: Telegram 30 msg/sec — worker queue bilan throttle

---

# 4. MERCHANT WEB PANEL (sport pit sotuvchilar)

MVP da maksimal sodda: mahsulot qo'yish + lead qabul qilish. Hech qanday ombor/analytics.

**Stack:** React + TypeScript + Vite, UI: shadcn/ui (tez), state: TanStack Query. Yoki HTMX+Go template (yanada tez) — implement qiladigan chatda tanlaysan.

## 4.1 Sahifalar

| Sahifa | Tarkib |
|---|---|
| Auth | Telefon + OTP (trener bilan bir xil mexanizm) |
| Ariza (1-marta) | Do'kon nomi, logo, telefon, Telegram username, manzil (matn). Status: `pending` → admin tasdiqlaydi |
| Mahsulotlar | Jadval: foto, nom, narx, kategoriya, holat (aktiv/yashirin). CRUD |
| Mahsulot forma | Nom (uz/ru), kategoriya (Protein/Kreatin/Gainer/Vitamin/Aminokislota/Boshqa), narx, tavsif, 1-4 foto, brend, og'irlik/hajm |
| Leadlar | Ro'yxat: sana, mahsulot, xaridor telefoni, holat (`yangi/bog'lanildi/sotildi/bekor`) — merchant o'zi belgilaydi |
| Sozlamalar | Do'kon ma'lumotlari, til |

## 4.2 Lead flow (delivery yo'q modeli)

```
Xaridor (app'da) mahsulotni ochadi → [Buyurtma berish] →
telefon tasdiqlash (app'da allaqachon bor) →
Lead yaratiladi → Merchantga Telegram xabar:
"🛒 Yangi buyurtma: Whey Protein 2kg — Aziz, +998 90 ***. Bog'laning!"
→ qolgani ular o'rtasida (telefon/telegram)
```

Biz to'lov va yetkazishga ARALASHMAYMIZ. Har lead loglanadi — bu keyin monetizatsiya asosi (lead-based billing).

---

# 5. ADMIN PANEL (ichki boshqaruv)

**Stack:** Eng tez yo'l — React admin template yoki Go + templ/HTMX. Chiroyi muhim emas, funksiya muhim.

| Bo'lim | Funksiya |
|---|---|
| Dashboard | Asosiy metrikalar: jami trenerlar, DAU/WAU, jami shogirdlar, bugungi yangi ro'yxatlar, yuborilgan notificationlar |
| Trenerlar | Ro'yxat, qidiruv, profil ko'rish (shogirdlar soni, oxirgi aktivlik), bloklash |
| Merchantlar | `pending` arizalar moderatsiyasi (tasdiqlash/rad), aktivlar ro'yxati |
| Mahsulotlar | Moderatsiya (nomaqbul kontent olib tashlash), kategoriyalar CRUD |
| Broadcast | Barcha trenerlarga bot orqali xabar (yangilik, feature e'lon) — segment: hamma / aktiv / passiv |
| Feature flags | `paywall_enabled`, `marketplace_enabled` — kod deploysiz yoqish/o'chirish |
| Loglar | Notification delivery log (yuborildi/xato), auth loglar |

Admin auth: email+parol + hardcoded whitelist (MVP), 2FA keyin.

---

# 6. BACKEND

## 6.1 Arxitektura

**Modulli monolit** (mikroservis EMAS — MVP tezligi muhim, sen buni yaxshi bilasan):

```
/cmd/api          — main, HTTP server (chi yoki gin)
/cmd/worker       — scheduler + notification worker
/internal/
  auth/           — OTP, JWT, sessions
  trainer/        — trener domeni
  student/        — shogird + tarif + davomad
  payment/        — to'lovlar, keyingi sana hisoblash
  notify/         — notification engine (queue, template, kanal: tg/push/sms)
  bot/            — Telegram webhook handler
  market/         — merchant, product, lead
  admin/          — admin endpointlar
  platform/       — db, config, logger, i18n, middleware
```

- **DB:** PostgreSQL 16 (bitta baza, sxema quyida)
- **Queue:** MVP uchun PostgreSQL-based queue (River yoki o'zing yozgan `notifications_outbox` polling) — Redis/Kafka KERAK EMAS hozir
- **Cache:** kerak bo'lsa keyin. MVP da yo'q.
- **Deploy:** bitta VPS (Hetzner/DO), Docker Compose: api + worker + postgres + caddy (TLS). CI: GitHub Actions → build → ssh deploy.
- **Fayllar (mahsulot fotolari):** S3-compatible (Cloudflare R2 — arzon/bepul boshlanish)

## 6.2 DB sxema (asosiy jadvallar)

```sql
users            (id, phone UNIQUE, role ENUM(trainer,merchant,admin),
                  name, lang, tg_chat_id NULL, created_at)

trainers         (user_id PK/FK, gym_name NULL, remind_time TIME DEFAULT '09:00',
                  plan ENUM(free,pro) DEFAULT free, plan_until NULL)

tariff_templates (id, trainer_id FK, name, type ENUM(monthly,package,single),
                  price BIGINT, sessions_count NULL, is_active)

students         (id, trainer_id FK, name, phone,
                  tg_chat_id NULL, invite_token UNIQUE,
                  tariff_type, tariff_price, sessions_total NULL,
                  sessions_used INT DEFAULT 0,
                  next_due_date DATE NULL, status ENUM(active,archived),
                  created_at)

payments         (id, student_id FK, trainer_id FK, amount BIGINT,
                  method ENUM(cash,card,payme,click),
                  paid_at DATE, period_from, period_to NULL, created_at)

attendance       (id, student_id FK, date DATE, UNIQUE(student_id, date))

notifications    (id, recipient_type ENUM(student,trainer,merchant),
                  recipient_id, channel ENUM(tg,push,sms),
                  template_key, payload JSONB,
                  status ENUM(queued,sent,failed), scheduled_at, sent_at NULL,
                  dedup_key UNIQUE NULL)   -- kunlik dedup uchun

merchants        (user_id PK/FK, shop_name, logo_url, address_text,
                  tg_username, status ENUM(pending,approved,blocked))

products         (id, merchant_id FK, name_uz, name_ru, category,
                  brand, price BIGINT, weight_text, description,
                  photos JSONB, status ENUM(active,hidden,rejected), created_at)

leads            (id, product_id FK, merchant_id FK,
                  buyer_name, buyer_phone,
                  status ENUM(new,contacted,sold,cancelled), created_at)

otp_codes        (phone, code_hash, attempts, expires_at)
```

Muhim biznes-logika:
- `next_due_date` hisoblash: `monthly` → oxirgi to'lov `period_to` + 1 kun; `package` → sana yo'q, `sessions_used >= sessions_total - 2` da eslatma
- Pul HAR DOIM `BIGINT` tiyin emas — so'mda butun son (O'zbekistonda tiyin ishlatilmaydi), lekin baribir integer, hech qachon float
- Soft delete faqat: `students.status=archived`, hech narsa DELETE qilinmaydi

## 6.3 API (REST, /api/v1)

```
POST /auth/otp/request        {phone}
POST /auth/otp/verify         {phone, code} → {access, refresh}
POST /auth/refresh

GET  /me                      profil + plan
PATCH /me

GET    /students?filter=debtors|upcoming|active|archived&q=
POST   /students
GET    /students/{id}
PATCH  /students/{id}
POST   /students/{id}/archive
POST   /students/{id}/remind          — qo'lda eslatma
GET    /students/{id}/payments
GET    /students/{id}/attendance

POST   /payments              {student_id, amount, method, paid_at}
POST   /attendance/bulk       {date, student_ids[]}

GET    /dashboard             — bugungi bloklar (due_today, due_soon, overdue)
GET    /stats                 — oylik daromad, 6 oylik seriya

GET    /tariffs  POST /tariffs  PATCH /tariffs/{id}

POST   /tg/webhook            — bot updates (secret header bilan)

-- Merchant
POST   /merchant/apply
GET    /merchant/products  POST ... PATCH ... 
GET    /merchant/leads     PATCH /merchant/leads/{id}

-- Marketplace (fase 1.5, app ichida)
GET    /market/products?category=&q=
POST   /market/products/{id}/lead

-- Admin (alohida auth middleware)
GET    /admin/metrics ...  (5-bo'limga mos endpointlar)
```

## 6.4 Notification engine (yurak qismi)

```
Worker har 60 soniyada:
1. SELECT ... FROM notifications WHERE status=queued AND scheduled_at <= now()
   FOR UPDATE SKIP LOCKED LIMIT 50
2. Kanal bo'yicha yuboradi (tg → sms fallback agar tg_chat_id NULL)
3. status=sent/failed, retry 3 marta (exponential backoff)

Scheduler (kunlik, har trener remind_time da, Asia/Tashkent TZ):
- due_today, due_in_3_days, overdue(1,3,7) so'rovlari →
  notifications jadvaliga INSERT, dedup_key = "{student_id}:{template}:{date}"
  (ON CONFLICT DO NOTHING — bir kunda bir xil xabar 2 marta ketmaydi)
```

Template'lar DB'da emas — kodda i18n fayllarda (`notify/templates/uz.toml`, `ru.toml`), payload'dan interpolatsiya.

## 6.5 Integratsiyalar

| Nima | Provayder | MVP |
|---|---|---|
| SMS OTP | Eskiz.uz (arzon, lokal) | ✅ fallback sifatida |
| Telegram | Bot API | ✅ asosiy |
| Push | FCM (Firebase) | ✅ minimal (badge/overdue) |
| To'lov qabul qilish (obuna) | Payme Business / Click | 🔶 paywall yoqilganda (6-oy) |
| Fayl storage | Cloudflare R2 | ✅ |

---

# 7. NON-FUNCTIONAL

- **i18n:** barcha user-facing matn uz/ru. Backend template + mobil ARB/JSON fayllar. Sana format: `15-avgust`, pul: `1 200 000 so'm`.
- **Timezone:** hamma narsa `Asia/Tashkent` da hisoblanadi, DB'da UTC saqlanadi.
- **Analytics eventlar** (PostHog self-host yoki Amplitude free): `signup, student_added, payment_added, attendance_marked, reminder_sent_manual, app_open` — PMF ni shu bilan o'lchaymiz (haftada 3+ app_open = aktiv trener).
- **Xavfsizlik:** OTP rate limit (5/soат/telefon), JWT secret rotation tayyor, telefon raqamlar loglarda mask, RBAC middleware (trainer faqat o'z studentlarini ko'radi — har so'rovda `trainer_id = ctx.user`).
- **Backup:** Postgres kunlik dump → R2, 30 kun retention.

---

# 8. IMPLEMENTATSIYA KETMA-KETLIGI (chatlar rejasi)

Har sprint = alohida chat. Har chatga shu hujjatning tegishli bo'limini ber.

| Sprint | Nima | Hujjat bo'limi | Natija |
|---|---|---|---|
| 1 | Backend skelet: auth (OTP+JWT), users, migrations, Docker Compose | §6.1–6.3 | Ishlaydigan API + deploy |
| 2 | Student/Payment/Attendance domeni + dashboard endpoint | §6.2–6.3 | To'liq CRUD + biznes-logika testlar bilan |
| 3 | Notification engine + scheduler + Telegram bot (shogird flow) | §6.4, §3 | Eslatmalar real ishlaydi |
| 4 | Mobile app: design system + auth + dashboard + students | §1, §2 (S1–S7) | APK qo'lda test |
| 5 | Mobile app: to'lov, davomad, statistika, sozlamalar | §2 (S8–S11) | Trener uchun to'liq MVP |
| 6 | Closed beta: 10-15 trener, feedback, bugfix | — | Retention data |
| 7 | Merchant panel + admin panel | §4, §5 | Moderatsiya ishlaydi |
| 8 | Marketplace bo'limi app'da + lead flow | §4.2 | Full loop |

**Muhim:** Sprint 6 dan oldin merchant/marketplace'ga TEGMA. Avval trener retention isbotlanadi — bu butun startupning asosi.

---

## 9. MVP dan ATAYIN chiqarib tashlanganlar (scope himoyasi)

Dark mode · shogird mobil app · in-app chat · online to'lov qabul qilish · mashg'ulot dasturi/workout builder · video kontent · delivery · reyting/otzivlar · iOS'dan oldin Android-first bo'lishi mumkin (O'zbekiston bozori ~85% Android)

Bularning har biri "keyin" — birortasi MVP'ni kechiktirmasin.
