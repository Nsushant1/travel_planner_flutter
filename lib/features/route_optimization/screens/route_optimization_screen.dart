import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_planner/core/constants/app_colors.dart';
import 'package:travel_planner/core/utils/tsp_solver.dart';
import 'package:travel_planner/data/models/activity.dart';
import 'package:travel_planner/data/models/itinerary_day.dart';
import 'package:travel_planner/data/models/trip.dart';
import 'package:travel_planner/features/itinerary/providers/itinerary_provider.dart';

class RouteOptimizationScreen extends ConsumerWidget {
  final String tripId;
  const RouteOptimizationScreen({required this.tripId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(currentTripProvider);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Route Optimizer')),
        body: const Center(child: Text('No trip loaded.')),
      );
    }

    return DefaultTabController(
      length: trip.days.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Route Optimizer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: _DayTabBar(days: trip.days),
          ),
        ),
        body: Column(
          children: [
            _AlgorithmBanner(trip: trip),
            Expanded(
              child: TabBarView(
                children: trip.days.map((day) {
                  return _DayRouteView(
                    day: day,
                    trip: trip,
                    onApplyRoute: (reordered) {
                      final idx = trip.days
                          .indexWhere((d) => d.dayNumber == day.dayNumber);
                      if (idx == -1) return;
                      final updatedDays = [...trip.days];
                      updatedDays[idx] =
                          day.copyWith(activities: reordered);
                      ref.read(currentTripProvider.notifier).update(
                            (_) => trip.copyWith(days: updatedDays),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Optimized route applied to Day ${day.dayNumber}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/map/${trip.id}'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.map_rounded),
          label: const Text('View on Map',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ─── Top info banner ──────────────────────────────────────────────────────────

class _AlgorithmBanner extends StatelessWidget {
  final Trip trip;
  const _AlgorithmBanner({required this.trip});

  bool get _hasCoordinates => trip.days.any(
      (d) => d.activities.any((a) => a.latitude != 0.0 || a.longitude != 0.0));

  @override
  Widget build(BuildContext context) {
    if (_hasCoordinates) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.warning.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'GPS coordinates are populated from Google Places. '
              'Route order is computed — distances show as 0 when no coords are available.',
              style: TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab bar ──────────────────────────────────────────────────────────────────

class _DayTabBar extends StatelessWidget {
  final List<ItineraryDay> days;
  const _DayTabBar({required this.days});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorWeight: 2.5,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      tabs: days.map((d) => Tab(text: 'Day ${d.dayNumber}')).toList(),
    );
  }
}

// ─── Per-day route view ───────────────────────────────────────────────────────

class _DayRouteView extends StatefulWidget {
  final ItineraryDay day;
  final Trip trip;
  final void Function(List<Activity> reordered)? onApplyRoute;
  const _DayRouteView({required this.day, required this.trip, this.onApplyRoute});

  @override
  State<_DayRouteView> createState() => _DayRouteViewState();
}

class _DayRouteViewState extends State<_DayRouteView>
    with AutomaticKeepAliveClientMixin {
  late final List<({double lat, double lng})> _points;
  late final List<int> _originalOrder;
  late final List<int> _optimizedOrder;
  late final double _originalKm;
  late final double _optimizedKm;
  bool _showOptimized = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final activities = widget.day.activities;

    _points =
        activities.map((a) => (lat: a.latitude, lng: a.longitude)).toList();

    _originalOrder = List.generate(activities.length, (i) => i);
    _optimizedOrder = TspSolver.nearestNeighbor(_points);
    _originalKm = TspSolver.totalDistanceKm(_points, _originalOrder);
    _optimizedKm = TspSolver.totalDistanceKm(_points, _optimizedOrder);
  }

  List<int> get _displayOrder =>
      _showOptimized ? _optimizedOrder : _originalOrder;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final activities = widget.day.activities;
    final savings = TspSolver.savingsPercent(_originalKm, _optimizedKm);
    final hasCoords = _points.any((p) => p.lat != 0.0 || p.lng != 0.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // Day title
        Text(
          widget.day.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '${activities.length} stops · TSP Nearest Neighbor',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Stats card
        _StatsCard(
          originalKm: _originalKm,
          optimizedKm: _optimizedKm,
          savings: savings,
          hasCoords: hasCoords,
        ),
        const SizedBox(height: 16),

        // Toggle
        _ViewToggle(
          showOptimized: _showOptimized,
          onChanged: (v) => setState(() => _showOptimized = v),
        ),
        const SizedBox(height: 20),

        // Apply button — only shown when optimized view is active
        if (_showOptimized && widget.onApplyRoute != null) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final reordered = _optimizedOrder
                    .map((i) => activities[i])
                    .toList();
                widget.onApplyRoute!(reordered);
              },
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Apply Optimized Route to Itinerary'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Route stops
        ...List.generate(_displayOrder.length, (i) {
          final actIndex = _displayOrder[i];
          final act = activities[actIndex];
          final isLast = i == _displayOrder.length - 1;

          double? legKm;
          if (!isLast) {
            final nextIndex = _displayOrder[i + 1];
            legKm = TspSolver.haversineKm(
              _points[actIndex].lat,
              _points[actIndex].lng,
              _points[nextIndex].lat,
              _points[nextIndex].lng,
            );
          }

          return _RouteStopRow(
            stopNumber: i + 1,
            activity: act,
            legKm: legKm,
            hasCoords: hasCoords,
            isFirst: i == 0,
            isLast: isLast,
          );
        }),
      ],
    );
  }
}

// ─── Stats card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final double originalKm;
  final double optimizedKm;
  final double savings;
  final bool hasCoords;

  const _StatsCard({
    required this.originalKm,
    required this.optimizedKm,
    required this.savings,
    required this.hasCoords,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: hasCoords
          ? Row(
              children: [
                _StatItem(
                  label: 'Original',
                  value: '${originalKm.toStringAsFixed(1)} km',
                  color: AppColors.textSecondary,
                  icon: Icons.timeline_rounded,
                ),
                const _Arrow(),
                _StatItem(
                  label: 'Optimized',
                  value: '${optimizedKm.toStringAsFixed(1)} km',
                  color: AppColors.success,
                  icon: Icons.route_rounded,
                ),
                const _Arrow(),
                _StatItem(
                  label: 'Saved',
                  value: '${savings.toStringAsFixed(0)}%',
                  color: AppColors.primary,
                  icon: Icons.savings_outlined,
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route Optimized',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Distances available once GPS coordinates are loaded.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatItem(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) => const Icon(
        Icons.arrow_forward_rounded,
        color: AppColors.divider,
        size: 18,
      );
}

// ─── View toggle ──────────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final bool showOptimized;
  final ValueChanged<bool> onChanged;
  const _ViewToggle({required this.showOptimized, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleBtn(
            label: 'Optimized Route',
            icon: Icons.auto_awesome_rounded,
            selected: showOptimized,
            color: AppColors.primary,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ToggleBtn(
            label: 'Original Order',
            icon: Icons.format_list_numbered_rounded,
            selected: !showOptimized,
            color: AppColors.textSecondary,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _ToggleBtn(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16, color: selected ? color : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Route stop row ───────────────────────────────────────────────────────────

class _RouteStopRow extends StatelessWidget {
  final int stopNumber;
  final Activity activity;
  final double? legKm;
  final bool hasCoords;
  final bool isFirst;
  final bool isLast;

  const _RouteStopRow({
    required this.stopNumber,
    required this.activity,
    required this.legKm,
    required this.hasCoords,
    required this.isFirst,
    required this.isLast,
  });

  Color get _stopColor {
    if (isFirst) return AppColors.success;
    if (isLast) return AppColors.accent;
    return AppColors.primary;
  }

  String get _stopLabel {
    if (isFirst) return 'START';
    if (isLast) return 'END';
    return 'STOP';
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: vertical connector + number badge
          SizedBox(
            width: 48,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: AppColors.divider,
                  ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _stopColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _stopColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$stopNumber',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right: card + leg indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isFirst) const SizedBox(height: 12),
                // Stop card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: _stopColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _stopLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _stopColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _SlotBadge(slot: activity.timeSlot),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              activity.locationName,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Leg distance to next stop
                if (!isLast) _LegIndicator(legKm: legKm, hasCoords: hasCoords),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slot badge ───────────────────────────────────────────────────────────────

class _SlotBadge extends StatelessWidget {
  final String slot;
  const _SlotBadge({required this.slot});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (slot) {
      'morning' => ('Morning', const Color(0xFFF59E0B)),
      'afternoon' => ('Afternoon', AppColors.primary),
      'evening' => ('Evening', const Color(0xFF7C3AED)),
      _ => (slot, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ─── Leg distance indicator ───────────────────────────────────────────────────

class _LegIndicator extends StatelessWidget {
  final double? legKm;
  final bool hasCoords;
  const _LegIndicator({this.legKm, required this.hasCoords});

  @override
  Widget build(BuildContext context) {
    final km = legKm ?? 0.0;
    final walkMins = TspSolver.walkingMinutes(km);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.arrow_downward_rounded,
              size: 14, color: AppColors.textHint),
          const SizedBox(width: 4),
          Text(
            hasCoords
                ? '${km.toStringAsFixed(1)} km  ·  ~$walkMins min walk'
                : 'Distance pending GPS data',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
