import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:travel_planner/data/models/activity.dart';
import 'package:travel_planner/data/models/itinerary_day.dart';
import 'package:travel_planner/data/models/place.dart';
import 'package:travel_planner/data/models/trip.dart';
import 'places_service.dart';

// geo: which natural feature this template requires (null = works anywhere)
// Recognized values: 'water', 'mountain', 'forest', 'thermal'
typedef _T = ({String title, String desc, int mins, String? geo});

class ItineraryGenerator {
  static const _uuid = Uuid();

  static String _d(String s, String dest) => s.replaceAll('{dest}', dest);

  // ─── Templates skipped for each budget level ──────────────────────────────
  static const Map<BudgetType, Set<String>> _budgetSkip = {
    BudgetType.low: {
      'Night Club',
      'Rooftop Bar Experience',
      'Fine Dining Experience',
      'Cocktail Masterclass',
      'Craft Beer Tour',
      'Local Brewery Tour',
      'Traditional Spa & Massage',
      'Ayurvedic Treatment',
      'Sound Healing Session',
      'Traditional Hammam',
      'Wellness Dinner',
      'Thermal Baths',
      'Afternoon Jazz Café',
    },
    BudgetType.medium: {},
    BudgetType.high: {},
  };

  // ─── Activity pool: interest → timeslot → templates ───────────────────────
  static const Map<TripInterest, Map<String, List<_T>>> _pool = {
    TripInterest.culture: {
      'morning': [
        (title: 'Historic Walk', desc: 'Explore the ancient streets and landmarks of {dest}', mins: 90, geo: null),
        (title: 'Temple & Shrine Visit', desc: 'Discover the spiritual heritage sites of {dest}', mins: 60, geo: null),
        (title: 'Archaeological Museum', desc: 'Uncover the centuries of history behind {dest}', mins: 90, geo: null),
        (title: 'Old Quarter Tour', desc: 'Wander through the preserved old quarter of {dest}', mins: 90, geo: null),
        (title: 'Heritage Monument Walk', desc: 'Visit the iconic monuments that define {dest}', mins: 75, geo: null),
      ],
      'afternoon': [
        (title: 'Art Gallery Tour', desc: 'Browse works by local artists in {dest}\'s finest gallery', mins: 120, geo: null),
        (title: 'Cultural Heritage Site', desc: 'Walk through a UNESCO-listed or protected site in {dest}', mins: 90, geo: null),
        (title: 'Craft & Textile Workshop', desc: 'Learn traditional craftsmanship unique to {dest}', mins: 120, geo: null),
        (title: 'Local History Museum', desc: 'Deep-dive into the stories that shaped {dest}', mins: 90, geo: null),
        (title: 'Guided City Tour', desc: 'Let a local guide reveal the hidden stories of {dest}', mins: 120, geo: null),
      ],
      'evening': [
        (title: 'Traditional Folk Performance', desc: 'Watch authentic music and dance of {dest} at a local venue', mins: 120, geo: null),
        (title: 'Illuminated Heritage Walk', desc: 'Explore {dest}\'s historic sites beautifully lit at night', mins: 90, geo: null),
        (title: 'Cultural Storytelling Evening', desc: 'Listen to local storytellers share the myths and legends of {dest}', mins: 90, geo: null),
        (title: 'Local Theater Show', desc: 'Enjoy a traditional theater production in {dest}', mins: 120, geo: null),
      ],
    },
    TripInterest.food: {
      'morning': [
        (title: 'Traditional Breakfast', desc: 'Start the day with an authentic {dest} breakfast spread', mins: 60, geo: null),
        (title: 'Street Food Walk', desc: 'Sample fresh morning street delicacies across {dest}', mins: 90, geo: null),
        (title: 'Local Bakery Visit', desc: 'Taste freshly baked breads and pastries unique to {dest}', mins: 60, geo: null),
        (title: 'Morning Food Market', desc: 'Explore the lively early-morning food stalls of {dest}', mins: 75, geo: null),
      ],
      'afternoon': [
        (title: 'Award-Winning Local Lunch', desc: 'Savor the finest regional cuisine {dest} has to offer', mins: 90, geo: null),
        (title: 'Food Market Exploration', desc: 'Browse vibrant stalls of fresh produce and local specialties in {dest}', mins: 90, geo: null),
        (title: 'Cooking Class', desc: 'Learn to prepare authentic {dest} dishes with a local chef', mins: 150, geo: null),
        (title: 'Spice & Flavour Market', desc: 'Discover the aromatic spice markets that define {dest}\'s cuisine', mins: 75, geo: null),
        (title: 'Café Culture Tour', desc: 'Hop through {dest}\'s most beloved local cafés', mins: 90, geo: null),
      ],
      'evening': [
        (title: 'Street Food Dinner Tour', desc: 'Explore the best street eats as {dest} comes alive at night', mins: 120, geo: null),
        (title: 'Fine Dining Experience', desc: 'Enjoy a curated tasting menu showcasing {dest}\'s best flavours', mins: 120, geo: null),
        (title: 'Night Food Market', desc: 'Browse a bustling night market packed with {dest} vendors', mins: 90, geo: null),
        (title: 'Local Brewery Tour', desc: 'Taste craft brews and local spirits unique to {dest}', mins: 90, geo: null),
      ],
    },
    TripInterest.adventure: {
      'morning': [
        (title: 'Sunrise Hike', desc: 'Trek to a scenic viewpoint above {dest} for spectacular views', mins: 150, geo: 'mountain'),
        (title: 'Mountain Biking Trail', desc: 'Cycle through the rugged terrain around {dest}', mins: 120, geo: 'mountain'),
        (title: 'Kayaking Session', desc: 'Paddle through the waterways near {dest}', mins: 120, geo: 'water'),
        (title: 'Rock Climbing', desc: 'Scale natural rock faces near {dest} with expert guides', mins: 150, geo: 'mountain'),
        (title: 'Trekking Expedition', desc: 'Head out on a guided trek through the wilderness near {dest}', mins: 180, geo: null),
      ],
      'afternoon': [
        (title: 'River Rafting', desc: 'Navigate exciting rapids on the rivers near {dest}', mins: 150, geo: 'water'),
        (title: 'Zip Line Adventure', desc: 'Soar above the treetops for a bird\'s-eye view of {dest}', mins: 90, geo: 'forest'),
        (title: 'ATV Off-Road Tour', desc: 'Explore the rugged outskirts of {dest} on an ATV', mins: 120, geo: null),
        (title: 'Rappelling & Canyoning', desc: 'Descend dramatic cliff faces near {dest}', mins: 150, geo: 'mountain'),
        (title: 'Paragliding', desc: 'Glide above the stunning landscape surrounding {dest}', mins: 90, geo: 'mountain'),
      ],
      'evening': [
        (title: 'Campfire Under the Stars', desc: 'Gather around a fire with stories and local snacks near {dest}', mins: 120, geo: null),
        (title: 'Night Safari', desc: 'Discover nocturnal wildlife in the areas around {dest}', mins: 120, geo: 'forest'),
        (title: 'Cliff-Side Sunset', desc: 'Watch the sun go down from a dramatic vantage point near {dest}', mins: 90, geo: 'mountain'),
      ],
    },
    TripInterest.nature: {
      'morning': [
        (title: 'Botanical Garden Walk', desc: 'Explore thousands of plant species in {dest}\'s serene gardens', mins: 90, geo: null),
        (title: 'Bird Watching at Dawn', desc: 'Spot rare and colorful bird species around {dest} at sunrise', mins: 120, geo: null),
        (title: 'Waterfall Trek', desc: 'Hike through lush forest to a stunning waterfall near {dest}', mins: 150, geo: 'water'),
        (title: 'Nature Photography Walk', desc: 'Capture the golden hour in the natural landscapes of {dest}', mins: 90, geo: null),
      ],
      'afternoon': [
        (title: 'National Park Exploration', desc: 'Hike and explore the protected natural landscapes near {dest}', mins: 180, geo: null),
        (title: 'Wildlife Sanctuary Visit', desc: 'Observe native animals in their natural habitat near {dest}', mins: 120, geo: 'forest'),
        (title: 'Scenic Lake Visit', desc: 'Relax by a picturesque lake in the vicinity of {dest}', mins: 90, geo: 'water'),
        (title: 'Forest Canopy Walk', desc: 'Walk among the treetops through a forest trail near {dest}', mins: 90, geo: 'forest'),
        (title: 'River Valley Exploration', desc: 'Follow a scenic river trail through the valleys around {dest}', mins: 120, geo: 'water'),
      ],
      'evening': [
        (title: 'Sunset at Panoramic Viewpoint', desc: 'Watch a breathtaking sunset from {dest}\'s highest accessible point', mins: 90, geo: null),
        (title: 'Stargazing Session', desc: 'Observe the night sky far from the city lights of {dest}', mins: 120, geo: null),
        (title: 'Firefly Nature Walk', desc: 'Witness the magical firefly display in the forests near {dest}', mins: 90, geo: 'forest'),
      ],
    },
    TripInterest.shopping: {
      'morning': [
        (title: 'Local Artisan Market', desc: 'Browse handmade crafts and unique products in {dest}', mins: 90, geo: null),
        (title: 'Antique Bazaar', desc: 'Hunt for vintage treasures and collectibles across {dest}', mins: 90, geo: null),
        (title: 'Morning Handicraft Market', desc: 'Discover traditional crafts and artwork in {dest}', mins: 75, geo: null),
      ],
      'afternoon': [
        (title: 'Shopping District Exploration', desc: 'Browse boutiques and flagship stores in {dest}\'s main shopping area', mins: 120, geo: null),
        (title: 'Souvenir & Keepsake Shopping', desc: 'Pick up authentic keepsakes from {dest}\'s best artisan shops', mins: 90, geo: null),
        (title: 'Local Textile Market', desc: 'Explore fabrics and fashion unique to {dest}', mins: 90, geo: null),
        (title: 'Local Products Store Tour', desc: 'Discover specialty stores carrying {dest}\'s finest local goods', mins: 75, geo: null),
      ],
      'evening': [
        (title: 'Night Market', desc: 'Browse stalls of local goods, food, and entertainment in {dest}', mins: 120, geo: null),
        (title: 'Evening Artisan Fair', desc: 'Find unique handmade items from {dest}\'s finest craftspeople', mins: 90, geo: null),
        (title: 'Flea & Vintage Market', desc: 'Discover one-of-a-kind vintage items and collectibles in {dest}', mins: 90, geo: null),
      ],
    },
    TripInterest.nightlife: {
      'morning': [
        (title: 'Slow Morning Brunch', desc: 'Ease into the day with a leisurely brunch in {dest}', mins: 90, geo: null),
        (title: 'Panoramic Café Morning', desc: 'Enjoy coffee and views at {dest}\'s most scenic café', mins: 60, geo: null),
        (title: 'City Stroll & Recovery', desc: 'A gentle walk through {dest} to start the day fresh', mins: 60, geo: null),
      ],
      'afternoon': [
        (title: 'Craft Beer Tour', desc: 'Visit {dest}\'s best craft breweries and taste local brews', mins: 120, geo: null),
        (title: 'Cocktail Masterclass', desc: 'Learn to mix classic and local cocktails in {dest}', mins: 90, geo: null),
        (title: 'Afternoon Jazz Café', desc: 'Relax to live jazz at one of {dest}\'s laid-back venues', mins: 90, geo: null),
      ],
      'evening': [
        (title: 'Rooftop Bar Experience', desc: 'Sip cocktails with panoramic views of {dest} at night', mins: 120, geo: null),
        (title: 'Live Music Venue', desc: 'Enjoy local bands and performers at a top venue in {dest}', mins: 150, geo: null),
        (title: 'Cultural Night Show', desc: 'Attend a vibrant night show blending {dest}\'s music and culture', mins: 120, geo: null),
        (title: 'Night Club', desc: 'Dance the night away at a popular club in {dest}', mins: 180, geo: null),
      ],
    },
    TripInterest.wellness: {
      'morning': [
        (title: 'Sunrise Yoga Session', desc: 'Start the day with guided yoga in a peaceful {dest} setting', mins: 90, geo: null),
        (title: 'Morning Meditation', desc: 'Center yourself with a guided meditation session in {dest}', mins: 60, geo: null),
        (title: 'Early Morning Swim', desc: 'Rejuvenate with an invigorating early swim near {dest}', mins: 60, geo: null),
        (title: 'Mindful Nature Walk', desc: 'A slow, mindful walk through {dest}\'s most peaceful green spaces', mins: 75, geo: null),
      ],
      'afternoon': [
        (title: 'Traditional Spa & Massage', desc: 'Unwind with traditional massage therapies in {dest}', mins: 120, geo: null),
        (title: 'Thermal Baths', desc: 'Soak in mineral-rich thermal waters near {dest}', mins: 90, geo: 'thermal'),
        (title: 'Ayurvedic Treatment', desc: 'Experience authentic Ayurvedic therapies available in {dest}', mins: 120, geo: null),
        (title: 'Sound Healing Session', desc: 'Restore balance through a sound bath session in {dest}', mins: 75, geo: null),
      ],
      'evening': [
        (title: 'Sunset Meditation', desc: 'End the day with a guided meditation at sunset in {dest}', mins: 60, geo: null),
        (title: 'Traditional Hammam', desc: 'Experience an authentic steam bath and scrub in {dest}', mins: 90, geo: null),
        (title: 'Wellness Dinner', desc: 'Enjoy a healthy, locally-sourced wellness dinner in {dest}', mins: 90, geo: null),
      ],
    },
  };

  // ─── Day title templates ───────────────────────────────────────────────────
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

  // ─── Geography detection ───────────────────────────────────────────────────

  /// Infers available natural features from place names and the geocoded
  /// display name. The returned set drives template filtering so that activities
  /// requiring specific terrain (mountain, water, forest, thermal) are only
  /// suggested when that terrain actually exists near the destination.
  static Set<String> detectGeoFeatures(
    List<Place> places,
    String displayName,
  ) {
    final features = <String>{};
    final lower = displayName.toLowerCase();

    // Check geocoded display name for geographic keywords
    final coastWords = ['coast', 'beach', 'bay', 'harbor', 'harbour', 'sea ', 'ocean', 'gulf', 'cove', 'lagoon'];
    final mountainWords = ['mountain', 'mount ', 'mt.', 'hill', 'peak', 'highland', 'alps', 'range', 'ridge'];
    final forestWords = ['forest', 'jungle', 'rainforest', 'woodland', 'wood'];
    final waterWords = ['river', 'lake', 'waterfall', 'falls', 'stream', 'canal', 'reservoir'];
    final thermalWords = ['thermal', 'hot spring', 'geyser', 'spa resort'];

    if (coastWords.any(lower.contains)) features.add('water');
    if (mountainWords.any(lower.contains)) features.add('mountain');
    if (forestWords.any(lower.contains)) features.add('forest');
    if (waterWords.any(lower.contains)) features.add('water');
    if (thermalWords.any(lower.contains)) features.add('thermal');

    // Check place names for geographic indicators
    for (final p in places) {
      final name = p.name.toLowerCase();
      if (coastWords.any(name.contains) || waterWords.any(name.contains)) {
        features.add('water');
      }
      if (mountainWords.any(name.contains)) features.add('mountain');
      if (forestWords.any(name.contains)) features.add('forest');
      if (thermalWords.any(name.contains)) features.add('thermal');
      if (p.category == 'nature') features.add('forest');
    }

    return features;
  }

  // ─── Async API (real places via Google Maps) ───────────────────────────────

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

    final geoFeatures = detectGeoFeatures(places, location.displayName);

    final minNeeded = numDays * 3;
    if (places.length < minNeeded) {
      return _fromTemplatesWithCoords(
        destination: destination,
        numDays: numDays,
        budget: budget,
        interests: interests,
        baseLat: location.lat,
        baseLng: location.lng,
        geoFeatures: geoFeatures,
      );
    }

    return _fromRealPlaces(
      destination: destination,
      numDays: numDays,
      places: places,
      interests: interests,
      budget: budget,
    );
  }

  // ─── Real-places path ──────────────────────────────────────────────────────

  static List<ItineraryDay> _fromRealPlaces({
    required String destination,
    required int numDays,
    required List<Place> places,
    required List<TripInterest> interests,
    required BudgetType budget,
  }) {
    // 1. Budget-based category filtering
    final filtered = places.where((p) {
      if (budget == BudgetType.low && p.category == 'nightlife') return false;
      return true;
    }).toList();

    // 2. Seeded shuffle so same destination gives a consistent but varied order
    filtered.shuffle(Random(destination.hashCode));

    // 3. Split into daytime (culture/nature/etc.) and evening (food/nightlife) pools
    final daytime = <Place>[];
    final evening = <Place>[];
    for (final p in filtered) {
      if (p.category == 'food' || p.category == 'nightlife') {
        evening.add(p);
      } else {
        daytime.add(p);
      }
    }

    // Top up daytime if sparse
    while (daytime.length < numDays * 2 && evening.isNotEmpty) {
      daytime.add(evening.removeLast());
    }

    // 4. Deduplicated iterators — no venue appears twice across the whole trip
    final usedNames = <String>{};
    int dtCursor = 0;
    int evCursor = 0;

    Place pickDaytime() {
      for (var attempt = 0; attempt < daytime.length; attempt++) {
        final p = daytime[dtCursor % daytime.length];
        dtCursor++;
        if (usedNames.add(p.name.toLowerCase())) return p;
      }
      final p = daytime[dtCursor % daytime.length];
      dtCursor++;
      return p;
    }

    Place pickEvening() {
      final pool = evening.isNotEmpty ? evening : daytime;
      for (var attempt = 0; attempt < pool.length; attempt++) {
        final p = pool[evCursor % pool.length];
        evCursor++;
        if (usedNames.add(p.name.toLowerCase())) return p;
      }
      final p = pool[evCursor % pool.length];
      evCursor++;
      return p;
    }

    final days = <ItineraryDay>[];
    for (var day = 0; day < numDays; day++) {
      days.add(ItineraryDay(
        dayNumber: day + 1,
        title: _d(_dayTitles[day % _dayTitles.length], destination),
        activities: [
          _activityFromPlace(pickDaytime(), 'morning'),
          _activityFromPlace(pickDaytime(), 'afternoon'),
          _activityFromPlace(pickEvening(), 'evening'),
        ],
      ));
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

  // ─── Template path with GPS coordinates ───────────────────────────────────

  static List<ItineraryDay> _fromTemplatesWithCoords({
    required String destination,
    required int numDays,
    required BudgetType budget,
    required List<TripInterest> interests,
    required double baseLat,
    required double baseLng,
    required Set<String> geoFeatures,
  }) {
    final rng = Random(destination.hashCode);
    double offset() => (rng.nextDouble() - 0.5) * 0.06;

    final morningPool = _mergePool(interests, 'morning', budget, geoFeatures);
    final afternoonPool = _mergePool(interests, 'afternoon', budget, geoFeatures);
    final eveningPool = _mergePool(interests, 'evening', budget, geoFeatures);

    final days = <ItineraryDay>[];
    for (var day = 0; day < numDays; day++) {
      days.add(ItineraryDay(
        dayNumber: day + 1,
        title: _d(_dayTitles[day % _dayTitles.length], destination),
        activities: [
          _pickWithCoords(morningPool, day, destination, 'morning', baseLat + offset(), baseLng + offset()),
          _pickWithCoords(afternoonPool, day, destination, 'afternoon', baseLat + offset(), baseLng + offset()),
          _pickWithCoords(eveningPool, day, destination, 'evening', baseLat + offset(), baseLng + offset()),
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

  // ─── Sync API (template-only, no location info) ────────────────────────────

  static List<ItineraryDay> generate({
    required String destination,
    required int numDays,
    required BudgetType budget,
    required List<TripInterest> interests,
  }) {
    // No geo info available — empty set means geo filtering is skipped
    const geoFeatures = <String>{};
    final morningPool = _mergePool(interests, 'morning', budget, geoFeatures);
    final afternoonPool = _mergePool(interests, 'afternoon', budget, geoFeatures);
    final eveningPool = _mergePool(interests, 'evening', budget, geoFeatures);

    final days = <ItineraryDay>[];
    for (var day = 0; day < numDays; day++) {
      days.add(ItineraryDay(
        dayNumber: day + 1,
        title: _d(_dayTitles[day % _dayTitles.length], destination),
        activities: [
          _pick(morningPool, day, destination, 'morning'),
          _pick(afternoonPool, day, destination, 'afternoon'),
          _pick(eveningPool, day, destination, 'evening'),
        ],
      ));
    }
    return days;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Merges templates from all selected interests for a slot, filtered by
  /// budget level and available geographic features.
  static List<_T> _mergePool(
    List<TripInterest> interests,
    String slot,
    BudgetType budget,
    Set<String> geoFeatures,
  ) {
    final skip = _budgetSkip[budget] ?? const {};
    final result = <_T>[];

    for (final interest in interests) {
      for (final t in _pool[interest]?[slot] ?? const <_T>[]) {
        // Skip templates excluded by budget
        if (skip.contains(t.title)) continue;
        // Skip templates requiring a geo feature we haven't detected
        // (only applies when we have actual geo data; empty set = no filtering)
        if (t.geo != null && geoFeatures.isNotEmpty && !geoFeatures.contains(t.geo)) continue;
        result.add(t);
      }
    }

    // Fallback: use universal culture templates (geo: null, always valid)
    if (result.isEmpty) {
      result.addAll(
        _pool[TripInterest.culture]![slot]!.where((t) => t.geo == null),
      );
    }
    return result;
  }

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
