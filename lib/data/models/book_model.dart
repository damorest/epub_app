import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class EpubFileModel extends Equatable {
  final String name;
  final String label;
  final int sizeKb;
  final String _url;

  const EpubFileModel({
    required this.name,
    required this.label,
    required this.sizeKb,
    required String url,
  }) : _url = url;

  factory EpubFileModel.fromJson(Map<String, dynamic> json, String slug) {
    final name = json['name'] as String? ?? '';
    final url = json['url'] as String? ??
        '${AppConstants.libraryBaseUrl}/books/$slug/$name';
    return EpubFileModel(
      name: name,
      label: json['label'] as String? ?? '',
      sizeKb: json['size_kb'] as int? ?? 0,
      url: url,
    );
  }

  String get downloadUrl => _url;

  @override
  List<Object?> get props => [name, _url];
}


class BookModel extends Equatable {
  final String slug;
  final String title;
  final int chapters;
  final List<EpubFileModel> epubFiles;

  const BookModel({
    required this.slug,
    required this.title,
    required this.chapters,
    required this.epubFiles,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final slug = json['slug'] as String? ?? '';
    final files = (json['epub_files'] as List<dynamic>? ?? [])
        .map((e) => EpubFileModel.fromJson(e as Map<String, dynamic>, slug))
        .toList();
    return BookModel(
      slug: slug,
      title: json['title'] as String? ?? '',
      chapters: json['chapters'] as int? ?? 0,
      epubFiles: files,
    );
  }

  @override
  List<Object?> get props => [slug, chapters];
}
