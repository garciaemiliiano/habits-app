import 'package:equatable/equatable.dart';

import 'heatmap_cell.dart';

class HabitStats extends Equatable {
  const HabitStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.score,
    required this.last4WeeksRate,
    required this.heatmap,
  });

  final int currentStreak;
  final int bestStreak;

  /// 0..1, score con decay tipo Loop Habits (EMA).
  final double score;

  /// 0..1, % cumplimiento últimas 4 semanas.
  final double last4WeeksRate;

  final List<HeatmapCell> heatmap;

  @override
  List<Object?> get props =>
      [currentStreak, bestStreak, score, last4WeeksRate, heatmap];
}
