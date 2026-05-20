import '../../core/utils/date_range.dart';
import '../repositories/completions_repository.dart';

class SetCompletion {
  SetCompletion(this._completions);

  final CompletionsRepository _completions;

  Future<void> call({
    required String habitId,
    required DateTime day,
    required bool completed,
  }) async {
    final d = DateRange.dayOf(day);
    if (completed) {
      await _completions.add(habitId: habitId, day: d);
    } else {
      await _completions.remove(habitId: habitId, day: d);
    }
  }
}
