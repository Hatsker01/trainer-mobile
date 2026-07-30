# 2026-07-30 — Prototip v3 · Trainer App ekran-ekran 1:1 (mobile + backend)

## Nima qilindi (hammasi commit, `flutter analyze` / `go test` toza)

**Poydevor**
- `ustoz_ui` (ishlatilmagan path-dependency) pubspec'dan olib tashlandi →
  `flutter pub get` / `analyze` endi ishlaydi (avval butun verifikatsiya bloklangandi).
- Dizayn tizimi prototip bilan solishtirildi: rang/shrift (Unbounded+Manrope)/tema
  nomlari ("Kechki zal"/"Gips") — allaqachon 1:1 mos. To'liq redizayn shart emas edi.
- Reja hujjati: `.claude/state/PROTO-V3-MAP.md` (24 ekran xaritasi + ma'lumot-gaplar).

**Ekranlar prototip v3 ga moslandi (commitlar)**
- `3313b10` dashboard: Kassa svetofori + stat kartalar (Bugun keldi/Faol shogird) + BUGUN.
- `ca3088e` shogirdlar ro'yxati · shogird formasi · kalendar+davomat · statistika.
- `c46b270` kassa: tushum hero kartasi (real statsdan).
- `f474e59` shogird profil · menyu/sozlamalar.
- Ishlatilgan usul: parallel Workflow (agent-per-screen) → i18n/route/gap qaytaradi →
  markazdan integratsiya (strings.dart) → analyze → commit. API 529 bo'lganda ba'zilarini
  qo'lda yozdim.

**Backend**
- `600bac6` **churn radar dvigateli** `internal/payment/churn.go` (§3.9) — sof funksiya,
  `attendance`+qarzdan hosila, 5 test. Sabablar: qarz+7kun / 2 hafta ketma-ket kelmadi /
  chastota ≥40% pasaydi. Yangi shogird (<4 hafta) radarsiz.

## Muhim qarorlar / topilmalar
- Backend `sessions` jadvali = refresh-token (mashg'ulot sessiyasi EMAS). "Bugungi lenta",
  kalendar slotlari uchun YANGI jadval/slot modeli kerak.
- Streak allaqachon bor: `internal/client/gamify.go` (sof funksiya, streak_weeks/at_risk).
  Trener dashboard pili uchun qayta ishlatiladi.
- SOXTA MA'LUMOT ISHLATILMADI: backendда yo'q ma'lumot (streak, churn, sessiya vaqtlari,
  davomat %, retsept xaridlari, top shogird) UI'ga QO'SHILMADI — dataGaps sifatida qayd.

## Chala qolgani / keyingi sessiya nimadan boshlaydi
1. **Churn endpointни ulash:** trener faol shogirdlari bo'yicha `AssessChurn` yurituvchi
   service+repo (attendance batch query) + `GET /stats` ga `churn[]` yoki yangi endpoint
   (`openapi.yaml`→`DECISIONS.md`) → mobil DTO → dashboard churn kartasi + statistika churn bo'limi.
2. **Streak endpoint:** gamify.Compute ni trener agregatiga ulash → dashboard streak pili.
3. **Kalendar/slot modeli:** migratsiya + CRUD + `GET /sessions?date=` → "Bugungi lenta" + Jadval.
4. **Auth 1:1 (ixtiyoriy):** maxsus raqam-klaviatura + "Tilni tanlash" ekrani (hozir funksional,
   system keyboard bilan).
5. **F2/F3 ekranlar (spec §8 — sprint 6 gacha marketplace'ga tegilmaydi):** QR skaner, slot
   yaratish, muzlatish, dastur builder, mashq kutubxonasi, retsept/marketplace, mini-sayt,
   paywall, ovozli kiritish.
