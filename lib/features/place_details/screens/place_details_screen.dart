import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/activity.dart';
import '../../../features/itinerary/providers/itinerary_provider.dart';

class PlaceDetailsScreen extends ConsumerWidget {
  final String placeId;
  const PlaceDetailsScreen({required this.placeId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(currentTripProvider);

    // Find the activity across all days
    Activity? activity;
    if (trip != null) {
      for (final day in trip.days) {
        for (final a in day.activities) {
          if (a.id == placeId) {
            activity = a;
            break;
          }
        }
        if (activity != null) break;
      }
    }

    if (activity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Place Details')),
        body: const Center(child: Text('Activity not found.')),
      );
    }

    final meta = _categoryMeta(activity.category, activity.timeSlot);
    final hasCoords = activity.latitude != 0.0 || activity.longitude != 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: meta.color,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: _HeroBackground(meta: meta),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges row
                  _BadgesRow(activity: activity, meta: meta),
                  const SizedBox(height: 20),

                  // Description
                  if (activity.description.isNotEmpty) ...[
                    _SectionTitle(label: 'About'),
                    const SizedBox(height: 10),
                    _DescriptionCard(text: activity.description),
                    const SizedBox(height: 20),
                  ],

                  // Info rows
                  _SectionTitle(label: 'Details'),
                  const SizedBox(height: 10),
                  _InfoCard(
                    rows: [
                      _InfoRow(
                        icon: Icons.place_rounded,
                        label: 'Location',
                        value: activity.locationName,
                        color: meta.color,
                      ),
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        label: 'Duration',
                        value: _formatDuration(activity.estimatedDurationMinutes),
                        color: meta.color,
                      ),
                      _InfoRow(
                        icon: meta.icon,
                        label: 'Category',
                        value: _humanize(activity.category),
                        color: meta.color,
                      ),
                      if (hasCoords)
                        _InfoRow(
                          icon: Icons.my_location_rounded,
                          label: 'Coordinates',
                          value:
                              '${activity.latitude.toStringAsFixed(5)}, ${activity.longitude.toStringAsFixed(5)}',
                          color: meta.color,
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                              text:
                                  '${activity!.latitude}, ${activity.longitude}',
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coordinates copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // View on Map button
                  if (trip != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/map/${trip.id}'),
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('View on Map'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: meta.color,
                          side: BorderSide(color: meta.color),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  static String _humanize(String s) =>
      s.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

// ─── Hero background ──────────────────────────────────────────────────────────

class _HeroBackground extends StatelessWidget {
  final _CategoryMeta meta;
  const _HeroBackground({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [meta.colorDark, meta.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Large faint icon decoration
          Positioned(
            right: -20,
            top: 20,
            child: Icon(meta.icon,
                size: 140, color: Colors.white.withValues(alpha: 0.08)),
          ),
          // Smaller icon top-left
          Positioned(
            left: 20,
            top: 60,
            child: Icon(meta.icon,
                size: 48, color: Colors.white.withValues(alpha: 0.12)),
          ),
        ],
      ),
    );
  }
}

// ─── Badges row ───────────────────────────────────────────────────────────────

class _BadgesRow extends StatelessWidget {
  final Activity activity;
  final _CategoryMeta meta;
  const _BadgesRow({required this.activity, required this.meta});

  @override
  Widget build(BuildContext context) {
    final slotMeta = _slotMeta(activity.timeSlot);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Chip(
          icon: slotMeta.icon,
          label: slotMeta.label,
          color: slotMeta.color,
        ),
        _Chip(
          icon: meta.icon,
          label: meta.label,
          color: meta.color,
        ),
      ],
    );
  }

  static ({String label, IconData icon, Color color}) _slotMeta(String slot) =>
      switch (slot) {
        'morning' => (
            label: 'Morning',
            icon: Icons.wb_sunny_rounded,
            color: AppColors.warning,
          ),
        'afternoon' => (
            label: 'Afternoon',
            icon: Icons.wb_cloudy_rounded,
            color: AppColors.primary,
          ),
        _ => (
            label: 'Evening',
            icon: Icons.nights_stay_rounded,
            color: const Color(0xFF7C3AED),
          ),
      };
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Description card ─────────────────────────────────────────────────────────

class _DescriptionCard extends StatelessWidget {
  final String text;
  const _DescriptionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast)
                const Divider(height: 1, indent: 50, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.copy_rounded,
                  size: 15, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ─── Category meta ────────────────────────────────────────────────────────────

class _CategoryMeta {
  final Color color;
  final Color colorDark;
  final IconData icon;
  final String label;
  const _CategoryMeta({
    required this.color,
    required this.colorDark,
    required this.icon,
    required this.label,
  });
}

_CategoryMeta _categoryMeta(String category, String timeSlot) {
  return switch (category) {
    'food' => _CategoryMeta(
        color: const Color(0xFFEA580C),
        colorDark: const Color(0xFFC2410C),
        icon: Icons.restaurant_rounded,
        label: 'Food & Dining',
      ),
    'nightlife' => _CategoryMeta(
        color: const Color(0xFF7C3AED),
        colorDark: const Color(0xFF5B21B6),
        icon: Icons.nightlife_rounded,
        label: 'Nightlife',
      ),
    'nature' => _CategoryMeta(
        color: const Color(0xFF059669),
        colorDark: const Color(0xFF047857),
        icon: Icons.park_rounded,
        label: 'Nature',
      ),
    'shopping' => _CategoryMeta(
        color: const Color(0xFF0891B2),
        colorDark: const Color(0xFF0E7490),
        icon: Icons.shopping_bag_outlined,
        label: 'Shopping',
      ),
    'wellness' => _CategoryMeta(
        color: const Color(0xFFDB2777),
        colorDark: const Color(0xFFBE185D),
        icon: Icons.self_improvement_rounded,
        label: 'Wellness',
      ),
    'adventure' => _CategoryMeta(
        color: const Color(0xFFD97706),
        colorDark: const Color(0xFFB45309),
        icon: Icons.terrain_rounded,
        label: 'Adventure',
      ),
    _ => _CategoryMeta(
        color: AppColors.primary,
        colorDark: AppColors.primaryDark,
        icon: Icons.account_balance_rounded,
        label: 'Culture',
      ),
  };
}
