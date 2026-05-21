import '../../core/utils/habit_frequency_format.dart';
import '../entities/habit_frequency.dart';
import '../entities/habit_insight.dart';
import '../entities/reminder_config.dart';
import '../repositories/coach_repository.dart';
import '../repositories/completions_repository.dart';
import '../repositories/habit_insights_repository.dart';
import '../repositories/habits_repository.dart';
import '../repositories/reminders_repository.dart';
import 'get_habit_stats.dart';

class GenerateHabitInsight {
  GenerateHabitInsight({
    required CoachRepository coach,
    required HabitInsightsRepository insights,
    required GetHabitStats getHabitStats,
    required HabitsRepository habits,
    required RemindersRepository reminders,
    required CompletionsRepository completions,
  })  : _coach = coach,
        _insights = insights,
        _getHabitStats = getHabitStats,
        _habits = habits,
        _reminders = reminders,
        _completions = completions;

  final CoachRepository _coach;
  final HabitInsightsRepository _insights;
  final GetHabitStats _getHabitStats;
  final HabitsRepository _habits;
  final RemindersRepository _reminders;
  final CompletionsRepository _completions;

  static const _weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  Future<HabitInsight?> getCached(String habitId) =>
      _insights.getLast(habitId);

  Future<HabitInsight> regenerate(String habitId) async {
    final habit = await _habits.getById(habitId);
    if (habit == null) {
      throw StateError('Hábito no encontrado: $habitId');
    }
    final stats = await _getHabitStats(habitId: habitId);
    final habitReminders = await _reminders.getForHabit(habit.id);
    final today = DateTime.now();
    final todayCount =
        await _completions.countOn(habitId: habit.id, day: today);

    final freqLabel = _buildFrequencyLabel(habit.frequency, habitReminders);
    final scorePct = (stats.score * 100).round();
    final ratePct = (stats.last4WeeksRate * 100).round();
    final todayTarget = _todayTargetFor(habit.frequency, habitReminders, today);
    final todayLine = habit.frequency is DailyFrequency && todayTarget > 1
        ? ' Hoy: $todayCount/$todayTarget.'
        : '';
    final summary = 'Racha actual: ${stats.currentStreak}d.'
        ' Mejor racha: ${stats.bestStreak}d.'
        ' Score: $scorePct%.'
        ' Últimas 4 semanas: $ratePct%.'
        '$todayLine';

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

  String _buildFrequencyLabel(
    HabitFrequency freq,
    List<ReminderConfig> reminders,
  ) {
    final base = HabitFrequencyFormat.format(freq);
    if (freq is! DailyFrequency) return base;
    final enabled = reminders.where((r) => r.enabled).toList();
    if (enabled.isEmpty) return '$base · sin recordatorios';
    enabled.sort((a, b) {
      final am = a.time.hour * 60 + a.time.minute;
      final bm = b.time.hour * 60 + b.time.minute;
      return am.compareTo(bm);
    });
    final detail = enabled.map((r) {
      final hh = r.time.hour.toString().padLeft(2, '0');
      final mm = r.time.minute.toString().padLeft(2, '0');
      final days = _maskToDays(r.weekdayMask);
      return '$hh:$mm $days';
    }).join(', ');
    return '$base · ${enabled.length} ${enabled.length == 1 ? "vez" : "veces"}'
        ' por día ($detail)';
  }

  int _todayTargetFor(
    HabitFrequency freq,
    List<ReminderConfig> reminders,
    DateTime day,
  ) {
    if (freq is! DailyFrequency) return 1;
    final weekdayBit = 1 << (day.weekday - 1);
    final dueToday = reminders
        .where((r) => r.enabled && (r.weekdayMask & weekdayBit) != 0)
        .length;
    return dueToday > 0 ? dueToday : 1;
  }

  String _maskToDays(int mask) {
    if (mask == 127 || mask == 0) return 'todos los días';
    final days = <String>[];
    for (var i = 0; i < 7; i++) {
      if ((mask & (1 << i)) != 0) days.add(_weekdayLabels[i]);
    }
    return days.join('-');
  }
}
