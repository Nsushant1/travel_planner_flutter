import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:travel_planner/data/models/activity.dart';
import 'package:travel_planner/data/models/itinerary_day.dart';
import 'package:travel_planner/data/models/place.dart';
import 'package:travel_planner/data/models/trip.dart';
import 'places_service.dart';

// ---------- internal template type ----------
typedef _T = ({String title, String desc, int mins});

class ItineraryGenerator {
  static const _uuid = Uuid();

  // Destination placeholder inside templates
  static String _d(String s, String dest) => s.replaceAll('{dest}', dest);

  // ─── Activity pool: interest → timeslot → templates ───────────────────────
  static const Map<TripInterest, Map<String, List<_T>>> _pool = {
    TripInterest.culture: {
      'morning': [
        (
          title: 'Historic Walk',
          desc: 'Explore the ancient streets and landmarks of {dest}',
          mins: 90
        ),
        (
          title: 'Temple & Shrine Visit',
          desc: 'Discover the spiritual heritage sites of {dest}',
          mins: 60
        ),
        (
          title: 'Archaeological Museum',
          desc: 'Uncover the centuries of history behind {dest}',
          mins: 90
        ),
        (
          title: 'Old Quarter Tour',
          desc: 'Wander through the preserved old quarter of {dest}',
          mins: 90
        ),
        (
          title: 'Heritage Monument Walk',
          desc: 'Visit the iconic monuments that define {dest}',
          mins: 75
        ),
      ],
      'afternoon': [
        (
          title: 'Art Gallery Tour',
          desc: 'Browse works by local artists in {dest}\'s finest gallery',
          mins: 120
        ),
        (
          title: 'Cultural Heritage Site',
          desc: 'Walk through a UNESCO-listed or protected site in {dest}',
          mins: 90
        ),
        (
          title: 'Craft & Textile Workshop',
          desc: 'Learn traditional craftsmanship unique to {dest}',
          mins: 120
        ),
        (
          title: 'Local History Museum',
          desc: 'Deep-dive into the stories that shaped {dest}',
          mins: 90
        ),
        (
          title: 'Guided City Tour',
          desc: 'Let a local guide reveal the hidden stories of {dest}',
          mins: 120
        ),
      ],
      'evening': [
        (
          title: 'Traditional Folk Performance',
          desc: 'Watch authentic music and dance of {dest} at a local venue',
          mins: 120
        ),
        (
          title: 'Illuminated Heritage Walk',
          desc: 'Explore {dest}\'s historic sites beautifully lit at night',
          mins: 90
        ),
        (
          title: 'Cultural Storytelling Evening',
          desc:
              'Listen to local storytellers share the myths and legends of {dest}',
          mins: 90
        ),
        (
          title: 'Local Theater Show',
          desc: 'Enjoy a traditional theater production in {dest}',
          mins: 120
        ),
      ],
    },
    TripInterest.food: {
      'morning': [
        (
          title: 'Traditional Breakfast',
          desc: 'Start the day with an authentic {dest} breakfast spread',
          mins: 60
        ),
        (
          title: 'Street Food Walk',
          desc: 'Sample fresh morning street delicacies across {dest}',
          mins: 90
        ),
        (
          title: 'Local Bakery Visit',
          desc: 'Taste freshly baked breads and pastries unique to {dest}',
          mins: 60
        ),
        (
          title: 'Morning Food Market',
          desc: 'Explore the lively early-morning food stalls of {dest}',
          mins: 75
        ),
      ],
      'afternoon': [
        (
          title: 'Award-Winning Local Lunch',
          desc: 'Savor the finest regional cuisine {dest} has to offer',
          mins: 90
        ),
        (
          title: 'Food Market Exploration',
          desc:
              'Browse vibrant stalls of fresh produce and local specialties in {dest}',
          mins: 90
        ),
        (
          title: 'Cooking Class',
          desc: 'Learn to prepare authentic {dest} dishes with a local chef',
          mins: 150
        ),
        (
          title: 'Spice & Flavour Market',
          desc:
              'Discover the aromatic spice markets that define {dest}\'s cuisine',
          mins: 75
        ),
        (
          title: 'Café Culture Tour',
          desc: 'Hop through {dest}\'s most beloved local cafés',
          mins: 90
        ),
      ],
      'evening': [
        (
          title: 'Street Food Dinner Tour',
          desc: 'Explore the best street eats as {dest} comes alive at night',
          mins: 120
        ),
        (
          title: 'Fine Dining Experience',
          desc:
              'Enjoy a curated tasting menu showcasing {dest}\'s best flavours',
          mins: 120
        ),
        (
          title: 'Night Food Market',
          desc: 'Browse a bustling night market packed with {dest} vendors',
          mins: 90
        ),
        (
          title: 'Local Brewery Tour',
          desc: 'Taste craft brews and local spirits unique to {dest}',
          mins: 90
        ),
      ],
    },
    TripInterest.adventure: {
      'morning': [
        (
          title: 'Sunrise Hike',
          desc: 'Trek to a scenic viewpoint above {dest} for spectacular views',
          mins: 150
        ),
        (
          title: 'Mountain Biking Trail',
          desc: 'Cycle through the rugged terrain around {dest}',
          mins: 120
        ),
        (
          title: 'Kayaking Session',
          desc: 'Paddle through the waterways near {dest}',
          mins: 120
        ),
        (
          title: 'Rock Climbing',
          desc: 'Scale natural rock faces near {dest} with expert guides',
          mins: 150
        ),
        (
          title: 'Trekking Expedition',
          desc: 'Head out on a guided trek through the wilderness near {dest}',
          mins: 180
        ),
      ],
      'afternoon': [
        (
          title: 'River Rafting',
          desc: 'Navigate exciting rapids on the rivers near {dest}',
          mins: 150
        ),
        (
          title: 'Zip Line Adventure',
          desc: 'Soar above the treetops for a bird\'s-eye view of {dest}',
          mins: 90
        ),
        (
          title: 'ATV Off-Road Tour',
          desc: 'Explore the rugged outskirts of {dest} on an ATV',
          mins: 120
        ),
        (
          title: 'Rappelling & Canyoning',
          desc: 'Descend dramatic cliff faces near {dest}',
          mins: 150
        ),
        (
          title: 'Paragliding',
          desc: 'Glide above the stunning landscape surrounding {dest}',
          mins: 90
        ),
      ],
      'evening': [
        (
          title: 'Campfire Under the Stars',
          desc:
              'Gather around a fire with stories and local snacks near {dest}',
          mins: 120
        ),
        (
          title: 'Night Safari',
          desc: 'Discover nocturnal wildlife in the areas around {dest}',
          mins: 120
        ),
        (
          title: 'Cliff-Side Sunset',
          desc:
              'Watch the sun go down from a dramatic vantage point near {dest}',
          mins: 90
        ),
      ],
    },
    TripInterest.nature: {
      'morning': [
        (
          title: 'Botanical Garden Walk',
          desc:
              'Explore thousands of plant species in {dest}\'s serene gardens',
          mins: 90
        ),
        (
          title: 'Bird Watching at Dawn',
          desc: 'Spot rare and colorful bird species around {dest} at sunrise',
          mins: 120
        ),
        (
          title: 'Waterfall Trek',
          desc: 'Hike through lush forest to a stunning waterfall near {dest}',
          mins: 150
        ),
        (
          title: 'Nature Photography Walk',
          desc: 'Capture the golden hour in the natural landscapes of {dest}',
          mins: 90
        ),
      ],
      'afternoon': [
        (
          title: 'National Park Exploration',
          desc: 'Hike and explore the protected natural landscapes near {dest}',
          mins: 180
        ),
        (
          title: 'Wildlife Sanctuary Visit',
          desc: 'Observe native animals in their natural habitat near {dest}',
          mins: 120
        ),
        (
          title: 'Scenic Lake Visit',
          desc: 'Relax by a picturesque lake in the vicinity of {dest}',
          mins: 90
        ),
        (
          title: 'Forest Canopy Walk',
          desc: 'Walk among the treetops through a forest trail near {dest}',
          mins: 90
        ),
        (
          title: 'River Valley Exploration',
          desc: 'Follow a scenic river trail through the valleys around {dest}',
          mins: 120
        ),
      ],
      'evening': [
        (
          title: 'Sunset at Panoramic Viewpoint',
          desc:
              'Watch a breathtaking sunset from {dest}\'s highest accessible point',
          mins: 90
        ),
        (
          title: 'Stargazing Session',
          desc: 'Observe the night sky far from the city lights of {dest}',
          mins: 120
        ),
        (
          title: 'Firefly Nature Walk',
          desc:
              'Witness the magical firefly display in the forests near {dest}',
          mins: 90
        ),
      ],
    },
    TripInterest.shopping: {
      'morning': [
        (
          title: 'Local Artisan Market',
          desc: 'Browse handmade crafts and unique products in {dest}',
          mins: 90
        ),
        (
          title: 'Antique Bazaar',
          desc: 'Hunt for vintage treasures and collectibles across {dest}',
          mins: 90
        ),
        (
          title: 'Morning Handicraft Market',
          desc: 'Discover traditional crafts and artwork in {dest}',
          mins: 75
        ),
      ],
      'afternoon': [
        (
          title: 'Shopping District Exploration',
          desc:
              'Browse boutiques and flagship stores in {dest}\'s main shopping area',
          mins: 120
        ),
        (
          title: 'Souvenir & Keepsake Shopping',
          desc: 'Pick up authentic keepsakes from {dest}\'s best artisan shops',
          mins: 90
        ),
        (
          title: 'Local Textile Market',
          desc: 'Explore fabrics and fashion unique to {dest}',
          mins: 90
        ),
        (
          title: 'Local Products Store Tour',
          desc:
              'Discover specialty stores carrying {dest}\'s finest local goods',
          mins: 75
        ),
      ],
      'evening': [
        (
          title: 'Night Market',
          desc:
              'Browse stalls of local goods, food, and entertainment in {dest}',
          mins: 120
        ),
        (
          title: 'Evening Artisan Fair',
          desc: 'Find unique handmade items from {dest}\'s finest craftspeople',
          mins: 90
        ),
        (
          title: 'Flea & Vintage Market',
          desc:
              'Discover one-of-a-kind vintage items and collectibles in {dest}',
          mins: 90
        ),
      ],
    },
    TripInterest.nightlife: {
      'morning': [
        (
          title: 'Slow Morning Brunch',
          desc: 'Ease into the day with a leisurely brunch in {dest}',
          mins: 90
        ),
        (
          title: 'Panoramic Café Morning',
          desc: 'Enjoy coffee and views at {dest}\'s most scenic café',
          mins: 60
        ),
        (
          title: 'City Stroll & Recovery',
          desc: 'A gentle walk through {dest} to start the day fresh',
          mins: 60
        ),
      ],
      'afternoon': [
        (
          title: 'Craft Beer Tour',
          desc: 'Visit {dest}\'s best craft breweries and taste local brews',
          mins: 120
        ),
        (
          title: 'Cocktail Masterclass',
          desc: 'Learn to mix classic and local cocktails in {dest}',
          mins: 90
        ),
        (
          title: 'Afternoon Jazz Café',
          desc: 'Relax to live jazz at one of {dest}\'s laid-back venues',
          mins: 90
        ),
      ],
      'evening': [
        (
          title: 'Rooftop Bar Experience',
          desc: 'Sip cocktails with panoramic views of {dest} at night',
          mins: 120
        ),
        (
          title: 'Live Music Venue',
          desc: 'Enjoy local bands and performers at a top venue in {dest}',
          mins: 150
        ),
        (
          title: 'Cultural Night Show',
          desc:
              'Attend a vibrant night show blending {dest}\'s music and culture',
          mins: 120
        ),
        (
          title: 'Night Club',
          desc: 'Dance the night away at a popular club in {dest}',
          mins: 180
        ),
      ],
    },
    TripInterest.wellness: {
      'morning': [
        (
          title: 'Sunrise Yoga Session',
          desc: 'Start the day with guided yoga in a peaceful {dest} setting',
          mins: 90
        ),
        (
          title: 'Morning Meditation',
          desc: 'Center yourself with a guided meditation session in {dest}',
          mins: 60
        ),
        (
          title: 'Early Morning Swim',
          desc: 'Rejuvenate with an invigorating early swim near {dest}',
          mins: 60
        ),
        (
          title: 'Mindful Nature Walk',
          desc:
              'A slow, mindful walk through {dest}\'s most peaceful green spaces',
          mins: 75
        ),
      ],
      'afternoon': [
        (
          title: 'Traditional Spa & Massage',
          desc: 'Unwind with traditional massage therapies in {dest}',
          mins: 120
        ),
        (
          title: 'Thermal Baths',
          desc: 'Soak in mineral-rich thermal waters near {dest}',
          mins: 90
        ),
        (
          title: 'Ayurvedic Treatment',
          desc: 'Experience authentic Ayurvedic therapies available in {dest}',
          mins: 120
        ),
        (
          title: 'Sound Healing Session',
          desc: 'Restore balance through a sound bath session in {dest}',
          mins: 75
        ),
      ],
      'evening': [
        (
          title: 'Sunset Meditation',
          desc: 'End the day with a guided meditation at sunset in {dest}',
          mins: 60
        ),
        (
          title: 'Traditional Hammam',
          desc: 'Experience an authentic steam bath and scrub in {dest}',
          mins: 90
        ),
        (
          title: 'Wellness Dinner',
          desc: 'Enjoy a healthy, locally-sourced wellness dinner in {dest}',
          mins: 90
        ),
      ],
    },
  };

  // ─── Day title templates (cycling through days) ───────────────────────────
  static const _dayTitles = [
    'Discovering {dest}',
    'Exploring {dest}',
    'The Heart of {dest}',
    'Hidden Gems of {dest}',
    'A Deeper Look at {dest}',
    'The Local Side of {dest}',
    'Slow Day in {dest}',
    'Adventures Around {dest}',
    'The Best of {dest}',
    'Farewell {dest}',
    'More of {dest}',
    'Another Day in {dest}',
    'Around {dest}',
    'Highlights of {dest}',
  ];

  // ─── Async API (real places via OpenStreetMap) ─────────────────────────────

  /// Fetches real POIs from OpenStreetMap for [destination] and builds a
  /// destination-specific itinerary. Falls back to template generation if
  /// geocoding fails or fewer than [numDays]×3 POIs are returned.
  static Future<List<ItineraryDay>> generateAsync({
    required String destination,
    required int numDays,
    required BudgetType budget,
    required List<TripInterest> interests,
    required PlacesService placesService,
  }) async {
    final location = await placesService.geocode(destination);
    if (location == null) {
      return generate(
        destination: destination,
        numDays: numDays,
        budget: budget,
        interests: interests,
      );
    }

    final places = await placesService.fetchNearbyPois(
      lat: location.lat,
      lng: location.lng,
      interests: interests,
    );

    final minNeeded = numDays * 3;
    if (places.length < minNeeded) {
      // Not enough real places — use templates but inject city coordinates
      // with small offsets so the TSP optimizer has spread coordinates.
      return _fromTemplatesWithCoords(
        destination: destination,
        numDays: numDays,
        budget: budget,
        interests: interests,
        baseLat: location.lat,
        baseLng: location.lng,
      );
    }

    return _fromRealPlaces(
      destination: destination,
      numDays: numDays,
      places: places,
      interests: interests,
    );
  }

  /// Builds itinerary days from real POI data, assigning places to morning /
  /// afternoon / evening slots based on their OSM category.
  static List<ItineraryDay> _fromRealPlaces({
    required String destination,
    required int numDays,
    required List<Place> places,
    required List<TripInterest> interests,
  }) {
    // Split places into slot buckets by category
    final evening = places
        .where((p) => p.category == 'food' || p.category == 'nightlife')
        .toList();
    final daytime = places
        .where((p) => p.category != 'food' && p.category != 'nightlife')
        .toList();

    // Ensure we have enough; if daytime is sparse pull from evening
    while (daytime.length < numDays * 2 && evening.isNotEmpty) {
      daytime.add(evening.removeLast());
    }

    final days = <ItineraryDay>[];
    var dayIdx = 0;
    var daytimeIdx = 0;
    var eveningIdx = 0;

    for (var day = 0; day < numDays; day++) {
      final morningPlace = daytime[daytimeIdx % daytime.length];
      daytimeIdx++;
      final afternoonPlace = daytime[daytimeIdx % daytime.length];
      daytimeIdx++;
      final eveningPlace = evening.isNotEmpty
          ? evening[eveningIdx % evening.length]
          : daytime[daytimeIdx % daytime.length];
      eveningIdx++;

      final titleIdx = dayIdx % _dayTitles.length;
      days.add(ItineraryDay(
        dayNumber: day + 1,
        title: _d(_dayTitles[titleIdx], destination),
        activities: [
          _activityFromPlace(morningPlace, 'morning'),
          _activityFromPlace(afternoonPlace, 'afternoon'),
          _activityFromPlace(eveningPlace, 'evening'),
        ],
      ));
      dayIdx++;
    }

    return days;
  }

  static Activity _activityFromPlace(Place place, String slot) {
    final duration = switch (slot) {
      'morning' => 90,
      'afternoon' => 120,
      _ => 90,
    };
    return Activity(
      id: _uuid.v4(),
      title: place.name,
      description: place.description.isNotEmpty
          ? place.description
          : 'A must-visit spot in the area.',
      timeSlot: slot,
      locationName: place.name,
      latitude: place.lat,
      longitude: place.lng,
      category: place.category,
      estimatedDurationMinutes: duration,
    );
  }

  /// Template-based generation that attaches approximate GPS coordinates so
  /// the TSP optimizer works even before the Places API integration.
  static List<ItineraryDay> _fromTemplatesWithCoords({
    required String destination,
    required int numDays,
    required BudgetType budget,
    required List<TripInterest> interests,
    required double baseLat,
    required double baseLng,
  }) {
    final rng = Random(destination.hashCode);

    double offset() => (rng.nextDouble() - 0.5) * 0.06; // ±~3 km

    final morningPool = _mergePool(interests, 'morning');
    final afternoonPool = _mergePool(interests, 'afternoon');
    final eveningPool = _mergePool(interests, 'evening');

    final days = <ItineraryDay>[];
    for (var day = 0; day < numDays; day++) {
      final titleIdx = day % _dayTitles.length;
      days.add(ItineraryDay(
        dayNumber: day + 1,
        title: _d(_dayTitles[titleIdx], destination),
        activities: [
          _pickWithCoords(morningPool, day, destination, 'morning',
              baseLat + offset(), baseLng + offset()),
          _pickWithCoords(afternoonPool, day, destination, 'afternoon',
              baseLat + offset(), baseLng + offset()),
          _pickWithCoords(eveningPool, day, destination, 'evening',
              baseLat + offset(), baseLng + offset()),
        ],
      ));
    }
    return days;
  }

  static Activity _pickWithCoords(
    List<_T> pool,
    int dayIndex,
    String dest,
    String slot,
    double lat,
    double lng,
  ) {
    final t = pool[dayIndex % pool.length];
    return Activity(
      id: _uuid.v4(),
      title: _d(t.title, dest),
      description: _d(t.desc, dest),
      timeSlot: slot,
      locationName: dest,
      latitude: lat,
      longitude: lng,
      category: slot,
      estimatedDurationMinutes: t.mins,
    );
  }

  // ─── Sync API (template-only, kept for backward compatibility) ─────────────
  static List<ItineraryDay> generate({
    required String destination,
    required int numDays,
    required BudgetType budget,
    required List<TripInterest> interests,
  }) {
    // Build per-slot activity pools merged from all selected interests
    final morningPool = _mergePool(interests, 'morning');
    final afternoonPool = _mergePool(interests, 'afternoon');
    final eveningPool = _mergePool(interests, 'evening');

    final days = <ItineraryDay>[];

    for (var day = 0; day < numDays; day++) {
      final activities = [
        _pick(morningPool, day, destination, 'morning'),
        _pick(afternoonPool, day, destination, 'afternoon'),
        _pick(eveningPool, day, destination, 'evening'),
      ];

      final titleIdx = day % _dayTitles.length;
      days.add(ItineraryDay(
        dayNumber: day + 1,
        title: _d(_dayTitles[titleIdx], destination),
        activities: activities,
      ));
    }

    return days;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Merges activity templates from all selected interests for a given slot.
  static List<_T> _mergePool(List<TripInterest> interests, String slot) {
    final result = <_T>[];
    for (final interest in interests) {
      result.addAll(_pool[interest]?[slot] ?? []);
    }
    // Fallback: if somehow empty, use culture morning
    if (result.isEmpty) result.addAll(_pool[TripInterest.culture]![slot]!);
    return result;
  }

  /// Picks an activity from the pool using the day index to avoid early repeats.
  static Activity _pick(List<_T> pool, int dayIndex, String dest, String slot) {
    final t = pool[dayIndex % pool.length];
    return Activity(
      id: _uuid.v4(),
      title: _d(t.title, dest),
      description: _d(t.desc, dest),
      timeSlot: slot,
      locationName: dest,
      latitude: 0.0,
      longitude: 0.0,
      category: slot,
      estimatedDurationMinutes: t.mins,
    );
  }
}
