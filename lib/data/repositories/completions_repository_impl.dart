import 'package:sqflite/sqflite.dart';

import '../../core/utils/date_range.dart';
import '../../domain/entities/completion.dart';
import '../../domain/repositories/completions_repository.dart';
import '../datasources/local_db.dart';
import '../models/completion_dto.dart';

class CompletionsRepositoryImpl implements CompletionsRepository {
  CompletionsRepositoryImpl(this._db);

  final LocalDb _db;

  @override
  Future<bool> isCompleted({
    required String habitId,
    required DateTime day,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      'completions',
      where: 'habit_id = ? AND day_key = ?',
      whereArgs: [habitId, DateRange.dayKeyOf(day)],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<int> countInRange({
    required String habitId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await _db.database;
    final fromKey = DateRange.dayKeyOf(from);
    // `to` es exclusivo: pasamos to-1 día como inclusive.
    final toExclusive = to.subtract(const Duration(days: 1));
    final toKey = DateRange.dayKeyOf(toExclusive);
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM completions '
      'WHERE habit_id = ? AND day_key BETWEEN ? AND ?;',
      [habitId, fromKey, toKey],
    );
    return (rows.first['n'] as num).toInt();
  }

  @override
  Future<List<Completion>> listInRange({
    required String habitId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await _db.database;
    final fromKey = DateRange.dayKeyOf(from);
    final toExclusive = to.subtract(const Duration(days: 1));
    final toKey = DateRange.dayKeyOf(toExclusive);
    final rows = await db.query(
      'completions',
      where: 'habit_id = ? AND day_key BETWEEN ? AND ?',
      whereArgs: [habitId, fromKey, toKey],
      orderBy: 'day_ms ASC',
    );
    return rows.map((r) => CompletionDto.fromMap(r).toEntity()).toList();
  }

  @override
  Future<List<Completion>> listAll(String habitId) async {
    final db = await _db.database;
    final rows = await db.query(
      'completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'day_ms ASC',
    );
    return rows.map((r) => CompletionDto.fromMap(r).toEntity()).toList();
  }

  @override
  Future<void> add({required String habitId, required DateTime day}) async {
    final db = await _db.database;
    final dto = CompletionDto.create(
      habitId: habitId,
      day: day,
      now: DateTime.now(),
    );
    // INSERT OR IGNORE para no romper el unique (habit_id, day_key).
    await db.insert(
      'completions',
      dto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<void> remove({
    required String habitId,
    required DateTime day,
  }) async {
    final db = await _db.database;
    await db.delete(
      'completions',
      where: 'habit_id = ? AND day_key = ?',
      whereArgs: [habitId, DateRange.dayKeyOf(day)],
    );
  }
}

