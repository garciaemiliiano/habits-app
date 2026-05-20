import '../entities/habit.dart';

abstract class HabitsRepository {
  Future<List<Habit>> getAll({bool includeArchived = false});
  Future<Habit?> getById(String id);
  Future<Habit> insert(Habit habit);
  Future<void> update(Habit habit);
  Future<void> reorder(List<String> orderedIds);
  Future<void> delete(String id);
  Future<int> nextPosition();
}
