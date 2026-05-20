/// Coach IA on-device. La impl concreta hoy usa Gemini Nano via Android
/// AICore. Interfaz agnóstica para poder swapear provider.
abstract class CoachRepository {
  /// True si el dispositivo soporta el coach y el modelo está disponible.
  Future<bool> isAvailable();

  /// Diagnóstico textual cuando `isAvailable` devuelve false (versión
  /// faltante, AICore no instalado, dispositivo no soportado, etc.).
  Future<String> availabilityDetails();

  /// Genera una respuesta para `prompt`, usando `systemInstruction` como
  /// preámbulo (contexto de hábitos del usuario + persona del coach).
  Future<String> ask({
    required String prompt,
    required String systemInstruction,
  });

  /// 3 preguntas cortas de seguimiento contextualizadas a la última
  /// respuesta. Devuelve [] si el modelo falla o no llega a 3 líneas
  /// parseables.
  Future<List<String>> generateSuggestions({
    required String lastAnswer,
    required String systemInstruction,
  });

  /// Análisis focused para UN hábito concreto. Recibe strings ya
  /// pre-formateados (la responsabilidad de format vive en el usecase).
  /// Devuelve markdown de 4-6 frases.
  Future<String> generateHabitInsight({
    required String habitName,
    required String habitDescription,
    required String habitFrequency,
    required String habitStatsSummary,
  });
}
