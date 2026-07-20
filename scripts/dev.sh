#!/usr/bin/env bash
# USTOZ mobil — lokal ishga tushirish yordamchisi.
#
#   ./scripts/dev.sh android    — emulyatorni ko'taradi va ilovani yuklaydi
#   ./scripts/dev.sh ios        — iOS simulyator (faqat macOS)
#   ./scripts/dev.sh web        — Chrome (tez tekshiruv)
#   ./scripts/dev.sh emulator   — faqat AVD ni ko'taradi
#
# Nima uchun skript kerak: API_URL platformaga qarab FARQ QILADI va noto'g'ri
# qiymat eng ko'p uchraydigan xato. Android emulyatorda `localhost` —
# emulyatorning o'zi, xost mashina emas.
set -euo pipefail

cd "$(dirname "$0")/.."

API_URL_ANDROID="${API_URL_ANDROID:-http://10.0.2.2:8080/api/v1}"
API_URL_IOS="${API_URL_IOS:-http://localhost:8080/api/v1}"
AVD="${AVD:-ustoz_pixel_api34}"
ANDROID_HOME="${ANDROID_HOME:-$HOME/development/android-sdk}"
# Backend healthz — xost tomondan tekshiriladi (emulyatordan emas).
HEALTH_URL="${HEALTH_URL:-http://localhost:8080/healthz}"

red()  { printf '\033[31m%s\033[0m\n' "$*"; }
grn()  { printf '\033[32m%s\033[0m\n' "$*"; }
ylw()  { printf '\033[33m%s\033[0m\n' "$*"; }

check_backend() {
	if curl -sf -m 3 "$HEALTH_URL" >/dev/null 2>&1; then
		grn "✓ backend javob beryapti: $HEALTH_URL"
	else
		red "✗ backend $HEALTH_URL da javob bermayapti."
		ylw "  Ko'taring (repo ildizida):"
		ylw "    docker compose --env-file .env -f deploy/docker-compose.yml up -d postgres migrate"
		ylw "    cd backend && make run"
		exit 1
	fi
}

boot_emulator() {
	export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

	if adb devices 2>/dev/null | grep -q 'emulator-.*device$'; then
		grn "✓ emulyator allaqachon ishlayapti"
		return
	fi

	if ! "$ANDROID_HOME/emulator/emulator" -list-avds 2>/dev/null | grep -qx "$AVD"; then
		red "✗ AVD topilmadi: $AVD"
		ylw "  Yarating:"
		ylw "    sdkmanager 'system-images;android-34;google_apis;x86_64'"
		ylw "    avdmanager create avd -n $AVD -k 'system-images;android-34;google_apis;x86_64' -d pixel_6"
		exit 1
	fi

	ylw "… emulyator ko'tarilmoqda ($AVD)"
	"$ANDROID_HOME/emulator/emulator" -avd "$AVD" \
		-no-snapshot-save -gpu swiftshader_indirect -no-boot-anim \
		>/tmp/ustoz-emulator.log 2>&1 &

	ylw "… boot kutilmoqda (bir necha daqiqa bo'lishi mumkin)"
	for _ in $(seq 1 60); do
		if [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; then
			grn "✓ emulyator tayyor"
			return
		fi
		sleep 5
	done
	red "✗ emulyator 5 daqiqada ko'tarilmadi — /tmp/ustoz-emulator.log ga qarang"
	exit 1
}

case "${1:-android}" in
android)
	check_backend
	boot_emulator
	grn "→ API_URL=$API_URL_ANDROID"
	exec flutter run -d emulator-5554 --dart-define=API_URL="$API_URL_ANDROID"
	;;
ios)
	[[ "$(uname)" == "Darwin" ]] || { red "✗ iOS faqat macOS da"; exit 1; }
	check_backend
	open -a Simulator || true
	grn "→ API_URL=$API_URL_IOS"
	exec flutter run -d iPhone --dart-define=API_URL="$API_URL_IOS"
	;;
web)
	check_backend
	# Web'da brauzer CORS qo'llaydi — backend ruxsat bermasa so'rov bloklanadi.
	ylw "eslatma: web MVP scope'ida emas (brief T0: Android + iOS)"
	grn "→ API_URL=$API_URL_IOS"
	exec flutter run -d chrome --dart-define=API_URL="$API_URL_IOS"
	;;
emulator)
	boot_emulator
	;;
*)
	red "noma'lum rejim: $1 (android | ios | web | emulator)"
	exit 1
	;;
esac
