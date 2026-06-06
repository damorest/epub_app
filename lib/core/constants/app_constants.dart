abstract final class AppConstants {
  static const apiBaseUrl     = 'https://witch-book.onrender.com';
  static const libraryBaseUrl = 'https://damorest.github.io/witch-book';
  static const booksJsonUrl   = '$libraryBaseUrl/books.json';
  static const pollInterval   = Duration(seconds: 2);
  static const pingInterval   = Duration(seconds: 20);
}
