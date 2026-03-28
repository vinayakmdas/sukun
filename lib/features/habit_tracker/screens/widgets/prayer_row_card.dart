// lib/screens/widgets/prayer_row_card.dart

import 'package:flutter/material.dart';
import 'package:sukman/core/theme/app_colors.dart';
import 'package:sukman/features/habit_tracker/model/prayer_status.dart';

import 'status_badge.dart';

class PrayerRowCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final PrayerStatus status;
  final VoidCallback onEditTap;

  const PrayerRowCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.status,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: status.rowBorderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prayerName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(prayerTime,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          StatusBadge(status: status),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.edit_rounded,
                  size: 14, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.border, size: 18),
        ],
      ),
    );
  }
}