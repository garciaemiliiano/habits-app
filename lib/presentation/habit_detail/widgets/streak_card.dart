import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.current,
    required this.best,
    required this.color,
  });

  final int current;
  final int best;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.local_fire_department, color: color, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$current días',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Racha actual',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$best',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Mejor',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
