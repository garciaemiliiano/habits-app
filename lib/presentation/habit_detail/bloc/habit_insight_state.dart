part of 'habit_insight_bloc.dart';

class HabitInsightState extends Equatable {
  const HabitInsightState({
    this.loading = false,
    this.available,
    this.cached,
    this.errorMessage,
  });

  final bool loading;
  final bool? available;
  final HabitInsight? cached;
  final String? errorMessage;

  HabitInsightState copyWith({
    bool? loading,
    bool? available,
    HabitInsight? cached,
    bool clearCached = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HabitInsightState(
      loading: loading ?? this.loading,
      available: available ?? this.available,
      cached: clearCached ? null : (cached ?? this.cached),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [loading, available, cached, errorMessage];
}
