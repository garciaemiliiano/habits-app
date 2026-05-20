import 'dart:math' as math;

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// SQLite local.
/// - v1: habits, completions, reminders, settings.
/// - v2: agrega habit_insights (cache de análisis IA por hábito).
/// - v3: reemplaza `reminders` (1 por hábito) por `habit_reminders` (N).
class LocalDb {
  static const _dbName = 'habits_app.db';
  static const _dbVersion = 3;

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            color_hex TEXT NOT NULL,
            icon_code INTEGER NOT NULL,
            frequency_kind TEXT NOT NULL,
            frequency_target INTEGER NOT NULL,
            daily_weekday_mask INTEGER NOT NULL DEFAULT 0,
            position INTEGER NOT NULL,
            archived INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          );
        ''');
        await db.execute(
          'CREATE INDEX idx_habits_archived_position ON habits(archived, position);',
        );

        await db.execute('''
          CREATE TABLE completions (
            id TEXT PRIMARY KEY,
            habit_id TEXT NOT NULL,
            day_key INTEGER NOT NULL,
            day_ms INTEGER NOT NULL,
            completed_at INTEGER NOT NULL,
            FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
          );
        ''');
        await db.execute(
          'CREATE UNIQUE INDEX uq_completion_habit_day ON completions(habit_id, day_key);',
        );
        await db.execute(
          'CREATE INDEX idx_completions_habit_day_ms ON completions(habit_id, day_ms);',
        );

        await _createHabitReminders(db);

        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          );
        ''');

        await _createHabitInsights(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createHabitInsights(db);
        }
        if (oldVersion < 3) {
          await _migrateRemindersToHabitReminders(db);
        }
      },
    );
  }

  Future<void> _createHabitReminders(Database db) async {
    await db.execute('''
      CREATE TABLE habit_reminders (
        id              TEXT PRIMARY KEY,
        habit_id        TEXT NOT NULL,
        enabled         INTEGER NOT NULL DEFAULT 1,
        hour            INTEGER NOT NULL,
        minute          INTEGER NOT NULL,
        weekday_mask    INTEGER NOT NULL DEFAULT 127,
        notification_id INTEGER NOT NULL,
        position        INTEGER NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
      );
    ''');
    await db.execute(
      'CREATE INDEX idx_habit_reminders_habit_id ON habit_reminders(habit_id);',
    );
  }

  Future<void> _createHabitInsights(Database db) async {
    await db.execute('''
      CREATE TABLE habit_insights (
        habit_id     TEXT PRIMARY KEY,
        text         TEXT NOT NULL,
        generated_at INTEGER NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
      );
    ''');
  }

  /// Migración v2 → v3: copia cada row de `reminders` (1 por hábito) a un
  /// row nuevo en `habit_reminders` (N por hábito) con id generado. El
  /// `notification_id` se preserva para no quebrar las notifs ya
  /// agendadas en flutter_local_notifications.
  Future<void> _migrateRemindersToHabitReminders(Database db) async {
    await _createHabitReminders(db);

    final rand = math.Random();
    final old = await db.query('reminders');
    for (final row in old) {
      final ms = DateTime.now().millisecondsSinceEpoch;
      final r = rand.nextInt(1 << 16).toRadixString(16).padLeft(4, '0');
      final id = 'r_${ms}_$r';
      await db.insert('habit_reminders', {
        'id': id,
        'habit_id': row['habit_id'],
        'enabled': row['enabled'],
        'hour': row['hour'],
        'minute': row['minute'],
        'weekday_mask': row['weekday_mask'],
        'notification_id': row['notification_id'],
        'position': 0,
      });
    }

    await db.execute('DROP TABLE IF EXISTS reminders;');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
