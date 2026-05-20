import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/di/injector.dart';
import '../../domain/llm/llm_provider.dart';
import 'bloc/coach_bloc.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/coach_availability_banner.dart';
import 'widgets/coach_input.dart';
import 'widgets/coach_suggestion_chip.dart';
import 'widgets/coach_thinking_bubble.dart';

class CoachPage extends StatelessWidget {
  const CoachPage({super.key});

  static const _initialChips = [
    '¿Cómo vengo esta semana?',
    '¿Qué hábito está más flojo?',
    'Dame un tip para mantener la racha.',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoachBloc, CoachState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Coach'),
            actions: [
              if (state.messages.isNotEmpty)
                IconButton(
                  tooltip: 'Limpiar chat',
                  onPressed: () =>
                      context.read<CoachBloc>().add(const CoachCleared()),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CoachState state) {
    if (state.checkingAvailability || state.available == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.available == false) {
      return CoachAvailabilityBanner(
        details: state.availabilityDetails,
        onRetry: () =>
            context.read<CoachBloc>().add(const CoachAvailabilityChecked()),
      );
    }
    if (state.messages.isEmpty) {
      return _EmptyState(
        onChipTap: (text) =>
            context.read<CoachBloc>().add(CoachQuestionAsked(text)),
      );
    }
    return _ChatBody(state: state);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onChipTap});
  final ValueChanged<String> onChipTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tu coach on-device',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preguntá lo que quieras sobre tus hábitos. Las '
                    'respuestas se generan en tu teléfono — no van a '
                    'la nube.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: CoachPage._initialChips
                        .map((c) => CoachSuggestionChip(
                              label: c,
                              onTap: () => onChipTap(c),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        CoachInput(enabled: true, onSend: onChipTap),
      ],
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody({required this.state});
  final CoachState state;

  @override
  Widget build(BuildContext context) {
    final messages = state.messages;
    final suggestions = state.dynamicSuggestions;
    final showSuggestionsRow = state.showSuggestions &&
        suggestions != null &&
        suggestions.isNotEmpty &&
        !state.thinking;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            itemCount: messages.length +
                (state.thinking ? 1 : 0) +
                (showSuggestionsRow ? 1 : 0),
            itemBuilder: (context, index) {
              // Index 0 = elemento más abajo de la lista (reverse).
              // Orden visual: [chips] [thinking] [msg N-1] [msg N-2] ...
              final extras = (state.thinking ? 1 : 0) +
                  (showSuggestionsRow ? 1 : 0);

              if (showSuggestionsRow && index == 0) {
                return _SuggestionsRow(
                  suggestions: suggestions,
                  onTap: (text) => context
                      .read<CoachBloc>()
                      .add(CoachQuestionAsked(text)),
                );
              }
              if (state.thinking &&
                  index == (showSuggestionsRow ? 1 : 0)) {
                return const CoachThinkingBubble();
              }
              final msgIndex = messages.length - 1 - (index - extras);
              return ChatBubble(message: messages[msgIndex]);
            },
          ),
        ),
        _PrivacyBanner(),
        CoachInput(
          enabled: !state.thinking,
          onSend: (text) =>
              context.read<CoachBloc>().add(CoachQuestionAsked(text)),
        ),
      ],
    );
  }
}

class _SuggestionsRow extends StatelessWidget {
  const _SuggestionsRow({required this.suggestions, required this.onTap});
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions
            .map((s) => CoachSuggestionChip(label: s, onTap: () => onTap(s)))
            .toList(),
      ),
    );
  }
}

class _PrivacyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = Injector.instance.activeLlmProvider;
    final tagline = switch (provider.tier) {
      LlmTier.onDevice => 'on-device · tus hábitos no salen del teléfono',
      LlmTier.cloud => 'nube · enviado a Google AI Studio',
    };
    final icon = switch (provider.tier) {
      LlmTier.onDevice => Icons.smartphone,
      LlmTier.cloud => Icons.cloud,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: cs.surfaceContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${provider.displayName} · $tagline',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
