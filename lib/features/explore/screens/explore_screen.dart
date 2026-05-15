import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/trip.dart';
import '../../trip_setup/providers/trip_setup_provider.dart';

// ─── Destination data ─────────────────────────────────────────────────────────

class _Destination {
  final String name;
  final String country;
  final String tagline;
  final String category; // beach | city | mountain | culture | adventure | nature
  final List<TripInterest> interests;
  final Color color;
  final Color colorDark;
  final IconData icon;

  const _Destination({
    required this.name,
    required this.country,
    required this.tagline,
    required this.category,
    required this.interests,
    required this.color,
    required this.colorDark,
    required this.icon,
  });
}

const _destinations = <_Destination>[
  _Destination(
    name: 'Paris', country: 'France', tagline: 'City of Light & Art',
    category: 'city', interests: [TripInterest.culture, TripInterest.food],
    color: Color(0xFF7C3AED), colorDark: Color(0xFF5B21B6),
    icon: Icons.account_balance_rounded,
  ),
  _Destination(
    name: 'Bali', country: 'Indonesia', tagline: 'Island of the Gods',
    category: 'beach', interests: [TripInterest.nature, TripInterest.wellness, TripInterest.culture],
    color: Color(0xFF0891B2), colorDark: Color(0xFF0E7490),
    icon: Icons.beach_access_rounded,
  ),
  _Destination(
    name: 'Tokyo', country: 'Japan', tagline: 'Tradition meets the future',
    category: 'city', interests: [TripInterest.culture, TripInterest.food, TripInterest.shopping],
    color: Color(0xFFDB2777), colorDark: Color(0xFFBE185D),
    icon: Icons.location_city_rounded,
  ),
  _Destination(
    name: 'Kathmandu', country: 'Nepal', tagline: 'Gateway to the Himalayas',
    category: 'mountain', interests: [TripInterest.adventure, TripInterest.culture, TripInterest.nature],
    color: Color(0xFF059669), colorDark: Color(0xFF047857),
    icon: Icons.terrain_rounded,
  ),
  _Destination(
    name: 'Santorini', country: 'Greece', tagline: 'Whitewashed cliffs & sunsets',
    category: 'beach', interests: [TripInterest.nature, TripInterest.food, TripInterest.wellness],
    color: Color(0xFF0369A1), colorDark: Color(0xFF075985),
    icon: Icons.wb_sunny_rounded,
  ),
  _Destination(
    name: 'Bangkok', country: 'Thailand', tagline: 'Street food & temples',
    category: 'city', interests: [TripInterest.food, TripInterest.culture, TripInterest.nightlife],
    color: Color(0xFFD97706), colorDark: Color(0xFFB45309),
    icon: Icons.restaurant_rounded,
  ),
  _Destination(
    name: 'Cape Town', country: 'South Africa', tagline: 'Mountains meet the ocean',
    category: 'adventure', interests: [TripInterest.adventure, TripInterest.nature, TripInterest.food],
    color: Color(0xFFEA580C), colorDark: Color(0xFFC2410C),
    icon: Icons.landscape_rounded,
  ),
  _Destination(
    name: 'Kyoto', country: 'Japan', tagline: 'Ancient temples & zen gardens',
    category: 'culture', interests: [TripInterest.culture, TripInterest.nature, TripInterest.wellness],
    color: Color(0xFF7C3AED), colorDark: Color(0xFF5B21B6),
    icon: Icons.temple_buddhist_rounded,
  ),
  _Destination(
    name: 'Marrakech', country: 'Morocco', tagline: 'Souks & desert adventures',
    category: 'culture', interests: [TripInterest.culture, TripInterest.shopping, TripInterest.food],
    color: Color(0xFFB45309), colorDark: Color(0xFF92400E),
    icon: Icons.mosque_rounded,
  ),
  _Destination(
    name: 'New York', country: 'USA', tagline: 'The city that never sleeps',
    category: 'city', interests: [TripInterest.culture, TripInterest.food, TripInterest.nightlife, TripInterest.shopping],
    color: Color(0xFF1D4ED8), colorDark: Color(0xFF1E40AF),
    icon: Icons.apartment_rounded,
  ),
  _Destination(
    name: 'Queenstown', country: 'New Zealand', tagline: 'Adventure capital of the world',
    category: 'adventure', interests: [TripInterest.adventure, TripInterest.nature],
    color: Color(0xFF16A34A), colorDark: Color(0xFF15803D),
    icon: Icons.paragliding_rounded,
  ),
  _Destination(
    name: 'Rome', country: 'Italy', tagline: 'Eternal city of history',
    category: 'culture', interests: [TripInterest.culture, TripInterest.food],
    color: Color(0xFFCA8A04), colorDark: Color(0xFFA16207),
    icon: Icons.account_balance_rounded,
  ),
  _Destination(
    name: 'Maldives', country: 'Maldives', tagline: 'Crystal lagoons & coral reefs',
    category: 'beach', interests: [TripInterest.nature, TripInterest.wellness, TripInterest.adventure],
    color: Color(0xFF0891B2), colorDark: Color(0xFF0E7490),
    icon: Icons.water_rounded,
  ),
  _Destination(
    name: 'Istanbul', country: 'Turkey', tagline: 'Where East meets West',
    category: 'culture', interests: [TripInterest.culture, TripInterest.food, TripInterest.shopping],
    color: Color(0xFFDC2626), colorDark: Color(0xFFB91C1C),
    icon: Icons.mosque_rounded,
  ),
  _Destination(
    name: 'Lisbon', country: 'Portugal', tagline: 'City of seven hills & fado',
    category: 'city', interests: [TripInterest.culture, TripInterest.food, TripInterest.nightlife],
    color: Color(0xFF0F766E), colorDark: Color(0xFF115E59),
    icon: Icons.tram_rounded,
  ),
  _Destination(
    name: 'Singapore', country: 'Singapore', tagline: 'Garden city of Asia',
    category: 'city', interests: [TripInterest.food, TripInterest.shopping, TripInterest.culture],
    color: Color(0xFF7C3AED), colorDark: Color(0xFF5B21B6),
    icon: Icons.park_rounded,
  ),
  _Destination(
    name: 'Barcelona', country: 'Spain', tagline: 'Gaudí & beach culture',
    category: 'city', interests: [TripInterest.culture, TripInterest.food, TripInterest.nightlife],
    color: Color(0xFFEA580C), colorDark: Color(0xFFC2410C),
    icon: Icons.architecture_rounded,
  ),
  _Destination(
    name: 'Vancouver', country: 'Canada', tagline: 'Mountains, forests & ocean',
    category: 'nature', interests: [TripInterest.nature, TripInterest.adventure, TripInterest.food],
    color: Color(0xFF059669), colorDark: Color(0xFF047857),
    icon: Icons.forest_rounded,
  ),
  _Destination(
    name: 'Cairo', country: 'Egypt', tagline: 'Pharaohs & the Nile',
    category: 'culture', interests: [TripInterest.culture, TripInterest.adventure],
    color: Color(0xFFD97706), colorDark: Color(0xFFB45309),
    icon: Icons.account_balance_rounded,
  ),
  _Destination(
    name: 'Prague', country: 'Czech Republic', tagline: 'Fairy-tale spires & old town',
    category: 'city', interests: [TripInterest.culture, TripInterest.nightlife, TripInterest.food],
    color: Color(0xFF7C3AED), colorDark: Color(0xFF5B21B6),
    icon: Icons.castle_rounded,
  ),
  _Destination(
    name: 'Phuket', country: 'Thailand', tagline: 'Tropical paradise & nightlife',
    category: 'beach', interests: [TripInterest.adventure, TripInterest.nightlife, TripInterest.food],
    color: Color(0xFF0891B2), colorDark: Color(0xFF0E7490),
    icon: Icons.beach_access_rounded,
  ),
  _Destination(
    name: 'Dubai', country: 'UAE', tagline: 'Desert luxury & sky-high thrills',
    category: 'adventure', interests: [TripInterest.shopping, TripInterest.adventure, TripInterest.nightlife],
    color: Color(0xFFCA8A04), colorDark: Color(0xFFA16207),
    icon: Icons.business_rounded,
  ),
  _Destination(
    name: 'Rio de Janeiro', country: 'Brazil', tagline: 'Carnival, beaches & samba',
    category: 'beach', interests: [TripInterest.adventure, TripInterest.culture, TripInterest.nightlife],
    color: Color(0xFF16A34A), colorDark: Color(0xFF15803D),
    icon: Icons.beach_access_rounded,
  ),
  _Destination(
    name: 'Amsterdam', country: 'Netherlands', tagline: 'Canals, bikes & museums',
    category: 'city', interests: [TripInterest.culture, TripInterest.food, TripInterest.nightlife],
    color: Color(0xFF1D4ED8), colorDark: Color(0xFF1E40AF),
    icon: Icons.directions_bike_rounded,
  ),
];

// ─── Category model ───────────────────────────────────────────────────────────

class _Category {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const _Category({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

const _categories = <_Category>[
  _Category(id: 'all',       label: 'All',       icon: Icons.explore_rounded,       color: AppColors.primary),
  _Category(id: 'city',      label: 'City',      icon: Icons.location_city_rounded,  color: Color(0xFF7C3AED)),
  _Category(id: 'beach',     label: 'Beach',     icon: Icons.beach_access_rounded,   color: Color(0xFF0891B2)),
  _Category(id: 'culture',   label: 'Culture',   icon: Icons.account_balance_rounded,color: Color(0xFFCA8A04)),
  _Category(id: 'adventure', label: 'Adventure', icon: Icons.terrain_rounded,        color: Color(0xFFEA580C)),
  _Category(id: 'mountain',  label: 'Mountain',  icon: Icons.landscape_rounded,      color: Color(0xFF059669)),
  _Category(id: 'nature',    label: 'Nature',    icon: Icons.forest_rounded,         color: Color(0xFF16A34A)),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _search = '';
  String _selectedCategory = 'all';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Destination> get _filtered {
    return _destinations.where((d) {
      final matchesSearch = _search.isEmpty ||
          d.name.toLowerCase().contains(_search.toLowerCase()) ||
          d.country.toLowerCase().contains(_search.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'all' || d.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _planTrip(_Destination dest) {
    final notifier = ref.read(tripSetupProvider.notifier);
    notifier.setDestination(dest.name);
    for (final interest in dest.interests) {
      notifier.toggleInterest(interest);
    }
    context.push('/trip-setup');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explore',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  Text('Discover your next adventure',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400)),
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
                    child: Icon(Icons.travel_explore_rounded,
                        size: 72, color: Colors.white12),
                  ),
                ),
              ),
            ),
          ),

          // ── Search bar ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search destination or country…',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.primary),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.textHint),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _search = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // ── Category chips ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 54,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final selected = _selectedCategory == cat.id;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? cat.color
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? cat.color
                              : AppColors.divider,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon,
                              size: 14,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Results header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Row(
                children: [
                  Text(
                    filtered.isEmpty
                        ? 'No results'
                        : '${filtered.length} destination${filtered.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Destination grid ──
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 52, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    const Text('No destinations found',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      'Try a different search or category',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) =>
                      _DestinationCard(dest: filtered[i], onPlan: _planTrip),
                  childCount: filtered.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Destination card ─────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  final _Destination dest;
  final void Function(_Destination) onPlan;
  const _DestinationCard({required this.dest, required this.onPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [dest.colorDark, dest.color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -8,
                    bottom: -8,
                    child: Icon(dest.icon,
                        size: 72,
                        color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _capitalize(dest.category),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dest.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 11, color: Colors.white70),
                            const SizedBox(width: 2),
                            Text(
                              dest.country,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Card footer
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dest.tagline,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onPlan(dest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dest.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Plan a Trip'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
