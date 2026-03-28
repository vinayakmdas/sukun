// ============================================================
// PRAYER TRACKER - Day Selection + Dot Mapping UI
// Architecture: BLoC + MVVM
// ============================================================

// ---------- MODELS ----------

// lib/models/prayer_day_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrayerDay {
  final int ramadanDay;
  final String gregorianDate;
  final String weekday;
  final List<PrayerDot> prayers;
  final bool isCurrent;

  const PrayerDay({
    required this.ramadanDay,
    required this.gregorianDate,
    required this.weekday,
    required this.prayers,
    this.isCurrent = false,
  });
}

class PrayerDot {
  final int index; // 1–5
  PrayerStatus status;

  PrayerDot({required this.index, this.status = PrayerStatus.unset});
}

enum PrayerStatus { unset, jamath, onTime, qadah, missed }

extension PrayerStatusExt on PrayerStatus {
  Color get color {
    switch (this) {
      case PrayerStatus.jamath:   return const Color(0xFF4CAF50);
      case PrayerStatus.onTime:   return const Color(0xFF2196F3);
      case PrayerStatus.qadah:    return const Color(0xFFFF9800);
      case PrayerStatus.missed:   return const Color(0xFFF44336);
      case PrayerStatus.unset:    return const Color(0xFFE0E0E0);
    }
  }

  String get label {
    switch (this) {
      case PrayerStatus.jamath:  return 'Jamath';
      case PrayerStatus.onTime:  return 'On Time';
      case PrayerStatus.qadah:   return 'Qadah';
      case PrayerStatus.missed:  return 'Missed';
      case PrayerStatus.unset:   return 'Unset';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerStatus.jamath:  return Icons.groups_rounded;
      case PrayerStatus.onTime:  return Icons.check_circle_rounded;
      case PrayerStatus.qadah:   return Icons.history_rounded;
      case PrayerStatus.missed:  return Icons.cancel_rounded;
      case PrayerStatus.unset:   return Icons.radio_button_unchecked;
    }
  }
}

// ---------- EVENTS ----------

// lib/bloc/prayer_event.dart
abstract class PrayerEvent {}

class SelectDayEvent extends PrayerEvent {
  final PrayerDay day;
  SelectDayEvent(this.day);
}

class SelectDotEvent extends PrayerEvent {
  final int dotIndex;
  SelectDotEvent(this.dotIndex);
}

class AssignStatusEvent extends PrayerEvent {
  final PrayerStatus status;
  AssignStatusEvent(this.status);
}

class NavigateToMappingEvent extends PrayerEvent {}

class ResetSelectionEvent extends PrayerEvent {}

// ---------- STATE ----------

// lib/bloc/prayer_state.dart
class PrayerState {
  final PrayerDay? selectedDay;
  final int? selectedDotIndex;
  final Map<int, PrayerStatus> dotMappings; // dotIndex → status
  final bool showMappingScreen;

  const PrayerState({
    this.selectedDay,
    this.selectedDotIndex,
    this.dotMappings = const {},
    this.showMappingScreen = false,
  });

  PrayerState copyWith({
    PrayerDay? selectedDay,
    int? selectedDotIndex,
    Map<int, PrayerStatus>? dotMappings,
    bool? showMappingScreen,
  }) {
    return PrayerState(
      selectedDay:       selectedDay       ?? this.selectedDay,
      selectedDotIndex:  selectedDotIndex,   // nullable reset allowed
      dotMappings:       dotMappings       ?? this.dotMappings,
      showMappingScreen: showMappingScreen ?? this.showMappingScreen,
    );
  }
}

// ---------- BLOC ----------

// lib/bloc/prayer_bloc.dart


class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  PrayerBloc() : super(const PrayerState()) {

    on<SelectDayEvent>((event, emit) {
      emit(state.copyWith(
        selectedDay: event.day,
        dotMappings: {},
        showMappingScreen: false,
      ));
    });

    on<SelectDotEvent>((event, emit) {
      emit(PrayerState(
        selectedDay:       state.selectedDay,
        selectedDotIndex:  event.dotIndex,
        dotMappings:       state.dotMappings,
        showMappingScreen: false,
      ));
    });

    on<AssignStatusEvent>((event, emit) {
      if (state.selectedDotIndex == null) return;
      final updated = Map<int, PrayerStatus>.from(state.dotMappings);
      updated[state.selectedDotIndex!] = event.status;
      emit(PrayerState(
        selectedDay:       state.selectedDay,
        selectedDotIndex:  null,
        dotMappings:       updated,
        showMappingScreen: false,
      ));
    });

    on<NavigateToMappingEvent>((event, emit) {
      emit(state.copyWith(showMappingScreen: true));
    });

    on<ResetSelectionEvent>((event, emit) {
      emit(const PrayerState());
    });
  }
}

// ---------- VIEWMODEL (ViewModel layer over BLoC) ----------

// lib/viewmodels/prayer_viewmodel.dart
class PrayerViewModel {
  final PrayerBloc bloc;

  PrayerViewModel(this.bloc);

  List<PrayerDay> get sampleWeek => [
    PrayerDay(ramadanDay: 1, gregorianDate: 'Mar 11', weekday: 'SUN',
      prayers: List.generate(5, (i) => PrayerDot(index: i + 1, status: PrayerStatus.jamath))),
    PrayerDay(ramadanDay: 2, gregorianDate: 'Mar 12', weekday: 'MON',
      prayers: [
        PrayerDot(index: 1, status: PrayerStatus.jamath),
        PrayerDot(index: 2, status: PrayerStatus.onTime),
        PrayerDot(index: 3, status: PrayerStatus.qadah),
        PrayerDot(index: 4, status: PrayerStatus.jamath),
        PrayerDot(index: 5, status: PrayerStatus.missed),
      ]),
    PrayerDay(ramadanDay: 3, gregorianDate: 'Mar 13', weekday: 'TUE', isCurrent: true,
      prayers: [
        PrayerDot(index: 1, status: PrayerStatus.jamath),
        PrayerDot(index: 2, status: PrayerStatus.onTime),
        PrayerDot(index: 3, status: PrayerStatus.qadah),
        PrayerDot(index: 4, status: PrayerStatus.unset),
        PrayerDot(index: 5, status: PrayerStatus.unset),
      ]),
    PrayerDay(ramadanDay: 4, gregorianDate: 'Mar 14', weekday: 'WED',
      prayers: List.generate(5, (i) => PrayerDot(index: i + 1))),
    PrayerDay(ramadanDay: 5, gregorianDate: 'Mar 15', weekday: 'THU',
      prayers: List.generate(5, (i) => PrayerDot(index: i + 1))),
  ];

  void selectDay(PrayerDay day)          => bloc.add(SelectDayEvent(day));
  void selectDot(int index)              => bloc.add(SelectDotEvent(index));
  void assignStatus(PrayerStatus status) => bloc.add(AssignStatusEvent(status));
  void goToMapping()                     => bloc.add(NavigateToMappingEvent());
  void reset()                           => bloc.add(ResetSelectionEvent());
}

// ============================================================
// UI SCREENS
// ============================================================

// lib/screens/prayer_calendar_screen.dart


class PrayerCalendarScreen extends StatelessWidget {
  const PrayerCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = PrayerViewModel(context.read<PrayerBloc>());

    return BlocConsumer<PrayerBloc, PrayerState>(
      listener: (context, state) {
        if (state.showMappingScreen && state.selectedDay != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<PrayerBloc>(),
                child: const PrayerMappingScreen(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F8F5),
          appBar: _buildAppBar(context),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRamadanHeader(),
              _buildStatusBar(state),
              _buildTabBar(),
              const SizedBox(height: 16),
              _buildLegend(),
              const SizedBox(height: 12),
              Expanded(
                child: _buildCalendarGrid(context, vm, state),
              ),
              if (state.selectedDay != null)
                _buildBottomAction(context, vm, state),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.star, color: Colors.white, size: 18),
        ),
      ),
      title: const Text('SUKUN',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 16,
          )),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE8F5E9),
            child: const Text('U', style: TextStyle(color: Color(0xFF4CAF50))),
          ),
        ),
      ],
    );
  }

  Widget _buildRamadanHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.chevron_left, color: Colors.black54),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ramadan 1447 AH',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text('March 2026',
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildStatusBar(PrayerState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ACTIVE STATUS',
                style: TextStyle(fontSize: 11, color: Colors.black45, letterSpacing: 1)),
            const Text('Day 12',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4CAF50))),
          ]),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Share Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTab('1. Farz Prayer', true),
          const SizedBox(width: 12),
          _buildTab('2. Sunnah Prayer', false),
          const SizedBox(width: 12),
          _buildTab('3. Qu...', false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: selected ? null : Border.all(color: Colors.black12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: PrayerStatus.values
            .where((s) => s != PrayerStatus.unset)
            .map((s) => Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                          color: s.color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(s.label.toUpperCase(),
                      style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
                ]))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(
      BuildContext context, PrayerViewModel vm, PrayerState state) {
    final days = vm.sampleWeek;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: days.map((day) {
          final isSelected = state.selectedDay?.ramadanDay == day.ramadanDay;
          return _DayColumn(
            day: day,
            isSelected: isSelected,
            dotMappings: isSelected ? state.dotMappings : {},
            selectedDotIndex: isSelected ? state.selectedDotIndex : null,
            onDayTap: () => vm.selectDay(day),
            onDotTap: (i) {
              vm.selectDay(day);
              vm.selectDot(i);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomAction(
      BuildContext context, PrayerViewModel vm, PrayerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              state.selectedDay != null
                  ? '${state.ramadanLabel} selected · ${state.dotMappings.length}/5 mapped'
                  : '',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () => vm.goToMapping(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Map Prayers →',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// Extension for convenience label
extension on PrayerState {
  String get ramadanLabel => selectedDay != null
      ? 'Ram ${selectedDay!.ramadanDay}'
      : '';
}

// ============================================================
// DAY COLUMN WIDGET
// ============================================================

class _DayColumn extends StatelessWidget {
  final PrayerDay day;
  final bool isSelected;
  final Map<int, PrayerStatus> dotMappings;
  final int? selectedDotIndex;
  final VoidCallback onDayTap;
  final void Function(int) onDotTap;

  const _DayColumn({
    required this.day,
    required this.isSelected,
    required this.dotMappings,
    required this.selectedDotIndex,
    required this.onDayTap,
    required this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDayTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(36),
          border: isSelected
              ? Border.all(color: const Color(0xFFFFD740), width: 2)
              : day.isCurrent
                  ? Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3), width: 1)
                  : null,
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black12, blurRadius: 8)]
              : null,
        ),
        child: Column(
          children: [
            Text(day.weekday,
                style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('${day.ramadanDay}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
                )),
            Text('Ram', style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF4CAF50) : Colors.black45)),
            Text(day.gregorianDate,
                style: const TextStyle(fontSize: 9, color: Colors.black38)),
            const SizedBox(height: 10),
            ...List.generate(5, (i) {
              final dotIdx = i + 1;
              final originalStatus = day.prayers.length > i
                  ? day.prayers[i].status
                  : PrayerStatus.unset;
              final mappedStatus = dotMappings[dotIdx];
              final displayStatus = mappedStatus ?? originalStatus;
              final isActiveDot = isSelected && selectedDotIndex == dotIdx;

              return GestureDetector(
                onTap: isSelected ? () => onDotTap(dotIdx) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: displayStatus == PrayerStatus.unset
                        ? const Color(0xFFE8F5E9).withOpacity(0.5)
                        : displayStatus.color,
                    shape: BoxShape.circle,
                    border: isActiveDot
                        ? Border.all(color: Colors.black, width: 2.5)
                        : displayStatus == PrayerStatus.unset
                            ? Border.all(color: Colors.black12, width: 1)
                            : null,
                    boxShadow: isActiveDot
                        ? [BoxShadow(color: Colors.black26, blurRadius: 6)]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dotIdx',
                      style: TextStyle(
                        color: displayStatus == PrayerStatus.unset
                            ? Colors.black38
                            : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (day.isCurrent)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('CURRENT',
                    style: TextStyle(fontSize: 8, color: Color(0xFF4CAF50), fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}




class PrayerMappingScreen extends StatelessWidget {
  const PrayerMappingScreen({super.key});

  static const List<String> _prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        final day = state.selectedDay;
        if (day == null) return const SizedBox.shrink();

        final vm = PrayerViewModel(context.read<PrayerBloc>());

        return Scaffold(
          backgroundColor: const Color(0xFFF4F8F5),
          appBar:AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
    onPressed: () => Navigator.pop(context),
  ),
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Map Prayers · Ram ${day.ramadanDay}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      Text(
        day.gregorianDate,
        style: const TextStyle(
          color: Colors.black45,
          fontSize: 12,
        ),
      ),
    ],
  ),
),
body: Column(
            children: [
              _buildProgress(state),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final dotIdx = i + 1;
                    final currentStatus =
                        state.dotMappings[dotIdx] ?? day.prayers[i].status;
                    return _PrayerMappingCard(
                      dotIndex: dotIdx,
                      prayerName: _prayerNames[i],
                      currentStatus: currentStatus,
                      isSelectedDot: state.selectedDotIndex == dotIdx,
                      onDotTap: () => vm.selectDot(dotIdx),
                      onStatusTap: (s) {
                        vm.selectDot(dotIdx);
                        vm.assignStatus(s); 
                      },
                    );
                  },
                ),
              ),
              _buildSaveButton(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgress(PrayerState state) {
    final mapped = state.dotMappings.length;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Text('$mapped/5 prayers mapped',
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const Spacer(),
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: mapped / 5,
                backgroundColor: const Color(0xFFE0E0E0),
                color: const Color(0xFF4CAF50),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, PrayerState state) {
    final allMapped = state.dotMappings.length == 5;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: allMapped ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Prayer mappings saved! ✓'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
            Navigator.pop(context);
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            disabledBackgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            allMapped ? 'Save All Mappings ✓' : 'Map all 5 prayers to save',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRAYER MAPPING CARD
// ============================================================

class _PrayerMappingCard extends StatelessWidget {
  final int dotIndex;
  final String prayerName;
  final PrayerStatus currentStatus;
  final bool isSelectedDot;
  final VoidCallback onDotTap;
  final void Function(PrayerStatus) onStatusTap;

  const _PrayerMappingCard({
    required this.dotIndex,
    required this.prayerName,
    required this.currentStatus,
    required this.isSelectedDot,
    required this.onDotTap,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelectedDot
            ? Border.all(color: const Color(0xFF4CAF50), width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: isSelectedDot
                ? const Color(0xFF4CAF50).withOpacity(0.15)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                GestureDetector(
                  onTap: onDotTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: currentStatus.color,
                      shape: BoxShape.circle,
                      border: isSelectedDot
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dotIndex',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prayerName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Row(children: [
                      Icon(currentStatus.icon, size: 14, color: currentStatus.color),
                      const SizedBox(width: 4),
                      Text(currentStatus.label,
                          style: TextStyle(
                              fontSize: 12, color: currentStatus.color, fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Status options row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: PrayerStatus.values
                  .where((s) => s != PrayerStatus.unset)
                  .map((s) => _StatusOption(
                        status: s,
                        isSelected: currentStatus == s,
                        onTap: () => onStatusTap(s),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final PrayerStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? status.color : status.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: status.color, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(status.icon,
                size: 20,
                color: isSelected ? Colors.white : status.color),
            const SizedBox(height: 2),
            Text(status.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : status.color,
                )),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAIN + DEPENDENCY INJECTION
// ============================================================

// lib/main.dart
