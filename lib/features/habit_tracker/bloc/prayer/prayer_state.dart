// lib/bloc/prayer_state.dart

import 'package:equatable/equatable.dart';
import 'package:sukman/features/habit_tracker/model/prayer_day_model.dart';

class PrayerState extends Equatable {
  final List<PrayerDay> week;           // BLoC seed list (today's entry)
  final Map<DateTime, PrayerDay> dayMap; // full Ramadan month — mutable copy
  final PrayerDay? selectedDay;
  final int navigationTrigger;

  const PrayerState({
    required this.week,
    required this.dayMap,
    this.selectedDay,
    this.navigationTrigger = 0,
  });

  PrayerState copyWith({
    List<PrayerDay>? week,
    Map<DateTime, PrayerDay>? dayMap,
    PrayerDay? selectedDay,
    bool clearSelectedDay = false,
    int? navigationTrigger,
  }) {
    return PrayerState(
      week:             week             ?? this.week,
      dayMap:           dayMap           ?? this.dayMap,
      selectedDay:      clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      navigationTrigger: navigationTrigger ?? this.navigationTrigger,
    );
  }

  @override
  List<Object?> get props => [week, dayMap, selectedDay, navigationTrigger];
}