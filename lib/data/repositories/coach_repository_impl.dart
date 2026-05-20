import 'package:flutter/services.dart' show rootBundle;

import '../../domain/llm/llm_provider.dart';
import '../../domain/repositories/coach_repository.dart';

class CoachRepositoryImpl implements CoachRepository {
  CoachRepositoryImpl({required LlmProvider Function() resolveActive})
      : _resolveActive = resolveActive;

  static const _suggestionsTemplatePath = 'assets/prompts/coach_suggestions.md';
  static const _insightTemplatePath = 'assets/prompts/habit_insight.md';

  final LlmProvider Function() _resolveActive;

  String? _cachedSuggestionsTemplate;
  String? _cachedInsightTemplate;

  LlmProvider get _active => _resolveActive();

  @override
  Future<bool> isAvailable() => _active.isAvailable();

  @override
  Future<String> availabilityDetails() => _active.availabilityDetails();

  @override
  Future<String> ask({
    required String prompt,
    required String systemInstruction,
  }) {
    final composed = '''
$systemInstruction

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
      final template = await _loadTemplate(
        _suggestionsTemplatePath,
        cached: () => _cachedSuggestionsTemplate,
        setCache: (v) => _cachedSuggestionsTemplate = v,
      );
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
    final template = await _loadTemplate(
      _insightTemplatePath,
      cached: () => _cachedInsightTemplate,
      setCache: (v) => _cachedInsightTemplate = v,
    );
    final composed = template
        .replaceAll('{{habit_name}}', habitName)
        .replaceAll('{{habit_description}}', habitDescription)
        .replaceAll('{{habit_frequency}}', habitFrequency)
        .replaceAll('{{habit_stats}}', habitStatsSummary);
    final raw = await _active.generate(
      prompt: composed,
      temperature: 0.5,
      maxOutputTokens: 256,
    );
    return raw.trim();
  }

  Future<String> _loadTemplate(
    String path, {
    required String? Function() cached,
    required void Function(String) setCache,
  }) async {
    final hit = cached();
    if (hit != null) return hit;
    final loaded = await rootBundle.loadString(path);
    setCache(loaded);
    return loaded;
  }
}
