import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/api_repository.dart';
import 'converter_state.dart';

class ConverterCubit extends Cubit<ConverterState> {
  final ApiRepository _api;
  Timer? _pollTimer;
  Timer? _pingTimer;
  String? _currentJobId;

  ConverterCubit(this._api) : super(const ConverterIdle());

  Future<void> startParsing({
    required String url,
    required String title,
    int start = 1,
    int end = 9999,
    bool followNext = false,
  }) async {
    emit(const ConverterLoading());
    try {
      final jobId = await _api.startParse(
        url: url,
        title: title,
        start: start,
        end: end,
        followNext: followNext,
      );
      _currentJobId = jobId;
      _startPolling(jobId);
      _startPing();
    } catch (e) {
      emit(ConverterError(e.toString()));
    }
  }

  Future<void> publish() async {
    final current = state;
    if (current is! ConverterDone || _currentJobId == null) return;
    emit(ConverterPublishing(current.job));
    try {
      final url = await _api.publishJob(_currentJobId!);
      emit(ConverterPublished(current.job.copyWith(siteUrl: url)));
    } catch (e) {
      emit(ConverterError(e.toString()));
    }
  }

  Future<void> cancel() async {
    if (_currentJobId == null) return;
    _stopTimers();
    try {
      await _api.cancelJob(_currentJobId!);
    } catch (_) {}
    _currentJobId = null;
    emit(const ConverterCancelled());
  }

  void reset() {
    _stopTimers();
    _currentJobId = null;
    emit(const ConverterIdle());
  }

  void _startPolling(String jobId) {
    _pollTimer = Timer.periodic(AppConstants.pollInterval, (_) async {
      try {
        final job = await _api.getStatus(jobId);
        if (isClosed) return;
        if (job.isRunning) {
          emit(ConverterRunning(job));
        } else if (job.isDone) {
          _stopTimers();
          emit(ConverterDone(job));
        } else if (job.isError) {
          _stopTimers();
          emit(ConverterError(job.error ?? 'Невідома помилка'));
        }
      } catch (_) {}
    });
  }

  void _startPing() {
    _pingTimer = Timer.periodic(AppConstants.pingInterval, (_) async {
      try { await _api.ping(); } catch (_) {}
    });
  }

  void _stopTimers() {
    _pollTimer?.cancel();
    _pingTimer?.cancel();
    _pollTimer = null;
    _pingTimer = null;
  }

  @override
  Future<void> close() {
    _stopTimers();
    return super.close();
  }
}
