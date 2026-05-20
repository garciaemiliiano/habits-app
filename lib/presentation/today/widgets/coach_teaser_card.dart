import 'package:flutter/material.dart';

class CoachTeaserCard extends StatelessWidget {
  const CoachTeaserCard({
    super.key,
    required this.available,
    required this.onPromptTap,
  });

  static const _quickPrompts = [
    '¿Cómo vengo hoy?',
    '¿Qué priorizo esta semana?',
    '¿Qué hábito está más flojo?',
  ];

  final bool available;
  final ValueChanged<String> onPromptTap;

  @override
  Widget build(BuildContext context) {
    if (!available) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: cs.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Preguntale a tu coach',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Te ayudo a mantener constancia con tus hábitos.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickPrompts
                  .map((p) => ActionChip(
                        label: Text(p),
                        onPressed: () => onPromptTap(p),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
