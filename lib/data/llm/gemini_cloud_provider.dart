import 'dart:async';

import 'package:googleai_dart/googleai_dart.dart';

import '../../domain/llm/llm_provider.dart';

/// Provider cloud que llama a Gemini 3.5 Flash via Google AI Studio.
/// La API key se resuelve dinámicamente (vive en AppPreferences) para
/// que el switch desde Settings tenga efecto inmediato sin re-bootear DI.
///
/// Acepta un callback opcional `onRequestSent` que se llama después de
/// cada `generate` exitoso — lo usa el `LlmUsageTracker` para contabilizar
/// el uso contra el rate limit del free tier.
class GeminiCloudProvider implements LlmProvider {
  GeminiCloudProvider({
    required String? Function() resolveApiKey,
    this.onRequestSent,
  }) : _resolveApiKey = resolveApiKey;

  static const providerId = 'gemini-3-flash';
  static const modelName = 'gemini-3.5-flash';

  final String? Function() _resolveApiKey;
  final void Function()? onRequestSent;

  @override
  String get id => providerId;

  @override
  LlmTier get tier => LlmTier.cloud;

  @override
  String get displayName => 'Gemini 3.5 Flash (cloud)';

  @override
  String get description =>
      'Cloud · más capaz que Nano. Requiere API key de Google AI Studio.';

  @override
  Future<bool> isAvailable() async {
    final key = _resolveApiKey();
    return key != null && key.trim().isNotEmpty;
  }

  @override
  Future<String> availabilityDetails() async {
    final key = _resolveApiKey();
    if (key == null || key.trim().isEmpty) {
      return 'Falta API key. Configurala en Ajustes → Modelo del asistente.';
    }
    return 'Listo · modelo $modelName.';
  }

  @override
  Future<String> generate({
    required String prompt,
    double temperature = 0.4,
    int maxOutputTokens = 256,
  }) async {
    final key = _resolveApiKey();
    if (key == null || key.trim().isEmpty) {
      throw StateError('Falta API key de Gemini.');
    }
    final client = GoogleAIClient(
      config: GoogleAIConfig.googleAI(
        authProvider: ApiKeyProvider(key),
      ),
    );
    try {
      final response = await client.models.generateContent(
        model: modelName,
        request: GenerateContentRequest(
          contents: [Content.text(prompt)],
          generationConfig: GenerationConfig(
            temperature: temperature,
            maxOutputTokens: maxOutputTokens,
          ),
        ),
      );
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw StateError('La respuesta vino vacía.');
      }
      // Solo contamos requests que efectivamente devolvieron contenido.
      onRequestSent?.call();
      return text;
    } finally {
      client.close();
    }
  }
}
