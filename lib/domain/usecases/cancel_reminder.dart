import '../../data/datasources/notifications_datasource.dart';
import '../repositories/reminders_repository.dart';

class CancelReminder {
  CancelReminder({required this.reminders, required this.notifications});

  final RemindersRepository reminders;
  final NotificationsDatasource notifications;

  /// Cancela las notificaciones de un reminder y lo borra de la DB.
  Future<void> call(String reminderId) async {
    final config = await reminders.getById(reminderId);
    if (config != null) {
      await notifications.cancelReminderNotifications(config.notificationId);
    }
    await reminders.deleteById(reminderId);
  }
}
