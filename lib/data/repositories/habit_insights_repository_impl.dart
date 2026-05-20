import 'package:sqflite/sqflite.dart';

import '../../domain/entities/habit_insight.dart';
import '../../domain/repositories/habit_insights_repository.dart';
import '../datasources/local_db.dart';

class HabitInsightsRepositoryImpl implements HabitInsightsRepository {
  HabitInsightsRepositoryImpl(this._db);

  final LocalDb _db;

  @override
  Future<HabitInsight?> getLast(String habitId) async {
    final db = await _db.database;
    final rows = await db.query(
      'habit_insights',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return HabitInsight(
      habitId: row['habit_id']! as String,
      text: row['text']! as String,
      generatedAt: DateTime.fromMillisecondsSinceEpoch(
        (row['generated_at']! as num).toInt(),
      ),
    );
  }

  @override
  Future<void> save(HabitInsight insight) async {
    final db = await _db.database;
    await db.insert(
      'habit_insights',
      {
        'habit_id': insight.habitId,
        'text': insight.text,
        'generated_at': insight.generatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String habitId) async {
    final db = await _db.database;
    await db.delete(
      'habit_insights',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
  }
}
