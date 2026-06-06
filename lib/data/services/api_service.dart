import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class ApiService {
  final String _base;

  ApiService({String? baseUrl}) : _base = baseUrl ?? AppConstants.apiBaseUrl;

  Future<Map<String, dynamic>> startParse({
    required String url,
    required String title,
    int start = 1,
    int end = 9999,
    bool followNext = false,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/parse'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'url': url,
        'title': title,
        'start': start,
        'end': end,
        'follow_next': followNext,
      }),
    );
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStatus(String jobId) async {
    final response = await http.get(Uri.parse('$_base/status/$jobId'));
    _checkStatus(response);
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> publishJob(String jobId) async {
    final response = await http.post(Uri.parse('$_base/publish/$jobId'));
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> cancelJob(String jobId) async {
    final response = await http.post(Uri.parse('$_base/cancel/$jobId'));
    _checkStatus(response);
  }

  Future<void> ping() async {
    await http.get(Uri.parse('$_base/ping')).timeout(const Duration(seconds: 5));
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
