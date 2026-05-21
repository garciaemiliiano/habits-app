import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/habit_frequency.dart';
import '../../../domain/entities/habit_with_today_status.dart';
import '../../shared/widgets/habit_icon_badge.dart';
import 'frequency_progress_chip.dart';

class TodayHabitTile extends StatefulWidget {
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
  State<TodayHabitTile> createState() => _TodayHabitTileState();
}

class _TodayHabitTileState extends State<TodayHabitTile> {
  late final ConfettiController _confetti;
  bool _wasComplete = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 800));
    _wasComplete = widget.status.completedToday;
  }

  @override
  void didUpdateWidget(covariant TodayHabitTile old) {
    super.didUpdateWidget(old);
    final isComplete = widget.status.completedToday;
    if (isComplete && !_wasComplete) {
      _confetti.play();
    }
    _wasComplete = isComplete;
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final habit = widget.status.habit;
    final completed = widget.status.completedToday;
    final met = widget.status.periodMet;

    final bg = completed
        ? habit.color.withValues(alpha: 0.18)
        : cs.surfaceContainerHigh;
    final borderColor = met && !completed
        ? habit.color.withValues(alpha: 0.7)
        : Colors.transparent;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
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
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          if (widget.status.isFlexible) ...[
                            const SizedBox(height: 4),
                            FrequencyProgressChip(
                              completed: widget.status.periodCompleted ?? 0,
                              target: widget.status.periodTarget ?? 0,
                              color: habit.color,
                              periodLabel:
                                  habit.frequency.kind == FrequencyKind.monthly
                                      ? 'este mes'
                                      : 'esta semana',
                            ),
                          ] else if (widget.status.hasMultipleDailyEvents) ...[
                            const SizedBox(height: 4),
                            FrequencyProgressChip(
                              completed: widget.status.todayCompleted,
                              target: widget.status.todayTarget,
                              color: habit.color,
                              periodLabel: 'hoy',
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
                    _TrailingIndicator(
                      completed: widget.status.todayCompleted,
                      target: widget.status.todayTarget,
                      color: habit.color,
                      outlineColor: cs.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Confetti emergiendo desde la zona del check, hacia arriba.
        Positioned(
          right: 24,
          top: 28,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirection: -math.pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.0,
            numberOfParticles: 18,
            maxBlastForce: 18,
            minBlastForce: 8,
            gravity: 0.35,
            shouldLoop: false,
            colors: [
              habit.color,
              habit.color.withValues(alpha: 0.7),
              cs.tertiary,
              cs.primary,
              Colors.amber,
            ],
          ),
        ),
      ],
    );
  }
}

class _TrailingIndicator extends StatelessWidget {
  const _TrailingIndicator({
    required this.completed,
    required this.target,
    required this.color,
    required this.outlineColor,
  });

  final int completed;
  final int target;
  final Color color;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    final isDone = completed >= target;
    if (target <= 1) {
      return AnimatedScale(
        scale: isDone ? 1.0 : 0.85,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOutCubicEmphasized,
        child: Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isDone ? color : outlineColor,
          size: 28,
        ),
      );
    }
    // Multi-evento. Mientras va progresando, mostramos el anillo con
    // contador. Al cumplir, se reemplaza por el check para que sea
    // visualmente claro que terminó.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutBack,
      child: isDone
          ? Icon(
              Icons.check_circle,
              key: const ValueKey('done'),
              color: color,
              size: 32,
            )
          : SizedBox(
              key: const ValueKey('progress'),
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: (completed / target).clamp(0.0, 1.0),
                      strokeWidth: 3,
                      backgroundColor: outlineColor.withValues(alpha: 0.25),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Text(
                    '$completed/$target',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: outlineColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}
