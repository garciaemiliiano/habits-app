import '../../core/utils/date_range.dart';
import '../../domain/entities/completion.dart';

class CompletionDto {
  CompletionDto({
    required this.id,
    required this.habitId,
    required this.dayKey,
    required this.dayMs,
    required this.completedAtMs,
  });

  final String id;
  final String habitId;
  final int dayKey;
  final int dayMs;
  final int completedAtMs;

  Map<String, Object?> toMap() => {
        'id': id,
        'habit_id': habitId,
        'day_key': dayKey,
        'day_ms': dayMs,
        'completed_at': completedAtMs,
      };

  factory CompletionDto.fromMap(Map<String, Object?> row) {
    return CompletionDto(
      id: row['id']! as String,
      habitId: row['habit_id']! as String,
      dayKey: (row['day_key']! as num).toInt(),
      dayMs: (row['day_ms']! as num).toInt(),
      completedAtMs: (row['completed_at']! as num).toInt(),
    );
  }

  factory CompletionDto.create({
    required String habitId,
    required DateTime day,
    required DateTime now,
  }) {
    final d = DateRange.dayOf(day);
    final key = DateRange.dayKeyOf(d);
    return CompletionDto(
      id: 'c_${habitId}_$key',
      habitId: habitId,
      dayKey: key,
      dayMs: d.millisecondsSinceEpoch,
      completedAtMs: now.millisecondsSinceEpoch,
    );
  }

  Completion toEntity() => Completion(
        id: id,
        habitId: habitId,
        day: DateTime.fromMillisecondsSinceEpoch(dayMs),
        completedAt: DateTime.fromMillisecondsSinceEpoch(completedAtMs),
      );
}
