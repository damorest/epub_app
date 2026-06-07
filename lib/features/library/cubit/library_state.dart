import 'package:equatable/equatable.dart';
import '../../../data/models/book_model.dart';

sealed class LibraryState extends Equatable {
  const LibraryState();
}

class LibraryInitial extends LibraryState {
  const LibraryInitial();
  @override
  List<Object?> get props => [];
}

class LibraryLoading extends LibraryState {
  const LibraryLoading();
  @override
  List<Object?> get props => [];
}

class LibraryLoaded extends LibraryState {
  final List<BookModel> books;
  const LibraryLoaded(this.books);
  @override
  List<Object?> get props => [books];
}

class LibraryError extends LibraryState {
  final String message;
  const LibraryError(this.message);
  @override
  List<Object?> get props => [message];
}

class LibraryDeleting extends LibraryState {
  final List<BookModel> books;
  final String deletingSlug;
  const LibraryDeleting(this.books, this.deletingSlug);
  @override
  List<Object?> get props => [books, deletingSlug];
}
