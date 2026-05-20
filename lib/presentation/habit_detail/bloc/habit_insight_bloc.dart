import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/habit_insight.dart';
import '../../../domain/repositories/coach_repository.dart';
import '../../../domain/usecases/generate_habit_insight.dart';

part 'habit_insight_event.dart';
part 'habit_insight_state.dart';

class HabitInsightBloc extends Bloc<HabitInsightEvent, HabitInsightState> {
  HabitInsightBloc({
    required CoachRepository coach,
    required GenerateHabitInsight generate,
  })  : _coach = coach,
        _generate = generate,
        super(const HabitInsightState()) {
    on<HabitInsightLoaded>(_onLoaded);
    on<HabitInsightRequested>(_onRequested);
  }

  final CoachRepository _coach;
  final GenerateHabitInsight _generate;

  Future<void> _onLoaded(
    HabitInsightLoaded event,
    Emitter<HabitInsightState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      final available = await _coach.isAvailable();
      final cached = await _generate.getCached(event.habitId);
      emit(state.copyWith(
        loading: false,
        available: available,
        cached: cached,
        clearCached: cached == null,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRequested(
    HabitInsightRequested event,
    Emitter<HabitInsightState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final insight = await _generate.regenerate(event.habitId);
      emit(state.copyWith(
        loading: false,
        available: true,
        cached: insight,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        errorMessage: 'No se pudo generar el análisis: $e',
      ));
    }
  }
}
