import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../data/models/book_model.dart';
import '../cubit/library_cubit.dart';
import '../cubit/library_state.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.navLibrary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<LibraryCubit>().load(),
          ),
        ],
      ),
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) => switch (state) {
          LibraryInitial() || LibraryLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          LibraryError() => _ErrorView(
              onRetry: () => context.read<LibraryCubit>().load(),
            ),
          LibraryLoaded(books: final books) => books.isEmpty
              ? _EmptyView()
              : _BookList(books: books),
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_books, size: 72, color: AppColors.border),
            const SizedBox(height: 20),
            const Text(
              AppTexts.libraryEmpty,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              AppTexts.libraryEmptyHint,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              AppTexts.serverUnavailable,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text(AppTexts.retry,
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
}

class _BookList extends StatelessWidget {
  const _BookList({required this.books});
  final List<BookModel> books;

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (_, i) => _BookCard(book: books[i]),
      );
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});
  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${book.chapters} ${AppTexts.chapters}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...book.epubFiles.map((f) => _DownloadButton(file: f)),
        ],
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.file});
  final EpubFileModel file;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            alignment: Alignment.centerLeft,
          ),
          icon: const Icon(Icons.download, size: 18),
          label: Text(
            '${file.label}  ·  ${file.sizeKb} КБ',
            style: const TextStyle(fontSize: 13),
          ),
          onPressed: () => launchUrl(
            Uri.parse(file.downloadUrl),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ),
    );
  }
}
