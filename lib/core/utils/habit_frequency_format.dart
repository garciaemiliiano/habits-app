import '../../domain/entities/habit_frequency.dart';

/// Formato natural en español para la frecuencia de un hábito. Reusado
/// por BuildHabitsContext y GenerateHabitInsight para serializar
/// hábitos en el prompt.
class HabitFrequencyFormat {
  HabitFrequencyFormat._();

  static const _weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  static String format(HabitFrequency freq) {
    return switch (freq) {
      DailyFrequency(:final weekdayMask) when weekdayMask == 0 =>
        'diario, todos los días',
      DailyFrequency(:final weekdayMask) => 'diario, ${_maskToDays(weekdayMask)}',
      TimesPerWeekFrequency(:final target) => '$target veces por semana',
      TimesPerMonthFrequency(:final target) => '$target veces por mes',
    };
  }

  static String _maskToDays(int mask) {
    final days = <String>[];
    for (var i = 0; i < 7; i++) {
      if ((mask & (1 << i)) != 0) days.add(_weekdayLabels[i]);
    }
    return days.join(' ');
  }
}
