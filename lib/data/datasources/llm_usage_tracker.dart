import 'local_db.dart';

class LlmUsageStats {
  const LlmUsageStats({required this.last60s, required this.today});
  final int last60s;
  final int today;
}

/// Trackea requests al provider cloud (Gemini API). Permite mostrar
/// barritas de uso del free tier en Settings. Pensado para hacer un
/// INSERT por request y agregaciones COUNT por rango.
class LlmUsageTracker {
  LlmUsageTracker(this._db);

  final LocalDb _db;

  Future<void> recordRequest() async {
    final db = await _db.database;
    await db.insert('llm_cloud_usage', {
      'timestamp_ms': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<LlmUsageStats> stats() async {
    final db = await _db.database;
    await _prune(db);
    final now = DateTime.now().millisecondsSinceEpoch;
    final minuteAgo = now - const Duration(minutes: 1).inMilliseconds;
    final dayAgo = now - const Duration(hours: 24).inMilliseconds;

    final minuteRow = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM llm_cloud_usage WHERE timestamp_ms >= ?;',
      [minuteAgo],
    );
    final dayRow = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM llm_cloud_usage WHERE timestamp_ms >= ?;',
      [dayAgo],
    );

    return LlmUsageStats(
      last60s: (minuteRow.first['n'] as num).toInt(),
      today: (dayRow.first['n'] as num).toInt(),
    );
  }

  /// Mantiene la tabla acotada — borra registros > 24h. Llamado por
  /// `stats()` al consultar.
  Future<void> _prune(db) async {
    final cutoff = DateTime.now()
        .subtract(const Duration(hours: 25))
        .millisecondsSinceEpoch;
    await db.delete(
      'llm_cloud_usage',
      where: 'timestamp_ms < ?',
      whereArgs: [cutoff],
    );
  }
}
