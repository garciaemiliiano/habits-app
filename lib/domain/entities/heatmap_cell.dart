import 'package:equatable/equatable.dart';

class HeatmapCell extends Equatable {
  const HeatmapCell({
    required this.day,
    required this.intensity,
    required this.completed,
  });

  /// Medianoche local del día.
  final DateTime day;

  /// 0..1. Para hábitos diarios siempre 0 o 1; para flexibles puede ser
  /// fracción del progreso del período al que pertenece este día.
  final double intensity;

  /// Si hubo completion concreta ese día.
  final bool completed;

  @override
  List<Object?> get props => [day, intensity, completed];
}
