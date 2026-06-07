import 'package:equatable/equatable.dart';
import '../../../data/models/job_model.dart';

sealed class ConverterState extends Equatable {
  const ConverterState();
}

class ConverterIdle extends ConverterState {
  const ConverterIdle();
  @override
  List<Object?> get props => [];
}

class ConverterLoading extends ConverterState {
  const ConverterLoading();
  @override
  List<Object?> get props => [];
}

class ConverterRunning extends ConverterState {
  final JobModel job;
  const ConverterRunning(this.job);
  @override
  List<Object?> get props => [job];
}

class ConverterDone extends ConverterState {
  final JobModel job;
  const ConverterDone(this.job);
  @override
  List<Object?> get props => [job];
}

class ConverterPublishing extends ConverterState {
  final JobModel job;
  const ConverterPublishing(this.job);
  @override
  List<Object?> get props => [job];
}

class ConverterPublished extends ConverterState {
  final JobModel job;
  const ConverterPublished(this.job);
  @override
  List<Object?> get props => [job];
}

class ConverterError extends ConverterState {
  final String message;
  const ConverterError(this.message);
  @override
  List<Object?> get props => [message];
}

class ConverterCancelled extends ConverterState {
  const ConverterCancelled();
  @override
  List<Object?> get props => [];
}
