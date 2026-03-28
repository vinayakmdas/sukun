// lib/models/prayer_day_model.dart
//
// Every day of the year has prayer data.
// Uses hijri package ONLY to label Ramadan days with their Ramadan number.
// Non-Ramadan days have ramadanDay = 0.
// Future days (after today) = unset and NOT tappable.
// Past + today = tappable and editable.

import 'package:hijri/hijri_calendar.dart';

import 'prayer_status.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class PrayerDay {
  final int ramadanDay;         // 1–30 if Ramadan, else 0
  final DateTime gregorianDate; // time-zeroed DateTime
  final bool isCurrent;         // true only for today
  final List<PrayerStatus> prayers; // 0=Fajr … 4=Isha

  const PrayerDay({
    required this.ramadanDay,
    required this.gregorianDate,
    required this.prayers,
    this.isCurrent = false,
  });

  // ── Display helpers ──────────────────────────────────────────────────────

  bool get isRamadan => ramadanDay > 0;

  /// "Mar 25"
  String get shortDate {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[gregorianDate.month - 1]} ${gregorianDate.day}';
  }

  /// "Wednesday, March 25, 2026"
  String get fullDateString {
    const wd = ['Monday','Tuesday','Wednesday','Thursday',
                 'Friday','Saturday','Sunday'];
    const mo = ['January','February','March','April','May','June',
                 'July','August','September','October','November','December'];
    return '${wd[gregorianDate.weekday - 1]}, '
           '${mo[gregorianDate.month - 1]} '
           '${gregorianDate.day}, ${gregorianDate.year}';
  }

  /// "WED"
  String get weekdayShort {
    const n = ['MON','TUE','WED','THU','FRI','SAT','SUN'];
    return n[gregorianDate.weekday - 1];
  }

  // ── Mutation ─────────────────────────────────────────────────────────────

  PrayerDay withUpdatedPrayer(int index, PrayerStatus status) {
    final updated = List<PrayerStatus>.from(prayers);
    updated[index] = status;
    return PrayerDay(
      ramadanDay:    ramadanDay,
      gregorianDate: gregorianDate,
      prayers:       updated,
      isCurrent:     isCurrent,
    );
  }

  // ── Progress ─────────────────────────────────────────────────────────────

  int    get mappedCount     => prayers.where((p) => p != PrayerStatus.unset).length;
  double get progress        => mappedCount / prayers.length;
  int    get progressPercent => (progress * 100).round();
}

// ─── Constants ────────────────────────────────────────────────────────────────

const List<String> kPrayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
const List<String> kPrayerTimes = ['05:12 AM', '12:34 PM', '03:58 PM', '06:42 PM', '08:05 PM'];

// ─── Build FULL YEAR map ──────────────────────────────────────────────────────
//
// Every day Jan 1 – Dec 31 gets a PrayerDay entry.
// hijri package is used to detect Ramadan days and assign ramadanDay number.
// Past days get seeded prayer data. Today = partial. Future = all unset.

Map<DateTime, PrayerDay> buildFullYearMap({
  required int hijriYear,
  required DateTime today,
}) {
  final todayNorm  = DateTime(today.year, today.month, today.day);
  final map        = <DateTime, PrayerDay>{};
  int   ramadanDay = 0;

  final scanStart = DateTime(today.year, 1, 1);
  final scanEnd   = DateTime(today.year, 12, 31);

  for (var d = scanStart;
       !d.isAfter(scanEnd);
       d = d.add(const Duration(days: 1))) {

    final key     = DateTime(d.year, d.month, d.day);
    final hijri   = HijriCalendar.fromDate(d);
    final isToday = key == todayNorm;
    final isPast  = key.isBefore(todayNorm);

    // Check if this day is in Ramadan for the given Hijri year
    final isRamadanDay =
        hijri.hYear == hijriYear && hijri.hMonth == 9;

    if (isRamadanDay) ramadanDay++;

    map[key] = PrayerDay(
      ramadanDay:    isRamadanDay ? ramadanDay : 0,
      gregorianDate: key,
      isCurrent:     isToday,
      prayers:       _seedPrayers(key, isToday, isPast),
    );
  }

  return map;
}

/// Seed prayer data:
/// - Future → all unset (not editable)
/// - Today  → partially done
/// - Past   → varied realistic data based on date
List<PrayerStatus> _seedPrayers(
    DateTime date, bool isToday, bool isPast) {
  if (isToday) {
    return [
      PrayerStatus.jamath,
      PrayerStatus.jamath,
      PrayerStatus.unset,
      PrayerStatus.unset,
      PrayerStatus.unset,
    ];
  }
  if (!isPast) {
    // Future — all unset, locked
    return List.filled(5, PrayerStatus.unset);
  }

  // Past — deterministic variety from date number
  const pool = [
    PrayerStatus.jamath,
    PrayerStatus.jamath,
    PrayerStatus.jamath,
    PrayerStatus.onTime,
    PrayerStatus.qadah,
    PrayerStatus.missed,
  ];
  final seed = date.day + date.month * 31;
  return List.generate(5, (i) => pool[(seed * 7 + i * 13) % pool.length]);
}

// ─── BLoC seed ────────────────────────────────────────────────────────────────

/// Returns today's PrayerDay as the initial BLoC seed.
List<PrayerDay> buildSampleWeek(
    Map<DateTime, PrayerDay> map, DateTime today) {
  final key = DateTime(today.year, today.month, today.day);
  final day = map[key];
  return day != null ? [day] : [];
}

// ─── Keep old name as alias so nothing else breaks ────────────────────────────
Map<DateTime, PrayerDay> buildRamadanMap({
  required int hijriYear,
  required DateTime today,
}) => buildFullYearMap(hijriYear: hijriYear, today: today);