// lib/screens/calendar/prayer_calendar_screen.dart
//
// RULES:

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sukman/features/habit_tracker/screens/details/day_detail_screen.dart';
import 'package:sukman/features/habit_tracker/screens/widgets/comming_soon_widget.dart';
import 'package:sukman/features/habit_tracker/view_model/prayer_viewmodel.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:sukman/core/theme/app_colors.dart';
import 'package:sukman/features/habit_tracker/bloc/prayer/prayer_bloc.dart';
import 'package:sukman/features/habit_tracker/bloc/prayer/prayer_state.dart';
import 'package:sukman/features/habit_tracker/model/prayer_day_model.dart';
import 'package:sukman/features/habit_tracker/model/prayer_status.dart';


// ─── Tabs ─────────────────────────────────────────────────────────────────────

const List<String> kTabLabels = [
  'Farz Prayer', 'Sunnah Prayer', 'Quran',
  'Fasting', 'Dhikr & Dua', 'Charity', 'Other Habit',
];
const List<String> kTabEmojis = ['🕌','🌙','📖','🌅','📿','💝','⭐'];

// ─── Screen ───────────────────────────────────────────────────────────────────

class PrayerCalendarScreen extends StatefulWidget {
  const PrayerCalendarScreen({super.key});

  @override
  State<PrayerCalendarScreen> createState() => _PrayerCalendarScreenState();
}

class _PrayerCalendarScreenState extends State<PrayerCalendarScreen> {
  int       _activeTab  = 0;
  DateTime  _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // today with no time component — single source of truth
  final DateTime _today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    final vm = PrayerViewModel(context.read<PrayerBloc>());

    return BlocListener<PrayerBloc, PrayerState>(
      // Navigate whenever navigationTrigger increments (same-day re-tap fix)
      listenWhen: (prev, curr) =>
          curr.navigationTrigger != prev.navigationTrigger &&
          curr.selectedDay != null,
      listener: (context, state) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<PrayerBloc>(),
              child: const DayDetailScreen(),
            ),
          ),
        ).then((_) {
          vm.clearSelectedDay();
          setState(() => _selectedDay = null);
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: BlocBuilder<PrayerBloc, PrayerState>(
          builder: (context, state) {
            final todayEntry   = state.dayMap[_today];
            final todayRamadan = todayEntry?.ramadanDay ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRamadanHeader(),
                _buildStatusBar(todayRamadan),
                _buildTabBar(),
                Expanded(
                  child: _activeTab == 0
                      ? _buildFarzContent(vm, state)
                      : ComingSoonTab(
                          tabName: kTabLabels[_activeTab],
                          emoji:   kTabEmojis[_activeTab],
                        ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(Icons.star_rounded,
              color: Colors.white, size: 16),
        ),
      ),
      title: const Text('SUKUN',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 16)),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: const Text('U',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  // ── Ramadan header ─────────────────────────────────────────────────────────

  Widget _buildRamadanHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: const Row(
        children: [
          Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ramadan 1447 AH',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary)),
                Text('Ramadan Prayer Tracker',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  // ── Status bar ─────────────────────────────────────────────────────────────

  Widget _buildStatusBar(int ramadanDay) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ACTIVE STATUS',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text(
                ramadanDay > 0 ? 'Day $ramadanDay' : '—',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share_rounded, size: 15),
            label: const Text('Share Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(kTabLabels.length, (i) {
            final selected = _activeTab == i;
            return GestureDetector(
              onTap: () => setState(() => _activeTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8, top: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.textPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: selected
                      ? null
                      : Border.all(
                          color: AppColors.border, width: 1.5),
                ),
                child: Text(
                  '${i + 1}. ${kTabLabels[i]}',
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Farz content ───────────────────────────────────────────────────────────

  Widget _buildFarzContent(PrayerViewModel vm, PrayerState state) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildLegend(),
        const SizedBox(height: 4),
        // Info hint
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 4),
          child: Row(
            children: const [
              Icon(Icons.info_outline_rounded,
                  size: 13, color: AppColors.textMuted),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Tap any past or today\'s date to log prayers  •  Future dates are locked 🔒',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: SingleChildScrollView(
            child: _buildTableCalendar(vm, state),
          ),
        ),
      ],
    );
  }

  // ── Legend ─────────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    const items = [
      (AppColors.jamath, 'JAMATH'),
      (AppColors.onTime, 'ON TIME'),
      (AppColors.qadah,  'QADAH'),
      (AppColors.missed, 'MISSED'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: items.map((item) {
          final (color, label) = item;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── TableCalendar ──────────────────────────────────────────────────────────

  Widget _buildTableCalendar(PrayerViewModel vm, PrayerState state) {
    final year     = _today.year;
    final firstDay = DateTime(year, 1, 1);
    final lastDay  = DateTime(year, 12, 31);

    return TableCalendar(
      firstDay:   firstDay,
      lastDay:    lastDay,
      focusedDay: _focusedDay,

      selectedDayPredicate: (day) =>
          _selectedDay != null && isSameDay(_selectedDay, day),

      onDaySelected: (selectedDay, focusedDay) {
        final key = DateTime(
            selectedDay.year, selectedDay.month, selectedDay.day);

        // ✅ BLOCK future dates — cannot log prayers for tomorrow onwards
        if (key.isAfter(_today)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.lock_rounded,
                      color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text("Future dates can't be logged yet 🔒"),
                ],
              ),
              backgroundColor: AppColors.textSecondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        // ✅ ALL past + today dates are tappable
        final prayerDay = state.dayMap[key];
        if (prayerDay == null) return;

        setState(() {
          _selectedDay = selectedDay;
          _focusedDay  = focusedDay;
        });
        vm.selectDay(prayerDay);
      },

      onPageChanged: (focusedDay) =>
          setState(() => _focusedDay = focusedDay),

      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month'
      },
      startingDayOfWeek: StartingDayOfWeek.sunday,

      // ── Header
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered:       true,
        titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary),
        leftChevronIcon: Icon(Icons.chevron_left_rounded,
            color: AppColors.primary, size: 26),
        rightChevronIcon: Icon(Icons.chevron_right_rounded,
            color: AppColors.primary, size: 26),
        headerPadding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface),
      ),

      // ── Days of week
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 13),
        weekendStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13),
      ),

      // ── Base style (all decoration handled in builders)
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        tablePadding: EdgeInsets.symmetric(horizontal: 8),
        cellMargin:   EdgeInsets.all(3),
        defaultDecoration:
            BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
        weekendDecoration:
            BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
        todayDecoration:
            BoxDecoration(color: Colors.transparent),
        selectedDecoration:
            BoxDecoration(color: Colors.transparent),
        defaultTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14),
        weekendTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14),
      ),

      // ── Custom builders for every cell type
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (ctx, day, _) =>
            _DayCell(day: day, dayMap: state.dayMap, today: _today),
        todayBuilder: (ctx, day, _) =>
            _DayCell(day: day, dayMap: state.dayMap,
                today: _today, isToday: true),
        selectedBuilder: (ctx, day, _) =>
            _DayCell(day: day, dayMap: state.dayMap,
                today: _today, isSelected: true),
        outsideBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    const items = [
      (Icons.dashboard_rounded,      'Dashboard', false),
      (Icons.calendar_month_rounded, 'Calendar',  true),
      (Icons.menu_book_rounded,      "Qur'an",    false),
      (Icons.auto_awesome_rounded,   'Dua',       false),
    ];
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: items.map((item) {
              final (icon, label, active) = item;
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: 22,
                        color: active
                            ? AppColors.primary
                            : AppColors.textMuted),
                    const SizedBox(height: 3),
                    Text(label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? AppColors.primary
                                : AppColors.textMuted)),
                    if (active)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Day Cell ─────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime day;
  final Map<DateTime, PrayerDay> dayMap;
  final DateTime today;
  final bool isToday;
  final bool isSelected;

  const _DayCell({
    required this.day,
    required this.dayMap,
    required this.today,
    this.isToday    = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final key       = DateTime(day.year, day.month, day.day);
    final prayerDay = dayMap[key];
    final isFuture  = key.isAfter(today);
    final prayers   = prayerDay?.prayers ?? List.filled(5, PrayerStatus.unset);
    final allUnset  = prayers.every((p) => p == PrayerStatus.unset);
    final isRamadan = prayerDay?.isRamadan ?? false;

    // ── Visual rules ─────────────────────────────────────────────────
    // Today            → solid green circle, white text
    // Selected past    → light green bg + gold border
    // Past non-today   → subtle green border
    // Future           → faded text + tiny lock
    // Ramadan days     → small crescent badge on top-right

    Color   bgColor   = Colors.transparent;
    Color   textColor = isFuture
        ? AppColors.textMuted.withOpacity(0.4)
        : AppColors.textPrimary;
    Border? border;

    if (isToday) {
      bgColor   = AppColors.primary;
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor   = AppColors.primaryLight;
      textColor = AppColors.primary;
      border    = Border.all(color: AppColors.accent, width: 2.5);
    } else if (!isFuture) {
      // Past day — subtle border to show it's tappable
      border = Border.all(
          color: AppColors.primary.withOpacity(0.18), width: 1);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Main cell column ────────────────────────────────────────
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Number circle
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color:  bgColor,
                shape:  BoxShape.circle,
                border: border,
              ),
              alignment: Alignment.center,
              child: isFuture
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${day.day}',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                        const Icon(Icons.lock_rounded,
                            size: 7,
                            color: AppColors.textMuted),
                      ],
                    )
                  : Text(
                      '${day.day}',
                      style: TextStyle(
                        color:      textColor,
                        fontWeight: FontWeight.w800,
                        fontSize:   14,
                      ),
                    ),
            ),

            const SizedBox(height: 3),

            // 5 prayer status dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final status = i < prayers.length
                    ? prayers[i]
                    : PrayerStatus.unset;
                return Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 0.8),
                  decoration: BoxDecoration(
                    color: (allUnset || isFuture)
                        ? AppColors.border
                        : _dotColor(status),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),

        // ── Ramadan crescent badge (top-right corner) ───────────────
        if (isRamadan && !isFuture)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('☽',
                  style: TextStyle(fontSize: 7, color: Colors.white)),
            ),
          ),

        // Future Ramadan badge
        if (isRamadan && isFuture)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Color _dotColor(PrayerStatus s) {
    switch (s) {
      case PrayerStatus.jamath:    return AppColors.jamath;
      case PrayerStatus.onTime:    return AppColors.onTime;
      case PrayerStatus.qadah:     return AppColors.qadah;
      case PrayerStatus.missed:    return AppColors.missed;
      case PrayerStatus.exemption: return AppColors.exemption;
      case PrayerStatus.unset:     return AppColors.border;
    }
  }
}