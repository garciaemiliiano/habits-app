import '../../app/preferences/app_preferences.dart';
import '../../core/utils/date_range.dart';
import '../../core/utils/streak_calculator.dart';
import '../../core/utils/week_helper.dart';
import '../entities/completion.dart';
import '../entities/habit.dart';
import '../entities/habit_frequency.dart';
import '../entities/habit_stats.dart';
import '../entities/heatmap_cell.dart';
import '../repositories/completions_repository.dart';
import '../repositories/habits_repository.dart';

class GetHabitStats {
  GetHabitStats({
    required this.habits,
    required this.completions,
    required this.prefs,
  });

  final HabitsRepository habits;
  final CompletionsRepository completions;
  final AppPreferences prefs;

  Future<HabitStats> call({
    required String habitId,
    int? heatmapMonths,
  }) async {
    final habit = await habits.getById(habitId);
    if (habit == null) {
      return const HabitStats(
        currentStreak: 0,
        bestStreak: 0,
        score: 0,
        last4WeeksRate: 0,
        heatmap: [],
      );
    }

    final today = DateRange.dayOf(DateTime.now());
    final months = heatmapMonths ?? prefs.heatmapMonths;
    final allCompletions = await completions.listAll(habitId);

    final wh = WeekHelper(prefs.weekStartsOn);

    final (current, best) = switch (habit.frequency) {
      DailyFrequency f => StreakCalculator.dailyStreaks(
          completions: allCompletions,
          frequency: f,
          today: today,
        ),
      _ => StreakCalculator.flexibleStreaks(
          completions: allCompletions,
          frequency: habit.frequency,
          today: today,
          week: wh,
        ),
    };

    final score = StreakCalculator.score(
      completions: allCompletions,
      frequency: habit.frequency,
      today: today,
    );

    final rate = StreakCalculator.last4WeeksRate(
      completions: allCompletions,
      frequency: habit.frequency,
      today: today,
      week: wh,
    );

    final heatmap = _buildHeatmap(
      habit: habit,
      completions: allCompletions,
      today: today,
      months: months,
      wh: wh,
    );

    return HabitStats(
      currentStreak: current,
      bestStreak: best,
      score: score,
      last4WeeksRate: rate,
      heatmap: heatmap,
    );
  }

  List<HeatmapCell> _buildHeatmap({
    required Habit habit,
    required List<Completion> completions,
    required DateTime today,
    required int months,
    required WeekHelper wh,
  }) {
    final from = DateTime(today.year, today.month - months + 1, 1);
    final end = today.add(const Duration(days: 1));
    final completedKeys = completions
        .map((c) => DateRange.dayKeyOf(c.day))
        .toSet();

    final cells = <HeatmapCell>[];
    var cursor = from;
    while (cursor.isBefore(end)) {
      final key = DateRange.dayKeyOf(cursor);
      final completed = completedKeys.contains(key);
      double intensity;
      if (completed) {
        intensity = 1.0;
      } else if (habit.frequency.kind == FrequencyKind.weekly ||
          habit.frequency.kind == FrequencyKind.monthly) {
        // Para flexibles, días del período con avance parcial reciben una
        // intensidad escalada al progreso semanal en ese día.
        final (wFrom, wTo) = habit.frequency.kind == FrequencyKind.weekly
            ? wh.weekRange(cursor)
            : wh.monthRange(cursor);
        final periodCount = _countInRange(completedKeys, wFrom, wTo);
        final target = habit.frequency.target;
        intensity = target == 0 ? 0 : (periodCount / target).clamp(0.0, 1.0);
        // Solo días previos al actual del período aportan; el día sin
        // completion vacío queda en intensity 0.
        if (intensity > 0 && !completed) {
          // damos un baseline visual leve
          intensity = intensity * 0.4;
        }
      } else {
        intensity = 0;
      }
      cells.add(HeatmapCell(
        day: cursor,
        intensity: intensity,
        completed: completed,
      ));
      cursor = cursor.add(const Duration(days: 1));
    }
    return cells;
  }

  int _countInRange(Set<int> completedKeys, DateTime from, DateTime to) {
    var count = 0;
    var d = from;
    while (d.isBefore(to)) {
      if (completedKeys.contains(DateRange.dayKeyOf(d))) count++;
      d = d.add(const Duration(days: 1));
    }
    return count;
  }
}
