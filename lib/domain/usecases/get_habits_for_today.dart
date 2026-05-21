import '../../app/preferences/app_preferences.dart';
import '../../core/utils/date_range.dart';
import '../../core/utils/week_helper.dart';
import '../entities/habit_frequency.dart';
import '../entities/habit_with_today_status.dart';
import '../repositories/completions_repository.dart';
import '../repositories/habits_repository.dart';
import '../repositories/reminders_repository.dart';

class GetHabitsForToday {
  GetHabitsForToday({
    required this.habits,
    required this.completions,
    required this.reminders,
    required this.prefs,
  });

  final HabitsRepository habits;
  final CompletionsRepository completions;
  final RemindersRepository reminders;
  final AppPreferences prefs;

  Future<List<HabitWithTodayStatus>> call(DateTime date) async {
    final day = DateRange.dayOf(date);
    final weekdayBit = 1 << (day.weekday - 1);
    final all = await habits.getAll();
    final result = <HabitWithTodayStatus>[];

    for (final habit in all) {
      final isDueToday = habit.frequency.isDueOn(day);
      final todayCompleted =
          await completions.countOn(habitId: habit.id, day: day);

      int todayTarget;
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
          todayTarget = 1;
        case TimesPerMonthFrequency(:final target):
          final (from, to) = WeekHelper(prefs.weekStartsOn).monthRange(day);
          periodCompleted = await completions.countInRange(
            habitId: habit.id,
            from: from,
            to: to,
          );
          periodTarget = target;
          todayTarget = 1;
        case DailyFrequency():
          final habitReminders = await reminders.getForHabit(habit.id);
          final dueToday = habitReminders
              .where((r) => r.enabled && (r.weekdayMask & weekdayBit) != 0)
              .length;
          todayTarget = dueToday > 0 ? dueToday : 1;
      }

      result.add(HabitWithTodayStatus(
        habit: habit,
        isDueToday: isDueToday,
        todayCompleted: todayCompleted,
        todayTarget: todayTarget,
        periodCompleted: periodCompleted,
        periodTarget: periodTarget,
      ));
    }

    return result;
  }
}
