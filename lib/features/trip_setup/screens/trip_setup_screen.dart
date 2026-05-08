import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TripSetupScreen extends StatelessWidget {
  const TripSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Plan a Trip')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_location_alt_outlined, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Trip Setup',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Coming in Phase 4 — destination, dates, budget & interests',
                style: TextStyle(fontSize: 13, color: AppColors.textHint),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
