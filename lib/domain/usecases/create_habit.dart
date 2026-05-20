import 'package:flutter/material.dart';

import '../entities/habit.dart';
import '../entities/habit_frequency.dart';
import '../entities/reminder_config.dart';
import '../repositories/habits_repository.dart';

class CreateHabit {
  CreateHabit(this._habits);

  final HabitsRepository _habits;

  Future<Habit> call({
    required String name,
    String? description,
    required Color color,
    required IconData icon,
    required HabitFrequency frequency,
    ReminderConfig? reminder,
  }) async {
    final now = DateTime.now();
    final habit = Habit(
      id: '',
      name: name.trim(),
      description: description?.trim().isEmpty == true ? null : description?.trim(),
      color: color,
      icon: icon,
      frequency: frequency,
      position: -1,
      archived: false,
      createdAt: now,
      updatedAt: now,
    );
    return _habits.insert(habit);
  }
}
