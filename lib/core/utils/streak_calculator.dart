import '../../domain/entities/completion.dart';
import '../../domain/entities/habit_frequency.dart';
import 'date_range.dart';
import 'week_helper.dart';

/// Cálculo puro de streak y score a partir de una lista de completions
/// + la frecuencia del hábito. No usa SQL.
class StreakCalculator {
  StreakCalculator._();

  /// Streak actual y mejor histórico para hábitos **diarios**.
  /// La regla: cuentan los días "due" según la frecuencia (mask de días).
  /// Si el último día due está marcado, el streak corre; si no, está en 0.
  static (int current, int best) dailyStreaks({
    required List<Completion> completions,
    required DailyFrequency frequency,
    required DateTime today,
  }) {
    final completedDays = completions
        .map((c) => DateRange.dayKeyOf(c.day))
        .toSet();

    int current = 0;
    int best = 0;
    int run = 0;
    var cursor = DateRange.dayOf(today);

    // Caminamos hacia atrás como mucho 3 años (~1100 días) para evitar
    // loops infinitos en datasets degenerados.
    const maxDays = 1100;
    var todayProcessed = false;

    for (var i = 0; i < maxDays; i++) {
      final isDue = frequency.isDueOn(cursor);
      if (isDue) {
        final key = DateRange.dayKeyOf(cursor);
        if (completedDays.contains(key)) {
          run += 1;
          if (run > best) best = run;
          if (!todayProcessed || current > 0 || i == 0) {
            current = run;
          }
        } else {
          // Si el día "due" más reciente no está completado:
          // - si es hoy, el streak puede mantenerse hasta fin de día,
          //   así que no lo cortamos para `current` (se mira al día due
          //   inmediatamente anterior).
          if (i == 0) {
            // hoy due pero no completado: streak actual = lo que viene atrás.
          } else {
            // racha cortada
            run = 0;
          }
        }
      }
      todayProcessed = true;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return (current, best);
  }

  /// Streak en "períodos" (semanas/meses) que cumplieron la meta.
  static (int current, int best) flexibleStreaks({
    required List<Completion> completions,
    required HabitFrequency frequency,
    required DateTime today,
    required WeekHelper week,
  }) {
    final completedDays = completions
        .map((c) => DateRange.dayKeyOf(c.day))
        .toSet();

    final target = frequency.target;
    int current = 0;
    int best = 0;
    int run = 0;

    bool periodMet(DateTime start, DateTime end) {
      var count = 0;
      var d = start;
      while (d.isBefore(end)) {
        if (completedDays.contains(DateRange.dayKeyOf(d))) count++;
        d = d.add(const Duration(days: 1));
      }
      return count >= target;
    }

    // Iteramos hacia atrás como mucho 150 períodos.
    const maxPeriods = 150;
    DateTime currentStart;
    DateTime currentEnd;
    if (frequency.kind == FrequencyKind.weekly) {
      currentStart = week.startOfWeek(today);
      currentEnd = week.startOfNextWeek(today);
    } else {
      // monthly
      currentStart = DateRange.monthStart(today);
      currentEnd = DateRange.nextMonthStart(today);
    }

    for (var i = 0; i < maxPeriods; i++) {
      final met = periodMet(currentStart, currentEnd);
      if (met) {
        run += 1;
        if (run > best) best = run;
        if (i == 0 || current == run - 1) {
          current = run;
        }
      } else {
        if (i == 0) {
          // El período actual aún puede cumplirse hoy: no cortamos el current.
        } else {
          run = 0;
        }
      }
      // Retrocede un período
      if (frequency.kind == FrequencyKind.weekly) {
        currentEnd = currentStart;
        currentStart = currentStart.subtract(const Duration(days: 7));
      } else {
        currentEnd = currentStart;
        currentStart = _previousMonthStart(currentStart);
      }
    }

    return (current, best);
  }

  static DateTime _previousMonthStart(DateTime monthStart) {
    final year = monthStart.month == 1 ? monthStart.year - 1 : monthStart.year;
    final month = monthStart.month == 1 ? 12 : monthStart.month - 1;
    return DateTime(year, month, 1);
  }

  /// Score con decay exponencial estilo Loop Habits.
  /// 1 al completar, decay diario `1 - alpha` cuando no se completa un
  /// día due. Devuelve el valor en `today`.
  static double score({
    required List<Completion> completions,
    required HabitFrequency frequency,
    required DateTime today,
    double alpha = 0.05,
  }) {
    final completedDays = completions
        .map((c) => DateRange.dayKeyOf(c.day))
        .toSet();

    if (completions.isEmpty) return 0;

    final first = completions
        .map((c) => c.day)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final start = DateRange.dayOf(first);
    final end = DateRange.dayOf(today);

    double s = 0;
    var cursor = start;
    while (!cursor.isAfter(end)) {
      final isDue = switch (frequency) {
        DailyFrequency f => f.isDueOn(cursor),
        // Para flexibles consideramos "due" todos los días: el peso es el
        // ratio target / 7 (o /días del mes).
        _ => true,
      };
      if (isDue) {
        final completed =
            completedDays.contains(DateRange.dayKeyOf(cursor));
        final weight = switch (frequency) {
          DailyFrequency() => 1.0,
          TimesPerWeekFrequency(:final target) => target / 7.0,
          TimesPerMonthFrequency(:final target) => target / 30.0,
        };
        if (completed) {
          s = s + alpha * (1.0 - s) * weight;
        } else {
          s = s - alpha * s * weight;
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return s.clamp(0.0, 1.0);
  }

  /// % cumplimiento de las últimas 4 semanas (frecuencia diaria: días
  /// completados / días due; flexible: períodos cumplidos / 4).
  static double last4WeeksRate({
    required List<Completion> completions,
    required HabitFrequency frequency,
    required DateTime today,
    required WeekHelper week,
  }) {
    final completedDays = completions
        .map((c) => DateRange.dayKeyOf(c.day))
        .toSet();

    if (frequency is DailyFrequency) {
      final end = DateRange.dayOf(today).add(const Duration(days: 1));
      final start = end.subtract(const Duration(days: 28));
      var due = 0;
      var done = 0;
      var d = start;
      while (d.isBefore(end)) {
        if (frequency.isDueOn(d)) {
          due++;
          if (completedDays.contains(DateRange.dayKeyOf(d))) done++;
        }
        d = d.add(const Duration(days: 1));
      }
      if (due == 0) return 0;
      return done / due;
    }

    // weekly / monthly: medimos 4 semanas hacia atrás como períodos
    // semanales independientemente del kind (monthly se prorratea).
    final endWeek = week.startOfNextWeek(today);
    int periodsMet = 0;
    for (var i = 0; i < 4; i++) {
      final wEnd = endWeek.subtract(Duration(days: 7 * i));
      final wStart = wEnd.subtract(const Duration(days: 7));
      var count = 0;
      var d = wStart;
      while (d.isBefore(wEnd)) {
        if (completedDays.contains(DateRange.dayKeyOf(d))) count++;
        d = d.add(const Duration(days: 1));
      }
      final weeklyTarget = switch (frequency) {
        TimesPerWeekFrequency(:final target) => target,
        TimesPerMonthFrequency(:final target) =>
          (target / 4.0).clamp(1, 31).round(),
        _ => 1,
      };
      if (count >= weeklyTarget) periodsMet++;
    }
    return periodsMet / 4.0;
  }
}
