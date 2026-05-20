import 'package:sqflite/sqflite.dart';

import '../../domain/entities/reminder_config.dart';
import '../../domain/repositories/reminders_repository.dart';
import '../datasources/local_db.dart';
import '../models/reminder_config_dto.dart';

class RemindersRepositoryImpl implements RemindersRepository {
  RemindersRepositoryImpl(this._db);

  final LocalDb _db;

  @override
  Future<List<ReminderConfig>> getForHabit(String habitId) async {
    final db = await _db.database;
    final rows = await db.query(
      'habit_reminders',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'position ASC',
    );
    return rows
        .map((r) => ReminderConfigDto.fromMap(r).toEntity())
        .toList(growable: false);
  }

  @override
  Future<List<ReminderConfig>> getAllEnabled() async {
    final db = await _db.database;
    final rows = await db.query('habit_reminders', where: 'enabled = 1');
    return rows
        .map((r) => ReminderConfigDto.fromMap(r).toEntity())
        .toList(growable: false);
  }

  @override
  Future<ReminderConfig?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      'habit_reminders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ReminderConfigDto.fromMap(rows.first).toEntity();
  }

  @override
  Future<void> upsert(ReminderConfig config) async {
    final db = await _db.database;
    await db.insert(
      'habit_reminders',
      ReminderConfigDto.fromEntity(config).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteById(String id) async {
    final db = await _db.database;
    await db.delete('habit_reminders', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAllForHabit(String habitId) async {
    final db = await _db.database;
    await db.delete(
      'habit_reminders',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
  }
}
