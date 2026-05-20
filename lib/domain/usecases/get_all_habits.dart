import '../entities/habit.dart';
import '../repositories/habits_repository.dart';

class GetAllHabits {
  GetAllHabits(this._habits);

  final HabitsRepository _habits;

  Future<List<Habit>> call({bool includeArchived = false}) =>
      _habits.getAll(includeArchived: includeArchived);
}
