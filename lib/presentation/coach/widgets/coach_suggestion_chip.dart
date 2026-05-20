import 'package:flutter/material.dart';

class CoachSuggestionChip extends StatelessWidget {
  const CoachSuggestionChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
      avatar: const Icon(Icons.auto_awesome, size: 16),
    );
  }
}
