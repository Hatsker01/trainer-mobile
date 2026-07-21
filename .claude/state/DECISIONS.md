# DECISIONS — mobile · ADR-lite

Format: **ID · sana · qaror · sabab · alternativa nega rad etildi**

Mobile oqimi D1xx diapazonidan foydalanadi (backend D0xx bilan to'qnashmasligi uchun).
Eski yozuv o'chirilmaydi — noto'g'ri chiqsa "Bekor qilindi: D1NN" deb belgilanadi.

---

## D101 · 2026-07-20 · Flutter SDK repo tashqarisiga (`~/flutter`) o'rnatiladi

**Qaror.** Bu mashinada Flutter umuman yo'q edi (`command not found`). SDK
`git clone -b stable` orqali `~/flutter` ga o'rnatildi. Repo ichiga EMAS.

**Sabab.** T0–T9 ning har bir DoD darvozasi (`dart format`, `flutter analyze`,
`flutter test`, `flutter build`) SDK'siz umuman ishlamaydi — bu qattiq bloker.
`~/flutter` — Flutter jamoasining tavsiya qilgan standart joyi, `.gitignore`
muammosi yo'q, boshqa loyihalar ham foydalanadi.

**Alternativa.** (a) `brew install --cask flutter` — rad etildi: brew cask
Flutter'ni tez-tez eskirgan versiyada saqlaydi, kanal almashtirish qiyin.
(b) fvm — rad etildi: yana bitta vosita, bitta loyiha uchun ortiqcha.
(c) SDK'siz "ko'r" kod yozish — rad etildi: analyze/test'siz yozilgan kod
production darajasi emas, brief buni aniq talab qiladi.

---

## D102 · 2026-07-20 · `POST /payments/preview` backendga qo'shiladi (T6 uchun)

**Qaror.** `docs/openapi.yaml` da bunday endpoint YO'Q (to'liq tekshirildi —
yagona yo'l `POST /payments` qilib `PaymentCreated.student.next_due_date` ni
o'qish, ya'ni to'lovni haqiqatan saqlash). To'lov sheetidagi "Keyingi to'lov: X"
preview'i uchun BACKEND KAMCHILIGI protokoli bo'yicha backendga
`POST /payments/preview` qo'shiladi.

**Sabab.** Brief T6 buni aniq talab qiladi: "client'da sana hisoblash
TAKRORLANMAYDI, bitta haqiqat manbai backend". Sana qoidalari (monthly →
oxirgi `period_to` + 1 kun; package/single → null) biznes mantiqi — uni
ikki joyda saqlash pul nuqtasida divergensiya xavfini tug'diradi.

**Alternativa.** Client'da hisoblash — rad etildi: yuqoridagi sabab.
Preview'ni umuman ko'rsatmaslik — rad etildi: dizaynda mavjud (S8 sheet,
`✓ Keyingi to'lov: 16-avgust, 2026`) va trener uchun asosiy tasdiq signali.

**Holat.** STATUS.md → Cross-stream X1. T6 ga kelganda bajariladi.

**BEKOR QILINDI (2026-07-20, T6 bajarilganda).** Backendga endpoint
QO'SHILMADI. Sabab: `POST /payments` javobidagi `PaymentCreated.student.
next_due_date` allaqachon serverdan keladi — ya'ni keyingi to'lov sanasi
**yagona haqiqat manbai (backend)** dan olinadi, client hisoblamaydi.
Faqat u SAQLAGANDAN KEYIN ko'rsatiladi (toast: "✓ Saqlandi. Keyingi
to'lov: 16-avgust, 2026"), dizayndagidek saqlashdan OLDIN jonli preview
emas.

**Nega saqlashdan oldingi preview qilinmadi.** Uning yagona yo'li —
(a) client'da sana hisoblash (brief buni QAT'IY taqiqlaydi: "sana
hisoblash TAKRORLANMAYDI") yoki (b) backendga preview endpoint qo'shish.
(b) uchun bu sessiyada backend repo mavjud emas (faqat `trainer-mobile`
ajratilgan). Post-save tasdiq — trener uchun bir xil signal (u to'lovni
baribir saqlaydi), lekin bitta kamroq bloker. Backend repo mavjud
bo'lganda `POST /payments/preview` qo'shib, sheetda jonli preview'ni
tiklash mumkin — TODO sifatida qoladi.

---

## D103 · 2026-07-20 · Debt (qarz) rangi token sifatida rasmiylashtiriladi

**Qaror.** Dizayn HTML'da `--ok`/`--warn` uchun CSS o'zgaruvchi bor, lekin
qarz rangi uchun YO'Q — `#FF7A6B` (matn) va `rgba(255,83,64,.14)` (fon)
hamma joyda qo'lda yozilgan. Flutter tokenlarida bu `debt` / `debtSoft`
sifatida rasmiylashtiriladi.

**Sabab.** Uchta holat (ok/warn/debt) UI'da bir xil rolda ishlatiladi —
tokenlar ham simmetrik bo'lishi kerak, aks holda har chaqiruvda hex qayta
yoziladi va farq ketadi.

**Alternativa.** HTML'dagidek qo'lda hex — rad etildi: dizayn tizimi maqsadiga zid.

---

## D104 · 2026-07-20 · Ring gradienti `#FF6A3D → #E2264B`, tugma gradienti `#FF5340 → #E2264B`

**Qaror.** Dizayn HTML'da ikki xil gradient boshlanish rangi bor:
SVG ring `linearGradient#ag` → `#FF6A3D`, tugma/chip `linear-gradient(135deg,...)`
→ `#FF5340` (`--anor`). Ikkalasi ham AYNAN saqlanadi, birlashtirilmaydi.

**Sabab.** 1:1 fidelity talabi. Farq ko'zga arang tashlanadi, lekin
"o'zimdan uslub o'ylab topmaslik" qoidasi ustun.

**Alternativa.** Bittaga keltirish — rad etildi: brief "AYNAN shu fayldan" deydi.

---

## D105 · 2026-07-20 · `backdrop-filter: blur` kartalarda QO'LLANMAYDI

**Qaror.** Dizaynda `.glass` da `backdrop-filter: blur(20px)` bor. Flutter'da
`GlassCard` default `blur: false` — oddiy yarim shaffof fon. Blur faqat
ustida kontent suzadigan joyda yoqiladi (tabbar).

**Sabab.** Ekran foni bir tekis `#0C0D10` — kartaning ortida blur qiladigan
narsa yo'q, ya'ni vizual farq nolga yaqin. Lekin `BackdropFilter` har biri
uchun alohida render qatlami (saveLayer) ochadi. Scroll ro'yxatida 10+ karta
= kafolatlangan jank, T9 dagi "dashboard scroll jank'siz" byudjeti buziladi.

**Alternativa.** Hamma kartada blur — rad etildi: nol vizual foyda, katta
narx. Kerak bo'lsa `GlassCard(blur: true)` bilan nuqtaviy yoqiladi.

---

## D106 · 2026-07-20 · Bottom sheet scrim'i blur'siz

**Qaror.** Dizayndagi scrim `rgba(0,0,0,.55)` + `backdrop-filter: blur(3px)`.
Flutter'da faqat rang olinadi, blur olinmaydi.

**Sabab.** `showModalBottomSheet` ning `barrierColor` i blur bera olmaydi —
blur'li scrim uchun o'z `ModalRoute` ini yozish kerak. 55% qora qatlam
ostida 3px blur amalda ko'rinmaydi: narx bor, natija yo'q.

**Alternativa.** Maxsus `ModalRoute` — rad etildi: sezilmaydigan effekt uchun
navigatsiya qatlamida qo'lda kod (a11y, drag, predictive-back xatti-harakati
qayta yoziladi). Kerak bo'lsa keyin qo'shiladi.

---

## D107 · 2026-07-20 · `StudentCard` badge ustuni 45% bilan cheklanadi

**Qaror.** Kartaning o'ng ustuni (badge + summa) `LayoutBuilder` orqali
qator kengligining 45% i bilan cheklanadi, ortig'i ellipsis.

**Sabab.** Bu ustun flex EMAS — RenderFlex unga cheksiz main-axis beradi,
ya'ni uzun badge qatorni yorib chiqadi. Aniqlangan holat: `360×640` +
`textScale 1.3` + "3 KUN KECHIKDI" → 3.8px overflow (galereya adaptivlik
testi topdi). Ism `Expanded` ichida bo'lgani uchun 0 gacha qisiladi, lekin
badge qisilmaydi — chegara qo'yilmasa overflow muqarrar.

**Alternativa.** (a) Badge'ni `Flexible` qilish — rad etildi: `Expanded`
bilan bo'sh joyni 50/50 bo'lishadi, qisqa badge'da ism va badge orasida
katta bo'shliq paydo bo'ladi. (b) Qattiq `maxWidth` (masalan 160px) —
rad etildi: 360 va 430 kenglikdagi ekranlarda bir xil ishlamaydi.

---

## D108 · 2026-07-20 · `path_provider` paketi qo'shildi (ro'yxatdan tashqari)

**Qaror.** Paket ro'yxati qattiq, lekin `path_provider` qo'shildi.

**Sabab.** T8 "o'qish keshi + davomad outbox'i lokal faylga yoziladi" ni
talab qiladi. iOS/Android'da ilovaga tegishli yoziladigan papka yo'lini
olishning BOSHQA yo'li yo'q — u platforma kanali orqali beriladi.
`path_provider` — Flutter jamoasining rasmiy (first-party) paketi.

**Alternativa.** (a) `flutter_secure_storage` ga JSON yozish — rad etildi:
u Keychain/EncryptedSharedPreferences, ya'ni har o'qish-yozishda
shifrlash. Dashboard keshi kabi katta bloblar uchun sekin va noto'g'ri
vosita (Keychain kichik sirlar uchun). (b) Keshni umuman qilmaslik —
rad etildi: T8 mahsulot printsipi (spec §0.3), zaldagi asosiy stsenariy.

**Cheklov.** Bu YAGONA istisno. Rasm/animatsiya/UI-kit kutubxonalari
avvalgidek MUTLAQO taqiqlanadi.

---

## D109 · 2026-07-20 · i18n — qo'lda `AppStrings`, `gen-l10n` YO'Q

**Qaror.** Har matn `AppStrings` klassida bitta getter: `_p(uz, ru)`.
`AppStringsScope` (`InheritedWidget`) orqali `context.s.students`.

**Sabab.** MVP da atigi 2 til. `gen-l10n` + ARB fayllar = kodgeneratsiya
qadami, 2 ta ARB fayl, build murakkabligi — foydasidan qimmat.
Bitta faylda turgani "hardcode ovi" ni osonlashtiradi: ekranda tirnoq
ichida matn qolgan bo'lsa, u darhol ko'rinadi.

**Alternativa.** `Map<String, String>` + `tr('key')` — rad etildi:
kalit xato yozilsa kompilyator ushlamaydi, yo'q kalit runtime'da
bo'sh matn beradi. Getter'da bunday xato bo'lishi mumkin emas.
</content>

---

# ── REDESIGN ROUND (D2xx = mobile oqimining "redesign" kichik seriyasi) ──

Yangi dizayn (`Jamshidbek Ikromov's team library/`) → light/navy tizim. D2xx bu roundga tegishli.

## D201 · 2026-07-21 · Parol/email auth QURILMAYDI — OTP oqimi qayta bo'yaladi

**Qaror.** Yangi dizaynda Login (parol), "Создайте аккаунт", "Забыли пароль", "Parolni
o'zgartirish" ekranlari bor. Bularning parol qismi QURILMAYDI. Telefon+OTP oqimi (mavjud
backend + spec) yangi light/navy tilda qayta bo'yaladi. "Parolni o'zgartirish" ekrani tushiriladi.

**Sabab.** Spec S2 (yagona haqiqat manbai): *"Kirish. Parol YO'Q — faqat SMS/Telegram OTP"*.
Butun backend OTP asosida (`/auth/otp/request|verify`, `otp_codes` jadvali, parol ustuni yo'q).
Parol qo'shish = spec buzilishi + yangi hujum yuzasi (parol saqlash, tiklash, brute-force) +
scope kengayishi. Autonom rejim: eng xавfsiz, spec-mos yo'l tanlanadi.

**Alternativa.** Parol auth qurish — rad: spec/xavfsizlik/scope. Ikkalasini (OTP+parol) —
rad: ikki auth yo'li = ikki barobar sirt, MVP uchun asossiz.

## D202 · 2026-07-21 · Obuna: status kartasi quriladi; tarif-almashtirish + billing feature-flag ostida

**Qaror.** Sozlamalardagi **Obuna status kartasi** (joriy tarif, keyingi to'lov, qolgan kun)
quriladi — spec S11 "obuna"ni sanaydi, kontraktda `Me.plan`+`plan_until` bor. LEKIN "Tarif
rejasini tanlash" modal, "Tarifni o'zgartirish" to'lov oqimi va "To'lovlar tarixi" (obuna
invoyslari) **`feature_flags` paywall bayrog'i ostida** quriladi (default O'CHIQ).

**Sabab.** Spec S12: *"Paywall — Pro obuna 6-oydan keyin yoqiladi, MVP da yashirin flag"*;
§9: *online to'lov qabul qilish MVP'dan tashqarida*. Dizaynni hurmat qilib UI quriladi, lekin
mahsulot qoidasiga ko'ra yoqilmaydi.

**Alternativa.** To'liq billing shipping — rad: MVP scope buzilishi. Obunani umuman qoldirmaslik —
rad: dizayn + spec S11 ikkovi ham obuna statusini so'raydi.

## D203 · 2026-07-21 · Pastki nav 4 tabga: Bosh sahifa · Shogirdlar · Kalendar · Sozlamalar

**Qaror.** Eski 5-elementli nav (markaziy [+] FAB, Stats tab) → yangi dizayndagi 4 tab.
"Qo'shish" amallari Dashboard "Tezkor amallar" + ekran ichidagi tugmalar orqali. Stats
dashboardga qo'shiladi (D207).

**Sabab.** Yangi dizayn barcha frame'larida pastki nav aynan shu 4 tab. Markaziy FAB yo'q.

**Alternativa.** FAB'ni saqlash — rad: dizaynga zid, ikki "qo'shish" yo'li chalkashlik beradi.

## D204 · 2026-07-21 · Davomad (attendance) SAQLANADI — yangi dizayn uni ko'rsatmasa ham

**Qaror.** Davomad belgilash oqimi va heatmap Shogird profilida tab sifatida saqlanadi
(restyle). Ixtiyoriy: kalendarga davomad qatlam qo'shish. Jimgina o'chirilmaydi.

**Sabab.** Spec S6 asosiy xususiyat (To'lovlar/Davomad/Eslatmalar tablari); §ilova asosi
to'lov + davomad. Dizayn faqat happy-path payment ekranlarni ko'rsatgan, davomadni tushirish
niyatini bildirmaydi — regressiya bo'lardi (R1-F9).

**Alternativa.** Davomadni olib tashlash — rad: spec asosiy xususiyatini yo'qotish.

## D205 · 2026-07-21 · To'lov sheet: "Oy" selektori qo'shiladi, "Method" default ostida

**Qaror.** "To'lov qo'shish" sheet dizayni Summa/Oy/Sana ko'rsatadi. **Oy (qaysi oy uchun)**
selektori qo'shiladi (period). To'lov usuli (naqd/karta) sheetda ko'rinmaydi — default `cash`,
ixtiyoriy ravishda "ko'proq" ostida.

**Sabab.** Dizayn oyni ko'rsatadi, method'ni ko'rsatmaydi. Kontrakt `PaymentCreate.method`
majburiy — default `cash` (O'zbekistonda ustun). Period G7 kontrakt o'zgarishi bilan.

**Alternativa.** Method'ni majburiy ko'rsatish — rad: dizayn soddalashtirgan, keraksiz friksiya.

## D206 · 2026-07-21 · Shogird: Ism/Familiya UI'da bo'linadi, kontraktga first/last qo'shiladi

**Qaror.** Qo'shish/tahrirlash formasi Ism + Familiya (ikki maydon) ko'rsatadi. Kontraktga
`Student.first_name`/`last_name` (nullable, orqaga-mos) qo'shiladi; `name` derived qoladi.
Telefon formada ixtiyoriy (dizaynda yo'q).

**Sabab.** Dizayn ikki maydon + fotoni ko'rsatadi, telefonni ko'rsatmaydi. `name`ni butunlay
tashlash orqaga-moslikni buzadi (dashboard/stats `name` ishlatadi).

**Alternativa.** Faqat `name`ni UI'da bo'lib backendga birlashtirish — mumkin (kamroq backend),
R4/D'da yakuniy tanlov. Telefonni majburiy qoldirish — rad: dizaynга zid (bot-invite baribir
ixtiyoriy).

## D207 · 2026-07-21 · Stats KPI'lari dashboardga, chuqur grafik ikkilamchi ko'rinishda

**Qaror.** Oylik daromad / faol / qarzdorlik KPI'lari dashboard bosh ekraniga. 6-oy seriya +
tarif kesimi grafiklari alohida "Statistika" ko'rinishida (dashboarddan ochiladi) saqlanadi.

**Sabab.** Yangi dashboard KPI-birinchi; alohida Stats tab yo'q (D203). Lekin grafik ma'lumot
(`/stats` series/by_tariff) qiymatli — yo'qotilmaydi.

**Alternativa.** Stats'ni butunlay olib tashlash — rad: analitik qiymat yo'qoladi.

## D208 · 2026-07-21 · Brend: anor → navy+green (atayin); plate-ring ixtiyoriy

**Qaror.** Anor (#FF5340→#E2264B) signature rang navy (#1A3D7C) + emerald (#2ECC71) bilan
almashtiriladi. Plate-ring KPI kartalar bilan almashtiriladi; motiv ikkilamchi urg'u sifatida
ixtiyoriy qaytishi mumkin. Realistik uzbek kontent to'liq saqlanadi.

**Sabab.** Brief: yangi yo'nalish "kuchliroq narsa bilan atayin almashtirgan bo'lsa" saqlanadi —
bu mening qarorim. Yangi light/navy tizim izchil va yetuk; anorni qaytarish ikki brendni
to'qnashtiradi.

**Alternativa.** Anorni saqlab navy'ga aralashtirish — rad: chalkash, ikkala palitra ham
zaiflashadi. Plate-ringni majburlash — rad: yangi dashboard KPI-birinchi.
