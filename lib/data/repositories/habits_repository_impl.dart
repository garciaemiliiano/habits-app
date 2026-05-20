import 'dart:math' as math;

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habits_repository.dart';
import '../datasources/local_db.dart';
import '../models/habit_dto.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  HabitsRepositoryImpl(this._db);

  final LocalDb _db;
  final _rand = math.Random();

  @override
  Future<List<Habit>> getAll({bool includeArchived = false}) async {
    final db = await _db.database;
    final rows = includeArchived
        ? await db.query('habits', orderBy: 'archived ASC, position ASC')
        : await db.query(
            'habits',
            where: 'archived = 0',
            orderBy: 'position ASC',
          );
    return rows.map((r) => HabitDto.fromMap(r).toEntity()).toList();
  }

  @override
  Future<Habit?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return HabitDto.fromMap(rows.first).toEntity();
  }

  @override
  Future<Habit> insert(Habit habit) async {
    final db = await _db.database;
    final withId = habit.id.isEmpty
        ? habit.copyWith(updatedAt: habit.updatedAt) // placeholder
        : habit;
    final id = habit.id.isEmpty ? _generateId() : habit.id;
    final position = habit.position < 0 ? await nextPosition() : habit.position;
    final toPersist = Habit(
      id: id,
      name: withId.name,
      description: withId.description,
      color: withId.color,
      icon: withId.icon,
      frequency: withId.frequency,
      position: position,
      archived: withId.archived,
      createdAt: withId.createdAt,
      updatedAt: withId.updatedAt,
    );
    await db.insert('habits', HabitDto.fromEntity(toPersist).toMap());
    return toPersist;
  }

  @override
  Future<void> update(Habit habit) async {
    final db = await _db.database;
    await db.update(
      'habits',
      HabitDto.fromEntity(habit).toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    final db = await _db.database;
    final batch = db.batch();
    for (var i = 0; i < orderedIds.length; i++) {
      batch.update(
        'habits',
        {'position': i, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [orderedIds[i]],
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> nextPosition() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(MAX(position), -1) AS max_pos FROM habits;',
    );
    final maxPos = (rows.first['max_pos'] as num?)?.toInt() ?? -1;
    return maxPos + 1;
  }

  String _generateId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    final rand = _rand.nextInt(1 << 16).toRadixString(16).padLeft(4, '0');
    return 'h_${ms}_$rand';
  }
}
