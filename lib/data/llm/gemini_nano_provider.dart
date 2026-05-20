import 'package:flutter/services.dart';
import 'package:gemini_nano_android/gemini_nano_android.dart';

import '../../domain/llm/llm_provider.dart';

class GeminiNanoProvider implements LlmProvider {
  GeminiNanoProvider({GeminiNanoAndroid? engine})
      : _engine = engine ?? GeminiNanoAndroid();

  static const providerId = 'gemini-nano';

  final GeminiNanoAndroid _engine;

  @override
  String get id => providerId;

  @override
  String get displayName => 'Gemini Nano';

  @override
  String get description =>
      'On-device vía Android AICore. Recomendado en Pixel 9.';

  @override
  Future<bool> isAvailable() async {
    try {
      return await _engine.isAvailable();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> availabilityDetails() async {
    try {
      final ok = await _engine.isAvailable();
      if (!ok) {
        return 'AICore no está listo. Verificá en Play Store que tengas'
            ' "AICore" y "Android System Intelligence" instalados y actualizados.';
      }
      final version = await _engine.getModelVersion();
      return 'Modelo activo: ${version ?? 'desconocido'}.';
    } on PlatformException catch (e) {
      return 'Error consultando AICore: ${e.message ?? e.code}';
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  @override
  Future<String> generate({
    required String prompt,
    double temperature = 0.4,
    int maxOutputTokens = 256,
  }) async {
    final results = await _engine.generate(
      prompt: prompt,
      temperature: temperature,
      maxOutputTokens: maxOutputTokens,
    );
    if (results.isEmpty) {
      throw StateError('El modelo no devolvió ningún candidato.');
    }
    return results.first.trim();
  }
}
