import 'package:flutter/material.dart';
import 'package:travel_planner/core/constants/app_colors.dart';
import 'package:travel_planner/data/models/activity.dart';

class ActivityTimelineCard extends StatelessWidget {
  final Activity activity;
  final bool isLast;
  final VoidCallback? onTap;

  const ActivityTimelineCard({
    required this.activity,
    this.isLast = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final slot = _slotMeta(activity.timeSlot);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 52,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: slot.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(slot.icon, color: slot.color, size: 18),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Card content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Slot label + time range + duration + chevron
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: slot.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(slot.icon, size: 10, color: slot.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${activity.scheduledTime} – ${activity.scheduledEndTime}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: slot.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.schedule_rounded,
                                size: 13, color: AppColors.textHint),
                            const SizedBox(width: 3),
                            Text(
                              _formatDuration(
                                  activity.estimatedDurationMinutes),
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textHint),
                            ),
                            if (onTap != null) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 16, color: AppColors.textHint),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Text(
                          activity.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Description
                        Text(
                          activity.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  ({String label, IconData icon, Color color}) _slotMeta(String slot) {
    return switch (slot) {
      'morning' => (
          label: 'Morning',
          icon: Icons.wb_sunny_outlined,
          color: const Color(0xFFF59E0B),
        ),
      'afternoon' => (
          label: 'Afternoon',
          icon: Icons.wb_cloudy_outlined,
          color: AppColors.primary,
        ),
      'evening' => (
          label: 'Evening',
          icon: Icons.nights_stay_outlined,
          color: const Color(0xFF7C3AED),
        ),
      _ => (
          label: slot,
          icon: Icons.circle,
          color: AppColors.textSecondary,
        ),
    };
  }
}
