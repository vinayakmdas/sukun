// lib/screens/widgets/day_column_widget.dart

import 'package:flutter/material.dart';
import 'package:sukman/core/theme/app_colors.dart';
import 'package:sukman/features/habit_tracker/model/prayer_day_model.dart';
import 'package:sukman/features/habit_tracker/model/prayer_status.dart';


class DayColumnWidget extends StatelessWidget {
  final PrayerDay day;
  final bool isSelected;
  final VoidCallback onTap;

  const DayColumnWidget({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(36),
          border: isSelected
              ? Border.all(color: AppColors.accent, width: 2)
              : day.isCurrent
                  ? Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5)
                  : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(day.weekdayShort,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              '${day.ramadanDay}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            Text('Ram',
                style: TextStyle(
                    fontSize: 9,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textMuted)),
            Text(day.shortDate,
                style: const TextStyle(
                    fontSize: 8, color: AppColors.border)),
            const SizedBox(height: 10),
            ...List.generate(
                5, (i) => _PrayerDot(number: i + 1, status: day.prayers[i])),
            if (day.isCurrent)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('TODAY',
                    style: const TextStyle(
                        fontSize: 7,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4)),
              ),
          ],
        ),
      ),
    );
  }
}

class _PrayerDot extends StatelessWidget {
  final int number;
  final PrayerStatus status;
  const _PrayerDot({required this.number, required this.status});

  @override
  Widget build(BuildContext context) {
    final isUnset = status == PrayerStatus.unset;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 34,
      height: 34,
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUnset
            ? AppColors.primaryLight.withOpacity(0.5)
            : status.color,
        border: isUnset ? Border.all(color: AppColors.border) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isUnset ? AppColors.textMuted : Colors.white,
        ),
      ),
    );
  }
}