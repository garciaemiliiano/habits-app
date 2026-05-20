part of 'today_bloc.dart';

sealed class TodayEvent extends Equatable {
  const TodayEvent();

  @override
  List<Object?> get props => [];
}

class TodayLoadRequested extends TodayEvent {
  const TodayLoadRequested();
}

class TodayRefreshRequested extends TodayEvent {
  const TodayRefreshRequested();
}

class TodayDateChanged extends TodayEvent {
  const TodayDateChanged(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}

class TodayHabitToggled extends TodayEvent {
  const TodayHabitToggled(this.habitId);
  final String habitId;
  @override
  List<Object?> get props => [habitId];
}
