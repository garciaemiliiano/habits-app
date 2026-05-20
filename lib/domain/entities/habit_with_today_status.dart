import 'package:equatable/equatable.dart';

import 'habit.dart';

/// DTO armado por `GetHabitsForToday` para la pantalla Today.
class HabitWithTodayStatus extends Equatable {
  const HabitWithTodayStatus({
    required this.habit,
    required this.isDueToday,
    required this.completedToday,
    this.periodCompleted,
    this.periodTarget,
  });

  final Habit habit;
  final bool isDueToday;
  final bool completedToday;

  /// Para frecuencias flexibles (weekly/monthly).
  final int? periodCompleted;
  final int? periodTarget;

  bool get isFlexible => periodTarget != null;
  bool get periodMet =>
      isFlexible && (periodCompleted ?? 0) >= (periodTarget ?? 0);

  @override
  List<Object?> get props =>
      [habit, isDueToday, completedToday, periodCompleted, periodTarget];
}
