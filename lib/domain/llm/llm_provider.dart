/// Abstracción de bajo nivel sobre un modelo de lenguaje. Cada
/// implementación concreta (Gemini Nano via AICore, cloud, etc.) cumple
/// esta interfaz. El `CoachRepository` orquesta usando el provider activo.
abstract class LlmProvider {
  /// Identificador estable. Ej: 'gemini-nano'.
  String get id;

  /// Nombre legible para la UI.
  String get displayName;

  /// Descripción breve para el selector. Una línea.
  String get description;

  /// True si el provider está listo para generar. False = no instalado,
  /// modelo no descargado, sin permisos, etc.
  Future<bool> isAvailable();

  /// Detalle textual de por qué no está disponible (cuando aplica) o info
  /// de versión cuando sí lo está.
  Future<String> availabilityDetails();

  /// Generación a partir de un prompt completo (system + user ya
  /// concatenados — la mayoría de los modelos on-device no aceptan system
  /// messages separados).
  Future<String> generate({
    required String prompt,
    double temperature = 0.4,
    int maxOutputTokens = 256,
  });
}
