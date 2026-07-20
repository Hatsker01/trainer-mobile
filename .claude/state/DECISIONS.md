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
</content>
