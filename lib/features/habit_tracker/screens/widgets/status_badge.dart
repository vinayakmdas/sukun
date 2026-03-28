// lib/screens/widgets/status_badge.dart

import 'package:flutter/material.dart';
import 'package:sukman/features/habit_tracker/model/prayer_status.dart';

class StatusBadge extends StatelessWidget {
  final PrayerStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 13, color: status.color),
          const SizedBox(width: 5),
          Text(
            status.badgeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: status.color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}