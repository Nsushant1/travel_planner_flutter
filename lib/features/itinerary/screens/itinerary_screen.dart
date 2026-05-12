import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/trip.dart';
import '../../../data/models/itinerary_day.dart';
import '../providers/itinerary_provider.dart';
import '../widgets/activity_timeline_card.dart';

class ItineraryScreen extends ConsumerWidget {
  final String tripId;
  const ItineraryScreen({required this.tripId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(currentTripProvider);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Itinerary')),
        body: const Center(child: Text('No trip found.')),
      );
    }

    return DefaultTabController(
      length: trip.days.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            _TripSliverAppBar(trip: trip),
          ],
          body: Column(
            children: [
              _DayTabBar(days: trip.days),
              Expanded(
                child: TabBarView(
                  children: trip.days
                      .map((day) => _DayView(day: day, trip: trip))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/route/${trip.id}'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.route_rounded),
          label: const Text('Optimize Route',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ─── Sliver App Bar ───────────────────────────────────────────────────────────

class _TripSliverAppBar extends StatelessWidget {
  final Trip trip;
  const _TripSliverAppBar({required this.trip});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM');
    final dateRange =
        '${fmt.format(trip.startDate)} – ${fmt.format(trip.endDate)}';

    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.destination,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '$dateRange  •  ${trip.totalDays} days',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(width: 8),
                _BudgetBadge(type: trip.budgetType),
              ],
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.flight_takeoff_rounded,
                  size: 72, color: Colors.white12),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.map_outlined),
          tooltip: 'View Map',
          onPressed: () => context.push('/map/${trip.id}'),
        ),
      ],
    );
  }
}

class _BudgetBadge extends StatelessWidget {
  final BudgetType type;
  const _BudgetBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      BudgetType.low => ('Budget', AppColors.budgetLow),
      BudgetType.medium => ('Mid-Range', AppColors.budgetMedium),
      BudgetType.high => ('Luxury', AppColors.budgetHigh),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─── Day tab bar ──────────────────────────────────────────────────────────────

class _DayTabBar extends StatelessWidget {
  final List<ItineraryDay> days;
  const _DayTabBar({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: days
            .map((d) => Tab(text: 'Day ${d.dayNumber}'))
            .toList(),
      ),
    );
  }
}

// ─── Day view ─────────────────────────────────────────────────────────────────

class _DayView extends StatelessWidget {
  final ItineraryDay day;
  final Trip trip;
  const _DayView({required this.day, required this.trip});

  @override
  Widget build(BuildContext context) {
    final date = trip.startDate.add(Duration(days: day.dayNumber - 1));
    final fmt = DateFormat('EEEE, dd MMM');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // Day header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fmt.format(date),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${day.activities.length} activities',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Activity timeline
        ...day.activities.asMap().entries.map((entry) {
          final isLast = entry.key == day.activities.length - 1;
          return ActivityTimelineCard(
            activity: entry.value,
            isLast: isLast,
          );
        }),
      ],
    );
  }
}
