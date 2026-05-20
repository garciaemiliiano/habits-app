import 'package:flutter/widgets.dart';

import '../../data/datasources/local_db.dart';
import '../../data/datasources/notifications_datasource.dart';
import '../../data/llm/gemini_nano_provider.dart';
import '../../data/repositories/coach_repository_impl.dart';
import '../../data/repositories/completions_repository_impl.dart';
import '../../data/repositories/habit_insights_repository_impl.dart';
import '../../data/repositories/habits_repository_impl.dart';
import '../../data/repositories/reminders_repository_impl.dart';
import '../../domain/llm/llm_provider.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../domain/repositories/completions_repository.dart';
import '../../domain/repositories/habit_insights_repository.dart';
import '../../domain/repositories/habits_repository.dart';
import '../../domain/repositories/reminders_repository.dart';
import '../../domain/usecases/archive_habit.dart';
import '../../domain/usecases/build_habits_context.dart';
import '../../domain/usecases/cancel_all_reminders_for_habit.dart';
import '../../domain/usecases/cancel_reminder.dart';
import '../../domain/usecases/create_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/generate_habit_insight.dart';
import '../../domain/usecases/get_all_habits.dart';
import '../../domain/usecases/get_habit_stats.dart';
import '../../domain/usecases/get_habits_for_today.dart';
import '../../domain/usecases/get_overall_stats.dart';
import '../../domain/usecases/reorder_habits.dart';
import '../../domain/usecases/reschedule_all_reminders.dart';
import '../../domain/usecases/schedule_reminder.dart';
import '../../domain/usecases/set_completion.dart';
import '../../domain/usecases/toggle_completion.dart';
import '../../domain/usecases/update_habit.dart';
import '../preferences/app_preferences.dart';

/// DI manual liviano. Si crece, migramos a `get_it`.
class Injector {
  Injector._();

  static final Injector instance = Injector._();

  /// Permite a `main.dart` setear el navigator key antes de armar la
  /// app, así notificaciones pueden hacer deep-link a HabitDetailPage.
  final GlobalKey<NavigatorState> rootNavigator = GlobalKey<NavigatorState>();

  late final LocalDb _localDb = LocalDb();

  late final NotificationsDatasource notifications =
      NotificationsDatasource(onTap: _handleNotificationTap);

  late final AppPreferences appPreferences = AppPreferences(_localDb);

  late final HabitsRepository habitsRepository =
      HabitsRepositoryImpl(_localDb);

  late final CompletionsRepository completionsRepository =
      CompletionsRepositoryImpl(_localDb);

  late final RemindersRepository remindersRepository =
      RemindersRepositoryImpl(_localDb);

  late final CreateHabit createHabit = CreateHabit(habitsRepository);
  late final UpdateHabit updateHabit = UpdateHabit(habitsRepository);
  late final ArchiveHabit archiveHabit = ArchiveHabit(habitsRepository);
  late final ReorderHabits reorderHabits = ReorderHabits(habitsRepository);
  late final GetAllHabits getAllHabits = GetAllHabits(habitsRepository);

  late final CancelReminder cancelReminder = CancelReminder(
    reminders: remindersRepository,
    notifications: notifications,
  );

  late final CancelAllRemindersForHabit cancelAllRemindersForHabit =
      CancelAllRemindersForHabit(
    reminders: remindersRepository,
    notifications: notifications,
  );

  late final DeleteHabit deleteHabit = DeleteHabit(
    habits: habitsRepository,
    cancelAllReminders: cancelAllRemindersForHabit,
  );

  late final ScheduleReminder scheduleReminder = ScheduleReminder(
    habits: habitsRepository,
    reminders: remindersRepository,
    notifications: notifications,
  );

  late final RescheduleAllRemindersUsecase rescheduleAllRemindersUsecase =
      RescheduleAllRemindersUsecase(
    habits: habitsRepository,
    reminders: remindersRepository,
    notifications: notifications,
  );

  late final ToggleCompletion toggleCompletion =
      ToggleCompletion(completionsRepository);
  late final SetCompletion setCompletion = SetCompletion(completionsRepository);

  late final GetHabitsForToday getHabitsForToday = GetHabitsForToday(
    habits: habitsRepository,
    completions: completionsRepository,
    prefs: appPreferences,
  );

  late final GetHabitStats getHabitStats = GetHabitStats(
    habits: habitsRepository,
    completions: completionsRepository,
    prefs: appPreferences,
  );

  late final GetOverallStats getOverallStats = GetOverallStats(
    habits: habitsRepository,
    getHabitStats: getHabitStats,
  );

  // ── IA on-device ────────────────────────────────────────────────────
  late final LlmProvider llmProvider = GeminiNanoProvider();

  late final CoachRepository coachRepository = CoachRepositoryImpl(
    resolveActive: () => llmProvider,
  );

  late final HabitInsightsRepository habitInsightsRepository =
      HabitInsightsRepositoryImpl(_localDb);

  late final BuildHabitsContext buildHabitsContext = BuildHabitsContext(
    getAllHabits: getAllHabits,
    getOverallStats: getOverallStats,
    prefs: appPreferences,
  );

  late final GenerateHabitInsight generateHabitInsight = GenerateHabitInsight(
    coach: coachRepository,
    insights: habitInsightsRepository,
    getHabitStats: getHabitStats,
    habits: habitsRepository,
  );

  /// Wrapper para `main.dart`.
  Future<void> rescheduleAllReminders() async {
    await rescheduleAllRemindersUsecase.call();
  }

  void _handleNotificationTap(String habitId) {
    // En fase 4 esto navega a HabitDetailPage. Por ahora deep-link no
    // crítico — se queda como hook noop hasta wirearlo en `app.dart`.
  }
}

/// Renombramos la clase del usecase para evitar colisión con el método
/// `rescheduleAllReminders` del Injector.
typedef RescheduleAllRemindersUsecase = RescheduleAllReminders;
