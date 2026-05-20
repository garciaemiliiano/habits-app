import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/habit.dart';
import '../../../domain/usecases/archive_habit.dart';
import '../../../domain/usecases/delete_habit.dart';
import '../../../domain/usecases/get_all_habits.dart';
import '../../../domain/usecases/reorder_habits.dart';

part 'habits_event.dart';
part 'habits_state.dart';

class HabitsBloc extends Bloc<HabitsEvent, HabitsState> {
  HabitsBloc({
    required GetAllHabits getAllHabits,
    required ArchiveHabit archiveHabit,
    required DeleteHabit deleteHabit,
    required ReorderHabits reorderHabits,
  })  : _getAllHabits = getAllHabits,
        _archiveHabit = archiveHabit,
        _deleteHabit = deleteHabit,
        _reorderHabits = reorderHabits,
        super(const HabitsState.initial()) {
    on<HabitsLoadRequested>(_onLoad);
    on<HabitsShowArchivedToggled>(_onToggleArchived);
    on<HabitsReordered>(_onReordered);
    on<HabitsArchiveToggled>(_onArchive);
    on<HabitsDeleted>(_onDeleted);
  }

  final GetAllHabits _getAllHabits;
  final ArchiveHabit _archiveHabit;
  final DeleteHabit _deleteHabit;
  final ReorderHabits _reorderHabits;

  Future<void> _onLoad(
      HabitsLoadRequested event, Emitter<HabitsState> emit) async {
    emit(state.copyWith(status: HabitsStatus.loading));
    await _fetch(emit);
  }

  void _onToggleArchived(
      HabitsShowArchivedToggled event, Emitter<HabitsState> emit) {
    emit(state.copyWith(showArchived: !state.showArchived));
  }

  Future<void> _onReordered(
      HabitsReordered event, Emitter<HabitsState> emit) async {
    try {
      await _reorderHabits(event.orderedIds);
      await _fetch(emit);
    } catch (e) {
      emit(state.copyWith(
        status: HabitsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onArchive(
      HabitsArchiveToggled event, Emitter<HabitsState> emit) async {
    try {
      await _archiveHabit(habitId: event.habitId, archived: event.archived);
      await _fetch(emit);
    } catch (e) {
      emit(state.copyWith(
        status: HabitsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleted(
      HabitsDeleted event, Emitter<HabitsState> emit) async {
    try {
      await _deleteHabit(event.habitId);
      await _fetch(emit);
    } catch (e) {
      emit(state.copyWith(
        status: HabitsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _fetch(Emitter<HabitsState> emit) async {
    try {
      final all = await _getAllHabits(includeArchived: true);
      emit(state.copyWith(
        status: HabitsStatus.loaded,
        habits: all,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HabitsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
