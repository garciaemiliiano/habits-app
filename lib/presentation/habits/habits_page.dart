import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../habit_detail/habit_detail_page.dart';
import '../habit_edit/habit_edit_page.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../stats/bloc/stats_bloc.dart';
import '../today/bloc/today_bloc.dart';
import 'bloc/habits_bloc.dart';
import 'widgets/habit_list_tile.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitsBloc, HabitsState>(
      builder: (context, state) {
        final visible = state.visibleHabits;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Hábitos'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Activos')),
                    ButtonSegment(value: true, label: Text('Archivados')),
                  ],
                  selected: {state.showArchived},
                  onSelectionChanged: (sel) => context
                      .read<HabitsBloc>()
                      .add(const HabitsShowArchivedToggled()),
                ),
              ),
            ),
          ),
          body: _buildBody(context, state, visible),
          floatingActionButton: state.showArchived
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

  Widget _buildBody(
    BuildContext context,
    HabitsState state,
    List visible,
  ) {
    if (state.status == HabitsStatus.loading && state.habits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (visible.isEmpty) {
      return Center(
        child: Text(
          state.showArchived
              ? 'No tenés hábitos archivados.'
              : 'Aún no tenés hábitos. Tocá + para crear uno.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (state.showArchived) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (_, i) {
          final h = visible[i];
          return HabitListTile(
            habit: h,
            onTap: () => _openDetail(context, h.id),
            onArchiveToggle: () => context.read<HabitsBloc>().add(
                  HabitsArchiveToggled(habitId: h.id, archived: false),
                ),
            onDelete: () => _confirmDelete(context, h.id, h.name),
          );
        },
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
      itemCount: visible.length,
      onReorder: (oldIndex, newIndex) {
        final ids = visible.map((h) => h.id as String).toList();
        if (newIndex > oldIndex) newIndex -= 1;
        final id = ids.removeAt(oldIndex);
        ids.insert(newIndex, id);
        context.read<HabitsBloc>().add(HabitsReordered(ids));
      },
      itemBuilder: (_, i) {
        final h = visible[i];
        return Padding(
          key: ValueKey(h.id),
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: HabitListTile(
            habit: h,
            onTap: () => _openDetail(context, h.id),
            onArchiveToggle: () => context.read<HabitsBloc>().add(
                  HabitsArchiveToggled(habitId: h.id, archived: true),
                ),
            onDelete: () => _confirmDelete(context, h.id, h.name),
          ),
        );
      },
    );
  }

  Future<void> _newHabit(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const HabitEditPage()),
    );
    if (created == true && context.mounted) _refreshAll(context);
  }

  Future<void> _openDetail(BuildContext context, String habitId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => HabitDetailPage(habitId: habitId)),
    );
    if (context.mounted) _refreshAll(context);
  }

  Future<void> _confirmDelete(
      BuildContext context, String habitId, String name) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Eliminar hábito',
      message: 'Se borrará "$name" y todo su historial. No se puede deshacer.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (ok && context.mounted) {
      context.read<HabitsBloc>().add(HabitsDeleted(habitId));
      _refreshAll(context);
    }
  }

  void _refreshAll(BuildContext context) {
    context.read<HabitsBloc>().add(const HabitsLoadRequested());
    context.read<TodayBloc>().add(const TodayRefreshRequested());
    context.read<StatsBloc>().add(const StatsLoadRequested());
  }
}
