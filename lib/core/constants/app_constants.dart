abstract final class AppConstants {
  static const apiBaseUrl     = 'https://witch-book.onrender.com';
  static const libraryBaseUrl = 'https://damorest.github.io/witch-book';
  // raw.githubusercontent.com bypasses GitHub Pages CDN — updates immediately after push
  static const booksJsonUrl   = 'https://raw.githubusercontent.com/damorest/witch-book/main/books.json';
  static const pollInterval   = Duration(seconds: 2);
  static const pingInterval   = Duration(seconds: 20);
}
