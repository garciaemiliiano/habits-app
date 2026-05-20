import '../repositories/habits_repository.dart';
import 'cancel_all_reminders_for_habit.dart';

class DeleteHabit {
  DeleteHabit({
    required this.habits,
    required this.cancelAllReminders,
  });

  final HabitsRepository habits;
  final CancelAllRemindersForHabit cancelAllReminders;

  Future<void> call(String habitId) async {
    // Cancelamos notificaciones explícitamente antes del CASCADE
    // (la DB borra las rows pero las notifs agendadas siguen vivas).
    await cancelAllReminders(habitId);
    await habits.delete(habitId);
  }
}
