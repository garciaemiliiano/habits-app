import '../../data/datasources/notifications_datasource.dart';
import '../entities/reminder_config.dart';
import '../repositories/habits_repository.dart';
import '../repositories/reminders_repository.dart';

class ScheduleReminder {
  ScheduleReminder({
    required this.habits,
    required this.reminders,
    required this.notifications,
  });

  final HabitsRepository habits;
  final RemindersRepository reminders;
  final NotificationsDatasource notifications;

  Future<void> call(ReminderConfig config) async {
    final habit = await habits.getById(config.habitId);
    if (habit == null) return;
    await reminders.upsert(config);
    await notifications.schedule(habit: habit, reminder: config);
  }
}
