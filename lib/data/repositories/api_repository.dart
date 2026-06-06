import '../models/job_model.dart';
import '../services/api_service.dart';

class ApiRepository {
  final ApiService _service;

  ApiRepository({ApiService? service}) : _service = service ?? ApiService();

  Future<String> startParse({
    required String url,
    required String title,
    int start = 1,
    int end = 9999,
    bool followNext = false,
  }) async {
    final data = await _service.startParse(
      url: url,
      title: title,
      start: start,
      end: end,
      followNext: followNext,
    );
    return data['job_id'] as String;
  }

  Future<JobModel> getStatus(String jobId) async {
    final data = await _service.getStatus(jobId);
    return JobModel.fromJson(data);
  }

  Future<String> publishJob(String jobId) async {
    final data = await _service.publishJob(jobId);
    return data['url'] as String;
  }

  Future<void> ping() => _service.ping();
}
