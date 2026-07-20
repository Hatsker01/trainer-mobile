.PHONY: help dev-android dev-ios dev-web devices emulator doctor get gen test lint fmt clean

# Android emulyator xost mashinaga `10.0.2.2` orqali murojaat qiladi.
# `localhost` emulyatorning O'ZI — backend u yerda yo'q, shuning uchun ishlamaydi.
API_URL_ANDROID ?= http://10.0.2.2:8080/api/v1

# iOS simulyator xost tarmog'ini BEVOSITA ulashadi — localhost to'g'ri ishlaydi.
API_URL_IOS     ?= http://localhost:8080/api/v1

AVD             ?= ustoz_pixel_api34
ANDROID_HOME    ?= $(HOME)/development/android-sdk
FLUTTER         ?= flutter

help: ## Buyruqlar ro'yxati
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

dev-android: ## Android emulyatorda ishga tushirish (to'g'ri API_URL bilan)
	@./scripts/dev.sh android

dev-ios: ## iOS simulyatorda ishga tushirish (faqat macOS)
	@./scripts/dev.sh ios

dev-web: ## Chrome'da ishga tushirish (tez tekshiruv uchun; MVP scope'da emas)
	@./scripts/dev.sh web

emulator: ## AVD ni fonda ko'tarish (agar o'chiq bo'lsa)
	@./scripts/dev.sh emulator

devices: ## Ulangan qurilmalar
	$(FLUTTER) devices

doctor: ## flutter doctor
	$(FLUTTER) doctor -v

get: ## Paketlarni yuklash
	$(FLUTTER) pub get

gen: ## json_serializable kod generatsiyasi
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

test: ## Testlar
	$(FLUTTER) test

lint: ## Statik tahlil (analysis_options.yaml qattiq)
	$(FLUTTER) analyze

fmt: ## Formatlash
	dart format lib test

clean: ## Build artefaktlarini tozalash
	$(FLUTTER) clean
