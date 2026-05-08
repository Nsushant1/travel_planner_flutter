import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final String placeId;

  const PlaceDetailsScreen({required this.placeId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Place Details')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Place Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Coming in Phase 6',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
