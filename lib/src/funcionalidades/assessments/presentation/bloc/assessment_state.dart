import 'package:equatable/equatable.dart';

enum AssessmentStatus { initial, loading, success, failure }

class AssessmentState extends Equatable {
  final AssessmentStatus status;
  final String? errorMessage;

  const AssessmentState({
    this.status = AssessmentStatus.initial,
    this.errorMessage,
  });

  AssessmentState copyWith({
    AssessmentStatus? status,
    String? errorMessage,
  }) {
    return AssessmentState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}