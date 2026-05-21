import 'package:flutter/services.dart' show rootBundle;

import '../../domain/llm/llm_provider.dart';
import '../../domain/repositories/coach_repository.dart';

class CoachRepositoryImpl implements CoachRepository {
  CoachRepositoryImpl({required LlmProvider Function() resolveActive})
      : _resolveActive = resolveActive;

  // Templates por feature/tier. Se cachean por path en `_templateCache`.
  static const _coachNanoPath = 'assets/prompts/coach/system_nano.md';
  static const _coachCloudPath = 'assets/prompts/coach/system_cloud.md';
  static const _insightBasePath =
      'assets/prompts/habit_insight/system_base.md';
  static const _insightNanoPath =
      'assets/prompts/habit_insight/system_nano.md';
  static const _insightCloudPath =
      'assets/prompts/habit_insight/system_cloud.md';
  static const _suggestionsTemplatePath = 'assets/prompts/coach_suggestions.md';

  final LlmProvider Function() _resolveActive;
  final Map<String, String> _templateCache = {};

  LlmProvider get _active => _resolveActive();

  @override
  Future<bool> isAvailable() => _active.isAvailable();

  @override
  Future<String> availabilityDetails() => _active.availabilityDetails();

  @override
  Future<String> ask({
    required String prompt,
    required String systemInstruction,
  }) async {
    final tierGuide = await _coachTierGuide(_active.tier);
    final composed = '''
$systemInstruction

$tierGuide

Pregunta del usuario:
$prompt
'''
        .trim();
    return _active.generate(prompt: composed);
  }

  @override
  Future<List<String>> generateSuggestions({
    required String lastAnswer,
    required String systemInstruction,
  }) async {
    try {
      final template = await _loadTemplate(_suggestionsTemplatePath);
      final body = template.replaceAll('{{last_answer}}', lastAnswer);
      final composed = '$systemInstruction\n\n$body'.trim();
      final raw = await _active.generate(
        prompt: composed,
        temperature: 0.6,
        maxOutputTokens: 96,
      );
      final lines = raw
          .split(RegExp(r'[\n\r]+'))
          .map((l) => l.trim())
          .map((l) => l.replaceFirst(RegExp(r'^[\-\*\d\.\)\s]+'), ''))
          .map((l) => l.replaceAll(RegExp(r'^["“”]|["“”]$'), ''))
          .where((l) => l.isNotEmpty && l.length <= 80)
          .take(3)
          .toList();
      return lines.length == 3 ? lines : <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  @override
  Future<String> generateHabitInsight({
    required String habitName,
    required String habitDescription,
    required String habitFrequency,
    required String habitStatsSummary,
  }) async {
    final base = await _loadTemplate(_insightBasePath);
    final tierGuide = await _insightTierGuide(_active.tier);

    final filledBase = base
        .replaceAll('{{habit_name}}', habitName)
        .replaceAll('{{habit_description}}', habitDescription)
        .replaceAll('{{habit_frequency}}', habitFrequency)
        .replaceAll('{{habit_stats}}', habitStatsSummary);

    final composed = '$filledBase\n\n$tierGuide'.trim();
    // Nano on-device tiene un cap hard de 256. Cloud (Flash) acepta más,
    // así que ahí le damos 512 para que no corte el punto 5.
    final maxTokens = _active.tier == LlmTier.onDevice ? 256 : 512;
    final raw = await _active.generate(
      prompt: composed,
      temperature: 0.5,
      maxOutputTokens: maxTokens,
    );
    return _trimIncompleteTail(raw.trim());
  }

  /// Si el modelo se quedó sin tokens y cortó a mitad de frase, recortamos
  /// hasta el último signo de cierre (. ! ? :) para no mostrar texto
  /// truncado al usuario. Si no hay ningún signo de cierre, devolvemos
  /// el texto tal cual.
  String _trimIncompleteTail(String s) {
    if (s.isEmpty) return s;
    final lastChar = s[s.length - 1];
    const closers = {'.', '!', '?', ':', '”', '"', ')'};
    if (closers.contains(lastChar)) return s;
    final match = RegExp(r'[.!?]')
        .allMatches(s)
        .fold<int>(-1, (acc, m) => m.end);
    if (match <= 0) return s;
    return s.substring(0, match).trim();
  }

  Future<String> _coachTierGuide(LlmTier tier) {
    final path = switch (tier) {
      LlmTier.onDevice => _coachNanoPath,
      LlmTier.cloud => _coachCloudPath,
    };
    return _loadTemplate(path);
  }

  Future<String> _insightTierGuide(LlmTier tier) {
    final path = switch (tier) {
      LlmTier.onDevice => _insightNanoPath,
      LlmTier.cloud => _insightCloudPath,
    };
    return _loadTemplate(path);
  }

  Future<String> _loadTemplate(String path) async {
    final hit = _templateCache[path];
    if (hit != null) return hit;
    final loaded = await rootBundle.loadString(path);
    _templateCache[path] = loaded;
    return loaded;
  }
}
