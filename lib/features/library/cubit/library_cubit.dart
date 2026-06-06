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
}
