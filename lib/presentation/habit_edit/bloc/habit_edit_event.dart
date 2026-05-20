part of 'habit_edit_bloc.dart';

sealed class HabitEditEvent extends Equatable {
  const HabitEditEvent();

  @override
  List<Object?> get props => [];
}

class HabitEditInitialized extends HabitEditEvent {
  const HabitEditInitialized({
    this.existing,
    this.existingReminders = const [],
  });
  final Habit? existing;
  final List<ReminderConfig> existingReminders;
  @override
  List<Object?> get props => [existing, existingReminders];
}

class HabitEditNameChanged extends HabitEditEvent {
  const HabitEditNameChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class HabitEditDescChanged extends HabitEditEvent {
  const HabitEditDescChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class HabitEditColorChanged extends HabitEditEvent {
  const HabitEditColorChanged(this.value);
  final Color value;
  @override
  List<Object?> get props => [value];
}

class HabitEditIconChanged extends HabitEditEvent {
  const HabitEditIconChanged(this.value);
  final IconData value;
  @override
  List<Object?> get props => [value];
}

class HabitEditFrequencyKindChanged extends HabitEditEvent {
  const HabitEditFrequencyKindChanged(this.value);
  final FrequencyKind value;
  @override
  List<Object?> get props => [value];
}

class HabitEditFrequencyTargetChanged extends HabitEditEvent {
  const HabitEditFrequencyTargetChanged(this.value);
  final int value;
  @override
  List<Object?> get props => [value];
}

class HabitEditWeekdayMaskChanged extends HabitEditEvent {
  const HabitEditWeekdayMaskChanged(this.value);
  final int value;
  @override
  List<Object?> get props => [value];
}

class HabitEditReminderAdded extends HabitEditEvent {
  const HabitEditReminderAdded({
    required this.time,
    required this.weekdayMask,
  });
  final TimeOfDay time;
  final int weekdayMask;
  @override
  List<Object?> get props => [time.hour, time.minute, weekdayMask];
}

class HabitEditReminderUpdated extends HabitEditEvent {
  const HabitEditReminderUpdated({
    required this.id,
    required this.time,
    required this.weekdayMask,
  });
  final String id;
  final TimeOfDay time;
  final int weekdayMask;
  @override
  List<Object?> get props => [id, time.hour, time.minute, weekdayMask];
}

class HabitEditReminderToggled extends HabitEditEvent {
  const HabitEditReminderToggled({required this.id, required this.enabled});
  final String id;
  final bool enabled;
  @override
  List<Object?> get props => [id, enabled];
}

class HabitEditReminderRemoved extends HabitEditEvent {
  const HabitEditReminderRemoved(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class HabitEditSubmitRequested extends HabitEditEvent {
  const HabitEditSubmitRequested();
}
