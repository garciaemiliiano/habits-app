import '../entities/completion.dart';

abstract class CompletionsRepository {
  /// True si la combinación habitId+day ya está marcada.
  Future<bool> isCompleted({required String habitId, required DateTime day});

  /// Cantidad de completions en un rango [from, to) (medianoche local).
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

  /// Marca el día como completado si no estaba.
  Future<void> add({required String habitId, required DateTime day});

  /// Desmarca el día si estaba completado.
  Future<void> remove({required String habitId, required DateTime day});
}
