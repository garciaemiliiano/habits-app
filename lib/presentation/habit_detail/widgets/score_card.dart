import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.score,
    required this.rateLast4Weeks,
    required this.color,
  });

  /// 0..1
  final double score;
  /// 0..1
  final double rateLast4Weeks;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).round();
    final rate = (rateLast4Weeks * 100).round();
    return Card(
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
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.15),
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
                    'Score',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$rate% últimas 4 semanas',
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
