import 'package:equatable/equatable.dart';

enum FrequencyKind { daily, weekly, monthly }

/// Cómo se mide el cumplimiento de un hábito.
sealed class HabitFrequency extends Equatable {
  const HabitFrequency();

  FrequencyKind get kind;
  int get target;

  /// ¿El hábito está "due" ese día? Para flexibles siempre true (se mide
  /// por período, no por día concreto).
  bool isDueOn(DateTime day) => true;

  factory HabitFrequency.fromKind({
    required FrequencyKind kind,
    required int target,
    int weekdayMask = 0,
  }) {
    return switch (kind) {
      FrequencyKind.daily => DailyFrequency(weekdayMask: weekdayMask),
      FrequencyKind.weekly => TimesPerWeekFrequency(target),
      FrequencyKind.monthly => TimesPerMonthFrequency(target),
    };
  }
}

/// Diario. Si `weekdayMask` == 0 → todos los días; si no, bit0=lun..bit6=dom.
class DailyFrequency extends HabitFrequency {
  const DailyFrequency({this.weekdayMask = 0});

  final int weekdayMask;

  @override
  FrequencyKind get kind => FrequencyKind.daily;

  @override
  int get target => 1;

  @override
  bool isDueOn(DateTime day) =>
      weekdayMask == 0 || (weekdayMask & (1 << (day.weekday - 1))) != 0;

  @override
  List<Object?> get props => [weekdayMask];
}

class TimesPerWeekFrequency extends HabitFrequency {
  const TimesPerWeekFrequency(this.target);

  @override
  FrequencyKind get kind => FrequencyKind.weekly;

  @override
  final int target;

  @override
  List<Object?> get props => [target];
}

class TimesPerMonthFrequency extends HabitFrequency {
  const TimesPerMonthFrequency(this.target);

  @override
  FrequencyKind get kind => FrequencyKind.monthly;

  @override
  final int target;

  @override
  List<Object?> get props => [target];
}
