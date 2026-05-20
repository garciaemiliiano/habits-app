import '../repositories/habits_repository.dart';

class ArchiveHabit {
  ArchiveHabit(this._habits);

  final HabitsRepository _habits;

  Future<void> call({required String habitId, required bool archived}) async {
    final habit = await _habits.getById(habitId);
    if (habit == null) return;
    await _habits.update(
      habit.copyWith(archived: archived, updatedAt: DateTime.now()),
    );
  }
}
