abstract final class AppTexts {
  // App
  static const appName = 'Моя бібліотека';

  // Bottom nav
  static const navLibrary   = 'Бібліотека';
  static const navConverter = 'Конвертер';

  // Screen eyebrows
  static const libraryEyebrow   = 'КОЛЕКЦІЯ';
  static const converterEyebrow = 'ВЕБ-НОВЕЛА → EPUB';

  // Splash
  static const splashWordmark = 'EPUB';
  static const splashSubtitle = 'БІБЛІОТЕКА ВЕБ-НОВЕЛ';

  // Library
  static const libraryEmpty      = 'Бібліотека порожня';
  static const libraryEmptyHint  = 'Перейди на вкладку Конвертер\nщоб додати книгу';
  static const serverUnavailable = 'Не вдалося завантажити бібліотеку';
  static const loadError         = 'Не вдалося завантажити';
  static const retry             = 'Спробувати знову';
  static const openOnSite        = 'Відкрити на сайті';
  static const chapters          = 'розділів';
  static const searchHint        = 'Пошук у бібліотеці';
  static const sortRecent        = 'Нещодавні';
  static const sortAz            = 'А–Я';
  static const sortVolume        = 'За обсягом';
  static const nothingFound      = 'Нічого не знайдено';

  // Converter — mode selector
  static const modeLabel           = 'Режим завантаження';
  static const modeFollowNextLabel = 'Кнопка «Далі»';
  static const modeFollowNext      = 'За посиланням';
  static const modePatternLabel    = 'Номер у посиланні';
  static const modePatternSub      = 'chapter-23, page/23';
  static const modePattern         = 'Шаблон {n}';
  static const modePatternDesc     = 'URL містить {n} — скрипт підставляє номер розділу';
  static const modeFollowNextDesc  = 'Скрипт сам переходить за кнопкою "Далі/Наступний"';

  // Converter — follow-next mode fields
  static const urlFirstChapterLabel = 'URL першого розділу';
  static const urlFirstChapterHint  = 'https://site.com/chapter-1';
  static const urlFirstChapterHelper = 'Скрипт сам знайде кнопку «Далі» і перейде на наступний';
  static const followNextHelper     = 'Скрипт сам натисне кнопку «Далі» і перейде до наступного розділу';
  static const limitLabel           = 'Максимум розділів';
  static const limitHint            = 'без обмежень';
  static const limitHelper          = 'Порожньо = завантажити всі підряд';

  // Converter — pattern mode fields
  static const urlAnyChapterLabel = 'URL будь-якого розділу';
  static const urlAnyChapterHint  = 'https://site.com/chapter-23';
  static const chapterNumLabel    = '№ розд.';
  static const urlPatternLabel    = 'URL розділів';
  static const urlPatternHelper   = '{n} буде замінено на номер розділу';
  static const fromChapter        = 'Від розділу';
  static const toChapter          = 'До розділу';
  static const toChapterAutoHint  = 'авто';
  static const toChapterAutoHelper = 'Порожньо = завантажити всі до кінця';
  static const endChapterHint     = 'кінець';
  static const toChapterHelper    = 'Порожньо = до кінця';

  // Converter — common
  static const titleLabel = 'Назва книги';
  static const titleHint  = 'Наприклад: Звільнити цю відьму';
  static const processBtn = 'Опрацювати';
  static const fillFields = 'Вкажи URL та назву книги';

  // Converter — waking stages (cycling messages while server cold-starts)
  static const wakingStages = [
    ('Будимо сервер…',        'Render засинає після 15 хв без активності — перша відповідь триває довше'),
    ('Зачекай трохи…',        'Зазвичай займає 15–30 секунд'),
    ('Він вже прокидається…', 'Безкоштовний план — потрібно трохи терпіння 😴'),
    ('Майже готово…',         'Сервер стартує, ось-ось відповість'),
    ('Ще мить…',              'Дякуємо за терпіння!'),
  ];

  // Converter — progress
  static const starting          = 'Запускаємо…';
  static const loadingTitle      = 'Завантажуємо…';
  static const dontClose         = 'Не закривай додаток — сервер обробляє запит';
  static const publishBtn        = 'Опублікувати на сайті';
  static const publishHint       = 'EPUB готовий. Натисни щоб він зʼявився в Бібліотеці';
  static const epubBuiltHint     = 'EPUB зібрано. Опублікуй, щоб книга з\'явилася в Бібліотеці';
  static const readySuffix       = 'розділів готово!';
  static const nothingDownloaded = 'Жодного розділу не збережено';

  // Converter — published
  static const bookPublished  = 'Книга опублікована!';
  static const siteUpdateHint = 'Через ~1 хвилину зʼявиться на сайті';
  static const publishedHint  = 'Через ~1 хвилину з\'явиться на сайті та в Бібліотеці';
  static const openLibrary    = 'Відкрити бібліотеку';
  static const backToConverter = 'Додати ще книгу';

  // Converter — error / cancel
  static const somethingWrong = 'Щось пішло не так';
  static const tryAgain       = 'Спробувати знову';
  static const cancelBtn      = 'Скасувати';
  static const cancelledTitle = 'Операцію скасовано';

  // Library — delete
  static const deleteTitle      = 'Видалити книгу';
  static const deleteConfirm    = 'Видалити';
  static const deleteConfirmBtn = 'Видалити';
  static const cancel           = 'Скасувати';
}
