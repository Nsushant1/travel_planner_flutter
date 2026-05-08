import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RouteOptimizationScreen extends StatelessWidget {
  final String tripId;

  const RouteOptimizationScreen({required this.tripId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Route Optimizer')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route_rounded, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'TSP Route Optimization',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Coming in Phase 5',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
