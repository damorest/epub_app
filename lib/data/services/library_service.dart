import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class LibraryService {
  Future<List<Map<String, dynamic>>> fetchBooks() async {
    // Unique timestamp creates a CDN cache miss on api.github.com
    final url = '${AppConstants.booksJsonUrl}?_=${DateTime.now().millisecondsSinceEpoch}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        // Returns raw file content instead of base64-encoded JSON envelope
        'Accept': 'application/vnd.github.raw+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );
    if (response.statusCode == 404) return [];
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
