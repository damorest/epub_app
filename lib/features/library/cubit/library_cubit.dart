import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/library_repository.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final LibraryRepository _repo;

  LibraryCubit(this._repo) : super(const LibraryInitial());

  Future<void> load() async {
    emit(const LibraryLoading());
    try {
      final books = await _repo.fetchBooks();
      emit(LibraryLoaded(books));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  // Після публікації повторює запит поки нова книга не з'явиться.
  Future<void> loadAfterPublish(String expectedTitle) async {
    const delays = [2, 8, 8, 10, 12];
    for (var i = 0; i < delays.length; i++) {
      await Future.delayed(Duration(seconds: delays[i]));
      if (isClosed) return;
      try {
        final books = await _repo.fetchBooks();
        if (isClosed) return;
        emit(LibraryLoaded(books));
        if (books.any((b) => b.title == expectedTitle)) return;
      } catch (_) {}
    }
  }

  Future<void> deleteBook(String slug) async {
    final current = state;
    if (current is! LibraryLoaded) return;
    emit(LibraryDeleting(current.books, slug));
    try {
      await _repo.deleteBook(slug);
      // Optimistic update — одразу прибираємо з UI
      final updated = current.books.where((b) => b.slug != slug).toList();
      emit(LibraryLoaded(updated));
      // Підтверджуємо зміни з GitHub після propagation delay
      await Future.delayed(const Duration(seconds: 3));
      if (!isClosed) {
        final fresh = await _repo.fetchBooks();
        if (!isClosed) emit(LibraryLoaded(fresh));
      }
    } catch (e) {
      emit(LibraryLoaded(current.books));
      rethrow;
    }
  }
}
