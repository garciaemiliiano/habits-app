part of 'habit_detail_bloc.dart';

enum HabitDetailStatus { initial, loading, loaded, failure }

class HabitDetailState extends Equatable {
  const HabitDetailState({
    required this.status,
    required this.habitId,
    required this.habit,
    required this.stats,
    required this.heatmapMonths,
    this.errorMessage,
  });

  const HabitDetailState.initial()
      : status = HabitDetailStatus.initial,
        habitId = '',
        habit = null,
        stats = null,
        heatmapMonths = 6,
        errorMessage = null;

  final HabitDetailStatus status;
  final String habitId;
  final Habit? habit;
  final HabitStats? stats;
  final int heatmapMonths;
  final String? errorMessage;

  HabitDetailState copyWith({
    HabitDetailStatus? status,
    String? habitId,
    Habit? habit,
    HabitStats? stats,
    int? heatmapMonths,
    String? errorMessage,
  }) {
    return HabitDetailState(
      status: status ?? this.status,
      habitId: habitId ?? this.habitId,
      habit: habit ?? this.habit,
      stats: stats ?? this.stats,
      heatmapMonths: heatmapMonths ?? this.heatmapMonths,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, habitId, habit, stats, heatmapMonths, errorMessage];
}
