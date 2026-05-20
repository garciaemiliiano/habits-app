import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/di/injector.dart';

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
