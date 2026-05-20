import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../app/di/injector.dart';
import '../bloc/habit_insight_bloc.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.habitId,
    required this.habitColor,
  });

  final String habitId;
  final Color habitColor;

  @override
  Widget build(BuildContext context) {
    final injector = Injector.instance;
    return BlocProvider(
      create: (_) => HabitInsightBloc(
        coach: injector.coachRepository,
        generate: injector.generateHabitInsight,
      )..add(HabitInsightLoaded(habitId)),
      child: _InsightView(habitId: habitId, habitColor: habitColor),
    );
  }
}

class _InsightView extends StatelessWidget {
  const _InsightView({required this.habitId, required this.habitColor});
  final String habitId;
  final Color habitColor;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitInsightBloc, HabitInsightState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      builder: (context, state) {
        if (state.available == false) {
          return _NotAvailableBanner();
        }
        if (state.cached != null) {
          return _CachedView(
            insight: state.cached!,
            color: habitColor,
            loading: state.loading,
            onRegenerate: () => context
                .read<HabitInsightBloc>()
                .add(HabitInsightRequested(habitId)),
          );
        }
        if (state.loading) {
          return const _LoadingCard();
        }
        return _CtaCard(
          color: habitColor,
          onTap: () => context
              .read<HabitInsightBloc>()
              .add(HabitInsightRequested(habitId)),
        );
      },
    );
  }
}

class _NotAvailableBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Análisis IA no disponible en este dispositivo.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  const _CtaCard({required this.color, required this.onTap});
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_outlined, color: color),
                const SizedBox(width: 8),
                Text(
                  '¿Cómo viene este hábito?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Pedí un análisis con tu coach on-device. Te tira patrones y '
              'una sugerencia para mejorar la racha.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(backgroundColor: color),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Pedir análisis'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Skeletonizer(
          enabled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 14, width: 200, color: cs.onSurface),
              const SizedBox(height: 10),
              Container(height: 12, width: double.infinity, color: cs.onSurface),
              const SizedBox(height: 6),
              Container(height: 12, width: double.infinity, color: cs.onSurface),
              const SizedBox(height: 6),
              Container(height: 12, width: 260, color: cs.onSurface),
              const SizedBox(height: 6),
              Container(height: 12, width: 200, color: cs.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}

class _CachedView extends StatelessWidget {
  const _CachedView({
    required this.insight,
    required this.color,
    required this.loading,
    required this.onRegenerate,
  });

  final dynamic insight; // HabitInsight; dynamic para no leakear el tipo aquí
  final Color color;
  final bool loading;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final generatedFmt =
        DateFormat('d MMM, HH:mm', 'es_AR').format(insight.generatedAt);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Análisis del coach',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  generatedFmt,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            MarkdownBody(data: insight.text),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: loading ? null : onRegenerate,
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Regenerar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
