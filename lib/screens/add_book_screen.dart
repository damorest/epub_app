import 'package:flutter/material.dart';
import '../api/api_client.dart';
import 'progress_screen.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _urlCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _startCtrl = TextEditingController(text: '1');
  final _endCtrl = TextEditingController();
  bool _followNext = false;
  bool _loading = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _titleCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = _urlCtrl.text.trim();
    final title = _titleCtrl.text.trim();

    if (url.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вкажи URL та назву книги')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await ApiClient.startParse(
        url: url,
        title: title,
        start: int.tryParse(_startCtrl.text) ?? 1,
        end: int.tryParse(_endCtrl.text) ?? 9999,
        followNext: _followNext,
      );
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProgressScreen(
            jobId: result['job_id'] as String,
            title: title,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Нова книга'),
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: const Color(0xFFc8a96e),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('URL розділів'),
            _field(
              _urlCtrl,
              'https://site.com/chapter-{n}',
              keyboardType: TextInputType.url,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              child: Text(
                'Використовуй {n} для номера розділу, або вкажи URL першого розділу з увімкненим перемикачем нижче',
                style: TextStyle(color: Colors.grey[700], fontSize: 11),
              ),
            ),
            _label('Назва книги'),
            _field(_titleCtrl, 'Назва'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Від розділу'),
                      _field(_startCtrl, '1', keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('До розділу (необов\'язково)'),
                      _field(_endCtrl, 'авто', keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16213e),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2a2a4a)),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Йти за кнопкою "Наступний розділ"',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: Text(
                  'Якщо URL не має {n} — увімкни це',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                value: _followNext,
                activeThumbColor: const Color(0xFFc8a96e),
                onChanged: (v) => setState(() => _followNext = v),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFc8a96e),
                  foregroundColor: const Color(0xFF1a1a2e),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF1a1a2e),
                        ),
                      )
                    : const Text('Опрацювати'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF9090a0), fontSize: 13),
        ),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF44445a)),
          filled: true,
          fillColor: const Color(0xFF16213e),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2a2a4a)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2a2a4a)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFc8a96e)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      );
}
