import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../habit_detail/habit_detail_page.dart';
import '../shared/widgets/habit_icon_badge.dart';
import 'bloc/stats_bloc.dart';
import 'widgets/overall_consistency_card.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Estadísticas')),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, StatsState state) {
    if (state.status == StatsStatus.loading && state.rows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.rows.isEmpty) {
      return const _EmptyStatsView();
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        OverallConsistencyCard(score: state.overallScore),
        const SizedBox(height: 16),
        Text('Por hábito', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...state.rows.map((row) {
          final scorePct = (row.stats.score * 100).round();
          return Card(
            child: ListTile(
              leading: HabitIconBadge(
                color: row.habit.color,
                icon: row.habit.icon,
                filled: true,
              ),
              title: Text(row.habit.name),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: row.stats.score,
                    minHeight: 6,
                    color: row.habit.color,
                    backgroundColor:
                        row.habit.color.withValues(alpha: 0.15),
                  ),
                ),
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$scorePct%',
                      style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: row.habit.color,
                      ),
                      Text(' ${row.stats.currentStreak}'),
                    ],
                  ),
                ],
              ),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => HabitDetailPage(habitId: row.habit.id),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _EmptyStatsView extends StatelessWidget {
  const _EmptyStatsView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights_outlined,
                size: 48,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin estadísticas todavía',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Creá un hábito y empezá a marcarlo para ver tu '
              'racha, score y consistencia general.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
