import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CoachThinkingBubble extends StatelessWidget {
  const CoachThinkingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Skeletonizer(
            enabled: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: 200, color: cs.onSurface),
                const SizedBox(height: 8),
                Container(height: 12, width: 240, color: cs.onSurface),
                const SizedBox(height: 8),
                Container(height: 12, width: 160, color: cs.onSurface),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
