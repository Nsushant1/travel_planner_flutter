import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ItineraryScreen extends StatelessWidget {
  final String tripId;

  const ItineraryScreen({required this.tripId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Itinerary')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Day-wise Itinerary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Coming in Phase 4',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
