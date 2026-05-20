import 'package:flutter/material.dart';

/// Paleta fija de 12 colores para asignar a hábitos. Se eligió una
/// distribución amplia del color wheel para que dos hábitos consecutivos
/// se distingan rápido en la lista.
class HabitColors {
  HabitColors._();

  static const palette = <Color>[
    Color(0xFF7C4DFF), // violeta (default / seed)
    Color(0xFFE91E63), // rosa
    Color(0xFFEF5350), // rojo
    Color(0xFFFF6F00), // naranja
    Color(0xFFFFC107), // amarillo
    Color(0xFF66BB6A), // verde
    Color(0xFF26A69A), // teal
    Color(0xFF26C6DA), // cian
    Color(0xFF42A5F5), // azul
    Color(0xFF5C6BC0), // indigo
    Color(0xFF8D6E63), // marrón
    Color(0xFF78909C), // gris azulado
  ];

  static Color fromHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    final value = int.parse(clean, radix: 16);
    return Color(0xFF000000 | value);
  }

  static String toHex(Color color) {
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }
}

/// Paleta fija de iconos (codepoints `IconData`) para asignar a hábitos.
/// Usamos Material Icons (incluidos por `uses-material-design: true`).
class HabitIcons {
  HabitIcons._();

  static const palette = <IconData>[
    Icons.check_circle_outline,
    Icons.self_improvement,
    Icons.menu_book,
    Icons.fitness_center,
    Icons.directions_run,
    Icons.water_drop,
    Icons.bedtime,
    Icons.restaurant,
    Icons.code,
    Icons.brush,
    Icons.music_note,
    Icons.spa,
    Icons.savings,
    Icons.local_florist,
    Icons.smoke_free,
    Icons.school,
    Icons.pets,
    Icons.cleaning_services,
    Icons.phone_iphone,
    Icons.favorite,
  ];

  static IconData fromCode(int code) {
    return palette.firstWhere(
      (i) => i.codePoint == code,
      orElse: () => Icons.check_circle_outline,
    );
  }
}
