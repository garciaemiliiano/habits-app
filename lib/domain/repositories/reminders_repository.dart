import '../entities/reminder_config.dart';

abstract class RemindersRepository {
  Future<List<ReminderConfig>> getForHabit(String habitId);
  Future<List<ReminderConfig>> getAllEnabled();
  Future<ReminderConfig?> getById(String id);
  Future<void> upsert(ReminderConfig config);
  Future<void> deleteById(String id);
  Future<void> deleteAllForHabit(String habitId);
}
