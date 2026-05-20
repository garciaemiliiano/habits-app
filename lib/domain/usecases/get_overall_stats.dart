import '../entities/habit.dart';
import '../entities/habit_stats.dart';
import '../repositories/habits_repository.dart';
import 'get_habit_stats.dart';

class OverallStatRow {
  const OverallStatRow({required this.habit, required this.stats});
  final Habit habit;
  final HabitStats stats;
}

class GetOverallStats {
  GetOverallStats({required this.habits, required this.getHabitStats});

  final HabitsRepository habits;
  final GetHabitStats getHabitStats;

  Future<List<OverallStatRow>> call() async {
    final all = await habits.getAll();
    final rows = <OverallStatRow>[];
    for (final h in all) {
      final stats = await getHabitStats(habitId: h.id, heatmapMonths: 3);
      rows.add(OverallStatRow(habit: h, stats: stats));
    }
    return rows;
  }
}
