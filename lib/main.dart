// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sukman/features/habit_tracker/bloc/prayer/prayer_bloc.dart';
import 'package:sukman/features/habit_tracker/model/prayer_day_model.dart';
import 'package:sukman/features/habit_tracker/screens/calender/prayer_calendar_screen.dart';

void main() {
  final today = DateTime.now();
  final dayMap = buildRamadanMap(hijriYear: 1447, today: today);
  final seed = buildSampleWeek(dayMap, today);

  runApp(SukunApp(dayMap: dayMap, seed: seed));
}

class SukunApp extends StatelessWidget {
  final Map<DateTime, PrayerDay> dayMap;
  final List<PrayerDay> seed;

  const SukunApp({
    super.key,
    required this.dayMap,
    required this.seed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PrayerBloc(dayMap: dayMap, seed: seed),
      child: MaterialApp(
        title: 'Sukun — Prayer Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF22C55E),
        ),
        home: const PrayerCalendarScreen(),
      ),
    );
  }
}