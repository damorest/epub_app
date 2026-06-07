import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/book_model.dart';
import '../../../shared/widgets/procedural_cover.dart';
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
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) {
          final books = switch (state) {
            LibraryLoaded(books: final b) => b,
            LibraryDeleting(books: final b) => b,
            _ => <BookModel>[],
          };
          final deletingSlug = state is LibraryDeleting ? state.deletingSlug : null;
          final isLoading = state is LibraryLoading || state is LibraryInitial;
          final isError = state is LibraryError;

          return _LibraryContent(
            books: books,
            isLoading: isLoading,
            isError: isError,
            deletingSlug: deletingSlug,
            onRefresh: () => context.read<LibraryCubit>().load(),
            onDelete: (slug) => _confirmDelete(context, books.firstWhere((b) => b.slug == slug)),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, BookModel book) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.dialogBarrier.withValues(alpha: 0.62),
      builder: (dialogContext) => _DeleteDialog(book: book),
    );
    if (ok == true && context.mounted) {
      try {
        await context.read<LibraryCubit>().deleteBook(book.slug);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Не вдалось видалити: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }
}

class _LibraryContent extends StatefulWidget {
  const _LibraryContent({
    required this.books,
    required this.isLoading,
    required this.isError,
    required this.deletingSlug,
    required this.onRefresh,
    required this.onDelete,
  });
  final List<BookModel> books;
  final bool isLoading;
  final bool isError;
  final String? deletingSlug;
  final VoidCallback onRefresh;
  final void Function(String slug) onDelete;

  @override
  State<_LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<_LibraryContent> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _SortMode _sort = _SortMode.recent;
  String? _expandedSlug;
  bool _firstExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.toLowerCase()));
  }

  @override
  void didUpdateWidget(_LibraryContent old) {
    super.didUpdateWidget(old);
    if (!_firstExpanded && widget.books.isNotEmpty) {
      _expandedSlug = widget.books.first.slug;
      _firstExpanded = true;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BookModel> get _filtered {
    var list = widget.books.where((b) =>
      _query.isEmpty || b.title.toLowerCase().contains(_query),
    ).toList();
    if (_sort == _SortMode.az) {
      list.sort((a, b) => a.title.compareTo(b.title));
    }
    return list;
  }

  int get _totalChapters => widget.books.fold(0, (s, b) => s + b.chapters);

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final top = MediaQuery.of(context).padding.top;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(22, top + 20, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppTexts.libraryEyebrow,
                              style: AppTypography.eyebrow),
                          const SizedBox(height: 7),
                          Text(AppTexts.navLibrary,
                              style: AppTypography.displayTitle),
                          const SizedBox(height: 5),
                          Text(
                            '${widget.books.length} книги · $_totalChapters розділів',
                            style: AppTypography.hint.copyWith(fontSize: 13.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _IconBtn(
                      icon: Icons.refresh_rounded,
                      onTap: widget.onRefresh,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Search
                _SearchField(controller: _searchCtrl),
                const SizedBox(height: 12),
                // Sort chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SortChip(label: AppTexts.sortRecent, active: _sort == _SortMode.recent,
                          onTap: () => setState(() => _sort = _SortMode.recent)),
                      const SizedBox(width: 8),
                      _SortChip(label: AppTexts.sortAz, active: _sort == _SortMode.az,
                          onTap: () => setState(() => _sort = _SortMode.az)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        if (widget.isLoading)
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
            ),
          )
        else if (widget.isError)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, color: AppColors.text3, size: 48),
                  const SizedBox(height: 16),
                  Text(AppTexts.loadError,
                      style: AppTypography.body.copyWith(fontSize: 15, color: AppColors.text2)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: widget.onRefresh,
                    child: Text(AppTexts.retry,
                        style: AppTypography.body.copyWith(color: AppColors.gold)),
                  ),
                ],
              ),
            ),
          )
        else if (filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_books_outlined,
                      color: AppColors.text3, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    _query.isEmpty ? AppTexts.libraryEmpty : AppTexts.nothingFound,
                    style: AppTypography.body.copyWith(fontSize: 15, color: AppColors.text2),
                  ),
                  if (_query.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      AppTexts.libraryEmptyHint,
                      style: AppTypography.hint.copyWith(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16, 0, 16, MediaQuery.of(context).padding.bottom + 100),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (context, i) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final book = filtered[i];
                final isExpanded = _expandedSlug == book.slug;
                return _BookCard(
                  book: book,
                  isExpanded: isExpanded,
                  isDeleting: book.slug == widget.deletingSlug,
                  onToggle: () => setState(() {
                    _expandedSlug = isExpanded ? null : book.slug;
                  }),
                  onDelete: () => widget.onDelete(book.slug),
                );
              },
            ),
          ),
      ],
    );
  }
}

enum _SortMode { recent, az }

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.line, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        style: AppTypography.body.copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: AppTexts.searchHint,
          hintStyle: AppTypography.body.copyWith(fontSize: 15, color: AppColors.text3),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.text3, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.goldSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: active ? AppColors.goldLine : AppColors.line,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.meta.copyWith(
            fontSize: 12.5,
            color: active ? AppColors.gold : AppColors.text3,
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, color: AppColors.gold, size: 20),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.isExpanded,
    required this.isDeleting,
    required this.onToggle,
    required this.onDelete,
  });
  final BookModel book;
  final bool isExpanded;
  final bool isDeleting;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isExpanded ? AppColors.goldLine : AppColors.line,
        ),
        gradient: isExpanded
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface2,
                  AppColors.surface,
                ],
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row (tappable)
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ProceduralCover(title: book.title),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: AppTypography.bookTitle.copyWith(height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${book.chapters} розд.',
                              style: AppTypography.meta,
                            ),
                            Container(
                              width: 3,
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.text3,
                              ),
                            ),
                            Text(
                              '${book.epubFiles.length} файли',
                              style: AppTypography.meta,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isDeleting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.danger,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.text3,
                          size: 20,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.text3,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded files list
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                Divider(height: 1, color: AppColors.line),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: book.epubFiles
                        .map((f) => _FileChip(file: f))
                        .toList(),
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _FileChip extends StatefulWidget {
  const _FileChip({required this.file});
  final EpubFileModel file;

  @override
  State<_FileChip> createState() => _FileChipState();
}

class _FileChipState extends State<_FileChip> {
  bool _downloading = false;

  Future<void> _download(BuildContext context) async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final response = await http
          .get(Uri.parse(widget.file.downloadUrl))
          .timeout(const Duration(seconds: 120));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${widget.file.name}';
      await File(filePath).writeAsBytes(response.bodyBytes);
      final result = await OpenFilex.open(filePath, type: 'application/epub+zip');
      if (result.type != ResultType.done) {
        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'application/epub+zip')],
          subject: widget.file.label,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: _downloading ? null : () => _download(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              _downloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.gold,
                      ),
                    )
                  : const Icon(
                      Icons.download_rounded,
                      color: AppColors.gold,
                      size: 18,
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.file.label,
                  style: AppTypography.label.copyWith(fontSize: 14, color: AppColors.text),
                ),
              ),
              Text(
                '${widget.file.sizeKb} КБ',
                style: AppTypography.meta.copyWith(fontSize: 12.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.book});
  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.9, end: 1.0),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.dialogSurf1, AppColors.dialogSurf2],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.lineStrong),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 26,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppTexts.deleteTitle,
                style: AppTypography.serifH2.copyWith(fontSize: 21),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Книга «${book.title}» та всі завантажені томи будуть видалені.',
                style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.text3, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text2,
                        side: const BorderSide(color: AppColors.lineStrong),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppTexts.cancel,
                          style: AppTypography.label.copyWith(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        backgroundColor:
                            AppColors.danger.withValues(alpha: 0.13),
                        side: BorderSide(
                            color: AppColors.danger.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(AppTexts.deleteConfirm,
                          style: AppTypography.label.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
