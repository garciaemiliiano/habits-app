import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/date_range.dart';
import '../../../domain/entities/habit_with_today_status.dart';
import '../../../domain/usecases/get_habits_for_today.dart';
import '../../../domain/usecases/toggle_completion.dart';

part 'today_event.dart';
part 'today_state.dart';

class TodayBloc extends Bloc<TodayEvent, TodayState> {
  TodayBloc({
    required GetHabitsForToday getHabitsForToday,
    required ToggleCompletion toggleCompletion,
  })  : _getHabitsForToday = getHabitsForToday,
        _toggleCompletion = toggleCompletion,
        super(TodayState.initial()) {
    on<TodayLoadRequested>(_onLoad);
    on<TodayRefreshRequested>(_onRefresh);
    on<TodayDateChanged>(_onDateChanged);
    on<TodayHabitToggled>(_onToggled);
  }

  final GetHabitsForToday _getHabitsForToday;
  final ToggleCompletion _toggleCompletion;

  Future<void> _onLoad(TodayLoadRequested event, Emitter<TodayState> emit) async {
    emit(state.copyWith(status: TodayStatus.loading));
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      TodayRefreshRequested event, Emitter<TodayState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onDateChanged(
      TodayDateChanged event, Emitter<TodayState> emit) async {
    emit(state.copyWith(
      selectedDate: DateRange.dayOf(event.date),
      status: TodayStatus.loading,
    ));
    await _fetch(emit);
  }

  Future<void> _onToggled(
      TodayHabitToggled event, Emitter<TodayState> emit) async {
    try {
      await _toggleCompletion(habitId: event.habitId, day: state.selectedDate);
      await _fetch(emit);
    } catch (e) {
      emit(state.copyWith(
        status: TodayStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _fetch(Emitter<TodayState> emit) async {
    try {
      final habits = await _getHabitsForToday(state.selectedDate);
      emit(state.copyWith(
        status: TodayStatus.loaded,
        habits: habits,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TodayStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
