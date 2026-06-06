import '../models/book_model.dart';
import '../services/library_service.dart';

class LibraryRepository {
  final LibraryService _service;

  LibraryRepository({LibraryService? service})
      : _service = service ?? LibraryService();

  Future<List<BookModel>> fetchBooks() async {
    final raw = await _service.fetchBooks();
    return raw.map(BookModel.fromJson).toList();
  }
}
