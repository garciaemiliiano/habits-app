part of 'coach_bloc.dart';

sealed class CoachEvent extends Equatable {
  const CoachEvent();

  @override
  List<Object?> get props => [];
}

class CoachAvailabilityChecked extends CoachEvent {
  const CoachAvailabilityChecked();
}

class CoachQuestionAsked extends CoachEvent {
  const CoachQuestionAsked(this.text);
  final String text;
  @override
  List<Object?> get props => [text];
}

class CoachCleared extends CoachEvent {
  const CoachCleared();
}

class CoachSuggestionsShown extends CoachEvent {
  const CoachSuggestionsShown();
}

class _CoachDynamicSuggestionsLoaded extends CoachEvent {
  const _CoachDynamicSuggestionsLoaded(this.suggestions);
  final List<String> suggestions;
  @override
  List<Object?> get props => [suggestions];
}
