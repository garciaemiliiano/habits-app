import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/coach_message.dart';
import '../../../domain/repositories/coach_repository.dart';
import '../../../domain/usecases/build_habits_context.dart';

part 'coach_event.dart';
part 'coach_state.dart';

class CoachBloc extends Bloc<CoachEvent, CoachState> {
  CoachBloc({
    required CoachRepository coach,
    required BuildHabitsContext buildContext,
  })  : _coach = coach,
        _buildContext = buildContext,
        super(const CoachState()) {
    on<CoachAvailabilityChecked>(_onAvailability);
    on<CoachQuestionAsked>(_onAsk);
    on<CoachCleared>(_onClear);
    on<CoachSuggestionsShown>(_onSuggestionsShown);
    on<_CoachDynamicSuggestionsLoaded>(_onDynamicSuggestionsLoaded);
  }

  static const _suggestionDelay = Duration(seconds: 10);

  final CoachRepository _coach;
  final BuildHabitsContext _buildContext;

  Future<void> _onAvailability(
    CoachAvailabilityChecked event,
    Emitter<CoachState> emit,
  ) async {
    emit(state.copyWith(checkingAvailability: true));
    final ok = await _coach.isAvailable();
    final details = await _coach.availabilityDetails();
    emit(state.copyWith(
      checkingAvailability: false,
      available: ok,
      availabilityDetails: details,
    ));
  }

  Future<void> _onAsk(
    CoachQuestionAsked event,
    Emitter<CoachState> emit,
  ) async {
    final userMsg = CoachMessage.user(event.text);
    emit(state.copyWith(
      messages: [...state.messages, userMsg],
      thinking: true,
      showSuggestions: false,
      clearDynamicSuggestions: true,
      clearError: true,
    ));

    try {
      final context = await _buildContext();
      final answer = await _coach.ask(
        prompt: event.text,
        systemInstruction: context,
      );
      final updatedMessages = [
        ...state.messages,
        CoachMessage.assistant(answer),
      ];
      emit(state.copyWith(
        messages: updatedMessages,
        thinking: false,
      ));

      // Sugerencias contextuales en background; guard contra race
      // conditions con `messages.length` snapshot.
      final snapshotLen = updatedMessages.length;
      // ignore: discarded_futures
      _coach
          .generateSuggestions(
        lastAnswer: answer,
        systemInstruction: context,
      )
          .then((suggestions) {
        if (isClosed) return;
        if (state.messages.length != snapshotLen) return;
        if (suggestions.isEmpty) return;
        add(_CoachDynamicSuggestionsLoaded(suggestions));
      });

      // Tras 10s sin actividad, mostramos sugerencias.
      Future<void>.delayed(_suggestionDelay).then((_) {
        if (!isClosed && state.messages.length == snapshotLen) {
          add(const CoachSuggestionsShown());
        }
      });
    } catch (e) {
      emit(state.copyWith(
        thinking: false,
        errorMessage: 'No se pudo responder: $e',
      ));
    }
  }

  void _onDynamicSuggestionsLoaded(
    _CoachDynamicSuggestionsLoaded event,
    Emitter<CoachState> emit,
  ) {
    emit(state.copyWith(dynamicSuggestions: event.suggestions));
  }

  void _onClear(CoachCleared event, Emitter<CoachState> emit) {
    emit(state.copyWith(
      messages: const [],
      showSuggestions: false,
      clearDynamicSuggestions: true,
      clearError: true,
    ));
  }

  void _onSuggestionsShown(
    CoachSuggestionsShown event,
    Emitter<CoachState> emit,
  ) {
    if (state.thinking || state.messages.isEmpty) return;
    if (state.messages.last.role != CoachRole.assistant) return;
    emit(state.copyWith(showSuggestions: true));
  }
}
