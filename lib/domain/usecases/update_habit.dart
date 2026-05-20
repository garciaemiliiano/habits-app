import '../entities/habit.dart';
import '../repositories/habits_repository.dart';

class UpdateHabit {
  UpdateHabit(this._habits);

  final HabitsRepository _habits;

  Future<Habit> call(Habit habit) async {
    final updated = habit.copyWith(updatedAt: DateTime.now());
    await _habits.update(updated);
    return updated;
  }
}
