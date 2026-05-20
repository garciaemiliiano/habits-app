part of 'today_bloc.dart';

enum TodayStatus { initial, loading, loaded, failure }

class TodayState extends Equatable {
  const TodayState({
    required this.status,
    required this.habits,
    required this.selectedDate,
    this.errorMessage,
  });

  factory TodayState.initial() => TodayState(
        status: TodayStatus.initial,
        habits: const [],
        selectedDate: DateRange.dayOf(DateTime.now()),
      );

  final TodayStatus status;
  final List<HabitWithTodayStatus> habits;
  final DateTime selectedDate;
  final String? errorMessage;

  TodayState copyWith({
    TodayStatus? status,
    List<HabitWithTodayStatus>? habits,
    DateTime? selectedDate,
    String? errorMessage,
  }) {
    return TodayState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, habits, selectedDate, errorMessage];
}
