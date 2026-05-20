import '../../core/utils/date_range.dart';
import '../repositories/completions_repository.dart';

class ToggleCompletion {
  ToggleCompletion(this._completions);

  final CompletionsRepository _completions;

  /// Devuelve el nuevo estado: true = quedó completado, false = quedó libre.
  Future<bool> call({required String habitId, required DateTime day}) async {
    final d = DateRange.dayOf(day);
    final exists = await _completions.isCompleted(habitId: habitId, day: d);
    if (exists) {
      await _completions.remove(habitId: habitId, day: d);
      return false;
    }
    await _completions.add(habitId: habitId, day: d);
    return true;
  }
}
