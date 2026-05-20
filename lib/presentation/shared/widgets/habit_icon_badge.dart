import 'package:flutter/material.dart';

class HabitIconBadge extends StatelessWidget {
  const HabitIconBadge({
    super.key,
    required this.color,
    required this.icon,
    required this.filled,
  });

  final Color color;
  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOutCubicEmphasized,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: filled ? Colors.white : color,
        size: 22,
      ),
    );
  }
}
