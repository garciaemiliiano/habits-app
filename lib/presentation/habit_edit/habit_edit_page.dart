import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/di/injector.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/reminder_config.dart';
import 'bloc/habit_edit_bloc.dart';
import 'widgets/color_picker_row.dart';
import 'widgets/frequency_selector.dart';
import 'widgets/icon_picker_sheet.dart';
import 'widgets/reminder_edit_sheet.dart';
import 'widgets/reminder_section.dart';

class HabitEditPage extends StatelessWidget {
  const HabitEditPage({
    super.key,
    this.existing,
    this.existingReminders = const [],
  });

  final Habit? existing;
  final List<ReminderConfig> existingReminders;

  @override
  Widget build(BuildContext context) {
    final injector = Injector.instance;
    return BlocProvider(
      create: (_) => HabitEditBloc(
        createHabit: injector.createHabit,
        updateHabit: injector.updateHabit,
        scheduleReminder: injector.scheduleReminder,
        cancelReminder: injector.cancelReminder,
        notifications: injector.notifications,
      )..add(HabitEditInitialized(
          existing: existing,
          existingReminders: existingReminders,
        )),
      child: const _HabitEditView(),
    );
  }
}

class _HabitEditView extends StatelessWidget {
  const _HabitEditView();

  Future<void> _openSheet(BuildContext context, {ReminderConfig? existing}) async {
    final bloc = context.read<HabitEditBloc>();
    final result = await showModalBottomSheet<ReminderSheetResult>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => ReminderEditSheet(
        initialTime: existing?.time,
        initialMask: existing?.weekdayMask ?? 127,
      ),
    );
    if (result == null) return;
    if (existing == null) {
      bloc.add(HabitEditReminderAdded(
        time: result.time,
        weekdayMask: result.weekdayMask,
      ));
    } else {
      bloc.add(HabitEditReminderUpdated(
        id: existing.id,
        time: result.time,
        weekdayMask: result.weekdayMask,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitEditBloc, HabitEditState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == HabitEditStatus.submitted) {
          Navigator.of(context).pop(true);
        } else if (state.status == HabitEditStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error al guardar')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.isEditing ? 'Editar hábito' : 'Nuevo hábito'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _NameField(state: state),
              const SizedBox(height: 12),
              _DescField(state: state),
              const SizedBox(height: 24),
              Text(
                'Color',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ColorPickerRow(
                selected: state.color,
                onChanged: (c) =>
                    context.read<HabitEditBloc>().add(HabitEditColorChanged(c)),
              ),
              const SizedBox(height: 16),
              Text(
                'Icono',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: state.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(state.icon, color: state.color, size: 28),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonal(
                    onPressed: () async {
                      final picked = await showModalBottomSheet<IconData>(
                        context: context,
                        showDragHandle: true,
                        builder: (_) => IconPickerSheet(
                          selected: state.icon,
                          tint: state.color,
                        ),
                      );
                      if (picked != null && context.mounted) {
                        context.read<HabitEditBloc>().add(
                              HabitEditIconChanged(picked),
                            );
                      }
                    },
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Frecuencia',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              FrequencySelector(
                kind: state.frequencyKind,
                target: state.frequencyTarget,
                weekdayMask: state.dailyWeekdayMask,
                onKindChanged: (k) => context
                    .read<HabitEditBloc>()
                    .add(HabitEditFrequencyKindChanged(k)),
                onTargetChanged: (t) => context
                    .read<HabitEditBloc>()
                    .add(HabitEditFrequencyTargetChanged(t)),
                onWeekdayMaskChanged: (m) => context
                    .read<HabitEditBloc>()
                    .add(HabitEditWeekdayMaskChanged(m)),
              ),
              if (state.validationErrors['target'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.validationErrors['target']!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              ReminderSection(
                reminders: state.reminders,
                maxReminders: HabitEditState.maxReminders,
                onAdd: () => _openSheet(context),
                onEdit: (r) => _openSheet(context, existing: r),
                onToggle: (id, enabled) => context
                    .read<HabitEditBloc>()
                    .add(HabitEditReminderToggled(id: id, enabled: enabled)),
                onDelete: (id) => context
                    .read<HabitEditBloc>()
                    .add(HabitEditReminderRemoved(id)),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: state.isSubmitting || !state.isValid
                    ? null
                    : () => context
                        .read<HabitEditBloc>()
                        .add(const HabitEditSubmitRequested()),
                child: state.isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(state.isEditing ? 'Guardar' : 'Crear'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.state});
  final HabitEditState state;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: state.name)
        ..selection = TextSelection.collapsed(offset: state.name.length),
      onChanged: (v) =>
          context.read<HabitEditBloc>().add(HabitEditNameChanged(v)),
      decoration: InputDecoration(
        labelText: 'Nombre',
        border: const OutlineInputBorder(),
        errorText: state.validationErrors['name'],
      ),
    );
  }
}

class _DescField extends StatelessWidget {
  const _DescField({required this.state});
  final HabitEditState state;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: state.description)
        ..selection = TextSelection.collapsed(offset: state.description.length),
      onChanged: (v) =>
          context.read<HabitEditBloc>().add(HabitEditDescChanged(v)),
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Descripción (opcional)',
        border: OutlineInputBorder(),
      ),
    );
  }
}
