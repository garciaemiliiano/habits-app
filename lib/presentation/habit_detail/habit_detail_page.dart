import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/di/injector.dart';
import '../../domain/entities/habit.dart';
import '../habit_edit/habit_edit_page.dart';
import '../habits/bloc/habits_bloc.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../stats/bloc/stats_bloc.dart';
import '../today/bloc/today_bloc.dart';
import 'bloc/habit_detail_bloc.dart';
import 'widgets/completion_chart.dart';
import 'widgets/habit_heatmap.dart';
import 'widgets/insight_card.dart';
import 'widgets/score_card.dart';
import 'widgets/streak_card.dart';

class HabitDetailPage extends StatelessWidget {
  const HabitDetailPage({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    final injector = Injector.instance;
    return BlocProvider(
      create: (_) => HabitDetailBloc(
        habits: injector.habitsRepository,
        getHabitStats: injector.getHabitStats,
        toggleCompletion: injector.toggleCompletion,
        completions: injector.completionsRepository,
        reminders: injector.remindersRepository,
      )..add(HabitDetailLoadRequested(habitId)),
      child: const _HabitDetailView(),
    );
  }
}

class _HabitDetailView extends StatefulWidget {
  const _HabitDetailView();

  @override
  State<_HabitDetailView> createState() => _HabitDetailViewState();
}

class _HabitDetailViewState extends State<_HabitDetailView> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitDetailBloc, HabitDetailState>(
      listenWhen: (prev, curr) => !prev.todayMet && curr.todayMet,
      listener: (context, state) => _confetti.play(),
      builder: (context, state) {
        final habit = state.habit;
        return Scaffold(
          appBar: AppBar(
            title: Text(habit?.name ?? 'Detalle'),
            actions: habit == null ? [] : _buildActions(context, habit),
          ),
          body: Stack(
            children: [
              _buildBody(context, state),
              // Confetti centrado arriba para que caiga a la vista.
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirection: math.pi / 2,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.0,
                  numberOfParticles: 40,
                  maxBlastForce: 24,
                  minBlastForce: 10,
                  gravity: 0.3,
                  shouldLoop: false,
                  colors: [
                    if (habit != null) habit.color,
                    if (habit != null) habit.color.withValues(alpha: 0.7),
                    Theme.of(context).colorScheme.tertiary,
                    Theme.of(context).colorScheme.primary,
                    Colors.amber,
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton:
              habit == null ? null : _buildFab(context, state, habit),
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context, Habit habit) {
    return [
      IconButton(
        tooltip: 'Editar',
        onPressed: () async {
          final reminders = await Injector.instance.remindersRepository
              .getForHabit(habit.id);
          if (!context.mounted) return;
          final updated = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => HabitEditPage(
                existing: habit,
                existingReminders: reminders,
              ),
            ),
          );
          if (updated == true && context.mounted) {
            context
                .read<HabitDetailBloc>()
                .add(HabitDetailLoadRequested(habit.id));
            _refreshAll(context);
          }
        },
        icon: const Icon(Icons.edit),
      ),
      PopupMenuButton<_DetailAction>(
        onSelected: (a) async {
          switch (a) {
            case _DetailAction.archive:
              await Injector.instance.archiveHabit(
                habitId: habit.id,
                archived: !habit.archived,
              );
              if (context.mounted) {
                _refreshAll(context);
                Navigator.of(context).pop();
              }
            case _DetailAction.delete:
              final ok = await showConfirmDialog(
                context,
                title: 'Eliminar hábito',
                message:
                    'Se borrará "${habit.name}" y todo su historial.',
                confirmLabel: 'Eliminar',
                destructive: true,
              );
              if (!ok) return;
              await Injector.instance.deleteHabit(habit.id);
              if (context.mounted) {
                _refreshAll(context);
                Navigator.of(context).pop();
              }
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _DetailAction.archive,
            child: Text(habit.archived ? 'Desarchivar' : 'Archivar'),
          ),
          const PopupMenuItem(
            value: _DetailAction.delete,
            child: Text('Eliminar'),
          ),
        ],
      ),
    ];
  }

  Widget _buildFab(BuildContext context, HabitDetailState state, Habit habit) {
    final met = state.todayMet;
    final multi = state.todayTarget > 1;
    final label = multi
        ? '${state.todayCompleted}/${state.todayTarget} hoy'
        : (met ? 'Hecho hoy' : 'Marcar hoy');
    return FloatingActionButton.extended(
      onPressed: met
          ? null
          : () => context.read<HabitDetailBloc>().add(
                HabitDetailCompletionToggled(DateTime.now()),
              ),
      icon: Icon(met ? Icons.check_circle : Icons.check),
      label: Text(label),
      backgroundColor:
          met ? habit.color.withValues(alpha: 0.4) : habit.color,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildBody(BuildContext context, HabitDetailState state) {
    if (state.status == HabitDetailStatus.loading && state.habit == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.habit == null) {
      return Center(
        child: Text(state.errorMessage ?? 'No se pudo cargar'),
      );
    }
    final habit = state.habit!;
    final stats = state.stats;
    final prefs = Injector.instance.appPreferences;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: habit.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(habit.icon, color: habit.color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  if (habit.description?.isNotEmpty == true)
                    Text(habit.description!,
                        style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (stats != null) ...[
          StreakCard(
            current: stats.currentStreak,
            best: stats.bestStreak,
            color: habit.color,
          ),
          const SizedBox(height: 12),
          ScoreCard(
            score: stats.score,
            rateLast4Weeks: stats.last4WeeksRate,
            color: habit.color,
          ),
          const SizedBox(height: 20),
          Text('Heatmap', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: HabitHeatmap(
                cells: stats.heatmap,
                color: habit.color,
                onCellTap: (day) => context
                    .read<HabitDetailBloc>()
                    .add(HabitDetailCompletionToggled(day)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Días cumplidos por semana',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'Cantidad de días que marcaste el hábito en cada una de las últimas 8 semanas (máx. 7).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CompletionChart(
                cells: stats.heatmap,
                color: habit.color,
                weekStartsOn: prefs.weekStartsOn,
              ),
            ),
          ),
          const SizedBox(height: 20),
          InsightCard(habitId: habit.id, habitColor: habit.color),
        ] else
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  void _refreshAll(BuildContext context) {
    context.read<TodayBloc>().add(const TodayRefreshRequested());
    context.read<HabitsBloc>().add(const HabitsLoadRequested());
    context.read<StatsBloc>().add(const StatsLoadRequested());
  }
}

enum _DetailAction { archive, delete }
