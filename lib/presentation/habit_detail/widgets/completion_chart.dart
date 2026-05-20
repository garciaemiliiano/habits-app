import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/date_range.dart';
import '../../../core/utils/week_helper.dart';
import '../../../domain/entities/heatmap_cell.dart';

/// % cumplimiento por semana (últimas N semanas), basado en las celdas
/// del heatmap (con `completed = true` cuenta como 1).
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

    final bars = <BarChartGroupData>[];
    for (var i = 0; i < weeks; i++) {
      final wEnd = endNext.subtract(Duration(days: 7 * i));
      final wStart = wEnd.subtract(const Duration(days: 7));
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
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
    }

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: 7,
          barGroups: bars.reversed.toList(),
          titlesData: const FlTitlesData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
