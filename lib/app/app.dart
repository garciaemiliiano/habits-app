import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/coach/bloc/coach_bloc.dart';
import '../presentation/habits/bloc/habits_bloc.dart';
import '../presentation/shell/main_shell.dart';
import '../presentation/stats/bloc/stats_bloc.dart';
import '../presentation/today/bloc/today_bloc.dart';
import 'di/injector.dart';
import 'preferences/app_preferences.dart';
import 'theme/app_theme.dart';

class HabitsApp extends StatefulWidget {
  const HabitsApp({super.key});

  @override
  State<HabitsApp> createState() => _HabitsAppState();
}

class _HabitsAppState extends State<HabitsApp> {
  late final AppPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = Injector.instance.appPreferences;
    _prefs.load();
  }

  @override
  Widget build(BuildContext context) {
    final injector = Injector.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TodayBloc(
            getHabitsForToday: injector.getHabitsForToday,
            toggleCompletion: injector.toggleCompletion,
          )..add(const TodayLoadRequested()),
        ),
        BlocProvider(
          create: (_) => HabitsBloc(
            getAllHabits: injector.getAllHabits,
            archiveHabit: injector.archiveHabit,
            deleteHabit: injector.deleteHabit,
            reorderHabits: injector.reorderHabits,
          )..add(const HabitsLoadRequested()),
        ),
        BlocProvider(
          create: (_) => StatsBloc(
            getOverallStats: injector.getOverallStats,
          )..add(const StatsLoadRequested()),
        ),
        BlocProvider(
          create: (_) => CoachBloc(
            coach: injector.coachRepository,
            buildContext: injector.buildHabitsContext,
          )..add(const CoachAvailabilityChecked()),
        ),
      ],
      child: AnimatedBuilder(
        animation: _prefs,
        builder: (context, _) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              final light = AppTheme.light(lightDynamic?.harmonized());
              final dark = _prefs.oled
                  ? AppTheme.oled(darkDynamic?.harmonized())
                  : AppTheme.dark(darkDynamic?.harmonized());
              return MaterialApp(
                navigatorKey: injector.rootNavigator,
                title: 'Hábitos',
                theme: light,
                darkTheme: dark,
                themeMode: _prefs.materialThemeMode,
                home: const MainShell(),
              );
            },
          );
        },
      ),
    );
  }
}
