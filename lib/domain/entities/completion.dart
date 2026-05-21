import 'package:equatable/equatable.dart';

class Completion extends Equatable {
  const Completion({
    required this.id,
    required this.habitId,
    required this.day,
    required this.completedAt,
    this.reminderId,
  });

  final String id;
  final String habitId;

  /// Medianoche local del día completado.
  final DateTime day;

  /// Momento real del tap (puede ser distinto al día si se marca retroactivo).
  final DateTime completedAt;

  /// Reminder que disparó este completion. `null` si fue tap manual.
  final String? reminderId;

  @override
  List<Object?> get props => [id, habitId, day, completedAt, reminderId];
}
