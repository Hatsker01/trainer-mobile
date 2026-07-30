import 'package:flutter/widgets.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';

/// i18n — `uz` / `ru`.
///
/// CLAUDE.md: user-facing matn HARDCODE QILINMAYDI. Har matn shu klassda
/// bitta getter — `_p(uz, ru)`. Bitta joyda turgani uchun "hardcode ovi"
/// oson: ekranlarda tirnoq ichida matn qolgan bo'lsa — u xato.
///
/// `flutter_localizations` / `gen-l10n` ISHLATILMADI: paket siyosati qattiq
/// va MVP da atigi 2 til bor — kodgeneratsiya narxi foydasidan katta.
class AppStrings {
  const AppStrings(this.lang);

  final Lang lang;

  String _p(String uz, String ru) => lang == Lang.uz ? uz : ru;

  // ------------------------------------------------------------- umumiy
  String get appName => 'USTOZ';
  String get save => _p('Saqlash', 'Сохранить');
  String get cancel => _p('Bekor qilish', 'Отмена');
  String get retry => _p('Qayta urinish', 'Повторить');
  String get next => _p('Davom etish', 'Продолжить');
  String get skip => _p("O'tkazib yuborish", 'Пропустить');
  String get done => _p('Tayyor', 'Готово');
  String get delete => _p('Arxivlash', 'Архивировать');
  String get edit => _p('Tahrirlash', 'Редактировать');
  String get search => _p('Qidirish', 'Поиск');
  String get all => _p('Hammasi', 'Все');
  String get sum => _p("so'm", 'сум');
  String get today => _p('Bugun', 'Сегодня');
  String get loading => _p('Yuklanmoqda…', 'Загрузка…');
  String get updating => _p('Yangilanmoqda…', 'Обновление…');

  // -------------------------------------------------------------- xatolar
  String get errNetwork =>
      _p("Internet aloqasi yo'q", 'Нет подключения к интернету');
  String get errGeneric => _p('Xatolik yuz berdi', 'Произошла ошибка');
  String get errTryAgain => _p("Qayta urinib ko'ring", 'Попробуйте ещё раз');

  // ----------------------------------------------------------- onboarding
  String get onb1Title =>
      _p('Shogirdlaringiz bir joyda', 'Ученики в одном месте');
  String get onb1Body => _p(
    "Kim to'ladi, kim qarzdor — bir qarashda ko'rinadi",
    'Кто заплатил, кто должен — видно с первого взгляда',
  );
  String get onb2Title => _p("To'lovni unutmaysiz", 'Не забудете про оплату');
  String get onb2Body => _p(
    "Eslatma shogirdga Telegram orqali o'zi ketadi",
    'Напоминание уходит ученику в Telegram автоматически',
  );
  String get onb3Title =>
      _p('Daromadingiz ko\'z oldingizda', 'Доход перед глазами');
  String get onb3Body => _p(
    'Oylik daromad, qarzdorlik va davomad — bitta ekranda',
    'Месячный доход, долги и посещаемость — на одном экране',
  );
  String get onbStart => _p('Boshlash', 'Начать');

  // ----------------------------------------------------------------- auth
  String get phoneTitle => _p('Telefon raqamingiz', 'Ваш номер телефона');
  String get phoneSubtitle =>
      _p('Tasdiqlash kodi yuboriladi', 'Отправим код подтверждения');
  String get phoneInvalid =>
      _p("Raqam to'liq emas", 'Номер введён не полностью');
  String get otpTitle => _p('Tasdiqlash kodi', 'Код подтверждения');
  String otpSubtitle(String phone) =>
      _p('$phone raqamiga yuborildi', 'Отправлен на $phone');
  String get otpInvalid => _p("Kod noto'g'ri", 'Неверный код');
  String get otpExpired => _p('Kod muddati tugagan', 'Срок кода истёк');
  String get otpResend => _p('Kodni qayta yuborish', 'Отправить код снова');
  String otpResendIn(int seconds) =>
      _p('Qayta yuborish — ${seconds}s', 'Повторить через $secondsс');
  String rateLimited(int seconds) => _p(
    'Juda ko\'p urinish. ${seconds}s dan keyin urinib ko\'ring',
    'Слишком много попыток. Повторите через $secondsс',
  );
  String get otpChannelTg =>
      _p('Kod Telegram orqali yuborildi', 'Код отправлен в Telegram');
  String get otpChannelSms =>
      _p('Kod SMS orqali yuborildi', 'Код отправлен по SMS');

  // -------------------------------------------------------------- profil
  String get profileTitle => _p('O\'zingiz haqingizda', 'О себе');
  String get profileSubtitle => _p(
    'Shogirdlar sizni shu nom bilan ko\'radi',
    'Ученики увидят вас под этим именем',
  );
  String get fieldName => _p('Ismingiz', 'Ваше имя');
  String get fieldGym => _p('Zal nomi', 'Название зала');
  String get fieldOptional => _p('ixtiyoriy', 'необязательно');
  String get fieldRequired =>
      _p("Bu maydon to'ldirilishi kerak", 'Обязательное поле');

  // ----------------------------------------------------------- dashboard
  String greeting(String name) => _p('Salom, $name', 'Привет, $name');
  String streakDays(int days) => _p('$days kun', '$days дн.');

  // ---------------------------------------------- REDESIGN (dashboard/umumiy)
  String get dashSubtitle =>
      _p("Bugungi umumiy ma'lumotlar", 'Общая информация за сегодня');
  String get kpiMonthRevenue => _p('Oylik daromad', 'Месячный доход');
  String get kpiThisMonth => _p('Shu oy', 'Этот месяц');
  String get kpiTotalDebt => _p('Jami qarzdorlik', 'Общий долг');
  String get kpiActiveStudents => _p('Faol shogirdlar', 'Активные ученики');
  String get statusPaidShort => _p("To'langan", 'Оплачено');
  String get statusPendingShort => _p('Kutilmoqda', 'Ожидается');
  String get quickActions => _p('Tezkor amallar', 'Быстрые действия');
  String get recentActivity => _p("So'nggi faoliyat", 'Последние действия');
  String get seeAll => _p("Barchasini ko'rish", 'Смотреть все');
  String studentsCount(int n) => _p('$n shogird', '$n учеников');
  String get activityPaid => _p("To'lov qabul qilindi", 'Оплата принята');
  String get activityPartial => _p("Qisman to'lov", 'Частичная оплата');
  String get activityOverdue => _p("Muddati o'tgan", 'Просрочено');

  // ------------------------------------------------ REDESIGN (shogird kartasi)
  String get currentBalance => _p('Joriy balans', 'Текущий баланс');
  String get totalPaidLabel => _p("Jami to'langan", 'Всего оплачено');
  String get lastPaymentLabel => _p("Oxirgi to'lov", 'Последняя оплата');
  String get badgeDebt => _p('Qarz', 'Долг');
  String get badgePaid => _p('Faol', 'Активен');
  String daysLate(int n) => _p('$n kun kechikdi', '$n дн. просрочки');

  // ------------------------------------------------ REDESIGN (shogird profili)
  String get studentProfileTitle => _p('Shogird profili', 'Профиль ученика');
  String get monthlyFeeLabel => _p("Oylik to'lov", 'Ежемесячная оплата');
  String get paymentPaid => _p("To'langan", 'Оплачено');
  String get paymentPartial => _p('Qisman', 'Частично');

  // ------------------------------------------------------- REDESIGN (kalendar)
  String get calendarTitle => _p('Kalendar', 'Календарь');
  String get calPlanned => _p('Rejal', 'План');
  String get legendTitle => _p('Belgilar', 'Обозначения');
  String get legendPaid => _p("To'langan to'lovlar", 'Оплаченные платежи');
  String get legendPartial => _p("Qisman to'lovlar", 'Частичные платежи');
  String get legendPlanned =>
      _p("Rejalashtirilgan to'lovlar", 'Запланированные платежи');
  String get dayPaymentsTitle => _p("To'lovlar", 'Платежи');
  String get noPaymentsDay =>
      _p("Bu kunda to'lov yo'q", 'Нет платежей в этот день');
  String get legendUnpaid => _p("To'lanmagan", 'Не оплачено');
  String get statusUnpaidLabel => _p("To'lanmagan", 'Не оплачено');
  String get calRemainder => _p('Qoldiq', 'Остаток');
  String get calAddPaymentRemainder =>
      _p("Qoldiqni to'lash", 'Оплатить остаток');

  /// "Iyul: 12 to'liq · 2 qisman · 3 kutilmoqda".
  String calMonthSummary(int month, int full, int partial, int planned) => _p(
    '${monthName(month)}: $full to\'liq · $partial qisman · $planned kutilmoqda',
    '${monthName(month)}: $full полн. · $partial частичн. · $planned ожид.',
  );

  // ------------------------------------------------- REDESIGN (bildirishnoma)
  String get notificationsTitle => _p('Bildirishnomalar', 'Уведомления');
  String newCount(int n) => _p('$n yangi', '$n новых');
  String dueOverdueDays(int n) => _p(
    "To'lov muddati $n kun oldin o'tgan",
    'Срок оплаты прошёл $n дн. назад',
  );
  String get dueTodayMsg => _p("To'lov muddati bugun", 'Срок оплаты сегодня');
  String weeksAgo(int n) => _p('$n hafta oldin', '$n нед. назад');
  String get noNotifications => _p("Bildirishnoma yo'q", 'Нет уведомлений');
  String get notifDetailTitle =>
      _p('Bildirishnoma tafsilotlari', 'Детали уведомления');
  String get markPaidAction =>
      _p("To'langan deb belgilash", 'Отметить оплаченным');
  String get viewProfile => _p("Profilni ko'rish", 'Открыть профиль');

  // ------------------------------------------------------- REDESIGN (navigatsiya)
  /// TZ §3.0: bottom bar "Bugun" deydi — "Bosh sahifa" emas.
  /// Trener ertalab ochadi va AYNAN bugunni ko'radi.
  String get navHome => _p('Bugun', 'Сегодня');
  String get navSettings => _p('Sozlamalar', 'Настройки');

  /// Bottom bar: Bugun · Shogirdlar · Jadval · Kassa · Menyu (TZ §3.0).
  String get navSchedule => _p('Jadval', 'Расписание');
  String get navCash => _p('Kassa', 'Касса');
  String get navMenu => _p('Menyu', 'Меню');

  // ── Kassa (TZ §3.6) ──
  String get cashPaid => _p("To'langan", 'Оплачено');
  String get cashDueSoon => _p('Yaqin', 'Скоро');
  String get cashOverdue => _p('Qarzdor', 'Долг');
  String get cashDebtTotal => _p('Jami qarz', 'Общий долг');
  String get cashEmptyTitle => _p("Kassa bo'sh", 'Касса пуста');
  String get cashEmptyMessage => _p(
    "Shogird qo'shsangiz to'lov holati shu yerda ko'rinadi.",
    'Добавьте ученика — статус оплат появится здесь.',
  );
  String get cashNoMatchTitle =>
      _p('Bu holatda shogird yo\'q', 'Нет учеников с этим статусом');
  String get cashNoMatchMessage => _p(
    'Boshqa filtrni tanlang yoki hammasini ko\'ring.',
    'Выберите другой фильтр или посмотрите всех.',
  );
  String get showAll => _p('Hammasini ko\'rsatish', 'Показать всех');

  // ------------------------------------------------------ REDESIGN (tavsiyalar)
  String get recommendationsTab => _p('Tavsiyalar', 'Рекомендации');
  String get addRecommendation =>
      _p("Tavsiya qo'shish", 'Добавить рекомендацию');
  String get recCategory => _p('Kategoriya', 'Категория');
  String get recTextHint => _p('Tavsiya matni…', 'Текст рекомендации…');
  String get linkProduct => _p("Mahsulot bog'lash", 'Привязать товар');
  String get toAllStudents => _p('Barcha shogirdlarga', 'Всем ученикам');
  String get referralHint => _p('Referal', 'Реферал');
  String get noRecommendations =>
      _p("Hali tavsiya yo'q", 'Пока нет рекомендаций');
  String recSentTo(String name) => _p(
    '✓ $name ga yuborildi — app + Telegram',
    '✓ Отправлено $name — app + Telegram',
  );
  String get recBroadcastSent =>
      _p('✓ Barcha shogirdlarga yuborildi', '✓ Отправлено всем ученикам');
  String get recDelete => _p("O'chirish", 'Удалить');
  String get recDeleteConfirm =>
      _p("Tavsiyani o'chirasizmi?", 'Удалить рекомендацию?');
  String get searchProduct => _p('Mahsulot qidirish', 'Поиск товара');
  String get send => _p('Yuborish', 'Отправить');
  String recCategoryName(String c) {
    switch (c) {
      case 'sportpit':
        return _p('Sport pit', 'Спортпит');
      case 'water':
        return _p('Suv', 'Вода');
      case 'sleep':
        return _p('Uyqu', 'Сон');
      case 'nutrition':
        return _p('Ovqatlanish', 'Питание');
      case 'training':
        return _p("Mashg'ulot", 'Тренировка');
      default:
        return _p('Boshqa', 'Другое');
    }
  }

  // ---------------------------------------------------------- REDESIGN (obuna)
  String get trainerRole => _p('Shaxsiy murabbiy', 'Персональный тренер');
  String get gymNameLabel => _p('Zal nomi', 'Название зала');
  String get languageSettings => _p('Til sozlamalari', 'Настройки языка');
  String get langUz => _p("O'zbek", 'Узбекский');
  String get langRu => _p('Rus', 'Русский');
  String get subscriptionTitle => _p('Obuna', 'Подписка');
  String get currentPlanLabel => _p('Joriy tarif', 'Текущий тариф');
  String get planPremium => 'Premium';
  String get nextPaymentLabel => _p("Keyingi to'lov", 'Следующая оплата');
  String get daysLeftLabel => _p('Qolgan kunlar', 'Осталось дней');
  String get changePlan => _p("Tarifni o'zgartirish", 'Изменить тариф');
  String get choosePlanTitle =>
      _p('Tarif rejasini tanlang', 'Выберите тарифный план');
  String get confirmAndPay =>
      _p("Tasdiqlash va to'lash", 'Подтвердить и оплатить');
  String get perMonth => _p('/ oy', '/ мес');
  String get noBillingHistory =>
      _p("To'lov tarixi yo'q", 'Нет истории платежей');
  List<String> get planFreeFeatures => _p2(
    const <String>[
      '10 tagacha shogird',
      "Asosiy to'lov kuzatuvi",
      "Kalendar ko'rinishi",
    ],
    const <String>['До 10 учеников', 'Базовый учёт оплат', 'Календарь'],
  );
  List<String> get planPremiumFeatures => _p2(
    const <String>[
      'Cheksiz shogirdlar',
      "Ilg'or to'lov kuzatuvi",
      'Avtomatik bildirishnomalar',
      'Hisobotlar va statistika',
      "Prioritet qo'llab-quvvatlash",
    ],
    const <String>[
      'Неограниченно учеников',
      'Продвинутый учёт оплат',
      'Автоуведомления',
      'Отчёты и статистика',
      'Приоритетная поддержка',
    ],
  );

  List<String> _p2(List<String> uz, List<String> ru) =>
      lang == Lang.uz ? uz : ru;
  String monthIncome(String month) => _p('$month daromadi', 'Доход за $month');
  String get goal => _p('maqsad', 'цель');

  // ------------------------------------------- G2/G4 (dashboard zichlik + maqsad)
  String get monthlyGoalLabel => _p('Oylik maqsad', 'Цель на месяц');
  String get setGoalPrompt =>
      _p('Oylik maqsad qo\'ying', 'Установите цель на месяц');
  String get setGoal => _p('Maqsad qo\'yish', 'Установить цель');
  String collectedPercent(int p) => _p('Yig\'ildi: $p%', 'Собрано: $p%');
  String get todaySection => _p('BUGUN', 'СЕГОДНЯ');
  String get qaPayment => _p('To\'lov', 'Оплата');
  String get qaStudent => _p('Shogird', 'Ученик');
  String get qaAttendance => _p('Davomad', 'Посещ.');
  String get goalReached50 =>
      _p('Maqsadning yarmiga yetdingiz! 💪', 'Половина цели достигнута! 💪');
  String get goalReached100 =>
      _p('Oylik maqsad bajarildi! 🎯', 'Цель месяца выполнена! 🎯');
  String daysOverdueShort(int n) => _p('$n kun', '$n дн.');
  String get dueToday => _p("Bugun to'lov", 'Оплата сегодня');
  String get dueSoon => _p('3 kun ichida', 'В ближайшие 3 дня');
  String get overdue => _p('Qarzdorlar', 'Должники');
  String get todaySchedule => _p('Bugungi jadval', 'Расписание на сегодня');
  String get allClear =>
      _p('Bugun hammasi joyida 💪', 'Сегодня всё в порядке 💪');
  String get markPaid => _p("✓ To'landi", '✓ Оплачено');
  String get remind => _p('Eslatish', 'Напомнить');
  String get reminderSent =>
      _p('✓ Eslatma yuborildi', '✓ Напоминание отправлено');
  String get noDuesToday =>
      _p("Bugun to'lov kutilmayapti", 'Сегодня оплат не ожидается');
  String get noSchedule => _p("Bugun mashg'ulot yo'q", 'Сегодня занятий нет');

  // Kassa svetofori (dashboard) — prototip v3.
  String get kassaTrafficLight => _p('Kassa svetofori', 'Касса-светофор');
  String get tlPaid => _p("to'langan", 'оплатили');
  String get tlSoon => _p('yaqin', 'скоро');
  String get tlDebt => _p('qarzdor', 'должники');
  String redsDebt(String amount) =>
      _p('Qizillar: $amount qarz', 'Красные: долг $amount');
  String get cameToday => _p('Bugun keldi', 'Пришли сегодня');

  // Prototip v3 ekranlari (students/form/stats).
  String get archivedHint => _p(
    "Arxivlangan shogirdlar qidiruvda kulrang ko'rinadi · 1 tap bilan qayta faollashtiriladi",
    'Архивные ученики отображаются серым в поиске · повторная активация в 1 касание',
  );
  String get studentFullName => _p('Ism-familiya', 'Имя и фамилия');
  String get phoneLabel => _p('Telefon', 'Телефон');
  String get sessionsTotalLabel =>
      _p("Mashg'ulotlar soni", 'Количество занятий');
  String get statPrevMonth => _p("O'TGAN OY", 'ПРОШЛЫЙ МЕСЯЦ');
  String get cashIncome => _p('tushum', 'поступления');
  String get cashExpected => _p('Kutilmoqda', 'Ожидается');
  String get cashDebtWord => _p('Qarz', 'Долг');
  String get cashGrowth => _p("O'sish", 'Рост');

  // Menyu / Sozlamalar (prototip v3).
  String get menu => _p('Menyu', 'Меню');
  String get proTitle => _p('USTOZ PRO', 'USTOZ PRO');
  String get subscriptionActive => _p('Obuna faol', 'Подписка активна');
  String get menuProUpsell =>
      _p('Cheksiz shogird va hisobotlar', 'Безлимит учеников и отчёты');
  String get botSettings => _p('Bot sozlamalari', 'Настройки бота');
  String get connected => _p('Ulangan', 'Подключён');
  String get notConnected => _p('Ulanmagan', 'Не подключён');
  String get theme => _p('Tema', 'Тема');
  String get themeDark => _p('Qora', 'Тёмная');
  String get themeLight => _p('Oq', 'Светлая');

  // Churn radar (§3.9).
  String get churnSectionTitle => _p('Churn radar', 'Churn-радар');
  String churnRiskTitle(String name) =>
      _p('Ketish riski · $name', 'Риск ухода · $name');
  String get churnReasonDebt =>
      _p("To'lov muddati o'tgan — bog'laning", 'Просрочена оплата — свяжитесь');
  String get churnReasonMiss =>
      _p('2 haftadan beri kelmayapti', 'Не приходит 2 недели');
  String get churnReasonDrop =>
      _p('Kelish chastotasi tushib ketdi', 'Частота посещений упала');
  String get churnSendMessage => _p('Xabar yuborish', 'Написать');
  String get churnRadar => _p('Radar', 'Радар');
  String get churnEmpty =>
      _p('Hozircha riskda shogird yo\'q 👍', 'Пока нет учеников в зоне риска 👍');
  String churnReason(String reason) => switch (reason) {
    'debt_overdue' => churnReasonDebt,
    'consecutive_miss' => churnReasonMiss,
    'attendance_drop' => churnReasonDrop,
    _ => churnReasonMiss,
  };

  // ----------------------------------------------------------- shogirdlar
  String get students => _p('Shogirdlar', 'Ученики');
  String activeCount(int n) => _p('$n aktiv', '$n активных');
  String get filterDebtors => _p('Qarzdor', 'Должники');
  String get filterUpcoming => _p('Yaqin', 'Скоро');
  String get filterActive => _p('Aktiv', 'Активные');
  String get filterArchived => _p('Arxiv', 'Архив');
  String get searchHint => _p('Ism yoki telefon', 'Имя или телефон');
  String get noStudents => _p('Hali shogird yo\'q', 'Учеников пока нет');
  String get noStudentsFound => _p('Hech narsa topilmadi', 'Ничего не найдено');
  String get addStudent => _p("Shogird qo'shish", 'Добавить ученика');
  String get student => _p('Shogird', 'Ученик');
  String get archiveConfirm => _p(
    'Shogird arxivga o\'tkaziladi. Ma\'lumotlari saqlanadi.',
    'Ученик будет перемещён в архив. Данные сохранятся.',
  );
  String get archived => _p('Arxivlandi', 'Архивирован');
  String get inviteSend => _p('Taklif yuborish', 'Отправить приглашение');
  String get tgConnected => _p('TG ulangan', 'TG подключён');
  String get tgNotConnected => _p('TG ulanmagan', 'TG не подключён');
  String get notConnectedToBot => _p(
    'Shogird Telegram botga ulanmagan',
    'Ученик не подключён к Telegram-боту',
  );

  // ------------------------------------------------------------- tariflar
  String get tariff => _p('Tarif', 'Тариф');
  String get tariffMonthly => _p('Oylik', 'Месячный');
  String get tariffPackage => _p('Paket', 'Пакет');
  String get tariffSingle => _p('Yakka', 'Разовый');
  String get tariffTemplates => _p('Tarif shablonlari', 'Шаблоны тарифов');
  String get tariffNew => _p('Yangi tarif', 'Новый тариф');
  String get price => _p('Narxi', 'Цена');
  String sessionsLeft(int n) => _p('$n qoldi', 'осталось $n');
  String sessionsOf(int total) => _p('$total mashg\'ulot', '$total занятий');

  String tariffName(TariffType type) => switch (type) {
    TariffType.monthly => tariffMonthly,
    TariffType.package => tariffPackage,
    TariffType.single => tariffSingle,
  };

  // -------------------------------------------------------------- to'lov
  String get payment => _p("To'lov", 'Оплата');
  String get addPayment => _p("To'lov qo'shish", 'Добавить оплату');
  String get savePayment => _p("To'lovni saqlash", 'Сохранить оплату');
  String get amount => _p('Summa', 'Сумма');
  String get paymentDate => _p("To'lov sanasi", 'Дата оплаты');
  String get method => _p('Usul', 'Способ');
  String get methodCash => _p('Naqd', 'Наличные');
  String get methodCard => _p('Karta', 'Карта');
  String nextPayment(String date) =>
      _p("Keyingi to'lov: $date", 'Следующая оплата: $date');
  String get paymentHistory => _p("To'lovlar", 'Платежи');
  String get history => _p('tarix', 'история');
  String get noPayments => _p("Hali to'lov yo'q", 'Платежей пока нет');
  String get receiptNote => _p(
    'Shogirdga Telegram orqali chek yuboriladi 📨',
    'Ученику отправится чек в Telegram 📨',
  );
  String paymentSaved(String? nextDue) => nextDue == null
      ? _p('✓ Saqlandi', '✓ Сохранено')
      : _p(
          "✓ Saqlandi. Keyingi to'lov: $nextDue",
          '✓ Сохранено. Следующая оплата: $nextDue',
        );

  String methodName(PaymentMethod m) => switch (m) {
    PaymentMethod.cash => methodCash,
    PaymentMethod.card => methodCard,
    PaymentMethod.payme => 'Payme',
    PaymentMethod.click => 'Click',
  };

  // -------------------------------------------------------------- davomad
  String get attendance => _p('Davomad', 'Посещаемость');
  String get markAttendance => _p('Davomad belgilash', 'Отметить посещаемость');
  String get lastWeeks => _p('oxirgi 8 hafta', 'последние 8 недель');
  String attendanceSaved(int marked) =>
      _p('✓ $marked ta belgilandi', '✓ Отмечено: $marked');
  String get noAttendance => _p('Davomad yo\'q', 'Нет посещений');

  // ----------------------------------------------------------- statistika
  String get stats => _p('Statistika', 'Статистика');
  String get statRevenue => _p('DAROMAD', 'ДОХОД');
  String get statDebt => _p('QARZDORLIK', 'ДОЛГИ');
  String get statActive => _p('AKTIV SHOGIRD', 'АКТИВНЫХ');
  String get statAttendance => _p("O'RTACHA DAVOMAD", 'СРЕДНЯЯ ПОСЕЩ.');
  String get revenueDynamics => _p('Daromad dinamikasi', 'Динамика дохода');
  String get byTariff => _p("Tariflar bo'yicha", 'По тарифам');
  String get sixMonths => _p('6 oy', '6 мес.');
  String debtorsCount(int n) => _p('$n shogird', '$n учеников');
  String get noStats => _p("Hali ma'lumot yo'q", 'Данных пока нет');

  // ------------------------------------------------------------ sozlamalar
  String get settings => _p('Sozlamalar', 'Настройки');
  String get profile => _p('Profil', 'Профиль');
  String get language => _p('Til', 'Язык');
  String get remindTime => _p('Eslatma vaqti', 'Время напоминаний');
  String get subscription => _p('Obuna', 'Подписка');
  String get planFree => _p('Bepul', 'Бесплатный');
  String get telegram => _p('Telegram', 'Telegram');
  String get connectTg => _p('Botni ulash', 'Подключить бота');
  String get signOut => _p('Chiqish', 'Выйти');
  String get signOutConfirm =>
      _p('Hisobdan chiqmoqchimisiz?', 'Выйти из аккаунта?');

  // ---------------------------------------------------------------- offline
  String get offlineBanner => _p(
    "Internet yo'q — saqlandi, keyin yuboriladi",
    'Нет интернета — сохранено, отправим позже',
  );
  String get offlineCached => _p(
    "Internet yo'q — oxirgi ma'lumot ko'rsatilmoqda",
    'Нет интернета — показаны последние данные',
  );
  String get paymentNeedsOnline =>
      _p("To'lov uchun internet kerak", 'Для оплаты нужен интернет');
  String pendingSync(int n) =>
      _p('$n ta belgi yuborilmoqda…', 'Отправляется отметок: $n');

  // ------------------------------------------------------------------ sana
  /// O'zbekcha oy nomlari (bosh kelishik) — `intl` ning `uz` lokali
  /// to'liq emas, shuning uchun qo'lda.
  static const List<String> _monthsUz = <String>[
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentabr',
    'oktabr',
    'noyabr',
    'dekabr',
  ];

  static const List<String> _monthsRu = <String>[
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  static const List<String> _monthsShortUz = <String>[
    'Yan',
    'Fev',
    'Mar',
    'Apr',
    'May',
    'Iyn',
    'Iyl',
    'Avg',
    'Sen',
    'Okt',
    'Noy',
    'Dek',
  ];

  static const List<String> _monthsShortRu = <String>[
    'Янв',
    'Фев',
    'Мар',
    'Апр',
    'Май',
    'Июн',
    'Июл',
    'Авг',
    'Сен',
    'Окт',
    'Ноя',
    'Дек',
  ];

  static const List<String> _weekdaysUz = <String>[
    'Dushanba',
    'Seshanba',
    'Chorshanba',
    'Payshanba',
    'Juma',
    'Shanba',
    'Yakshanba',
  ];

  static const List<String> _weekdaysRu = <String>[
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  /// `19-iyul` / `19 июля`.
  String dayMonth(DateTime d) => lang == Lang.uz
      ? '${d.day}-${_monthsUz[d.month - 1]}'
      : '${d.day} ${_monthsRu[d.month - 1]}';

  /// `Yakshanba, 19-iyul` / `Воскресенье, 19 июля`.
  String weekdayDayMonth(DateTime d) {
    final String weekday = lang == Lang.uz
        ? _weekdaysUz[d.weekday - 1]
        : _weekdaysRu[d.weekday - 1];
    return '$weekday, ${dayMonth(d)}';
  }

  /// `16-avgust, 2026` / `16 августа 2026`.
  String fullDate(DateTime d) => lang == Lang.uz
      ? '${dayMonth(d)}, ${d.year}'
      : '${dayMonth(d)} ${d.year}';

  /// Oy nomi bosh harf bilan: `Iyul` / `Июль`.
  String monthName(int month) => lang == Lang.uz
      ? _capitalize(_monthsUz[month - 1])
      : _capitalize(_monthsRu[month - 1]);

  /// Grafik yorlig'i: `Iyl` / `Июл`.
  String monthShort(int month) =>
      lang == Lang.uz ? _monthsShortUz[month - 1] : _monthsShortRu[month - 1];

  /// Kalendar ustun sarlavhalari (Du..Ya).
  List<String> get weekdayShort => lang == Lang.uz
      ? const <String>['Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sha', 'Ya']
      : const <String>['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  /// `Fevral 2026`.
  String monthYear(DateTime d) => '${monthName(d.month)} ${d.year}';

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// `context.s.students` — har widget'da provider o'qimaslik uchun.
///
/// `AppStringsScope` `MaterialApp` ustida turadi va til o'zgarganda
/// BUTUN daraxtni qayta quradi (T7: "til almashganda BARCHA ekran
/// matnlari almashadi").
class AppStringsScope extends InheritedWidget {
  const AppStringsScope({
    required this.strings,
    required super.child,
    super.key,
  });

  final AppStrings strings;

  static AppStrings of(BuildContext context) {
    final AppStringsScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppStringsScope>();
    return scope?.strings ?? const AppStrings(Lang.uz);
  }

  @override
  bool updateShouldNotify(AppStringsScope old) =>
      old.strings.lang != strings.lang;
}

extension AppStringsX on BuildContext {
  AppStrings get s => AppStringsScope.of(this);
}
