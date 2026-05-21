import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/date_range.dart';
import '../../../core/utils/week_helper.dart';
import '../../../domain/entities/heatmap_cell.dart';

/// Días cumplidos por semana (últimas N semanas). Cada barra cuenta los
/// días dentro de esa semana en que hubo al menos una completion (cap 7).
class CompletionChart extends StatelessWidget {
  const CompletionChart({
    super.key,
    required this.cells,
    required this.color,
    required this.weekStartsOn,
    this.weeks = 8,
  });

  final List<HeatmapCell> cells;
  final Color color;
  final int weekStartsOn;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final wh = WeekHelper(weekStartsOn);
    final now = DateRange.dayOf(DateTime.now());
    final endNext = wh.startOfNextWeek(now);
    final completedKeys = cells
        .where((c) => c.completed)
        .map((c) => DateRange.dayKeyOf(c.day))
        .toSet();

    final cs = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
        );
    final weekFmt = DateFormat('d/M', 'es_AR');

    final weekStarts = <DateTime>[];
    final bars = <BarChartGroupData>[];
    for (var i = 0; i < weeks; i++) {
      final wEnd = endNext.subtract(Duration(days: 7 * i));
      final wStart = wEnd.subtract(const Duration(days: 7));
      weekStarts.add(wStart);
      var count = 0;
      var d = wStart;
      while (d.isBefore(wEnd)) {
        if (completedKeys.contains(DateRange.dayKeyOf(d))) count++;
        d = d.add(const Duration(days: 1));
      }
      bars.add(BarChartGroupData(
        x: weeks - i - 1,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: color,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
    }
    // Las semanas estaban más viejas → más nuevas con i=0 = actual.
    // weekStarts[0] = semana actual. Para mapear bar.x → label, invertimos.
    final orderedStarts = weekStarts.reversed.toList();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: 7,
          minY: 0,
          barGroups: bars.reversed.toList(),
          titlesData: FlTitlesData(
            show: true,
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final v = value.toInt();
                  if (v < 0 || v > 7) return const SizedBox.shrink();
                  if (v != 0 && v != 7) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text('$v', style: labelStyle),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= orderedStarts.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(weekFmt.format(orderedStarts[i]),
                        style: labelStyle),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (v) => FlLine(
              color: cs.outlineVariant.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              getTooltipColor: (_) => cs.inverseSurface,
              getTooltipItem: (group, _, rod, __) {
                final i = group.x;
                final start =
                    i >= 0 && i < orderedStarts.length ? orderedStarts[i] : null;
                final days = rod.toY.toInt();
                final lbl = start == null
                    ? '$days días'
                    : 'Semana del ${weekFmt.format(start)}: $days días';
                return BarTooltipItem(
                  lbl,
                  TextStyle(
                    color: cs.onInverseSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
