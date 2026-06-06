class Job {
  final String id;
  final String title;
  final String status;
  final int progress;
  final int total;
  final String current;
  final String? error;
  final String? siteUrl;

  const Job({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    required this.total,
    required this.current,
    this.error,
    this.siteUrl,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        progress: json['progress'] as int? ?? 0,
        total: json['total'] as int? ?? 0,
        current: json['current'] as String? ?? '',
        error: json['error'] as String?,
        siteUrl: json['site_url'] as String?,
      );

  bool get isPending => status == 'pending';
  bool get isRunning => status == 'running' || status == 'pending';
  bool get isDone => status == 'done';
  bool get isPublished => status == 'published';
  bool get isError => status == 'error';

  double get progressFraction =>
      total > 0 ? (progress / total).clamp(0.0, 1.0) : 0.0;
}
