import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app/app.dart';
import 'app/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null);

  tzdata.initializeTimeZones();
  try {
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));
  } catch (_) {
    // Si falla la detección de tz, dejamos UTC como fallback.
  }

  await Injector.instance.appPreferences.load();
  await Injector.instance.notifications.init();
  // Reagenda recordatorios (cubre reboot + cambio de tz).
  unawaited(Injector.instance.rescheduleAllReminders());

  runApp(const HabitsApp());
}
