import 'dart:math' as math;

final _rand = math.Random();

/// Genera id para un nuevo reminder con formato `r_<ms>_<rand4>`.
String generateReminderId() {
  final ms = DateTime.now().millisecondsSinceEpoch;
  final r = _rand.nextInt(1 << 16).toRadixString(16).padLeft(4, '0');
  return 'r_${ms}_$r';
}
