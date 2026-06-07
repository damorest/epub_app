import '../models/book_model.dart';
import '../services/api_service.dart';
import '../services/library_service.dart';

class LibraryRepository {
  final LibraryService _library;
  final ApiService _api;

  LibraryRepository({LibraryService? service, ApiService? api})
      : _library = service ?? LibraryService(),
        _api = api ?? ApiService();

  Future<List<BookModel>> fetchBooks() async {
    final raw = await _library.fetchBooks();
    return raw.map(BookModel.fromJson).toList();
  }

  Future<void> deleteBook(String slug) => _api.deleteBook(slug);
}
