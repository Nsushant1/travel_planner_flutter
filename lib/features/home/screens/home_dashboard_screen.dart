import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/core/constants/app_colors.dart';
import 'package:travel_planner/core/widgets/shimmer.dart';
import 'package:travel_planner/data/models/trip.dart';
import 'package:travel_planner/features/auth/providers/auth_provider.dart';
import 'package:travel_planner/features/itinerary/providers/itinerary_provider.dart';
import 'package:travel_planner/features/saved_trips/providers/saved_trips_provider.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final firstName = authState.displayName?.split(' ').first ??
        authState.email?.split('@').first ??
        'Traveler';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(firstName),
            _buildPlanTripCard(context),
            _buildFeaturesSection(),
            const _RecentTripsSection(),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(String name) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${_capitalize(name)} 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Where are you going next?',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
              child: const Icon(Icons.person_outline,
                  color: AppColors.primary, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildPlanTripCard(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: GestureDetector(
          onTap: () => context.push('/trip-setup'),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan a New Trip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'AI-powered itineraries tailored\nto your interests & budget',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 16),
                      _StartButton(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.flight_takeoff_rounded,
                  size: 64,
                  color: Colors.white24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFeaturesSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What TripGenie offers',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _FeatureChip(
                  icon: Icons.auto_awesome,
                  label: 'Smart Itinerary',
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 10),
                _FeatureChip(
                  icon: Icons.route_rounded,
                  label: 'Route Optimizer',
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _FeatureChip(
                  icon: Icons.map_rounded,
                  label: 'Live Maps',
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                _FeatureChip(
                  icon: Icons.cloud_outlined,
                  label: 'Weather Aware',
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Get Started',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 16),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Trips Section ─────────────────────────────────────────────────────

class _RecentTripsSection extends ConsumerWidget {
  const _RecentTripsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(savedTripsProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Trips',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                tripsAsync.maybeWhen(
                  data: (trips) => trips.isNotEmpty
                      ? GestureDetector(
                          onTap: () => context.go('/saved'),
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            tripsAsync.when(
              loading: () => const Column(
                children: [
                  TripTileSkeleton(),
                  TripTileSkeleton(),
                  TripTileSkeleton(),
                ],
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (trips) => trips.isEmpty
                  ? _emptyState()
                  : Column(
                      children: trips
                          .take(3)
                          .map((t) => _RecentTripTile(trip: t))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Column(
          children: [
            Icon(Icons.luggage_outlined, size: 44, color: AppColors.textHint),
            SizedBox(height: 10),
            Text(
              'No trips yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tap "Plan a New Trip" to get started',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ],
        ),
      );
}

class _RecentTripTile extends ConsumerWidget {
  final Trip trip;
  const _RecentTripTile({required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('dd MMM yyyy');
    final (budgetLabel, budgetColor) = switch (trip.budgetType) {
      BudgetType.low => ('Budget', AppColors.budgetLow),
      BudgetType.medium => ('Mid-Range', AppColors.budgetMedium),
      BudgetType.high => ('Luxury', AppColors.budgetHigh),
    };

    return GestureDetector(
      onTap: () {
        ref.read(currentTripProvider.notifier).state = trip;
        context.push('/itinerary/${trip.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flight_takeoff_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.destination,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${fmt.format(trip.startDate)}  •  ${trip.totalDays} days',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: budgetColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                budgetLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: budgetColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
