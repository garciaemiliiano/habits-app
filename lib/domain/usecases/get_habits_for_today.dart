import '../../app/preferences/app_preferences.dart';
import '../../core/utils/date_range.dart';
import '../../core/utils/week_helper.dart';
import '../entities/habit_frequency.dart';
import '../entities/habit_with_today_status.dart';
import '../repositories/completions_repository.dart';
import '../repositories/habits_repository.dart';

class GetHabitsForToday {
  GetHabitsForToday({
    required this.habits,
    required this.completions,
    required this.prefs,
  });

  final HabitsRepository habits;
  final CompletionsRepository completions;
  final AppPreferences prefs;

  Future<List<HabitWithTodayStatus>> call(DateTime date) async {
    final day = DateRange.dayOf(date);
    final all = await habits.getAll();
    final result = <HabitWithTodayStatus>[];

    for (final habit in all) {
      final isDueToday = habit.frequency.isDueOn(day);
      final completedToday =
          await completions.isCompleted(habitId: habit.id, day: day);

      int? periodCompleted;
      int? periodTarget;
      switch (habit.frequency) {
        case TimesPerWeekFrequency(:final target):
          final wh = WeekHelper(prefs.weekStartsOn);
          final (from, to) = wh.weekRange(day);
          periodCompleted = await completions.countInRange(
            habitId: habit.id,
            from: from,
            to: to,
          );
          periodTarget = target;
        case TimesPerMonthFrequency(:final target):
          final (from, to) = WeekHelper(prefs.weekStartsOn).monthRange(day);
          periodCompleted = await completions.countInRange(
            habitId: habit.id,
            from: from,
            to: to,
          );
          periodTarget = target;
        case DailyFrequency():
          break;
      }

      result.add(HabitWithTodayStatus(
        habit: habit,
        isDueToday: isDueToday,
        completedToday: completedToday,
        periodCompleted: periodCompleted,
        periodTarget: periodTarget,
      ));
    }

    return result;
  }
}
