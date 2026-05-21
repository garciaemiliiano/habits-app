import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/date_range.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_frequency.dart';
import '../../../domain/entities/habit_stats.dart';
import '../../../domain/repositories/completions_repository.dart';
import '../../../domain/repositories/habits_repository.dart';
import '../../../domain/repositories/reminders_repository.dart';
import '../../../domain/usecases/get_habit_stats.dart';
import '../../../domain/usecases/toggle_completion.dart';

part 'habit_detail_event.dart';
part 'habit_detail_state.dart';

class HabitDetailBloc extends Bloc<HabitDetailEvent, HabitDetailState> {
  HabitDetailBloc({
    required HabitsRepository habits,
    required GetHabitStats getHabitStats,
    required ToggleCompletion toggleCompletion,
    required CompletionsRepository completions,
    required RemindersRepository reminders,
  })  : _habits = habits,
        _getHabitStats = getHabitStats,
        _toggleCompletion = toggleCompletion,
        _completions = completions,
        _reminders = reminders,
        super(const HabitDetailState.initial()) {
    on<HabitDetailLoadRequested>(_onLoad);
    on<HabitDetailCompletionToggled>(_onToggle);
    on<HabitDetailHeatmapRangeChanged>(_onRangeChanged);
  }

  final HabitsRepository _habits;
  final GetHabitStats _getHabitStats;
  final ToggleCompletion _toggleCompletion;
  final CompletionsRepository _completions;
  final RemindersRepository _reminders;

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
    final habit = state.habit;
    if (habit == null) return;
    final isToday = DateRange.dayOf(event.day) == DateRange.dayOf(DateTime.now());
    final target = isToday ? state.todayTarget : 1;
    await _toggleCompletion(
      habitId: habit.id,
      day: event.day,
      target: target,
    );
    await _fetch(emit, habit.id);
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
      final today = DateRange.dayOf(DateTime.now());
      final todayCompleted =
          await _completions.countOn(habitId: habitId, day: today);
      final todayTarget = await _computeTodayTarget(habit, today);
      emit(state.copyWith(
        status: HabitDetailStatus.loaded,
        habit: habit,
        stats: stats,
        todayCompleted: todayCompleted,
        todayTarget: todayTarget,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HabitDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<int> _computeTodayTarget(Habit habit, DateTime day) async {
    if (habit.frequency is! DailyFrequency) return 1;
    final habitReminders = await _reminders.getForHabit(habit.id);
    final weekdayBit = 1 << (day.weekday - 1);
    final dueToday = habitReminders
        .where((r) => r.enabled && (r.weekdayMask & weekdayBit) != 0)
        .length;
    return dueToday > 0 ? dueToday : 1;
  }
}
