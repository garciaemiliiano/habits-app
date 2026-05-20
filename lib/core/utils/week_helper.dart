import 'date_range.dart';

/// Calcula rangos de semana y mes según preferencia `weekStartsOn`
/// (1=lunes, 7=domingo; convención `DateTime.weekday`).
class WeekHelper {
  WeekHelper(this.weekStartsOn);

  final int weekStartsOn;

  /// Inicio (medianoche) de la semana que contiene `dt`.
  DateTime startOfWeek(DateTime dt) {
    final day = DateRange.dayOf(dt);
    final diff = (day.weekday - weekStartsOn + 7) % 7;
    return day.subtract(Duration(days: diff));
  }

  /// Inicio de la siguiente semana (= end exclusivo de la actual).
  DateTime startOfNextWeek(DateTime dt) =>
      startOfWeek(dt).add(const Duration(days: 7));

  /// Rango (inclusive, exclusive) de la semana que contiene `dt`.
  (DateTime, DateTime) weekRange(DateTime dt) =>
      (startOfWeek(dt), startOfNextWeek(dt));

  /// Rango (inclusive, exclusive) del mes que contiene `dt`.
  (DateTime, DateTime) monthRange(DateTime dt) =>
      (DateRange.monthStart(dt), DateRange.nextMonthStart(dt));
}
