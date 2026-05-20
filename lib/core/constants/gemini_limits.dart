/// Límites del free tier de Gemini API (Google AI Studio).
/// Valores actuales (mayo 2026) — ajustables si Google los cambia.
class GeminiFreeTierLimits {
  GeminiFreeTierLimits._();

  /// Requests por minuto permitidas en el plan gratuito.
  static const requestsPerMinute = 15;

  /// Requests por día permitidas en el plan gratuito.
  static const requestsPerDay = 1500;
}
