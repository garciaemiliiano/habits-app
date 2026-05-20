import 'package:flutter/material.dart';

/// Bottom sheet para crear o editar un reminder (TimePicker + chips de
/// días). Devuelve `(TimeOfDay, int weekdayMask)` por `Navigator.pop`
/// o `null` si se cancela.
class ReminderEditSheet extends StatefulWidget {
  const ReminderEditSheet({
    super.key,
    this.initialTime,
    this.initialMask = 127,
  });

  final TimeOfDay? initialTime;
  final int initialMask;

  @override
  State<ReminderEditSheet> createState() => _ReminderEditSheetState();
}

class _ReminderEditSheetState extends State<ReminderEditSheet> {
  late TimeOfDay _time = widget.initialTime ?? const TimeOfDay(hour: 9, minute: 0);
  late int _mask = widget.initialMask;

  static const _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final tf = _time.format(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialTime == null ? 'Nuevo horario' : 'Editar horario',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) setState(() => _time = picked);
              },
              icon: const Icon(Icons.access_time),
              label: Text('Hora: $tf'),
            ),
            const SizedBox(height: 20),
            Text(
              'Días',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final bit = 1 << i;
                final selected = (_mask & bit) != 0;
                return FilterChip(
                  label: Text(_labels[i]),
                  selected: selected,
                  onSelected: (v) {
                    final updated = v ? _mask | bit : _mask & ~bit;
                    // No permitir dejar mask en 0 (al menos 1 día).
                    if (updated != 0) setState(() => _mask = updated);
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    ReminderSheetResult(time: _time, weekdayMask: _mask),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReminderSheetResult {
  const ReminderSheetResult({required this.time, required this.weekdayMask});
  final TimeOfDay time;
  final int weekdayMask;
}
