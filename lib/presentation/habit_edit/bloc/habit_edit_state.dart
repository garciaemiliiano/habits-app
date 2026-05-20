part of 'habit_edit_bloc.dart';

enum HabitEditStatus { editing, submitting, submitted, failure }

class HabitEditState extends Equatable {
  const HabitEditState({
    required this.existing,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.frequencyKind,
    required this.frequencyTarget,
    required this.dailyWeekdayMask,
    required this.reminders,
    required this.initialReminderIds,
    required this.deletedReminderIds,
    required this.status,
    this.savedHabit,
    this.validationErrors = const {},
    this.errorMessage,
  });

  factory HabitEditState.empty() => HabitEditState(
        existing: null,
        name: '',
        description: '',
        color: HabitColors.palette.first,
        icon: HabitIcons.palette.first,
        frequencyKind: FrequencyKind.daily,
        frequencyTarget: 1,
        dailyWeekdayMask: 0,
        reminders: const [],
        initialReminderIds: const {},
        deletedReminderIds: const [],
        status: HabitEditStatus.editing,
      );

  static const maxReminders = 6;

  final Habit? existing;
  final String name;
  final String description;
  final Color color;
  final IconData icon;
  final FrequencyKind frequencyKind;
  final int frequencyTarget;
  final int dailyWeekdayMask;

  /// Lista local de reminders en edición. Persisten en `habit_reminders`
  /// recién al submit.
  final List<ReminderConfig> reminders;

  /// Ids de los reminders que vinieron precargados desde DB. Sirve para
  /// distinguir borrar/agregar en la sesión actual.
  final Set<String> initialReminderIds;

  /// Ids de reminders preexistentes que el user borró durante esta
  /// sesión de edición. Se cancelan en el submit.
  final List<String> deletedReminderIds;

  final HabitEditStatus status;
  final Habit? savedHabit;
  final Map<String, String> validationErrors;
  final String? errorMessage;

  bool get isEditing => existing != null;
  bool get isSubmitting => status == HabitEditStatus.submitting;
  bool get isValid => name.trim().isNotEmpty;
  bool get canAddReminder => reminders.length < maxReminders;
  bool get hasEnabledReminders => reminders.any((r) => r.enabled);

  HabitEditState copyWith({
    Habit? existing,
    String? name,
    String? description,
    Color? color,
    IconData? icon,
    FrequencyKind? frequencyKind,
    int? frequencyTarget,
    int? dailyWeekdayMask,
    List<ReminderConfig>? reminders,
    Set<String>? initialReminderIds,
    List<String>? deletedReminderIds,
    HabitEditStatus? status,
    Habit? savedHabit,
    Map<String, String>? validationErrors,
    String? errorMessage,
  }) {
    return HabitEditState(
      existing: existing ?? this.existing,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      frequencyKind: frequencyKind ?? this.frequencyKind,
      frequencyTarget: frequencyTarget ?? this.frequencyTarget,
      dailyWeekdayMask: dailyWeekdayMask ?? this.dailyWeekdayMask,
      reminders: reminders ?? this.reminders,
      initialReminderIds: initialReminderIds ?? this.initialReminderIds,
      deletedReminderIds: deletedReminderIds ?? this.deletedReminderIds,
      status: status ?? this.status,
      savedHabit: savedHabit ?? this.savedHabit,
      validationErrors: validationErrors ?? this.validationErrors,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        existing,
        name,
        description,
        color,
        icon,
        frequencyKind,
        frequencyTarget,
        dailyWeekdayMask,
        reminders,
        initialReminderIds,
        deletedReminderIds,
        status,
        savedHabit,
        validationErrors,
        errorMessage,
      ];
}
