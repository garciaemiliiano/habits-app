import '../../core/utils/date_range.dart';
import '../repositories/completions_repository.dart';

/// Comportamiento del tap en la tile de un hábito:
/// - Si todavía no llegó al `target`, suma 1 completion.
/// - Si ya lo alcanzó, resetea (borra todas las de ese día).
///
/// Cuando `target` es 1 (caso clásico binario), se comporta como un toggle.
/// Cuando es > 1 (hábito con varios reminders), el tap avanza 1 por 1
/// hasta el target y al pasarlo vuelve a 0.
class ToggleCompletion {
  ToggleCompletion(this._completions);

  final CompletionsRepository _completions;

  /// Devuelve el nuevo conteo del día tras el tap.
  Future<int> call({
    required String habitId,
    required DateTime day,
    int target = 1,
  }) async {
    final d = DateRange.dayOf(day);
    final current = await _completions.countOn(habitId: habitId, day: d);
    if (current >= target) {
      await _completions.remove(habitId: habitId, day: d);
      return 0;
    }
    await _completions.add(habitId: habitId, day: d);
    return current + 1;
  }
}
