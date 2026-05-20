import 'package:equatable/equatable.dart';

class HabitInsight extends Equatable {
  const HabitInsight({
    required this.habitId,
    required this.text,
    required this.generatedAt,
  });

  final String habitId;
  final String text;
  final DateTime generatedAt;

  @override
  List<Object?> get props => [habitId, text, generatedAt];
}
