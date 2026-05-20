import 'package:flutter/material.dart';

import '../../../domain/entities/habit_frequency.dart';

class FrequencySelector extends StatelessWidget {
  const FrequencySelector({
    super.key,
    required this.kind,
    required this.target,
    required this.weekdayMask,
    required this.onKindChanged,
    required this.onTargetChanged,
    required this.onWeekdayMaskChanged,
  });

  final FrequencyKind kind;
  final int target;
  final int weekdayMask;
  final ValueChanged<FrequencyKind> onKindChanged;
  final ValueChanged<int> onTargetChanged;
  final ValueChanged<int> onWeekdayMaskChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<FrequencyKind>(
          segments: const [
            ButtonSegment(
              value: FrequencyKind.daily,
              label: Text('Diario'),
              icon: Icon(Icons.today_outlined),
            ),
            ButtonSegment(
              value: FrequencyKind.weekly,
              label: Text('Semana'),
              icon: Icon(Icons.view_week_outlined),
            ),
            ButtonSegment(
              value: FrequencyKind.monthly,
              label: Text('Mes'),
              icon: Icon(Icons.calendar_month_outlined),
            ),
          ],
          selected: {kind},
          onSelectionChanged: (s) => onKindChanged(s.first),
        ),
        const SizedBox(height: 16),
        switch (kind) {
          FrequencyKind.daily => _WeekdayMaskRow(
              mask: weekdayMask,
              onChanged: onWeekdayMaskChanged,
            ),
          FrequencyKind.weekly => _TargetStepper(
              label: 'Veces por semana',
              value: target,
              min: 1,
              max: 7,
              onChanged: onTargetChanged,
            ),
          FrequencyKind.monthly => _TargetStepper(
              label: 'Veces por mes',
              value: target,
              min: 1,
              max: 31,
              onChanged: onTargetChanged,
            ),
        },
      ],
    );
  }
}

class _WeekdayMaskRow extends StatelessWidget {
  const _WeekdayMaskRow({required this.mask, required this.onChanged});

  final int mask;
  final ValueChanged<int> onChanged;

  static const _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final allDays = mask == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Todos los días'),
          value: allDays,
          onChanged: (v) => onChanged(v ? 0 : 0x7F),
        ),
        if (!allDays)
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final bit = 1 << i;
              final selected = (mask & bit) != 0;
              return FilterChip(
                label: Text(_labels[i]),
                selected: selected,
                onSelected: (v) {
                  final updated = v ? mask | bit : mask & ~bit;
                  onChanged(updated == 0 ? 0x7F : updated);
                },
              );
            }),
          ),
      ],
    );
  }
}

class _TargetStepper extends StatelessWidget {
  const _TargetStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton.filledTonal(
          onPressed:
              value > min ? () => onChanged((value - 1).clamp(min, max)) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed:
              value < max ? () => onChanged((value + 1).clamp(min, max)) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
