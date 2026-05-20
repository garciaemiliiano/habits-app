import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/di/injector.dart';
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
      )..add(HabitDetailLoadRequested(habitId)),
      child: const _HabitDetailView(),
    );
  }
}

class _HabitDetailView extends StatelessWidget {
  const _HabitDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitDetailBloc, HabitDetailState>(
      builder: (context, state) {
        final habit = state.habit;
        return Scaffold(
          appBar: AppBar(
            title: Text(habit?.name ?? 'Detalle'),
            actions: habit == null
                ? []
                : [
                    IconButton(
                      tooltip: 'Editar',
                      onPressed: () async {
                        final reminders = await Injector.instance
                            .remindersRepository
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
                            context.read<HabitsBloc>().add(
                                  HabitsArchiveToggled(
                                      habitId: habit.id,
                                      archived: !habit.archived),
                                );
                            if (context.mounted) Navigator.of(context).pop();
                          case _DetailAction.delete:
                            final ok = await showConfirmDialog(
                              context,
                              title: 'Eliminar hábito',
                              message:
                                  'Se borrará "${habit.name}" y todo su historial.',
                              confirmLabel: 'Eliminar',
                              destructive: true,
                            );
                            if (ok && context.mounted) {
                              context
                                  .read<HabitsBloc>()
                                  .add(HabitsDeleted(habit.id));
                              Navigator.of(context).pop();
                            }
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: _DetailAction.archive,
                          child: Text(
                            habit.archived ? 'Desarchivar' : 'Archivar',
                          ),
                        ),
                        const PopupMenuItem(
                          value: _DetailAction.delete,
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),
                  ],
          ),
          body: _buildBody(context, state),
          floatingActionButton: habit == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => context.read<HabitDetailBloc>().add(
                        HabitDetailCompletionToggled(DateTime.now()),
                      ),
                  icon: const Icon(Icons.check),
                  label: const Text('Marcar hoy'),
                  backgroundColor: habit.color,
                  foregroundColor: Colors.white,
                ),
        );
      },
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
            'Cumplimiento por semana',
            style: Theme.of(context).textTheme.titleMedium,
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
