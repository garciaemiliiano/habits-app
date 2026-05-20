/// Helpers de fechas en tz local.
class DateRange {
  DateRange._();

  /// Medianoche local del día de la fecha dada.
  static DateTime dayOf(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Convierte una fecha a `yyyymmdd` int (ej. 20260519).
  static int dayKeyOf(DateTime dt) {
    final d = dayOf(dt);
    return d.year * 10000 + d.month * 100 + d.day;
  }

  /// Diferencia en días entre dos fechas (ignora horas).
  static int daysBetween(DateTime a, DateTime b) {
    return dayOf(b).difference(dayOf(a)).inDays;
  }

  /// Inicio del mes que contiene `dt`.
  static DateTime monthStart(DateTime dt) => DateTime(dt.year, dt.month, 1);

  /// Inicio del mes siguiente.
  static DateTime nextMonthStart(DateTime dt) {
    final year = dt.month == 12 ? dt.year + 1 : dt.year;
    final month = dt.month == 12 ? 1 : dt.month + 1;
    return DateTime(year, month, 1);
  }
}
