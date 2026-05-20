import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_overall_stats.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({required GetOverallStats getOverallStats})
      : _getOverallStats = getOverallStats,
        super(const StatsState.initial()) {
    on<StatsLoadRequested>(_onLoad);
  }

  final GetOverallStats _getOverallStats;

  Future<void> _onLoad(
      StatsLoadRequested event, Emitter<StatsState> emit) async {
    emit(state.copyWith(status: StatsStatus.loading));
    try {
      final rows = await _getOverallStats();
      final avgScore = rows.isEmpty
          ? 0.0
          : rows.map((r) => r.stats.score).reduce((a, b) => a + b) /
              rows.length;
      emit(state.copyWith(
        status: StatsStatus.loaded,
        rows: rows,
        overallScore: avgScore,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StatsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
