// lib/models/prayer_status.dart

import 'package:flutter/material.dart';
import 'package:sukman/core/theme/app_colors.dart';

enum PrayerStatus { jamath, onTime, qadah, missed, exemption, unset }

extension PrayerStatusExt on PrayerStatus {
  Color get color {
    switch (this) {
      case PrayerStatus.jamath:    return AppColors.jamath;
      case PrayerStatus.onTime:    return AppColors.onTime;
      case PrayerStatus.qadah:     return AppColors.qadah;
      case PrayerStatus.missed:    return AppColors.missed;
      case PrayerStatus.exemption: return AppColors.exemption;
      case PrayerStatus.unset:     return AppColors.unset;
    }
  }

  Color get bgColor {
    switch (this) {
      case PrayerStatus.jamath:    return AppColors.jamathBg;
      case PrayerStatus.onTime:    return AppColors.onTimeBg;
      case PrayerStatus.qadah:     return AppColors.qadahBg;
      case PrayerStatus.missed:    return AppColors.missedBg;
      case PrayerStatus.exemption: return AppColors.exemptionBg;
      case PrayerStatus.unset:     return AppColors.unsetBg;
    }
  }

  String get label {
    switch (this) {
      case PrayerStatus.jamath:    return 'JAMATH';
      case PrayerStatus.onTime:    return 'ON TIME';
      case PrayerStatus.qadah:     return 'QADAH';
      case PrayerStatus.missed:    return 'MISSED';
      case PrayerStatus.exemption: return 'EXEMPTION';
      case PrayerStatus.unset:     return 'PENDING';
    }
  }

  String get badgeText {
    switch (this) {
      case PrayerStatus.jamath:    return 'COMPLETED';
      case PrayerStatus.onTime:    return 'ON TIME';
      case PrayerStatus.qadah:     return 'PRAYED LATE';
      case PrayerStatus.missed:    return 'MISSED';
      case PrayerStatus.exemption: return 'EXEMPT';
      case PrayerStatus.unset:     return 'PENDING';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerStatus.jamath:    return Icons.groups_rounded;
      case PrayerStatus.onTime:    return Icons.check_circle_rounded;
      case PrayerStatus.qadah:     return Icons.history_rounded;
      case PrayerStatus.missed:    return Icons.cancel_rounded;
      case PrayerStatus.exemption: return Icons.shield_rounded;
      case PrayerStatus.unset:     return Icons.radio_button_unchecked;
    }
  }

  String get emoji {
    switch (this) {
      case PrayerStatus.jamath:    return '👥';
      case PrayerStatus.onTime:    return '✅';
      case PrayerStatus.qadah:     return '⏱';
      case PrayerStatus.missed:    return '❌';
      case PrayerStatus.exemption: return '🛡';
      case PrayerStatus.unset:     return '○';
    }
  }

  Color get rowBorderColor {
    if (this == PrayerStatus.unset)   return AppColors.unsetDot;
    if (this == PrayerStatus.missed)  return AppColors.missed;
    if (this == PrayerStatus.qadah)   return AppColors.qadah;
    return AppColors.primary;
  }
}