import 'package:flutter/material.dart';

class OverallConsistencyCard extends StatelessWidget {
  const OverallConsistencyCard({super.key, required this.score});

  /// 0..1
  final double score;

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).round();
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: score,
                    strokeWidth: 6,
                    color: cs.primary,
                    backgroundColor: cs.primary.withValues(alpha: 0.15),
                  ),
                  Text(
                    '$pct',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consistencia general',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Promedio del score de todos tus hábitos.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
