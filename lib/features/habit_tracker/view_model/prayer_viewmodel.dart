// lib/viewmodels/prayer_viewmodel.dart

import 'package:sukman/features/habit_tracker/bloc/prayer/prayer_bloc.dart';
import 'package:sukman/features/habit_tracker/bloc/prayer/prayer_event.dart';
import 'package:sukman/features/habit_tracker/model/prayer_day_model.dart';
import 'package:sukman/features/habit_tracker/model/prayer_status.dart';



class PrayerViewModel {
  final PrayerBloc _bloc;
  const PrayerViewModel(this._bloc);

  void selectDay(PrayerDay day)  => _bloc.add(SelectDayEvent(day));
  void clearSelectedDay()        => _bloc.add(const ClearSelectedDayEvent());

  void updatePrayerStatus({
    required DateTime gregorianDate,
    required int prayerIndex,
    required PrayerStatus status,
  }) {
    _bloc.add(UpdatePrayerStatusEvent(
      gregorianDate: gregorianDate,
      prayerIndex:   prayerIndex,
      status:        status,
    ));
  }

  void reset() => _bloc.add(const ResetEvent());
}