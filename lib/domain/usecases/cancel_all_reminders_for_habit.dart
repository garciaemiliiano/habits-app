import '../../data/datasources/notifications_datasource.dart';
import '../repositories/reminders_repository.dart';

class CancelAllRemindersForHabit {
  CancelAllRemindersForHabit({
    required this.reminders,
    required this.notifications,
  });

  final RemindersRepository reminders;
  final NotificationsDatasource notifications;

  /// Cancela todas las notificaciones agendadas para el hábito y borra
  /// sus rows en `habit_reminders`. Pensado para `DeleteHabit`.
  Future<void> call(String habitId) async {
    final all = await reminders.getForHabit(habitId);
    for (final r in all) {
      await notifications.cancelReminderNotifications(r.notificationId);
    }
    await reminders.deleteAllForHabit(habitId);
  }
}
