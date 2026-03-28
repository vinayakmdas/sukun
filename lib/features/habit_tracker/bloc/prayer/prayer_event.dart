// lib/bloc/prayer_event.dart

import 'package:sukman/features/habit_tracker/model/prayer_day_model.dart';
import 'package:sukman/features/habit_tracker/model/prayer_status.dart';



abstract class PrayerEvent { const PrayerEvent(); }

class SelectDayEvent extends PrayerEvent {
  final PrayerDay day;
  const SelectDayEvent(this.day);
}

class ClearSelectedDayEvent extends PrayerEvent {
  const ClearSelectedDayEvent();
}

class UpdatePrayerStatusEvent extends PrayerEvent {
  final DateTime gregorianDate;   // ← DateTime key instead of ramadanDay int
  final int prayerIndex;
  final PrayerStatus status;

  const UpdatePrayerStatusEvent({
    required this.gregorianDate,
    required this.prayerIndex,
    required this.status,
  });
}

class ResetEvent extends PrayerEvent {
  const ResetEvent();
}