# USTOZ — trener mobil ilovasi

Trenerlar uchun shogird va to'lov boshqaruvi (CRM). Flutter 3 / Dart 3,
dark-only, portrait-only, O'zbekiston bozori (uz/ru).
Bundle id: `uz.ustoz.trainer` · Android minSdk 23 · iOS 13+.

Dizayn manbasi: `design/ustoz-v2.1-tavsiyalar.html` ("KECHKI ZAL" temasi).
API kontrakti: `docs/openapi.yaml` — har endpoint unga **1:1** mos.
Vazifalar holati: `.claude/state/STATUS.md` (**T0–T9**).

---

## Talablar

- **Flutter** stable (3.44+), **Dart** 3.12+
- Android: **JDK 17**, Android SDK (platform 34+, build-tools 36)
- iOS: **Xcode 15+**, iOS 13+

```bash
flutter doctor
```

---

## Ishga tushirish

API manzili `--dart-define=API_URL` orqali (markazlashgan `Env` klassi).

```bash
flutter pub get
dart run build_runner build          # DTO generatsiyasi (birinchi marta)

# Android emulyator (10.0.2.2 = xost mashina):
flutter run --dart-define=API_URL=http://10.0.2.2:8080/api/v1

# iOS simulyator:
flutter run --dart-define=API_URL=http://localhost:8080/api/v1

# Prism mock (backendsiz):
flutter run --dart-define=API_URL=http://localhost:4010/api/v1
```

Debug buildda komponent galereyasi: `/dev/gallery` (release'da tree-shake).

---

## Build

### Android (release, obfuscated, split-per-abi)

```bash
flutter build apk --release \
  --split-per-abi --obfuscate --split-debug-info=build/symbols \
  --dart-define=API_URL=https://api.ustoz.uz/api/v1
```

Natija: `build/app/outputs/flutter-apk/app-<abi>-release.apk`.
Simvollar `build/symbols/` da (crash de-obfuscation uchun saqlanadi).

### iOS (release)

```bash
flutter build ios --release \
  --obfuscate --split-debug-info=build/symbols \
  --dart-define=API_URL=https://api.ustoz.uz/api/v1
```

---

## Sifat darvozalari (majburiy)

```bash
dart format lib test
flutter analyze          # 0 xato (qattiq lintlar)
flutter test             # hammasi yashil
```

---

## Arxitektura

```
lib/
  core/
    theme/    AppColors (ThemeExtension), AppText, AppSpacing, AppMotion
    widgets/  design system (GlassCard, PlitaRing, StudentCard, …)
    api/      Dio client, interceptorlar (auth/refresh/error), DTO'lar
    router/   go_router — sessiya asosida redirect
    i18n/     AppStrings (uz/ru), AppStringsScope
    storage/  secure storage (token), fayl kesh (LocalStore)
    utils/    money formatter
  features/<feature>/  data / providers (Riverpod) / ui
  dev/gallery.dart     komponent galereyasi (debug-only)
```

**Qatlamlar:** `ui → providers → repository → api`. UI hech qachon xom
`DioException` ko'rmaydi — interceptor uni `AppException` ga aylantiradi.

**Offline (T8):** dashboard/shogirdlar keshi (stale-while-revalidate),
davomad outbox'i (tarmoq qaytganda avtomatik yuborish). To'lov OFFLINE
QILINMAYDI — pul operatsiyasi faqat jonli.

Muhim qarorlar: `.claude/state/DECISIONS.md`.

---

## Texnik qoidalar

- **Pul:** `int` (so'm, butun). Hech qachon `double`.
- **Sana:** `format: date` (TZ'siz) va `format: date-time` (UTC) FARQLI
  parse (`converters.dart`).
- **Telefon:** `+998XXXXXXXXX` (13 belgi). Loglarda mask qilinadi.
- **i18n:** user-facing matn hardcode qilinmaydi — `AppStrings`.
- **Hech narsa DELETE qilinmaydi** — `status=archived`.
