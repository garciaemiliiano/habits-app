part of 'coach_bloc.dart';

class CoachState extends Equatable {
  const CoachState({
    this.checkingAvailability = false,
    this.available,
    this.availabilityDetails,
    this.messages = const [],
    this.thinking = false,
    this.showSuggestions = false,
    this.dynamicSuggestions,
    this.errorMessage,
  });

  final bool checkingAvailability;
  final bool? available;
  final String? availabilityDetails;
  final List<CoachMessage> messages;
  final bool thinking;
  final bool showSuggestions;
  final List<String>? dynamicSuggestions;
  final String? errorMessage;

  CoachState copyWith({
    bool? checkingAvailability,
    bool? available,
    String? availabilityDetails,
    List<CoachMessage>? messages,
    bool? thinking,
    bool? showSuggestions,
    List<String>? dynamicSuggestions,
    bool clearDynamicSuggestions = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CoachState(
      checkingAvailability:
          checkingAvailability ?? this.checkingAvailability,
      available: available ?? this.available,
      availabilityDetails: availabilityDetails ?? this.availabilityDetails,
      messages: messages ?? this.messages,
      thinking: thinking ?? this.thinking,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      dynamicSuggestions: clearDynamicSuggestions
          ? null
          : (dynamicSuggestions ?? this.dynamicSuggestions),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        checkingAvailability,
        available,
        availabilityDetails,
        messages,
        thinking,
        showSuggestions,
        dynamicSuggestions,
        errorMessage,
      ];
}
