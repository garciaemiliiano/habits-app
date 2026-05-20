import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/di/injector.dart';
import '../../core/constants/gemini_limits.dart';
import '../../data/datasources/llm_usage_tracker.dart';
import '../../data/llm/gemini_cloud_provider.dart';
import '../../data/llm/gemini_nano_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Injector.instance.appPreferences;

    return AnimatedBuilder(
      animation: prefs,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Ajustes')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _ModelSection(),
              const SizedBox(height: 24),
              Text(
                'Tema',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Auto'),
                    icon: Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Claro'),
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Oscuro'),
                    icon: Icon(Icons.dark_mode),
                  ),
                ],
                selected: {prefs.themeMode},
                onSelectionChanged: (sel) => prefs.setThemeMode(sel.first),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Modo OLED'),
                subtitle: const Text(
                  'Fondo negro puro en oscuro (ahorra batería)',
                ),
                value: prefs.oled,
                onChanged: (v) => prefs.setOled(v),
              ),
              const SizedBox(height: 8),
              Text(
                'La semana empieza el',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('Lunes')),
                  ButtonSegment(value: 7, label: Text('Domingo')),
                ],
                selected: {prefs.weekStartsOn},
                onSelectionChanged: (sel) => prefs.setWeekStartsOn(sel.first),
              ),
              const SizedBox(height: 16),
              Text(
                'Rango de heatmap',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [3, 6, 12].map((m) {
                  return ChoiceChip(
                    label: Text('$m meses'),
                    selected: prefs.heatmapMonths == m,
                    onSelected: (_) => prefs.setHeatmapMonths(m),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final granted = await Injector.instance.notifications
                      .requestPermissions();
                  if (!granted && context.mounted) {
                    await openAppSettings();
                  }
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text('Permisos de notificaciones'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModelSection extends StatelessWidget {
  const _ModelSection();

  @override
  Widget build(BuildContext context) {
    final prefs = Injector.instance.appPreferences;
    final activeId = prefs.llmProviderId;
    final isCloud = activeId == GeminiCloudProvider.providerId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modelo del asistente',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: GeminiNanoProvider.providerId,
              label: Text('Nano'),
              icon: Icon(Icons.smartphone),
            ),
            ButtonSegment(
              value: GeminiCloudProvider.providerId,
              label: Text('Cloud'),
              icon: Icon(Icons.cloud),
            ),
          ],
          selected: {activeId},
          onSelectionChanged: (sel) => prefs.setLlmProviderId(sel.first),
        ),
        const SizedBox(height: 8),
        _AvailabilityLine(providerId: activeId),
        if (isCloud) ...[
          const SizedBox(height: 16),
          const _ApiKeyEditor(),
          const SizedBox(height: 16),
          const _CloudUsageCard(),
        ],
      ],
    );
  }
}

class _AvailabilityLine extends StatelessWidget {
  const _AvailabilityLine({required this.providerId});
  final String providerId;

  @override
  Widget build(BuildContext context) {
    final provider = Injector.instance.llmProviders
        .firstWhere((p) => p.id == providerId);
    return FutureBuilder<String>(
      future: provider.availabilityDetails(),
      builder: (context, snap) {
        final text = snap.data ?? '…';
        final cs = Theme.of(context).colorScheme;
        return Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ApiKeyEditor extends StatefulWidget {
  const _ApiKeyEditor();

  @override
  State<_ApiKeyEditor> createState() => _ApiKeyEditorState();
}

class _ApiKeyEditorState extends State<_ApiKeyEditor> {
  late final TextEditingController _controller =
      TextEditingController(text: Injector.instance.appPreferences.geminiApiKey ?? '');
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          obscureText: _obscure,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'API key de Gemini',
            hintText: 'AIza…',
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Pegar',
                  icon: const Icon(Icons.content_paste),
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    final text = data?.text?.trim();
                    if (text != null && text.isNotEmpty) {
                      _controller.text = text;
                      _controller.selection = TextSelection.collapsed(
                        offset: _controller.text.length,
                      );
                    }
                  },
                ),
                IconButton(
                  tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Generala en aistudio.google.com/apikey',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonal(
            onPressed: () async {
              final key = _controller.text.trim();
              await Injector.instance.appPreferences.setGeminiApiKey(
                key.isEmpty ? null : key,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API key guardada.')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ),
      ],
    );
  }
}

class _CloudUsageCard extends StatefulWidget {
  const _CloudUsageCard();

  @override
  State<_CloudUsageCard> createState() => _CloudUsageCardState();
}

class _CloudUsageCardState extends State<_CloudUsageCard> {
  Future<LlmUsageStats>? _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = Injector.instance.llmUsageTracker.stats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Uso de Gemini Cloud (free tier)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<LlmUsageStats>(
              future: _future,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(),
                  );
                }
                final s = snap.data!;
                return Column(
                  children: [
                    _UsageBar(
                      label: 'Último minuto',
                      used: s.last60s,
                      limit: GeminiFreeTierLimits.requestsPerMinute,
                    ),
                    const SizedBox(height: 10),
                    _UsageBar(
                      label: 'Hoy',
                      used: s.today,
                      limit: GeminiFreeTierLimits.requestsPerDay,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar({
    required this.label,
    required this.used,
    required this.limit,
  });

  final String label;
  final int used;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final ratio = limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    final cs = Theme.of(context).colorScheme;
    final color = ratio < 0.7
        ? cs.primary
        : (ratio < 0.9 ? cs.tertiary : cs.error);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              '$used / $limit',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}
