part of 'habits_bloc.dart';

sealed class HabitsEvent extends Equatable {
  const HabitsEvent();

  @override
  List<Object?> get props => [];
}

class HabitsLoadRequested extends HabitsEvent {
  const HabitsLoadRequested();
}

class HabitsShowArchivedToggled extends HabitsEvent {
  const HabitsShowArchivedToggled();
}

class HabitsReordered extends HabitsEvent {
  const HabitsReordered(this.orderedIds);
  final List<String> orderedIds;
  @override
  List<Object?> get props => [orderedIds];
}

class HabitsArchiveToggled extends HabitsEvent {
  const HabitsArchiveToggled({required this.habitId, required this.archived});
  final String habitId;
  final bool archived;
  @override
  List<Object?> get props => [habitId, archived];
}

class HabitsDeleted extends HabitsEvent {
  const HabitsDeleted(this.habitId);
  final String habitId;
  @override
  List<Object?> get props => [habitId];
}
