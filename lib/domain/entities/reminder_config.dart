import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ReminderConfig extends Equatable {
  const ReminderConfig({
    required this.id,
    required this.habitId,
    required this.enabled,
    required this.time,
    required this.weekdayMask,
    required this.notificationId,
    this.position = 0,
  });

  final String id;
  final String habitId;
  final bool enabled;
  final TimeOfDay time;

  /// Bitmask de días: bit0=lun..bit6=dom. 127 = todos los días.
  final int weekdayMask;

  /// Id estable base para `flutter_local_notifications.cancel()`. Cada
  /// weekday agendado usa `notificationId + (weekday-1)`.
  final int notificationId;

  /// Orden visual dentro del hábito.
  final int position;

  ReminderConfig copyWith({
    String? habitId,
    bool? enabled,
    TimeOfDay? time,
    int? weekdayMask,
    int? position,
  }) {
    return ReminderConfig(
      id: id,
      habitId: habitId ?? this.habitId,
      enabled: enabled ?? this.enabled,
      time: time ?? this.time,
      weekdayMask: weekdayMask ?? this.weekdayMask,
      notificationId: notificationId,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [
        id,
        habitId,
        enabled,
        time.hour,
        time.minute,
        weekdayMask,
        notificationId,
        position,
      ];
}
