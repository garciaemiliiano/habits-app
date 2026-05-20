import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/habit.dart';
import '../../domain/entities/reminder_config.dart';

/// Wrap de `flutter_local_notifications` para reminders de hábitos.
/// Una notificación por (hábito, día de la semana habilitado).
class NotificationsDatasource {
  NotificationsDatasource({void Function(String habitId)? onTap})
      : _onTap = onTap;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final void Function(String habitId)? _onTap;

  static const _channelId = 'habits_reminders';
  static const _channelName = 'Recordatorios';
  static const _channelDescription =
      'Notificaciones para chequear hábitos del día';

  Future<void> init() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        final payload = resp.payload;
        if (payload != null && _onTap != null) {
          _onTap(payload);
        }
      },
    );

    // Crear el canal de notificaciones explícitamente para Android 8+.
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    final granted = await androidPlugin.requestNotificationsPermission();
    final exact = await androidPlugin.requestExactAlarmsPermission();
    return (granted ?? false) && (exact ?? false);
  }

  /// Cancela todas las notificaciones derivadas de un reminder y reagenda
  /// según `weekdayMask`. Si el reminder no está enabled, solo cancela.
  Future<void> schedule({
    required Habit habit,
    required ReminderConfig reminder,
  }) async {
    // Cancelar primero los 7 ids derivados (uno por weekday).
    for (var i = 0; i < 7; i++) {
      await _plugin.cancel(reminder.notificationId + i);
    }
    if (!reminder.enabled || reminder.weekdayMask == 0) return;

    for (var weekday = 1; weekday <= 7; weekday++) {
      final bit = 1 << (weekday - 1);
      if ((reminder.weekdayMask & bit) == 0) continue;

      final scheduledDate = _nextInstanceOf(
        weekday: weekday,
        hour: reminder.time.hour,
        minute: reminder.time.minute,
      );

      await _plugin.zonedSchedule(
        reminder.notificationId + (weekday - 1),
        habit.name,
        habit.description?.isNotEmpty == true
            ? habit.description!
            : '¿Lo hiciste hoy?',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            color: habit.color,
            colorized: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: habit.id,
      );
    }
  }

  /// Cancela las 7 notificaciones derivadas de un reminder (una por
  /// weekday). El `notificationId` es el id base — se cancela `id+0..6`.
  Future<void> cancelReminderNotifications(int notificationId) async {
    for (var i = 0; i < 7; i++) {
      await _plugin.cancel(notificationId + i);
    }
  }

  tz.TZDateTime _nextInstanceOf({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// Id estable derivado del id del reminder. Reservamos 7 ids
/// consecutivos (uno por weekday) — multiplicamos por 10 para que dos
/// reminders distintos no choquen.
int notificationIdForReminder(String reminderId) {
  final hash = reminderId.codeUnits.fold<int>(0, (acc, c) => acc * 31 + c);
  return (hash.abs() % (1 << 24)) * 10;
}
