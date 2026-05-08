import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MapScreen extends StatelessWidget {
  final String tripId;

  const MapScreen({required this.tripId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Trip Map')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Interactive Map',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Coming in Phase 6 — Google Maps + Route Polyline',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
