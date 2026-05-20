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

  ThemeMode _themeMode = ThemeMode.system;
  bool _oled = false;
  // 1 = lunes (default es_AR), 7 = domingo. Usamos la convención de
  // DateTime.weekday (1..7, lun..dom).
  int _weekStartsOn = 1;
  int _heatmapMonths = 6;

  ThemeMode get themeMode => _themeMode;
  ThemeMode get materialThemeMode => _themeMode;
  bool get oled => _oled;
  int get weekStartsOn => _weekStartsOn;
  int get heatmapMonths => _heatmapMonths;

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
