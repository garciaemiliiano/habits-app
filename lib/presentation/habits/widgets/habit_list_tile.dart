import 'package:flutter/material.dart';

import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_frequency.dart';
import '../../shared/widgets/habit_icon_badge.dart';

class HabitListTile extends StatelessWidget {
  const HabitListTile({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onArchiveToggle,
    required this.onDelete,
  });

  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final freqLabel = _formatFrequency(habit.frequency);
    return ListTile(
      onTap: onTap,
      leading: HabitIconBadge(
        color: habit.color,
        icon: habit.icon,
        filled: true,
      ),
      title: Text(habit.name),
      subtitle: Text(freqLabel),
      trailing: PopupMenuButton<_Action>(
        onSelected: (a) {
          switch (a) {
            case _Action.archive:
              onArchiveToggle();
            case _Action.delete:
              onDelete();
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _Action.archive,
            child: Text(habit.archived ? 'Desarchivar' : 'Archivar'),
          ),
          const PopupMenuItem(
            value: _Action.delete,
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatFrequency(HabitFrequency f) {
    return switch (f) {
      DailyFrequency(:final weekdayMask) when weekdayMask == 0 => 'Diario',
      DailyFrequency() => 'Días específicos',
      TimesPerWeekFrequency(:final target) => '$target veces por semana',
      TimesPerMonthFrequency(:final target) => '$target veces por mes',
    };
  }
}

enum _Action { archive, delete }
