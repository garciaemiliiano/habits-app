import 'package:equatable/equatable.dart';

enum CoachRole { user, assistant }

class CoachMessage extends Equatable {
  CoachMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory CoachMessage.user(String content) =>
      CoachMessage(role: CoachRole.user, content: content);

  factory CoachMessage.assistant(String content) =>
      CoachMessage(role: CoachRole.assistant, content: content);

  final CoachRole role;
  final String content;
  final DateTime timestamp;

  @override
  List<Object?> get props => [role, content, timestamp];
}
