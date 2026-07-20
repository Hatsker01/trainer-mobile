# USTOZ

Trenerlar uchun shogird va to'lov boshqaruvi (CRM) + sport nutrition marketplace.
O'zbekiston bozori. Trener → mobile app, shogird → Telegram bot, merchant/admin → web.
To'liq kontekst: `docs/ustoz-mvp-spec.md` (yagona haqiqat manbai).

---

## SESSIYA PROTOKOLI

**Bu bo'lim majburiy. Har sessiya shu tartibda ishlaydi.**

1. **Ishni boshlashdan OLDIN o'qi:** `.claude/state/SYSTEM.md`, `.claude/state/STATUS.md`,
   `.claude/state/DECISIONS.md` va `.claude/state/journal/` dagi oxirgi 2-3 yozuv.

2. **STATUS.md dan vazifa ol:** o'z oqiming ustunidagi birinchi `[ ]` vazifani `[~]` ga
   o'zgartir va yoniga sessiya nomingni yoz (masalan `[~] B2 — sessiya: backend-2`).
   Boshqa oqim `[~]` qilib qo'ygan vazifaga **TEGMA**.

3. **Faqat o'z oqimingga tegishli papkada ishla.** Boshqa papkani o'zgartirish kerak
   bo'lsa — **o'zgartirma**, STATUS.md dagi "Cross-stream so'rovlar" bo'limiga yozib qo'y.

4. **API o'zgarishi kerakmi?** Avval `docs/openapi.yaml` ga o'zgartirish kirit,
   `DECISIONS.md` ga sabab yoz, **KEYIN** kod yoz. Kontraktsiz endpoint yozish taqiqlanadi.

5. **Sessiya oxirida MAJBURIY:**
   - (a) `STATUS.md` ni yangila (`[~]`→`[x]` yoki chala qolgani haqida izoh)
   - (b) `.claude/state/journal/` ga yangi fayl yoz: `YYYY-MM-DD-HHMM-<oqim>.md` —
     nima qilindi, qaysi fayllar, qanday qarorlar, nima chala qoldi,
     keyingi sessiya nimadan boshlashi
   - (c) Arxitektura o'zgargan bo'lsa `SYSTEM.md` ni yangila

6. **Commit har mantiqiy qadamda:** `<oqim>: <nima>` formatida
   (masalan `backend: add otp auth handlers`).

---

## Texnik qoidalar

- **Pul:** `BIGINT`, so'mda butun son, hech qachon `float`. Tiyin ishlatilmaydi.
- **Vaqt:** DB'da UTC (`timestamptz`), biznes-logika `Asia/Tashkent` da hisoblanadi.
- **Sana:** `paid_at`, `next_due_date`, `attendance.date` — `DATE` tipi (TZ'siz).
- **Telefon:** `+998XXXXXXXXX` formatda saqlanadi (13 belgi, probelsiz).
- **i18n:** user-facing matn hardcode qilinmaydi — `uz`/`ru` kalitlar orqali.
- **Hech narsa DELETE qilinmaydi** — faqat `status=archived`.
- **RBAC:** har so'rovda `trainer_id = ctx.user` — trener faqat o'z shogirdlarini ko'radi.
- **Loglar:** telefon raqamlar mask qilinadi (`+998 90 ***`).
- **Dizayn manbasi:** `design/*.html` — ranglar/spacing/komponentlar o'sha yerdan olinadi.
- **Har endpoint** `docs/openapi.yaml` dagi sxemaga **1:1** mos bo'lishi shart.

---

## Oqimlar va egalik

| Oqim | Papkalar (faqat shu yerda yoz) |
|---|---|
| **backend** | `backend/`, `deploy/` |
| **mobile** | `mobile/` |
| **bot** | `backend/internal/bot/`, `backend/internal/notify/` |

- **bot** oqimi backend ichida yashaydi (spec §6.1) — `backend/` ning qolgan qismiga
  tegmaydi, backend oqimi bilan STATUS.md dagi "Cross-stream so'rovlar" orqali kelishadi.
- `docs/openapi.yaml` — **umumiy**. O'zgartirish faqat DECISIONS.md yozuvi bilan.
- `design/*.html` va `docs/ustoz-mvp-spec.md` — **read-only**, hech kim o'zgartirmaydi.
- Fase 2 papkalari (`merchant-web/`, `admin-web/`) — MVP da tegilmaydi (spec §8:
  sprint 6 dan oldin merchant/marketplace'ga TEGMA).

---

## Scope himoyasi

MVP dan atayin chiqarilgan (spec §9): dark mode · shogird mobil app · in-app chat ·
online to'lov qabul qilish · workout builder · video · delivery · reyting.
Bularni "foydali bo'lardi" deb qo'shma.
