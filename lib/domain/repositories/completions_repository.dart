import '../entities/completion.dart';

abstract class CompletionsRepository {
  /// True si hay al menos una completion ese día.
  Future<bool> isCompleted({required String habitId, required DateTime day});

  /// Cuántas completions tiene un hábito en un día puntual.
  Future<int> countOn({required String habitId, required DateTime day});

  /// Cantidad de completions en un rango [from, to) (medianoche local).
  /// Cuenta TODAS las repeticiones, no solo días distintos.
  Future<int> countInRange({
    required String habitId,
    required DateTime from,
    required DateTime to,
  });

  /// Devuelve completions de un hábito en un rango, ordenadas por día asc.
  Future<List<Completion>> listInRange({
    required String habitId,
    required DateTime from,
    required DateTime to,
  });

  /// Todas las completions de un hábito (limit razonable para stats).
  Future<List<Completion>> listAll(String habitId);

  /// Agrega una completion (sin deduplicar por día — permite N por día).
  /// `reminderId` opcional para trackear qué notificación la disparó.
  Future<void> add({
    required String habitId,
    required DateTime day,
    String? reminderId,
  });

  /// Borra TODAS las completions de ese día (reset).
  Future<void> remove({required String habitId, required DateTime day});

  /// Borra la última completion (más reciente) de ese día. No-op si no hay.
  Future<void> removeLastOn({
    required String habitId,
    required DateTime day,
  });
}
