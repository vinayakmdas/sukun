// lib/screens/widgets/update_prayer_modal.dart

import 'package:flutter/material.dart';
import 'package:sukman/core/theme/app_colors.dart';
import 'package:sukman/features/habit_tracker/model/prayer_day_model.dart';
import 'package:sukman/features/habit_tracker/model/prayer_status.dart';


class UpdatePrayerModal extends StatefulWidget {
  final int prayerIndex;
  final PrayerStatus currentStatus;
  final String dayLabel;
  final ValueChanged<PrayerStatus> onSave;

  const UpdatePrayerModal({
    super.key,
    required this.prayerIndex,
    required this.currentStatus,
    required this.dayLabel,
    required this.onSave,
  });

  @override
  State<UpdatePrayerModal> createState() => _UpdatePrayerModalState();
}

class _UpdatePrayerModalState extends State<UpdatePrayerModal> {
  late PrayerStatus _selected;

  static const List<PrayerStatus> _options = [
    PrayerStatus.jamath,
    PrayerStatus.onTime,
    PrayerStatus.qadah,
    PrayerStatus.missed,
    PrayerStatus.exemption,
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentStatus == PrayerStatus.unset
        ? PrayerStatus.jamath
        : widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    final prayerName = kPrayerNames[widget.prayerIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildPrayerNameRow(prayerName),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 20),
            _buildStatusGrid(),
            const SizedBox(height: 28),
            _buildActionRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Update Prayer Status',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(widget.dayLabel,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close_rounded,
              color: AppColors.textMuted, size: 22),
        ),
      ],
    );
  }

  Widget _buildPrayerNameRow(String prayerName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(prayerName,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const Spacer(),
          const Icon(Icons.chat_bubble_outline_rounded,
              color: AppColors.border, size: 20),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _options.map((opt) {
        final isSelected = _selected == opt;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => setState(() => _selected = opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? opt.color : const Color(0xFFF9FAFB),
                  border: Border.all(
                      color: isSelected ? opt.color : AppColors.border,
                      width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(opt.emoji,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      opt.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: isSelected ? Colors.white : opt.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Cancel',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_selected);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: AppColors.primary.withOpacity(0.35),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
          child: const Text('Save Changes',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ],
    );
  }
}