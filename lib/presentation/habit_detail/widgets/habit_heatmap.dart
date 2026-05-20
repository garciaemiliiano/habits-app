import 'package:flutter/material.dart';

import '../../../core/utils/date_range.dart';
import '../../../domain/entities/heatmap_cell.dart';

/// Heatmap GitHub-style. Cada columna = semana, cada fila = día de la
/// semana (0=lun..6=dom). Tap en una celda emite el día.
class HabitHeatmap extends StatelessWidget {
  const HabitHeatmap({
    super.key,
    required this.cells,
    required this.color,
    required this.onCellTap,
  });

  final List<HeatmapCell> cells;
  final Color color;
  final ValueChanged<DateTime> onCellTap;

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) return const SizedBox.shrink();

    // Asegurar orden ascendente.
    final sorted = [...cells]..sort((a, b) => a.day.compareTo(b.day));

    // Indexar por día.
    final byDay = <int, HeatmapCell>{};
    for (final c in sorted) {
      byDay[DateRange.dayKeyOf(c.day)] = c;
    }

    final first = sorted.first.day;
    final last = sorted.last.day;

    // Alinear primer día a inicio de semana (lunes).
    final offset = first.weekday - 1; // 0..6
    final start = first.subtract(Duration(days: offset));
    final end = last.add(Duration(days: 7 - last.weekday));

    final totalDays = end.difference(start).inDays + 1;
    final weeks = (totalDays / 7).ceil();

    return LayoutBuilder(builder: (context, constraints) {
      final cellSize =
          ((constraints.maxWidth - (weeks - 1) * 3) / weeks).clamp(8.0, 18.0);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(7, (row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Row(
                children: List.generate(weeks, (col) {
                  final day = start.add(Duration(days: col * 7 + row));
                  final cell = byDay[DateRange.dayKeyOf(day)];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: GestureDetector(
                      onTap: cell == null ? null : () => onCellTap(day),
                      child: _Cell(
                        size: cellSize,
                        intensity: cell?.intensity ?? 0,
                        color: color,
                        outside: cell == null,
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      );
    });
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.size,
    required this.intensity,
    required this.color,
    required this.outside,
  });

  final double size;
  final double intensity;
  final Color color;
  final bool outside;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = outside
        ? Colors.transparent
        : cs.surfaceContainerHigh;
    final filled = color.withValues(alpha: intensity.clamp(0.0, 1.0));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: outside
            ? base
            : Color.alphaBlend(filled, base),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
