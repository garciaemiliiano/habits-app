import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/habit_colors.dart';
import '../../../core/utils/id_generator.dart';
import '../../../data/datasources/notifications_datasource.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_frequency.dart';
import '../../../domain/entities/reminder_config.dart';
import '../../../domain/usecases/cancel_reminder.dart';
import '../../../domain/usecases/create_habit.dart';
import '../../../domain/usecases/schedule_reminder.dart';
import '../../../domain/usecases/update_habit.dart';

part 'habit_edit_event.dart';
part 'habit_edit_state.dart';

class HabitEditBloc extends Bloc<HabitEditEvent, HabitEditState> {
  HabitEditBloc({
    required CreateHabit createHabit,
    required UpdateHabit updateHabit,
    required ScheduleReminder scheduleReminder,
    required CancelReminder cancelReminder,
    required NotificationsDatasource notifications,
  })  : _createHabit = createHabit,
        _updateHabit = updateHabit,
        _scheduleReminder = scheduleReminder,
        _cancelReminder = cancelReminder,
        _notifications = notifications,
        super(HabitEditState.empty()) {
    on<HabitEditInitialized>(_onInit);
    on<HabitEditNameChanged>((e, emit) => emit(state.copyWith(name: e.value)));
    on<HabitEditDescChanged>(
        (e, emit) => emit(state.copyWith(description: e.value)));
    on<HabitEditColorChanged>(
        (e, emit) => emit(state.copyWith(color: e.value)));
    on<HabitEditIconChanged>((e, emit) => emit(state.copyWith(icon: e.value)));
    on<HabitEditFrequencyKindChanged>((e, emit) => emit(state.copyWith(
        frequencyKind: e.value,
        frequencyTarget: switch (e.value) {
          FrequencyKind.daily => 1,
          FrequencyKind.weekly => 3,
          FrequencyKind.monthly => 4,
        })));
    on<HabitEditFrequencyTargetChanged>(
        (e, emit) => emit(state.copyWith(frequencyTarget: e.value)));
    on<HabitEditWeekdayMaskChanged>(
        (e, emit) => emit(state.copyWith(dailyWeekdayMask: e.value)));
    on<HabitEditReminderAdded>(_onReminderAdded);
    on<HabitEditReminderUpdated>(_onReminderUpdated);
    on<HabitEditReminderToggled>(_onReminderToggled);
    on<HabitEditReminderRemoved>(_onReminderRemoved);
    on<HabitEditSubmitRequested>(_onSubmit);
  }

  final CreateHabit _createHabit;
  final UpdateHabit _updateHabit;
  final ScheduleReminder _scheduleReminder;
  final CancelReminder _cancelReminder;
  final NotificationsDatasource _notifications;

  void _onInit(HabitEditInitialized event, Emitter<HabitEditState> emit) {
    final h = event.existing;
    if (h == null) {
      emit(HabitEditState.empty());
      return;
    }
    final freq = h.frequency;
    emit(HabitEditState(
      existing: h,
      name: h.name,
      description: h.description ?? '',
      color: h.color,
      icon: h.icon,
      frequencyKind: freq.kind,
      frequencyTarget: freq.target,
      dailyWeekdayMask: switch (freq) {
        DailyFrequency(:final weekdayMask) => weekdayMask,
        _ => 0,
      },
      reminders: List.unmodifiable(event.existingReminders),
      initialReminderIds:
          event.existingReminders.map((r) => r.id).toSet(),
      deletedReminderIds: const [],
      status: HabitEditStatus.editing,
    ));
  }

  void _onReminderAdded(
    HabitEditReminderAdded event,
    Emitter<HabitEditState> emit,
  ) {
    if (!state.canAddReminder) return;
    final id = generateReminderId();
    final newReminder = ReminderConfig(
      id: id,
      habitId: state.existing?.id ?? '',
      enabled: true,
      time: event.time,
      weekdayMask: event.weekdayMask,
      notificationId: notificationIdForReminder(id),
      position: state.reminders.length,
    );
    emit(state.copyWith(reminders: [...state.reminders, newReminder]));
  }

  void _onReminderUpdated(
    HabitEditReminderUpdated event,
    Emitter<HabitEditState> emit,
  ) {
    final updated = state.reminders.map((r) {
      if (r.id != event.id) return r;
      return r.copyWith(time: event.time, weekdayMask: event.weekdayMask);
    }).toList();
    emit(state.copyWith(reminders: updated));
  }

  void _onReminderToggled(
    HabitEditReminderToggled event,
    Emitter<HabitEditState> emit,
  ) {
    final updated = state.reminders.map((r) {
      if (r.id != event.id) return r;
      return r.copyWith(enabled: event.enabled);
    }).toList();
    emit(state.copyWith(reminders: updated));
  }

  void _onReminderRemoved(
    HabitEditReminderRemoved event,
    Emitter<HabitEditState> emit,
  ) {
    final remaining = state.reminders.where((r) => r.id != event.id).toList();
    // Reasignar positions consecutivos para mantener orden.
    final repositioned = <ReminderConfig>[
      for (var i = 0; i < remaining.length; i++)
        remaining[i].copyWith(position: i),
    ];
    final wasExisting = state.initialReminderIds.contains(event.id);
    emit(state.copyWith(
      reminders: repositioned,
      deletedReminderIds: wasExisting
          ? [...state.deletedReminderIds, event.id]
          : state.deletedReminderIds,
    ));
  }

  Future<void> _onSubmit(
      HabitEditSubmitRequested event, Emitter<HabitEditState> emit) async {
    final errors = <String, String>{};
    if (state.name.trim().isEmpty) {
      errors['name'] = 'El nombre es obligatorio';
    }
    if (state.frequencyKind == FrequencyKind.weekly &&
        (state.frequencyTarget < 1 || state.frequencyTarget > 7)) {
      errors['target'] = 'Entre 1 y 7';
    }
    if (state.frequencyKind == FrequencyKind.monthly &&
        (state.frequencyTarget < 1 || state.frequencyTarget > 31)) {
      errors['target'] = 'Entre 1 y 31';
    }
    if (errors.isNotEmpty) {
      emit(state.copyWith(validationErrors: errors));
      return;
    }

    emit(state.copyWith(status: HabitEditStatus.submitting));
    try {
      final freq = HabitFrequency.fromKind(
        kind: state.frequencyKind,
        target: state.frequencyTarget,
        weekdayMask: state.dailyWeekdayMask,
      );
      Habit saved;
      if (state.existing == null) {
        saved = await _createHabit(
          name: state.name,
          description: state.description,
          color: state.color,
          icon: state.icon,
          frequency: freq,
        );
      } else {
        saved = await _updateHabit(state.existing!.copyWith(
          name: state.name.trim(),
          description: state.description.trim().isEmpty
              ? null
              : state.description.trim(),
          color: state.color,
          icon: state.icon,
          frequency: freq,
        ));
      }

      // Pedir permisos de notificaciones si hay reminders activos. Si el
      // user deniega, igual persistimos la config pero no van a sonar.
      if (state.hasEnabledReminders) {
        await _notifications.requestPermissions();
      }

      // Cancelar los reminders eliminados en esta sesión.
      for (final id in state.deletedReminderIds) {
        await _cancelReminder(id);
      }

      // Upsert + schedule de cada reminder en el state.
      for (final r in state.reminders) {
        await _scheduleReminder(r.copyWith(habitId: saved.id));
      }

      emit(state.copyWith(
        status: HabitEditStatus.submitted,
        savedHabit: saved,
        validationErrors: const {},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HabitEditStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
