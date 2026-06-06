abstract final class AppTexts {
  // App
  static const appName = 'Моя бібліотека';

  // Bottom nav
  static const navLibrary   = 'Бібліотека';
  static const navConverter = 'Конвертер';

  // Library
  static const libraryEmpty     = 'Бібліотека порожня';
  static const libraryEmptyHint = 'Перейди на вкладку Конвертер\nщоб додати книгу';
  static const serverUnavailable = 'Сервер не відповідає';
  static const retry            = 'Спробувати знову';
  static const openOnSite       = 'Відкрити на сайті';
  static const chapters         = 'розділів';

  // Converter — form
  static const urlLabel    = 'URL розділів';
  static const urlHint     = 'https://site.com/chapter-{n}';
  static const urlHelper   = 'Використовуй {n} для номера розділу, або URL першого розділу з перемикачем нижче';
  static const titleLabel  = 'Назва книги';
  static const titleHint   = 'Назва';
  static const fromChapter = 'Від розділу';
  static const toChapter   = 'До розділу';
  static const toChapterHint = 'авто';
  static const followNext     = 'Йти за кнопкою "Наступний розділ"';
  static const followNextHint = 'Якщо URL не має {n} — увімкни це';
  static const processBtn     = 'Опрацювати';
  static const fillFields     = 'Вкажи URL та назву книги';

  // Converter — progress
  static const starting    = 'Запускаємо…';
  static const dontClose   = 'Не закривай додаток — сервер обробляє запит';
  static const publishBtn  = 'Опублікувати';
  static const publishHint = 'Натисни "Опублікувати" — книга зʼявиться на сайті';
  static const readySuffix = 'розділів готово!';

  // Converter — published
  static const bookPublished  = 'Книга опублікована!';
  static const siteUpdateHint = 'Через ~1 хвилину зʼявиться на сайті';
  static const openLibrary    = 'Відкрити бібліотеку';
  static const backToConverter = 'Додати ще книгу';

  // Converter — error
  static const somethingWrong = 'Щось пішло не так';
  static const tryAgain       = 'Спробувати знову';

  // Converter — cancel
  static const cancelBtn      = 'Скасувати';
  static const cancelledTitle = 'Операцію скасовано';
}
