import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_client.dart';
import 'add_book_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> _books = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final books = await ApiClient.getBooks();
      setState(() { _books = books; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Моя бібліотека'),
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: const Color(0xFFc8a96e),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFc8a96e)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 56, color: Color(0xFF44445a)),
                      const SizedBox(height: 16),
                      Text(
                        'Сервер не відповідає',
                        style: TextStyle(color: Colors.grey[500], fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Спробувати знову',
                            style: TextStyle(color: Color(0xFFc8a96e))),
                      ),
                    ],
                  ),
                )
              : _books.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.library_books,
                              size: 72, color: Color(0xFF2a2a4a)),
                          const SizedBox(height: 20),
                          Text('Бібліотека порожня',
                              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                          const SizedBox(height: 6),
                          Text('Натисни + щоб додати книгу',
                              style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _books.length,
                      itemBuilder: (context, i) => _BookCard(book: _books[i]),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFc8a96e),
        foregroundColor: const Color(0xFF1a1a2e),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookScreen()),
          );
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});
  final Map<String, dynamic> book;

  @override
  Widget build(BuildContext context) {
    final status = book['status'] as String? ?? '';
    final siteUrl = book['site_url'] as String?;
    final chapters = book['chapters'] as int? ?? 0;

    final statusColor = switch (status) {
      'published' => const Color(0xFF4caf50),
      'error' => Colors.redAccent,
      'done' => const Color(0xFFc8a96e),
      _ => Colors.grey,
    };

    final statusLabel = switch (status) {
      'published' => 'Опубліковано',
      'error' => 'Помилка',
      'done' => 'Готово до публікації',
      'running' => 'Завантажується…',
      _ => 'Очікує',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2a2a4a)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book['title'] as String? ?? '',
            style: const TextStyle(
              color: Color(0xFFc8a96e),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$chapters розділів',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11),
                ),
              ),
            ],
          ),
          if (status == 'published' && siteUrl != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFc8a96e),
                  foregroundColor: const Color(0xFF1a1a2e),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.open_in_browser, size: 18),
                label: const Text('Відкрити на сайті',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => launchUrl(Uri.parse(siteUrl),
                    mode: LaunchMode.externalApplication),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
