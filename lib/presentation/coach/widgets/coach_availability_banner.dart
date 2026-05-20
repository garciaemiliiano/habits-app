import 'package:flutter/material.dart';

class CoachAvailabilityBanner extends StatelessWidget {
  const CoachAvailabilityBanner({
    super.key,
    required this.details,
    required this.onRetry,
  });

  final String? details;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off,
                size: 48,
                color: cs.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Coach no disponible',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              details ??
                  'Tu dispositivo todavía no tiene Gemini Nano vía AICore.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
