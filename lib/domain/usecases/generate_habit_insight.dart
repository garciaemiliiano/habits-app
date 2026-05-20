import '../../core/utils/habit_frequency_format.dart';
import '../entities/habit_insight.dart';
import '../repositories/coach_repository.dart';
import '../repositories/habit_insights_repository.dart';
import '../repositories/habits_repository.dart';
import 'get_habit_stats.dart';

class GenerateHabitInsight {
  GenerateHabitInsight({
    required CoachRepository coach,
    required HabitInsightsRepository insights,
    required GetHabitStats getHabitStats,
    required HabitsRepository habits,
  })  : _coach = coach,
        _insights = insights,
        _getHabitStats = getHabitStats,
        _habits = habits;

  final CoachRepository _coach;
  final HabitInsightsRepository _insights;
  final GetHabitStats _getHabitStats;
  final HabitsRepository _habits;

  Future<HabitInsight?> getCached(String habitId) =>
      _insights.getLast(habitId);

  Future<HabitInsight> regenerate(String habitId) async {
    final habit = await _habits.getById(habitId);
    if (habit == null) {
      throw StateError('Hábito no encontrado: $habitId');
    }
    final stats = await _getHabitStats(habitId: habitId);

    final freqLabel = HabitFrequencyFormat.format(habit.frequency);
    final scorePct = (stats.score * 100).round();
    final ratePct = (stats.last4WeeksRate * 100).round();
    final summary = 'Racha actual: ${stats.currentStreak}d.'
        ' Mejor racha: ${stats.bestStreak}d.'
        ' Score: $scorePct%.'
        ' Últimas 4 semanas: $ratePct%.';

    final descLabel = (habit.description?.trim().isNotEmpty ?? false)
        ? habit.description!.trim()
        : '(sin descripción)';
    final text = await _coach.generateHabitInsight(
      habitName: habit.name,
      habitDescription: descLabel,
      habitFrequency: freqLabel,
      habitStatsSummary: summary,
    );

    final insight = HabitInsight(
      habitId: habitId,
      text: text,
      generatedAt: DateTime.now(),
    );
    await _insights.save(insight);
    return insight;
  }
}
