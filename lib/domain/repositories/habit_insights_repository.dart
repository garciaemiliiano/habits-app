import '../entities/habit_insight.dart';

abstract class HabitInsightsRepository {
  Future<HabitInsight?> getLast(String habitId);
  Future<void> save(HabitInsight insight);
  Future<void> delete(String habitId);
}
