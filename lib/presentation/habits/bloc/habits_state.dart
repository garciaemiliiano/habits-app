part of 'habits_bloc.dart';

enum HabitsStatus { initial, loading, loaded, failure }

class HabitsState extends Equatable {
  const HabitsState({
    required this.status,
    required this.habits,
    required this.showArchived,
    this.errorMessage,
  });

  const HabitsState.initial()
      : status = HabitsStatus.initial,
        habits = const [],
        showArchived = false,
        errorMessage = null;

  final HabitsStatus status;
  final List<Habit> habits;
  final bool showArchived;
  final String? errorMessage;

  List<Habit> get visibleHabits =>
      habits.where((h) => h.archived == showArchived).toList(growable: false);

  HabitsState copyWith({
    HabitsStatus? status,
    List<Habit>? habits,
    bool? showArchived,
    String? errorMessage,
  }) {
    return HabitsState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      showArchived: showArchived ?? this.showArchived,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, habits, showArchived, errorMessage];
}
