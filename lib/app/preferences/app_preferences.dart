import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/datasources/local_db.dart';

/// Preferencias persistentes en la tabla `settings`. ChangeNotifier para
/// que la UI rebuildee al cambiarlas (sin Bloc adicional).
class AppPreferences extends ChangeNotifier {
  AppPreferences(this._db);

  final LocalDb _db;

  static const _kThemeMode = 'theme_mode';
  static const _kOled = 'oled';
  static const _kWeekStartsOn = 'week_starts_on';
  static const _kHeatmapMonths = 'heatmap_months';
  static const _kLlmProviderId = 'llm_provider_id';
  static const _kGeminiApiKey = 'gemini_api_key';

  ThemeMode _themeMode = ThemeMode.system;
  bool _oled = false;
  // 1 = lunes (default es_AR), 7 = domingo. Usamos la convención de
  // DateTime.weekday (1..7, lun..dom).
  int _weekStartsOn = 1;
  int _heatmapMonths = 6;
  String _llmProviderId = 'gemini-nano';
  String? _geminiApiKey;

  ThemeMode get themeMode => _themeMode;
  ThemeMode get materialThemeMode => _themeMode;
  bool get oled => _oled;
  int get weekStartsOn => _weekStartsOn;
  int get heatmapMonths => _heatmapMonths;
  String get llmProviderId => _llmProviderId;
  String? get geminiApiKey => _geminiApiKey;

  Future<void> load() async {
    final db = await _db.database;
    final rows = await db.query('settings');
    for (final row in rows) {
      final key = row['key'] as String;
      final value = row['value'] as String;
      switch (key) {
        case _kThemeMode:
          _themeMode = _parseThemeMode(value);
        case _kOled:
          _oled = value == '1';
        case _kWeekStartsOn:
          _weekStartsOn = int.tryParse(value) ?? 1;
        case _kHeatmapMonths:
          _heatmapMonths = int.tryParse(value) ?? 6;
        case _kLlmProviderId:
          if (value.isNotEmpty) _llmProviderId = value;
        case _kGeminiApiKey:
          _geminiApiKey = value.isEmpty ? null : value;
      }
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _put(_kThemeMode, mode.name);
    notifyListeners();
  }

  Future<void> setOled(bool value) async {
    _oled = value;
    await _put(_kOled, value ? '1' : '0');
    notifyListeners();
  }

  Future<void> setWeekStartsOn(int weekday) async {
    _weekStartsOn = weekday;
    await _put(_kWeekStartsOn, weekday.toString());
    notifyListeners();
  }

  Future<void> setHeatmapMonths(int months) async {
    _heatmapMonths = months;
    await _put(_kHeatmapMonths, months.toString());
    notifyListeners();
  }

  Future<void> setLlmProviderId(String id) async {
    if (id == _llmProviderId) return;
    _llmProviderId = id;
    await _put(_kLlmProviderId, id);
    notifyListeners();
  }

  Future<void> setGeminiApiKey(String? key) async {
    final cleaned = key?.trim();
    final next = (cleaned == null || cleaned.isEmpty) ? null : cleaned;
    if (next == _geminiApiKey) return;
    _geminiApiKey = next;
    await _put(_kGeminiApiKey, next ?? '');
    notifyListeners();
  }

  Future<void> _put(String key, String value) async {
    final db = await _db.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ThemeMode _parseThemeMode(String value) {
    return ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
