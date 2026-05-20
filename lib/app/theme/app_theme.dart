import 'package:flutter/material.dart';

/// Builders M3 Expressive con seed color como fallback cuando no hay
/// dynamic color. Seed violeta para diferenciar visualmente de health-app.
class AppTheme {
  AppTheme._();

  static const _seed = Color(0xFF7C4DFF);

  static ThemeData light(ColorScheme? scheme) {
    final cs = scheme ??
        ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light);
    return _build(cs);
  }

  static ThemeData dark(ColorScheme? scheme) {
    final cs = scheme ??
        ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark);
    return _build(cs);
  }

  /// Variante OLED: fondo negro puro y superficies oscuras para ahorrar
  /// pixeles en pantallas OLED. Mantiene los acentos del scheme base.
  static ThemeData oled(ColorScheme? scheme) {
    final base = scheme ??
        ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark);
    final oledScheme = base.copyWith(
      surface: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: const Color(0xFF0A0A0A),
      surfaceContainer: const Color(0xFF111111),
      surfaceContainerHigh: const Color(0xFF161616),
      surfaceContainerHighest: const Color(0xFF1B1B1B),
    );
    return _build(oledScheme).copyWith(
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.black,
    );
  }

  static ThemeData _build(ColorScheme cs) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: const StadiumBorder(),
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
