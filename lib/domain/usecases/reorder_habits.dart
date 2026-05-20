import '../repositories/habits_repository.dart';

class ReorderHabits {
  ReorderHabits(this._habits);

  final HabitsRepository _habits;

  Future<void> call(List<String> orderedIds) => _habits.reorder(orderedIds);
}
