import 'package:flutter/material.dart';

import '../../../core/constants/habit_colors.dart';

class IconPickerSheet extends StatelessWidget {
  const IconPickerSheet({
    super.key,
    required this.selected,
    required this.tint,
  });

  final IconData selected;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elegir icono',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: HabitIcons.palette.length,
              itemBuilder: (_, i) {
                final icon = HabitIcons.palette[i];
                final isSelected = icon.codePoint == selected.codePoint;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).pop(icon),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tint.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? tint : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(icon, color: tint, size: 28),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
