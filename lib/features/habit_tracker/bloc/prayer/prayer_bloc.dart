// lib/bloc/prayer_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sukman/features/habit_tracker/model/prayer_day_model.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  PrayerBloc({
    required Map<DateTime, PrayerDay> dayMap,
    required List<PrayerDay> seed,
  }) : super(PrayerState(week: seed, dayMap: dayMap)) {
    on<SelectDayEvent>(_onSelectDay);
    on<ClearSelectedDayEvent>(_onClearSelectedDay);
    on<UpdatePrayerStatusEvent>(_onUpdatePrayerStatus);
    on<ResetEvent>(_onReset);
  }

  void _onSelectDay(SelectDayEvent event, Emitter<PrayerState> emit) {
    emit(state.copyWith(
      selectedDay:       event.day,
      navigationTrigger: state.navigationTrigger + 1,
    ));
  }

  void _onClearSelectedDay(
      ClearSelectedDayEvent event, Emitter<PrayerState> emit) {
    emit(state.copyWith(clearSelectedDay: true));
  }

  void _onUpdatePrayerStatus(
    UpdatePrayerStatusEvent event,
    Emitter<PrayerState> emit,
  ) {
    // Update dayMap
    final updatedMap = Map<DateTime, PrayerDay>.from(state.dayMap);
    final key = DateTime(
      event.gregorianDate.year,
      event.gregorianDate.month,
      event.gregorianDate.day,
    );
    if (updatedMap.containsKey(key)) {
      updatedMap[key] =
          updatedMap[key]!.withUpdatedPrayer(event.prayerIndex, event.status);
    }

    // Also refresh selectedDay
    PrayerDay? updatedSelected = state.selectedDay;
    if (state.selectedDay != null) {
      final selKey = DateTime(
        state.selectedDay!.gregorianDate.year,
        state.selectedDay!.gregorianDate.month,
        state.selectedDay!.gregorianDate.day,
      );
      if (selKey == key) {
        updatedSelected = updatedMap[key];
      }
    }

    emit(state.copyWith(dayMap: updatedMap, selectedDay: updatedSelected));
  }

  void _onReset(ResetEvent event, Emitter<PrayerState> emit) {
    emit(state.copyWith(clearSelectedDay: true));
  }
}