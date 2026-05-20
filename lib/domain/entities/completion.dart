import 'package:equatable/equatable.dart';

class Completion extends Equatable {
  const Completion({
    required this.id,
    required this.habitId,
    required this.day,
    required this.completedAt,
  });

  final String id;
  final String habitId;

  /// Medianoche local del día completado.
  final DateTime day;

  /// Momento real del tap (puede ser distinto al día si se marca retroactivo).
  final DateTime completedAt;

  @override
  List<Object?> get props => [id, habitId, day, completedAt];
}
