# DESIGN_AUDIT3 — zichlik + tipografiya auditi (G5)

Sana: 2026-07-21 · Sessiya: fix-1 · Kontekst: foydalanuvchi real telefonda
"hamma narsa haddan katta" dedi. Standart: **zich moliyaviy ilova** (bank
ilovalari). Manba qoidalar: brief G1 + DECISIONS D210–D212.

## 0. Pul — yagona manba (grep isboti)

Qoida: butun app'da pul faqat `Money.format/compact/withUnit` (probel ajratgich,
vergul YO'Q) va ko'rsatish `MoneyText` orqali. Suffiks `so'm` ~57% o'lchamda, soft.

`grep -rn "NumberFormat\|,000\|,so'm" lib` (`.g.dart` chiqarilgan):

| Topilma | Holat |
|---|---|
| `settings_screen.dart:612` `'50,000 so'm'` (vergul!) | **[FIXED]** → `Money.format(50000)` = `50 000` |
| `money.dart:10` sharhda "NumberFormat ISHLATILMAYDI" | sharh, muammo emas |
| `money.dart:52` `toStringAsFixed(1)` (mln kasr: "6.8 mln") | to'g'ri (kasr, vergul emas) |
| `stats_screen.dart:131` `toStringAsFixed(0)` (foiz "13%") | pul emas |

Yakuniy holat: **vergulli pul 0 ta**. `Money.compact` — millionlar `mln`
(K/M sxemasi bekor, eski stale test to'g'rilandi).

## 1. Tipografiya shkalasi (token darajasi)

- Display (`display24`, 24) — FAQAT sahifa sarlavhasi. Pulga ishlatilmaydi
  (grep §3 = 0 ta).
- KPI/hero pul — `money24` (24) hero daromad; `money20` (20) KPI; `money15`
  (15) mini; `money12` (12) ro'yxat. Eski `money24@fontSize:27` override
  OLIB TASHLANDI.
- To'lov sheetidagi bitta katta summa `money40` (40) — yagona hero raqam istisno.
- `so'm` suffiks — `MoneyText` da avtomatik ~57% + soft.

## 2. Ekran-ma-ekran holat

| Ekran | Zichlik | Izoh |
|---|---|---|
| **Dashboard (S4)** | ✅ qayta qurildi (G2) | screenEdge 16, cardPadDense 14, yig'ma hero+ring, BUGUN, tezkor 3, faoliyat zich. 1-4 bo'lim 393×852 scroll'siz (test isbot) |
| **Kalendar** | ✅ qayta qurildi (G3) | rang-kodli kunlar, kun sheeti (qoldiq), oy xulosasi, screenEdge 16 |
| **To'lov sheeti (S8)** | ✅ | `money40` hero (yagona katta raqam, joyida). Qoldiq-prefill kalendardan |
| **Sozlamalar/Obuna** | ✅ comma FIXED | plan narxi endi `Money.format`. Qolgan spacing eski token (keyingi round) |
| **Shogirdlar / Profil** | ⚠️ eski token | `screenH=20`, `cardPad=16` — funksional, lekin dashboard qadar zich emas. Follow-up: dense tokenlarga ko'chirish |
| **Statistika (S10)** | ⚠️ eski token | `money21` KPI (21px — chegara ichida). Grafik zich |
| **Auth/Onboarding** | ⚠️ eski token | `display24` sarlavha (to'g'ri, sahifa sarlavhasi). Kam ma'lumot zichligi shart emas |
| **Bildirishnomalar** | ⚠️ eski token | `Money.withUnit` ishlatadi (probel, vergulsiz — to'g'ri) |

Belgilar: ✅ shu round zichlashtirildi · ⚠️ funksional, follow-up dense-token ko'chirish.

## 3. Touch target / a11y

- Dashboard bell 44×44, tezkor amal 44+, BUGUN "To'lov" tugma ≥44 balandlik.
- Kalendar kun katagi 34px (grid), lekin butun katak `HitTestBehavior.opaque`
  bilan bosiladigan zona kattaroq (aspect 1.0).
- textScale 1.3 — `maxLines:1 + ellipsis` pul/ism ustunlarida; hero ring
  proporsional masshtablanadi (`PlitaRing` `k` faktori).

## 4. Follow-up (bu round emas)

1. Shogirdlar/Profil/Statistika/Bildirishnoma → dense tokenlarga ko'chirish.
2. G4 to'liq: streak + haftalik digest (D213 — talab qilinmagan, backend kerak).
3. Sozlamalarga "Oylik maqsad" qatori (hozir dashboard hero'dan qo'yiladi).
