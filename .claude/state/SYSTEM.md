# SYSTEM — mobile arxitekturasi

USTOZ trener mobil ilovasi. Flutter 3 / Dart 3, null-safety, portrait-only,
dark-only (MVP). Bundle id `uz.ustoz.trainer`. Android minSdk 23, iOS 13+.

---

## 1. Tashqi bog'lanishlar

| Nima | Qayerda | Izoh |
|---|---|---|
| Backend API | `--dart-define=API_URL` | Default `http://10.0.2.2:8080/api/v1` (Android emulyator) |
| Kontrakt | `docs/openapi.yaml` | Yagona haqiqat manbai. DTO'lar 1:1 mos |
| Dizayn | `design/ustoz-v2.1-tavsiyalar.html` | read-only. Barcha token/komponent shu yerdan |
| Prism mock | `http://localhost:4010/api/v1` | Backendsiz ishlash uchun |

Auth: `Authorization: Bearer <access>` (JWT, 15 daqiqa). Refresh 30 kun,
`POST /auth/refresh`. **Logout endpoint YO'Q** — chiqish = lokal tokenlarni tozalash.

---

## 2. Paket siyosati (QATTIQ)

`flutter_riverpod` · `go_router` · `dio` · `flutter_secure_storage` · `intl` ·
`json_annotation` (+`build_runner`, `json_serializable` dev) · `share_plus` ·
`connectivity_plus`.

Boshqa paket YO'Q. Rasm/animatsiya/UI-kit kutubxonalari **taqiqlanadi** —
hammasi `CustomPainter` + implicit animations bilan qo'lda. Fontlar lokal
(`assets/fonts`), `google_fonts` YO'Q (offline + start tezligi).

Yangi paket faqat DECISIONS.md yozuvi bilan.

---

## 3. Papka strukturasi

```
lib/
  core/
    theme/      AppColors, AppText, AppSpacing, AppRadius, AppMotion
    widgets/    design system komponentlari (har biri alohida fayl)
    api/        Dio client, interceptorlar, AppException
    router/     go_router konfiguratsiyasi
    i18n/       uz/ru kalitlar
    storage/    secure storage (token), fayl kesh (T8)
    utils/      money/date formatterlar
  features/
    <feature>/
      data/       DTO (json_serializable) + repository
      providers/  Riverpod (AsyncNotifier)
      ui/         ekranlar + feature'ga xos widgetlar
  dev/gallery.dart   komponent galereyasi (faqat debug)
```

Feature'lar: `auth`, `dashboard`, `students`, `payments`, `attendance`,
`stats`, `settings`, `splash`.

---

## 4. Qatlamlar qoidasi

- `ui` → `providers` → `repository` → `api`. Teskari yo'nalish yo'q.
- UI **hech qachon** xom `DioException` ko'rmaydi — interceptor uni
  `AppException` ga aylantiradi (network/timeout/validation/rateLimit/server).
- Repozitoriy interfeys + impl (test uchun mock qilinadi).
- Riverpod `select` bilan nuqtaviy rebuild — butun ekranni qayta qurish yo'q.

---

## 5. Texnik qoidalar (CLAUDE.md dan)

- **Pul:** `int` (so'm, butun). Hech qachon `double`. `Money` = int64.
- **Vaqt:** DB UTC, biznes-logika `Asia/Tashkent`.
- **Sana:** `paid_at`, `next_due_date`, `attendance.date` — `DATE` (TZ'siz).
- **Telefon:** `+998XXXXXXXXX` (13 belgi).
- **i18n:** user-facing matn hardcode qilinmaydi — `uz`/`ru` kalitlar.
- **Hech narsa DELETE qilinmaydi** — `status=archived`.
- **Loglar:** telefon mask qilinadi (`+998 90 ***`).

---

## 6. Sifat darvozalari

Har vazifa yopilishidan oldin: `dart format` toza · `flutter analyze` 0 xato ·
`flutter test` yashil. `analysis_options.yaml` qattiq — `prefer_const_*`,
`always_use_package_imports` **xato** darajasida (ogohlantirish emas).

Performance byudjeti (T9): cold start < 2s (profile), dashboard scroll jank'siz,
APK < 20MB (arm64, `--obfuscate --split-debug-info --split-per-abi`).

---

## 7. Muhit (2026-07-20 holati)

| Vosita | Holat |
|---|---|
| Flutter SDK | `~/flutter` (stable) — D101 bilan o'rnatildi |
| Xcode | **YO'Q** (faqat Command Line Tools) → iOS build mumkin emas (STATUS B2) |
| JDK / Android SDK | **YO'Q** → Android release build mumkin emas (STATUS B3) |
</content>
