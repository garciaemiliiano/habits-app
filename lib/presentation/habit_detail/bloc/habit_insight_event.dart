part of 'habit_insight_bloc.dart';

sealed class HabitInsightEvent extends Equatable {
  const HabitInsightEvent();
  @override
  List<Object?> get props => [];
}

class HabitInsightLoaded extends HabitInsightEvent {
  const HabitInsightLoaded(this.habitId);
  final String habitId;
  @override
  List<Object?> get props => [habitId];
}

class HabitInsightRequested extends HabitInsightEvent {
  const HabitInsightRequested(this.habitId);
  final String habitId;
  @override
  List<Object?> get props => [habitId];
}
