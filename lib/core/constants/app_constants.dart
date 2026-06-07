abstract final class AppConstants {
  static const apiBaseUrl     = 'https://witch-book.onrender.com';
  static const libraryBaseUrl = 'https://damorest.github.io/witch-book';
  // GitHub Contents API — reads directly from git, not CDN-cached like raw.githubusercontent.com
  static const booksJsonUrl   = 'https://api.github.com/repos/damorest/witch-book/contents/books.json';
  static const pollInterval   = Duration(seconds: 2);
  static const pingInterval   = Duration(seconds: 20);
}
