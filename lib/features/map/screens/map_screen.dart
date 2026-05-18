import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:travel_planner/core/constants/app_colors.dart';
import 'package:travel_planner/core/utils/tsp_solver.dart';
import 'package:travel_planner/data/models/activity.dart';
import 'package:travel_planner/data/models/itinerary_day.dart';
import 'package:travel_planner/features/itinerary/providers/itinerary_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String tripId;
  const MapScreen({required this.tripId, super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  int _selectedDayIndex = 0;
  Activity? _tappedActivity;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  bool _hasCoords(Activity a) => a.latitude != 0.0 || a.longitude != 0.0;

  LatLng _latLng(Activity a) => LatLng(a.latitude, a.longitude);

  ({Color bg, Color fg, IconData icon}) _slotStyle(String slot) =>
      switch (slot) {
        'morning' => (
            bg: const Color(0xFFF59E0B),
            fg: Colors.white,
            icon: Icons.wb_sunny_rounded,
          ),
        'afternoon' => (
            bg: AppColors.primary,
            fg: Colors.white,
            icon: Icons.wb_cloudy_rounded,
          ),
        _ => (
            bg: const Color(0xFF7C3AED),
            fg: Colors.white,
            icon: Icons.nights_stay_rounded,
          ),
      };

  List<Activity> _orderedActivities(ItineraryDay day) {
    final acts = day.activities;
    final withCoords = acts.where(_hasCoords).toList();
    if (withCoords.length < 2) return acts;

    final points =
        withCoords.map((a) => (lat: a.latitude, lng: a.longitude)).toList();
    final order = TspSolver.nearestNeighbor(points);
    return order.map((i) => withCoords[i]).toList();
  }

  void _fitBounds(List<Activity> activities) {
    final pts = activities.where(_hasCoords).map(_latLng).toList();
    if (pts.isEmpty) return;
    if (pts.length == 1) {
      _mapController.move(pts.first, 14);
      return;
    }
    final bounds = LatLngBounds.fromPoints(pts);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(currentTripProvider);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip Map')),
        body: const Center(child: Text('No trip found.')),
      );
    }

    final day = trip.days[_selectedDayIndex];
    final ordered = _orderedActivities(day);
    final hasAnyCoords = ordered.any(_hasCoords);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Map ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: hasAnyCoords
                  ? _latLng(ordered.firstWhere(_hasCoords))
                  : const LatLng(20, 0),
              initialZoom: 13,
              onMapReady: () => _fitBounds(ordered),
              onTap: (_, __) => setState(() => _tappedActivity = null),
            ),
            children: [
              // OSM tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.travel_planner',
                maxZoom: 19,
              ),

              // Route polyline
              if (hasAnyCoords)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: ordered.where(_hasCoords).map(_latLng).toList(),
                      strokeWidth: 3.0,
                      color: AppColors.primary.withValues(alpha: 0.7),
                      pattern: StrokePattern.dashed(segments: [12, 6]),
                    ),
                  ],
                ),

              // Activity markers
              if (hasAnyCoords)
                MarkerLayer(
                  markers: ordered
                      .where(_hasCoords)
                      .toList()
                      .asMap()
                      .entries
                      .map((e) {
                    final idx = e.key;
                    final activity = e.value;
                    final style = _slotStyle(activity.timeSlot);
                    final isTapped = _tappedActivity == activity;

                    return Marker(
                      point: _latLng(activity),
                      width: 44,
                      height: 56,
                      child: GestureDetector(
                        onTap: () => setState(() => _tappedActivity = activity),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: isTapped ? 44 : 36,
                              height: isTapped ? 44 : 36,
                              decoration: BoxDecoration(
                                color: style.bg,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white,
                                    width: isTapped ? 3 : 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: style.bg.withValues(alpha: 0.5),
                                    blurRadius: isTapped ? 10 : 4,
                                    spreadRadius: isTapped ? 2 : 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    color: style.fg,
                                    fontSize: isTapped ? 15 : 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            // Marker pin tail
                            CustomPaint(
                              size: const Size(10, 6),
                              painter: _PinTailPainter(color: style.bg),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),

          // ── AppBar overlay ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _MapAppBar(trip: trip),
          ),

          // ── Day selector ──
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 4,
            left: 12,
            right: 12,
            child: _DaySelector(
              days: trip.days,
              selectedIndex: _selectedDayIndex,
              onSelect: (i) {
                setState(() {
                  _selectedDayIndex = i;
                  _tappedActivity = null;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _fitBounds(_orderedActivities(trip.days[i]));
                });
              },
            ),
          ),

          // ── No-coords warning ──
          if (!hasAnyCoords)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white70, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No GPS coordinates for this day yet. Generate a new trip to get real place locations.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Legend ──
          if (hasAnyCoords)
            const Positioned(
              bottom: 24,
              right: 16,
              child: _SlotLegend(),
            ),

          // ── Tapped activity info card ──
          if (_tappedActivity != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: _ActivityInfoCard(
                activity: _tappedActivity!,
                onClose: () => setState(() => _tappedActivity = null),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Map AppBar ────────────────────────────────────────────────────────────────

class _MapAppBar extends StatelessWidget {
  final dynamic trip;
  const _MapAppBar({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              '${trip.destination} — Map',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ─── Day Selector ──────────────────────────────────────────────────────────────

class _DaySelector extends StatelessWidget {
  final List<ItineraryDay> days;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _DaySelector({
    required this.days,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.asMap().entries.map((e) {
          final selected = e.key == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Day ${e.value.dayNumber}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Slot Legend ───────────────────────────────────────────────────────────────

class _SlotLegend extends StatelessWidget {
  const _SlotLegend();

  @override
  Widget build(BuildContext context) {
    const items = [
      (color: Color(0xFFF59E0B), label: 'Morning'),
      (color: AppColors.primary, label: 'Afternoon'),
      (color: Color(0xFF7C3AED), label: 'Evening'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(item.label,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─── Activity Info Card ────────────────────────────────────────────────────────

class _ActivityInfoCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onClose;

  const _ActivityInfoCard({required this.activity, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final slotColor = switch (activity.timeSlot) {
      'morning' => const Color(0xFFF59E0B),
      'afternoon' => AppColors.primary,
      _ => const Color(0xFF7C3AED),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: slotColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.place_rounded, color: slotColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: slotColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activity.timeSlot[0].toUpperCase() +
                            activity.timeSlot.substring(1),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: slotColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (activity.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.push('/place/${activity.id}'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: slotColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded,
                          size: 13, color: slotColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close_rounded,
                size: 20, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// ─── Pin tail painter ──────────────────────────────────────────────────────────

class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinTailPainter old) => old.color != color;
}
