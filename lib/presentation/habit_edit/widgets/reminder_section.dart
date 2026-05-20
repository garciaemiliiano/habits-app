import 'package:flutter/material.dart';

import '../../../domain/entities/reminder_config.dart';

class ReminderSection extends StatelessWidget {
  const ReminderSection({
    super.key,
    required this.reminders,
    required this.maxReminders,
    required this.onAdd,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final List<ReminderConfig> reminders;
  final int maxReminders;
  final VoidCallback onAdd;
  final ValueChanged<ReminderConfig> onEdit;
  final void Function(String id, bool enabled) onToggle;
  final ValueChanged<String> onDelete;

  static const _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final canAdd = reminders.length < maxReminders;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recordatorios',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(
              '${reminders.length}/$maxReminders',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (reminders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Sin recordatorios. Tocá + para agregar uno.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          )
        else
          Column(
            children: reminders
                .map((r) => _ReminderTile(
                      reminder: r,
                      labels: _labels,
                      onTap: () => onEdit(r),
                      onToggle: (v) => onToggle(r.id, v),
                      onDelete: () => onDelete(r.id),
                    ))
                .toList(),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            message: canAdd ? '' : 'Máximo $maxReminders horarios',
            child: FilledButton.tonalIcon(
              onPressed: canAdd ? onAdd : null,
              icon: const Icon(Icons.add),
              label: const Text('Agregar horario'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.labels,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final ReminderConfig reminder;
  final List<String> labels;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timeFmt = reminder.time.format(context);
    final daysLabel = _formatMask(reminder.weekdayMask);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    timeFmt,
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    daysLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: reminder.enabled
                              ? cs.onSurface
                              : cs.onSurfaceVariant,
                        ),
                  ),
                ),
                Switch.adaptive(
                  value: reminder.enabled,
                  onChanged: onToggle,
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: onDelete,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatMask(int mask) {
    if (mask == 127) return 'Todos los días';
    final days = <String>[];
    for (var i = 0; i < 7; i++) {
      if ((mask & (1 << i)) != 0) days.add(labels[i]);
    }
    return days.join(' · ');
  }
}
