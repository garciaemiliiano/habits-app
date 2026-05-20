import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import '../../app/preferences/app_preferences.dart';
import '../../core/utils/habit_frequency_format.dart';
import 'get_all_habits.dart';
import 'get_overall_stats.dart';

/// Carga el system prompt del coach desde un asset Markdown y rellena los
/// placeholders con los datos reales del usuario (hábitos + stats).
class BuildHabitsContext {
  BuildHabitsContext({
    required GetAllHabits getAllHabits,
    required GetOverallStats getOverallStats,
    required AppPreferences prefs,
  })  : _getAllHabits = getAllHabits,
        _getOverallStats = getOverallStats,
        _prefs = prefs;

  static const _templatePath = 'assets/prompts/coach/system_base.md';

  // ignore: unused_field
  final GetAllHabits _getAllHabits;
  final GetOverallStats _getOverallStats;
  final AppPreferences _prefs;

  String? _cachedTemplate;

  Future<String> call({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final rows = await _getOverallStats();
    final active = rows.where((r) => !r.habit.archived).toList();
    final template = await _loadTemplate();

    final summary = active.isEmpty
        ? 'El usuario todavía no tiene hábitos activos.'
        : active.map(_formatHabitLine).join('\n');

    final dateFmt = DateFormat('EEEE d \'de\' MMMM \'de\' yyyy', 'es_AR');
    final todayLabel = _capitalize(dateFmt.format(today));
    final weekLabel = _prefs.weekStartsOn == 1 ? 'lunes' : 'domingo';

    final replacements = <String, String>{
      'today_date': todayLabel,
      'week_starts_on': weekLabel,
      'habits_count': active.length.toString(),
      'habits_summary': summary,
    };

    var out = template;
    replacements.forEach((k, v) {
      out = out.replaceAll('{{$k}}', v);
    });
    return out;
  }

  String _formatHabitLine(OverallStatRow row) {
    final h = row.habit;
    final s = row.stats;
    final freq = HabitFrequencyFormat.format(h.frequency);
    final scorePct = (s.score * 100).round();
    final ratePct = (s.last4WeeksRate * 100).round();
    final descPart = (h.description?.trim().isNotEmpty ?? false)
        ? ' — "${h.description!.trim()}"'
        : '';
    return '- "${h.name}" ($freq)$descPart: racha ${s.currentStreak}d'
        ' (mejor: ${s.bestStreak}d) · score $scorePct%'
        ' · últimas 4 semanas $ratePct%';
  }

  Future<String> _loadTemplate() async {
    final cached = _cachedTemplate;
    if (cached != null) return cached;
    final loaded = await rootBundle.loadString(_templatePath);
    _cachedTemplate = loaded;
    return loaded;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
