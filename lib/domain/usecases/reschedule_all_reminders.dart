import '../../data/datasources/notifications_datasource.dart';
import '../repositories/habits_repository.dart';
import '../repositories/reminders_repository.dart';

class RescheduleAllReminders {
  RescheduleAllReminders({
    required this.habits,
    required this.reminders,
    required this.notifications,
  });

  final HabitsRepository habits;
  final RemindersRepository reminders;
  final NotificationsDatasource notifications;

  Future<void> call() async {
    final all = await reminders.getAllEnabled();
    for (final config in all) {
      final habit = await habits.getById(config.habitId);
      if (habit == null) continue;
      await notifications.schedule(habit: habit, reminder: config);
    }
  }
}
