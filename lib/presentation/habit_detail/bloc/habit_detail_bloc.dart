import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_stats.dart';
import '../../../domain/repositories/habits_repository.dart';
import '../../../domain/usecases/get_habit_stats.dart';
import '../../../domain/usecases/toggle_completion.dart';

part 'habit_detail_event.dart';
part 'habit_detail_state.dart';

class HabitDetailBloc extends Bloc<HabitDetailEvent, HabitDetailState> {
  HabitDetailBloc({
    required HabitsRepository habits,
    required GetHabitStats getHabitStats,
    required ToggleCompletion toggleCompletion,
  })  : _habits = habits,
        _getHabitStats = getHabitStats,
        _toggleCompletion = toggleCompletion,
        super(const HabitDetailState.initial()) {
    on<HabitDetailLoadRequested>(_onLoad);
    on<HabitDetailCompletionToggled>(_onToggle);
    on<HabitDetailHeatmapRangeChanged>(_onRangeChanged);
  }

  final HabitsRepository _habits;
  final GetHabitStats _getHabitStats;
  final ToggleCompletion _toggleCompletion;

  Future<void> _onLoad(
      HabitDetailLoadRequested event, Emitter<HabitDetailState> emit) async {
    emit(state.copyWith(
      status: HabitDetailStatus.loading,
      habitId: event.habitId,
    ));
    await _fetch(emit, event.habitId);
  }

  Future<void> _onToggle(HabitDetailCompletionToggled event,
      Emitter<HabitDetailState> emit) async {
    if (state.habit == null) return;
    await _toggleCompletion(habitId: state.habit!.id, day: event.day);
    await _fetch(emit, state.habit!.id);
  }

  Future<void> _onRangeChanged(HabitDetailHeatmapRangeChanged event,
      Emitter<HabitDetailState> emit) async {
    emit(state.copyWith(heatmapMonths: event.months));
    if (state.habit != null) {
      await _fetch(emit, state.habit!.id);
    }
  }

  Future<void> _fetch(Emitter<HabitDetailState> emit, String habitId) async {
    try {
      final habit = await _habits.getById(habitId);
      if (habit == null) {
        emit(state.copyWith(
          status: HabitDetailStatus.failure,
          errorMessage: 'Hábito no encontrado',
        ));
        return;
      }
      final stats = await _getHabitStats(
        habitId: habitId,
        heatmapMonths: state.heatmapMonths,
      );
      emit(state.copyWith(
        status: HabitDetailStatus.loaded,
        habit: habit,
        stats: stats,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HabitDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
