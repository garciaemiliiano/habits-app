import 'package:flutter/material.dart';

import '../coach/coach_page.dart';
import '../habits/habits_page.dart';
import '../settings/settings_page.dart';
import '../today/today_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// Permite a otras pantallas saltar a una tab (ej. Today → Coach con
  /// un prompt prellenado). El shell escucha este notifier y rebuildea.
  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Stats temporalmente oculta — se rehabilita agregándola al array.
  static const _tabs = <_TabSpec>[
    _TabSpec(label: 'Hoy', icon: Icons.today_outlined, selected: Icons.today),
    _TabSpec(
      label: 'Hábitos',
      icon: Icons.list_alt_outlined,
      selected: Icons.list_alt,
    ),
    _TabSpec(
      label: 'Coach',
      icon: Icons.auto_awesome_outlined,
      selected: Icons.auto_awesome,
    ),
    _TabSpec(
      label: 'Ajustes',
      icon: Icons.tune_outlined,
      selected: Icons.tune,
    ),
  ];

  static const _pages = <Widget>[
    TodayPage(),
    HabitsPage(),
    CoachPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: MainShell.tabIndex,
      builder: (context, index, _) {
        return Scaffold(
          body: IndexedStack(index: index, children: _pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => MainShell.tabIndex.value = i,
            destinations: _tabs
                .map((t) => NavigationDestination(
                      icon: Icon(t.icon),
                      selectedIcon: Icon(t.selected),
                      label: t.label,
                    ))
                .toList(growable: false),
          ),
        );
      },
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.label,
    required this.icon,
    required this.selected,
  });
  final String label;
  final IconData icon;
  final IconData selected;
}
