import 'package:flutter/material.dart';

import '../../../domain/entities/habit_with_today_status.dart';
import '../../shared/widgets/habit_icon_badge.dart';
import 'frequency_progress_chip.dart';

class TodayHabitTile extends StatelessWidget {
  const TodayHabitTile({
    super.key,
    required this.status,
    required this.onTap,
    required this.onLongPress,
  });

  final HabitWithTodayStatus status;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final habit = status.habit;
    final completed = status.completedToday;
    final met = status.periodMet;

    final bg = completed
        ? habit.color.withValues(alpha: 0.18)
        : cs.surfaceContainerHigh;
    final borderColor = met && !completed
        ? habit.color.withValues(alpha: 0.7)
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOutCubicEmphasized,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                HabitIconBadge(
                  color: habit.color,
                  icon: habit.icon,
                  filled: completed,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (status.isFlexible) ...[
                        const SizedBox(height: 4),
                        FrequencyProgressChip(
                          completed: status.periodCompleted ?? 0,
                          target: status.periodTarget ?? 0,
                          color: habit.color,
                        ),
                      ] else if (habit.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          habit.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: completed ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubicEmphasized,
                  child: Icon(
                    completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: completed ? habit.color : cs.outline,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
