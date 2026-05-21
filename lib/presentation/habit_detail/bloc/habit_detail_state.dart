part of 'habit_detail_bloc.dart';

enum HabitDetailStatus { initial, loading, loaded, failure }

class HabitDetailState extends Equatable {
  const HabitDetailState({
    required this.status,
    required this.habitId,
    required this.habit,
    required this.stats,
    required this.heatmapMonths,
    required this.todayCompleted,
    required this.todayTarget,
    this.errorMessage,
  });

  const HabitDetailState.initial()
      : status = HabitDetailStatus.initial,
        habitId = '',
        habit = null,
        stats = null,
        heatmapMonths = 6,
        todayCompleted = 0,
        todayTarget = 1,
        errorMessage = null;

  final HabitDetailStatus status;
  final String habitId;
  final Habit? habit;
  final HabitStats? stats;
  final int heatmapMonths;

  /// Cuántas veces se marcó hoy.
  final int todayCompleted;

  /// Cuántas veces "debería" marcarse hoy (= cantidad de reminders enabled
  /// para este weekday, mínimo 1).
  final int todayTarget;

  final String? errorMessage;

  bool get todayMet => todayCompleted >= todayTarget;

  HabitDetailState copyWith({
    HabitDetailStatus? status,
    String? habitId,
    Habit? habit,
    HabitStats? stats,
    int? heatmapMonths,
    int? todayCompleted,
    int? todayTarget,
    String? errorMessage,
  }) {
    return HabitDetailState(
      status: status ?? this.status,
      habitId: habitId ?? this.habitId,
      habit: habit ?? this.habit,
      stats: stats ?? this.stats,
      heatmapMonths: heatmapMonths ?? this.heatmapMonths,
      todayCompleted: todayCompleted ?? this.todayCompleted,
      todayTarget: todayTarget ?? this.todayTarget,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        habitId,
        habit,
        stats,
        heatmapMonths,
        todayCompleted,
        todayTarget,
        errorMessage,
      ];
}
