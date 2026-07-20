# USTOZ — trener mobil ilovasi

Flutter 3 · Dart 3 · null-safety · portrait-only (MVP)
Bundle id: `uz.ustoz.trainer` · Android minSdk 23 · iOS 13+

Dizayn manbasi: `design/ustoz-v2.1-tavsiyalar.html` (read-only).
API kontrakti: `docs/openapi.yaml` — har endpoint unga **1:1** mos.

**Boshlashdan oldin ildizdagi `CLAUDE.md` sessiya protokolini o'qi.**
Vazifalar: `.claude/state/STATUS.md` → Mobile ustuni (**T0–T9**).

---

## Toolchain

Bu mashinada toolchain `~/development/` ga o'rnatilgan (sudo'siz, tizimga
tegmasdan — sabab: `DECISIONS.md` **D032**). `~/.bashrc` ga PATH bloki
qo'shilgan, shuning uchun yangi terminalda hech narsa qilish shart emas.

| Nima | Versiya | Joy |
|---|---|---|
| Flutter | 3.44.6 stable | `~/development/flutter` |
| Dart | 3.12.2 | (Flutter ichida) |
| JDK | Temurin 17.0.19 | `~/development/jdk17` |
| Android SDK | platform 36, build-tools 36.0.0, NDK 28.2 | `~/development/android-sdk` |

```bash
flutter doctor        # Flutter ✓ · Android toolchain ✓
```

> `Linux toolchain ✗` — normal. clang/cmake/ninja `sudo apt` talab qiladi va
> faqat `flutter run -d linux` uchun kerak. Mobil ilova, testlar va APK
> ularsiz ishlaydi.

---

## Ishga tushirish

`API_URL` majburiy emas (defaulti bor), lekin aniq berish tavsiya etiladi.
Android emulyatorda xost mashina — `10.0.2.2`, `localhost` EMAS.

```bash
# Jonli backend (backend/ da: make run)
flutter run --dart-define=API_URL=http://10.0.2.2:8080/api/v1

# Prism mock — backend kerak emas.
# Diqqat: prism /api/v1 prefiksini QO'SHMAYDI (SYSTEM.md §1).
npx @stoplight/prism-cli mock ../docs/openapi.yaml --port 4010
flutter run --dart-define=API_URL=http://10.0.2.2:4010

# Real qurilmada: 10.0.2.2 o'rniga kompyuterning LAN IP'si
flutter run --dart-define=API_URL=http://192.168.1.50:8080/api/v1
```

Demo ma'lumot: `cd ../backend && make seed` (3 trener, 18 shogird, tarix bilan).

---

## Sifat darvozalari

Vazifa **yopilmaydi** agar bularning biri qizil bo'lsa:

```bash
dart format --set-exit-if-changed lib test
flutter analyze          # 0 issue
flutter test             # hammasi yashil
```

`analysis_options.yaml` qattiq: `always_use_package_imports` va
`prefer_const_*` — **warning emas, `error`**. Nisbiy import yozib bo'lmaydi.

Kod generatsiyasi (DTO'lar, T2 dan boshlab):

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Build

```bash
# Android release (obfuscate + split-per-abi)
flutter build apk --release --split-per-abi \
  --obfuscate --split-debug-info=build/symbols

# iOS (macOS talab qiladi)
flutter build ios --release
```

**Joriy hajm** (T0 skeleti, 2026-07-20): arm64 **16.3 MB** · armeabi-v7a 13.4 MB
· x86_64 17.7 MB. Byudjet: arm64 < 20 MB (T9).

> `--obfuscate` ishlatilganda `build/symbols` ni **saqlab qo'yish shart** —
> ularsiz release crash-stacktrace'lari o'qib bo'lmas holga keladi.

---

## Struktura

```
lib/
  core/
    api/        dio client + interceptorlar (T2)
    env.dart    --dart-define konfiguratsiya
    i18n/       uz/ru — hardcode matn YO'Q (T7)
    router/     go_router
    storage/    secure storage + fayl kesh (T8)
    theme/      AppColors / AppText / AppSpacing (T1)
    utils/      pul va sana formatterlari
    widgets/    dizayn tizimi komponentlari (T1)
  features/
    <feature>/
      data/       DTO + repository
      providers/  Riverpod
      ui/         ekranlar
  dev/gallery.dart   komponent galereyasi — faqat debug (T1)
```

## Paket siyosati

Ro'yxat **qat'iy** (brief T0): `flutter_riverpod`, `go_router`, `dio`,
`flutter_secure_storage`, `intl`, `json_annotation` (+ `build_runner`,
`json_serializable` dev), `share_plus`, `connectivity_plus`.

Yangi paket — faqat `DECISIONS.md` yozuvi bilan.
**Rasm / animatsiya / UI-kit kutubxonalari mutlaqo taqiqlanadi** — hamma
vizual narsa qo'lda (`CustomPainter` + implicit animations).

Fontlar lokal **variable** TTF, `google_fonts` YO'Q (offline + cold start —
D031). Kirill va lotin qamrovi tekshirilgan.
