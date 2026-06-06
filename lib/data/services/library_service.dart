import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class LibraryService {
  Future<List<Map<String, dynamic>>> fetchBooks() async {
    final response = await http.get(Uri.parse(AppConstants.booksJsonUrl));
    if (response.statusCode == 404) return [];
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
