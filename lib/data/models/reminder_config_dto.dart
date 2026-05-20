import 'package:flutter/material.dart';

import '../../domain/entities/reminder_config.dart';

class ReminderConfigDto {
  ReminderConfigDto({
    required this.id,
    required this.habitId,
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.weekdayMask,
    required this.notificationId,
    required this.position,
  });

  final String id;
  final String habitId;
  final int enabled;
  final int hour;
  final int minute;
  final int weekdayMask;
  final int notificationId;
  final int position;

  Map<String, Object?> toMap() => {
        'id': id,
        'habit_id': habitId,
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
        'weekday_mask': weekdayMask,
        'notification_id': notificationId,
        'position': position,
      };

  factory ReminderConfigDto.fromMap(Map<String, Object?> row) {
    return ReminderConfigDto(
      id: row['id']! as String,
      habitId: row['habit_id']! as String,
      enabled: (row['enabled']! as num).toInt(),
      hour: (row['hour']! as num).toInt(),
      minute: (row['minute']! as num).toInt(),
      weekdayMask: (row['weekday_mask']! as num).toInt(),
      notificationId: (row['notification_id']! as num).toInt(),
      position: (row['position']! as num).toInt(),
    );
  }

  factory ReminderConfigDto.fromEntity(ReminderConfig c) {
    return ReminderConfigDto(
      id: c.id,
      habitId: c.habitId,
      enabled: c.enabled ? 1 : 0,
      hour: c.time.hour,
      minute: c.time.minute,
      weekdayMask: c.weekdayMask,
      notificationId: c.notificationId,
      position: c.position,
    );
  }

  ReminderConfig toEntity() => ReminderConfig(
        id: id,
        habitId: habitId,
        enabled: enabled == 1,
        time: TimeOfDay(hour: hour, minute: minute),
        weekdayMask: weekdayMask,
        notificationId: notificationId,
        position: position,
      );
}
