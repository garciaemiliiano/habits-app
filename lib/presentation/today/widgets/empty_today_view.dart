import 'package:flutter/material.dart';

class EmptyTodayView extends StatelessWidget {
  const EmptyTodayView({super.key, required this.onCreate});

  final VoidCallback onCreate;

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
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_outlined,
                size: 48,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin hábitos todavía',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Creá tu primer hábito para empezar a trackearlo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo hábito'),
            ),
          ],
        ),
      ),
    );
  }
}
