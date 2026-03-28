// lib/screens/detail/day_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sukman/core/theme/app_colors.dart';
import 'package:sukman/features/habit_tracker/bloc/prayer/prayer_bloc.dart';
import 'package:sukman/features/habit_tracker/bloc/prayer/prayer_state.dart';
import 'package:sukman/features/habit_tracker/model/prayer_day_model.dart';
import 'package:sukman/features/habit_tracker/view_model/prayer_viewmodel.dart';

import '../widgets/prayer_row_card.dart';
import '../widgets/update_prayer_modal.dart';

class DayDetailScreen extends StatelessWidget {
  const DayDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        final day = state.selectedDay;
        if (day == null) return const SizedBox.shrink();

        final vm = PrayerViewModel(context.read<PrayerBloc>());

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, day),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildHeroHeader(day),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildProgressCard(day),
                      const SizedBox(height: 10),
                      _buildStreakCard(),
                      const SizedBox(height: 24),
                      _buildPrayerSection(context, vm, day),
                      const SizedBox(height: 16),
                      _buildQuranCard(),
                      const SizedBox(height: 10),
                      _buildSadaqahCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, PrayerDay day) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'RAMADAN 1447  ›  DAY ${day.ramadanDay} DETAILS',
        style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildHeroHeader(PrayerDay day) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${day.ramadanDay} Ramadan 1447',
              style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.1)),
          const SizedBox(height: 4),
          Text(day.fullDateString,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _ActionButton(
                      label: 'Share Day',
                      icon: Icons.share_rounded,
                      filled: true,
                      onTap: () {})),
              const SizedBox(width: 12),
              Expanded(
                  child: _ActionButton(
                      label: 'Edit Log',
                      icon: Icons.edit_rounded,
                      filled: false,
                      onTap: () {})),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(PrayerDay day) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DAILY PRAYER PROGRESS',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${day.progressPercent}%',
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
              const Spacer(),
              const Text('🧍', style: TextStyle(fontSize: 28)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: day.progress,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: const Text('🔥', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('12 Days Consistent',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              Text('Spiritual Streak',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerSection(
      BuildContext context, PrayerViewModel vm, PrayerDay day) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Farz Prayers',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            Text('VIEW ALL',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(5, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PrayerRowCard(
              prayerName: kPrayerNames[i],
              prayerTime: kPrayerTimes[i],
              status: day.prayers[i],
              onEditTap: () => _openEditModal(context, vm, day, i),
            ),
          );
        }),
      ],
    );
  }

  void _openEditModal(BuildContext context, PrayerViewModel vm,
      PrayerDay day, int prayerIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => UpdatePrayerModal(
        prayerIndex: prayerIndex,
        currentStatus: day.prayers[prayerIndex],
        dayLabel: '${day.ramadanDay} Ramadan 1447 / ${day.shortDate}',
        onSave: (newStatus) {
          vm.updatePrayerStatus(
            gregorianDate: day.gregorianDate,
            prayerIndex:   prayerIndex,
            status:        newStatus,
          );
        },
      ),
    );
  }

  Widget _buildQuranCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📖  DAILY QUR'AN",
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1)),
                SizedBox(height: 4),
                Text('Juz 12 • Surah Hud',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                SizedBox(height: 3),
                Text(
                    'Continue your reflection on the stories of the Prophets.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSadaqahCard() {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: const Text('💝', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sadaqah',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text('Daily contribution logged',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded,
              color: AppColors.primary, size: 24),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      ('🏠', 'Dashboard', true),
      ('📅', 'Calendar',  false),
      ('📖', "Qur'an",    false),
      ('✨', 'Dua',       false),
    ];
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: items.map((item) {
              final (emoji, label, active) = item;
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
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

// ─── Private sub-widgets ─────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: filled ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: filled
                        ? Colors.white
                        : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}