part of 'habit_detail_bloc.dart';

sealed class HabitDetailEvent extends Equatable {
  const HabitDetailEvent();
  @override
  List<Object?> get props => [];
}

class HabitDetailLoadRequested extends HabitDetailEvent {
  const HabitDetailLoadRequested(this.habitId);
  final String habitId;
  @override
  List<Object?> get props => [habitId];
}

class HabitDetailCompletionToggled extends HabitDetailEvent {
  const HabitDetailCompletionToggled(this.day);
  final DateTime day;
  @override
  List<Object?> get props => [day];
}

class HabitDetailHeatmapRangeChanged extends HabitDetailEvent {
  const HabitDetailHeatmapRangeChanged(this.months);
  final int months;
  @override
  List<Object?> get props => [months];
}
