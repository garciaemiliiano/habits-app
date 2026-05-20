part of 'stats_bloc.dart';

enum StatsStatus { initial, loading, loaded, failure }

class StatsState extends Equatable {
  const StatsState({
    required this.status,
    required this.rows,
    required this.overallScore,
    this.errorMessage,
  });

  const StatsState.initial()
      : status = StatsStatus.initial,
        rows = const [],
        overallScore = 0,
        errorMessage = null;

  final StatsStatus status;
  final List<OverallStatRow> rows;
  final double overallScore;
  final String? errorMessage;

  StatsState copyWith({
    StatsStatus? status,
    List<OverallStatRow>? rows,
    double? overallScore,
    String? errorMessage,
  }) {
    return StatsState(
      status: status ?? this.status,
      rows: rows ?? this.rows,
      overallScore: overallScore ?? this.overallScore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, rows, overallScore, errorMessage];
}
