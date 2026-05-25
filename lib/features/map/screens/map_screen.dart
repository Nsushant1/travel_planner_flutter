import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  GoogleMapController? _mapController;
  int _selectedDayIndex = 0;
  Activity? _tappedActivity;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  bool _hasCoords(Activity a) => a.latitude != 0.0 || a.longitude != 0.0;

  LatLng _latLng(Activity a) => LatLng(a.latitude, a.longitude);

  Color _slotColor(String slot) => switch (slot) {
        'morning' => const Color(0xFFF59E0B),
        'afternoon' => AppColors.primary,
        _ => const Color(0xFF7C3AED),
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

  // ─── Canvas-painted numbered pin ───────────────────────────────────────────

  Future<BitmapDescriptor> _buildMarkerIcon(int number, Color bg) async {
    const double r = 40;
    const double totalH = 56;
    const double w = r * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, totalH));

    canvas.drawCircle(const Offset(r, r), r, Paint()..color = bg);
    canvas.drawCircle(
      const Offset(r, r),
      r - 3,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final tailPath = ui.Path()
      ..moveTo(r - 7, r * 2 - 6)
      ..lineTo(r, totalH)
      ..lineTo(r + 7, r * 2 - 6)
      ..close();
    canvas.drawPath(tailPath, Paint()..color = bg);

    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(r - tp.width / 2, r - tp.height / 2));

    final picture = recorder.endRecording();
    final img = await picture.toImage(w.toInt(), totalH.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  // ─── Build markers + polyline for a day ────────────────────────────────────

  Future<void> _buildOverlay(List<Activity> ordered) async {
    final withCoords = ordered.where(_hasCoords).toList();

    final markers = <Marker>{};
    for (var i = 0; i < withCoords.length; i++) {
      final a = withCoords[i];
      final icon = await _buildMarkerIcon(i + 1, _slotColor(a.timeSlot));
      markers.add(Marker(
        markerId: MarkerId(a.id),
        position: _latLng(a),
        icon: icon,
        onTap: () => setState(() => _tappedActivity = a),
      ));
    }

    final polylines = <Polyline>{};
    if (withCoords.length >= 2) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: withCoords.map(_latLng).toList(),
        width: 3,
        color: AppColors.primary.withValues(alpha: 0.7),
        patterns: [PatternItem.dash(12), PatternItem.gap(6)],
      ));
    }

    if (mounted) {
      setState(() {
        _markers = markers;
        _polylines = polylines;
      });
    }
  }

  void _fitBounds(List<Activity> activities) {
    final ctrl = _mapController;
    if (ctrl == null) return;
    final pts = activities.where(_hasCoords).toList();
    if (pts.isEmpty) return;
    if (pts.length == 1) {
      ctrl.animateCamera(CameraUpdate.newLatLngZoom(_latLng(pts.first), 14));
      return;
    }
    final lats = pts.map((a) => a.latitude);
    final lngs = pts.map((a) => a.longitude);
    ctrl.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(lats.reduce(min), lngs.reduce(min)),
          northeast: LatLng(lats.reduce(max), lngs.reduce(max)),
        ),
        60,
      ),
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
    final initialTarget = hasAnyCoords
        ? _latLng(ordered.firstWhere(_hasCoords))
        : const LatLng(20, 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Map ──
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: initialTarget, zoom: 13),
            markers: _markers,
            polylines: _polylines,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _buildOverlay(ordered).then((_) => _fitBounds(ordered));
            },
            onTap: (_) => setState(() => _tappedActivity = null),
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
                  _markers = {};
                  _polylines = {};
                });
                final newOrdered = _orderedActivities(trip.days[i]);
                _buildOverlay(newOrdered).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _fitBounds(newOrdered),
                  );
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
