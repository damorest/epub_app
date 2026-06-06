import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_client.dart';
import '../models/job.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, required this.jobId, required this.title});
  final String jobId;
  final String title;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Job? _job;
  Timer? _timer;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    try {
      final data = await ApiClient.getStatus(widget.jobId);
      final job = Job.fromJson(data);
      if (!mounted) return;
      setState(() => _job = job);
      if (job.isDone || job.isPublished || job.isError) {
        _timer?.cancel();
      }
    } catch (_) {}
  }

  Future<void> _publish() async {
    setState(() => _publishing = true);
    try {
      await ApiClient.publishJob(widget.jobId);
      await _poll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e')),
      );
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;

    return PopScope(
      canPop: job?.isRunning != true,
      child: Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          title: Text(widget.title, overflow: TextOverflow.ellipsis),
          backgroundColor: const Color(0xFF16213e),
          foregroundColor: const Color(0xFFc8a96e),
          automaticallyImplyLeading: job?.isRunning != true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: job == null
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFc8a96e)))
              : _buildBody(job),
        ),
      ),
    );
  }

  Widget _buildBody(Job job) {
    if (job.isRunning) return _buildRunning(job);
    if (job.isDone) return _buildDone(job);
    if (job.isPublished) return _buildPublished(job);
    if (job.isError) return _buildError(job);
    return const SizedBox.shrink();
  }

  Widget _buildRunning(Job job) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              color: Color(0xFFc8a96e), strokeWidth: 3),
          const SizedBox(height: 36),
          Text(
            job.current.isEmpty ? 'Запускаємо…' : job.current,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (job.total > 0) ...[
            const SizedBox(height: 28),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: job.progressFraction,
                minHeight: 8,
                color: const Color(0xFFc8a96e),
                backgroundColor: const Color(0xFF2a2a4a),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${job.progress} / ${job.total} розділів',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
          const SizedBox(height: 40),
          Text(
            'Не закривай додаток — сервер обробляє запит',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _buildDone(Job job) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline,
              color: Color(0xFFc8a96e), size: 80),
          const SizedBox(height: 24),
          Text(
            '${job.total} розділів готово!',
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Натисни "Опублікувати" — книга з\'явиться на сайті',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _primaryButton(
            label: 'Опублікувати',
            icon: Icons.rocket_launch,
            loading: _publishing,
            onPressed: _publish,
          ),
        ],
      );

  Widget _buildPublished(Job job) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rocket_launch, color: Color(0xFFc8a96e), size: 80),
          const SizedBox(height: 24),
          const Text(
            'Книга опублікована!',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Через ~1 хвилину з\'явиться на сайті',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 40),
          if (job.siteUrl != null)
            _primaryButton(
              label: 'Відкрити бібліотеку',
              icon: Icons.open_in_browser,
              onPressed: () => launchUrl(
                Uri.parse(job.siteUrl!),
                mode: LaunchMode.externalApplication,
              ),
            ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Повернутись до бібліотеки',
              style: TextStyle(color: Color(0xFF9090a0)),
            ),
          ),
        ],
      );

  Widget _buildError(Job job) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Щось пішло не так',
            style: TextStyle(color: Colors.redAccent, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            job.error ?? '',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Назад',
              style: TextStyle(color: Color(0xFFc8a96e), fontSize: 16),
            ),
          ),
        ],
      );

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool loading = false,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFc8a96e),
            foregroundColor: const Color(0xFF1a1a2e),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          icon: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Color(0xFF1a1a2e)),
                )
              : Icon(icon),
          label: Text(label),
          onPressed: loading ? null : onPressed,
        ),
      );
}
