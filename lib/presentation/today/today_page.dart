import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../habit_detail/habit_detail_page.dart';
import '../habit_edit/habit_edit_page.dart';
import '../habits/bloc/habits_bloc.dart';
import '../stats/bloc/stats_bloc.dart';
import 'bloc/today_bloc.dart';
import 'widgets/empty_today_view.dart';
import 'widgets/today_habit_tile.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodayBloc, TodayState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Hoy'),
            actions: [
              IconButton(
                tooltip: 'Ir a fecha',
                onPressed: () => _pickDate(context, state),
                icon: const Icon(Icons.calendar_month_outlined),
              ),
            ],
          ),
          body: Column(
            children: [
              _DateSelector(state: state),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
          floatingActionButton: state.habits.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _newHabit(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo hábito'),
                ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TodayState state) {
    if (state.status == TodayStatus.loading && state.habits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == TodayStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage ?? 'Error desconocido',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    if (state.habits.isEmpty) {
      return EmptyTodayView(onCreate: () => _newHabit(context));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: state.habits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final h = state.habits[i];
        return TodayHabitTile(
          status: h,
          onTap: () =>
              context.read<TodayBloc>().add(TodayHabitToggled(h.habit.id)),
          onLongPress: () => _openDetail(context, h.habit.id),
        );
      },
    );
  }

  Future<void> _newHabit(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const HabitEditPage()),
    );
    if (created == true && context.mounted) {
      _refreshAll(context);
    }
  }

  Future<void> _openDetail(BuildContext context, String habitId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => HabitDetailPage(habitId: habitId)),
    );
    if (context.mounted) _refreshAll(context);
  }

  void _refreshAll(BuildContext context) {
    context.read<TodayBloc>().add(const TodayRefreshRequested());
    context.read<HabitsBloc>().add(const HabitsLoadRequested());
    context.read<StatsBloc>().add(const StatsLoadRequested());
  }

  Future<void> _pickDate(BuildContext context, TodayState state) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );
    if (picked != null && context.mounted) {
      context.read<TodayBloc>().add(TodayDateChanged(picked));
    }
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.state});
  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = state.selectedDate == today;
    final isFuture = state.selectedDate.isAfter(today);
    final label = DateFormat('EEEE d \'de\' MMMM', 'es_AR')
        .format(state.selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => context.read<TodayBloc>().add(
                  TodayDateChanged(
                    state.selectedDate.subtract(const Duration(days: 1)),
                  ),
                ),
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    isToday ? 'Hoy' : (isFuture ? 'Futuro' : 'Día'),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    _capitalize(label),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: isToday
                ? null
                : () => context.read<TodayBloc>().add(
                      TodayDateChanged(
                        state.selectedDate.add(const Duration(days: 1)),
                      ),
                    ),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

