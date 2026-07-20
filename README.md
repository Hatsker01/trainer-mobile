# mobile — USTOZ trener ilovasi (Flutter)

Flutter app (iOS + Android). Trener uchun asosiy mahsulot.

- **Dizayn manbasi:** `design/ustoz-client-app.html` va `design/ustoz-v2.1-tavsiyalar.html`
- **API:** `docs/openapi.yaml`. Dev'da backend KUTILMAYDI — mock server ishlatiladi:
  `npx @stoplight/prism-cli mock docs/openapi.yaml --port 4010`
  (prism `/api/v1` prefiksisiz xizmat qiladi — `.claude/state/SYSTEM.md` ga qara)
- **Stack:** Riverpod/Bloc + Drift (offline kesh) + dio
- **Ekranlar:** spec §2.2 (S1–S12)

**Boshlashdan oldin ildizdagi `CLAUDE.md` sessiya protokolini o'qi.**
Vazifalar: `.claude/state/STATUS.md` → Mobile ustuni (M1 dan boshlanadi).
