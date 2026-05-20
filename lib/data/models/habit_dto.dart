import '../../core/constants/habit_colors.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_frequency.dart';

class HabitDto {
  HabitDto({
    required this.id,
    required this.name,
    required this.description,
    required this.colorHex,
    required this.iconCode,
    required this.frequencyKind,
    required this.frequencyTarget,
    required this.dailyWeekdayMask,
    required this.position,
    required this.archived,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  final String id;
  final String name;
  final String? description;
  final String colorHex;
  final int iconCode;
  final String frequencyKind;
  final int frequencyTarget;
  final int dailyWeekdayMask;
  final int position;
  final int archived;
  final int createdAtMs;
  final int updatedAtMs;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'color_hex': colorHex,
        'icon_code': iconCode,
        'frequency_kind': frequencyKind,
        'frequency_target': frequencyTarget,
        'daily_weekday_mask': dailyWeekdayMask,
        'position': position,
        'archived': archived,
        'created_at': createdAtMs,
        'updated_at': updatedAtMs,
      };

  factory HabitDto.fromMap(Map<String, Object?> row) {
    return HabitDto(
      id: row['id']! as String,
      name: row['name']! as String,
      description: row['description'] as String?,
      colorHex: row['color_hex']! as String,
      iconCode: (row['icon_code']! as num).toInt(),
      frequencyKind: row['frequency_kind']! as String,
      frequencyTarget: (row['frequency_target']! as num).toInt(),
      dailyWeekdayMask: (row['daily_weekday_mask']! as num).toInt(),
      position: (row['position']! as num).toInt(),
      archived: (row['archived']! as num).toInt(),
      createdAtMs: (row['created_at']! as num).toInt(),
      updatedAtMs: (row['updated_at']! as num).toInt(),
    );
  }

  factory HabitDto.fromEntity(Habit habit) {
    final kind = habit.frequency.kind;
    return HabitDto(
      id: habit.id,
      name: habit.name,
      description: habit.description,
      colorHex: HabitColors.toHex(habit.color),
      iconCode: habit.icon.codePoint,
      frequencyKind: kind.name,
      frequencyTarget: habit.frequency.target,
      dailyWeekdayMask: switch (habit.frequency) {
        DailyFrequency(:final weekdayMask) => weekdayMask,
        _ => 0,
      },
      position: habit.position,
      archived: habit.archived ? 1 : 0,
      createdAtMs: habit.createdAt.millisecondsSinceEpoch,
      updatedAtMs: habit.updatedAt.millisecondsSinceEpoch,
    );
  }

  Habit toEntity() {
    final kind = FrequencyKind.values.firstWhere(
      (k) => k.name == frequencyKind,
      orElse: () => FrequencyKind.daily,
    );
    return Habit(
      id: id,
      name: name,
      description: description,
      color: HabitColors.fromHex(colorHex),
      icon: HabitIcons.fromCode(iconCode),
      frequency: HabitFrequency.fromKind(
        kind: kind,
        target: frequencyTarget,
        weekdayMask: dailyWeekdayMask,
      ),
      position: position,
      archived: archived == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    );
  }
}
