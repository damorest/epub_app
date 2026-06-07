import 'package:equatable/equatable.dart';

class JobModel extends Equatable {
  final String id;
  final String title;
  final String status;
  final int progress;
  final int total;
  final String current;
  final String? error;
  final String? siteUrl;

  const JobModel({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    required this.total,
    required this.current,
    this.error,
    this.siteUrl,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) => JobModel(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        progress: json['progress'] as int? ?? 0,
        total: json['total'] as int? ?? 0,
        current: json['current'] as String? ?? '',
        error: json['error'] as String?,
        siteUrl: json['site_url'] as String?,
      );

  JobModel copyWith({String? status, String? siteUrl}) => JobModel(
        id: id,
        title: title,
        status: status ?? this.status,
        progress: progress,
        total: total,
        current: current,
        error: error,
        siteUrl: siteUrl ?? this.siteUrl,
      );

  bool get isRunning   => status == 'running' || status == 'pending';
  bool get isDone      => status == 'done';
  bool get isPublished => status == 'published';
  bool get isError     => status == 'error';

  double get progressFraction =>
      total > 0 ? (progress / total).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [id, status, progress, total, current, error, siteUrl];
}
