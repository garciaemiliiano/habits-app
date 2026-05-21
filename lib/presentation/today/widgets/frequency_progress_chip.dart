import 'package:flutter/material.dart';

class FrequencyProgressChip extends StatelessWidget {
  const FrequencyProgressChip({
    super.key,
    required this.completed,
    required this.target,
    required this.color,
    this.periodLabel = 'esta semana',
  });

  final int completed;
  final int target;
  final Color color;

  /// Texto que va al lado del ratio, ej. "esta semana", "este mes", "hoy".
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final met = completed >= target;
    final bg = met ? color.withValues(alpha: 0.25) : color.withValues(alpha: 0.10);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_rounded : Icons.event_repeat_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$completed/$target $periodLabel',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
