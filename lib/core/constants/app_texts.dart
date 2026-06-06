abstract final class AppTexts {
  // App
  static const appName = 'Моя бібліотека';

  // Bottom nav
  static const navLibrary   = 'Бібліотека';
  static const navConverter = 'Конвертер';

  // Library
  static const libraryEmpty       = 'Бібліотека порожня';
  static const libraryEmptyHint   = 'Перейди на вкладку Конвертер\nщоб додати книгу';
  static const serverUnavailable  = 'Не вдалося завантажити бібліотеку';
  static const retry              = 'Спробувати знову';
  static const openOnSite         = 'Відкрити на сайті';
  static const chapters           = 'розділів';

  // Converter — mode selector
  static const modeLabel          = 'Режим завантаження';
  static const modePattern        = 'Шаблон {n}';
  static const modeFollowNext     = 'За посиланням';
  static const modePatternDesc    = 'URL містить {n} — скрипт підставляє номер розділу';
  static const modeFollowNextDesc = 'Скрипт сам переходить за кнопкою "Далі/Наступний"';

  // Converter — pattern mode fields
  static const urlPatternLabel    = 'URL розділів';
  static const urlPatternHelper   = '{n} буде замінено на номер розділу';
  static const fromChapter        = 'Від розділу';
  static const toChapter          = 'До розділу';
  static const toChapterAutoHint  = 'авто';
  static const toChapterAutoHelper= 'Порожньо = завантажити всі до кінця';

  // Converter — follow-next mode fields
  static const urlFirstChapterLabel  = 'URL першого розділу';
  static const urlFirstChapterHelper = 'Скрипт сам знайде кнопку «Далі» і перейде на наступний';
  static const limitLabel            = 'Максимум розділів';
  static const limitHint             = 'без обмежень';
  static const limitHelper           = 'Порожньо = завантажити всі підряд';

  // Converter — common
  static const titleLabel   = 'Назва книги';
  static const titleHint    = 'Наприклад: Звільнити цю відьму';
  static const processBtn   = 'Опрацювати';
  static const fillFields   = 'Вкажи URL та назву книги';

  // Converter — progress
  static const starting    = 'Запускаємо…';
  static const dontClose   = 'Не закривай додаток — сервер обробляє запит';
  static const publishBtn  = 'Опублікувати на сайті';
  static const publishHint = 'EPUB готовий. Натисни щоб він зʼявився в Бібліотеці';
  static const readySuffix = 'розділів готово!';

  // Converter — published
  static const bookPublished   = 'Книга опублікована!';
  static const siteUpdateHint  = 'Через ~1 хвилину зʼявиться на сайті';
  static const openLibrary     = 'Відкрити бібліотеку';
  static const backToConverter = 'Додати ще книгу';

  // Converter — error / cancel
  static const somethingWrong  = 'Щось пішло не так';
  static const tryAgain        = 'Спробувати знову';
  static const cancelBtn       = 'Скасувати';
  static const cancelledTitle  = 'Операцію скасовано';

  // Library — delete
  static const deleteTitle      = 'Видалити книгу';
  static const deleteConfirm    = 'Видалити';
  static const deleteConfirmBtn = 'Видалити';
  static const cancel           = 'Скасувати';
}
