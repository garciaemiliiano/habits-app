import 'package:equatable/equatable.dart';

import 'habit.dart';

/// DTO armado por `GetHabitsForToday` para la pantalla Today.
class HabitWithTodayStatus extends Equatable {
  const HabitWithTodayStatus({
    required this.habit,
    required this.isDueToday,
    required this.todayCompleted,
    required this.todayTarget,
    this.periodCompleted,
    this.periodTarget,
  });

  final Habit habit;
  final bool isDueToday;

  /// Cuántas veces marcó el hábito hoy.
  final int todayCompleted;

  /// Cuántas veces "debería" marcarlo hoy. Para daily: cantidad de reminders
  /// enabled que disparan en este weekday (mínimo 1). Para weekly/monthly: 1.
  final int todayTarget;

  /// Para frecuencias flexibles (weekly/monthly).
  final int? periodCompleted;
  final int? periodTarget;

  bool get completedToday => todayCompleted >= todayTarget;

  /// Solo tiene sentido mostrar X/N cuando hay más de un evento esperado.
  bool get hasMultipleDailyEvents => todayTarget > 1;

  bool get isFlexible => periodTarget != null;
  bool get periodMet =>
      isFlexible && (periodCompleted ?? 0) >= (periodTarget ?? 0);

  @override
  List<Object?> get props => [
        habit,
        isDueToday,
        todayCompleted,
        todayTarget,
        periodCompleted,
        periodTarget,
      ];
}
