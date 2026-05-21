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
    return (await countOn(habitId: habitId, day: day)) > 0;
  }

  @override
  Future<int> countOn({
    required String habitId,
    required DateTime day,
  }) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM completions '
      'WHERE habit_id = ? AND day_key = ?;',
      [habitId, DateRange.dayKeyOf(day)],
    );
    return (rows.first['n'] as num).toInt();
  }

  @override
  Future<int> countInRange({
    required String habitId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await _db.database;
    final fromKey = DateRange.dayKeyOf(from);
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
      orderBy: 'completed_at ASC',
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
      orderBy: 'completed_at ASC',
    );
    return rows.map((r) => CompletionDto.fromMap(r).toEntity()).toList();
  }

  @override
  Future<void> add({
    required String habitId,
    required DateTime day,
    String? reminderId,
  }) async {
    final db = await _db.database;
    final dto = CompletionDto.create(
      habitId: habitId,
      day: day,
      now: DateTime.now(),
      reminderId: reminderId,
    );
    await db.insert('completions', dto.toMap());
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

  @override
  Future<void> removeLastOn({
    required String habitId,
    required DateTime day,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      'completions',
      columns: ['id'],
      where: 'habit_id = ? AND day_key = ?',
      whereArgs: [habitId, DateRange.dayKeyOf(day)],
      orderBy: 'completed_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return;
    await db.delete(
      'completions',
      where: 'id = ?',
      whereArgs: [rows.first['id']],
    );
  }
}

