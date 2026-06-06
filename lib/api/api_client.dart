import 'dart:convert';
import 'package:http/http.dart' as http;

const _baseUrl = 'https://witch-book.onrender.com';

class ApiClient {
  static Future<Map<String, dynamic>> startParse({
    required String url,
    required String title,
    int start = 1,
    int end = 9999,
    bool followNext = false,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/parse'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'url': url,
        'title': title,
        'start': start,
        'end': end,
        'follow_next': followNext,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Сервер повернув ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getStatus(String jobId) async {
    final response = await http.get(Uri.parse('$_baseUrl/status/$jobId'));
    if (response.statusCode != 200) {
      throw Exception('Статус недоступний');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> publishJob(String jobId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/publish/$jobId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Помилка публікації: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getBooks() async {
    final response = await http.get(Uri.parse('$_baseUrl/books'));
    if (response.statusCode != 200) throw Exception('Не вдалось завантажити книги');
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
