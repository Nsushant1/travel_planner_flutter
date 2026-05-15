import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/place.dart';
import '../models/trip.dart';

const _uuid = Uuid();

class GeocodedLocation {
  final double lat;
  final double lng;
  final String displayName;

  const GeocodedLocation({
    required this.lat,
    required this.lng,
    required this.displayName,
  });
}

class PlacesService {
  static const _nominatim = 'https://nominatim.openstreetmap.org';
  static const _overpass = 'https://overpass-api.de/api/interpreter';
  static const _userAgent = 'TripGenie/1.0 (Flutter travel planner)';

  final Dio _dio;

  PlacesService(this._dio);

  // ─── Geocoding ──────────────────────────────────────────────────────────────

  Future<GeocodedLocation?> geocode(String destination) async {
    try {
      final resp = await _dio.get(
        '$_nominatim/search',
        queryParameters: {
          'q': destination,
          'format': 'json',
          'limit': 1,
          'addressdetails': 0,
        },
        options: Options(headers: {'User-Agent': _userAgent}),
      );
      final data = resp.data as List<dynamic>;
      if (data.isEmpty) return null;
      final item = data.first as Map<String, dynamic>;
      return GeocodedLocation(
        lat: double.parse(item['lat'] as String),
        lng: double.parse(item['lon'] as String),
        displayName: item['display_name'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  // ─── POI fetching via Overpass ──────────────────────────────────────────────

  Future<List<Place>> fetchNearbyPois({
    required double lat,
    required double lng,
    required List<TripInterest> interests,
    int radiusMeters = 15000,
    int maxResults = 90,
  }) async {
    final query = _buildOverpassQuery(lat, lng, radiusMeters, interests);
    try {
      final resp = await _dio.post(
        _overpass,
        data: query,
        options: Options(
          headers: {'User-Agent': _userAgent},
          contentType: 'application/x-www-form-urlencoded',
        ),
      );
      final elements = (resp.data['elements'] as List<dynamic>?) ?? [];
      final places = <Place>[];

      for (final el in elements) {
        final map = el as Map<String, dynamic>;
        final tags = (map['tags'] as Map<String, dynamic>?) ?? {};

        final name = (tags['name:en'] as String?) ?? (tags['name'] as String?);
        if (name == null || name.trim().isEmpty) continue;

        // Prefer node coords; for way/relation use center
        double? eLat, eLng;
        if (map['type'] == 'node') {
          eLat = (map['lat'] as num?)?.toDouble();
          eLng = (map['lon'] as num?)?.toDouble();
        } else {
          final center = map['center'] as Map<String, dynamic>?;
          eLat = (center?['lat'] as num?)?.toDouble();
          eLng = (center?['lon'] as num?)?.toDouble();
        }
        if (eLat == null || eLng == null) continue;

        places.add(Place(
          id: _uuid.v4(),
          name: name.trim(),
          description: _buildDescription(tags),
          lat: eLat,
          lng: eLng,
          category: _classifyCategory(tags, interests),
        ));

        if (places.length >= maxResults) break;
      }
      return places;
    } catch (_) {
      return [];
    }
  }

  // ─── Overpass query builder ─────────────────────────────────────────────────

  String _buildOverpassQuery(
    double lat,
    double lng,
    int radius,
    List<TripInterest> interests,
  ) {
    final buf = StringBuffer();
    buf.write('[out:json][timeout:25];\n(\n');

    final around = 'around:$radius,$lat,$lng';

    // Always fetch tourism & historic attractions
    buf.write('  node[tourism~"museum|gallery|attraction|monument|castle|viewpoint|zoo|aquarium|theme_park"][$around];\n');
    buf.write('  way[tourism~"museum|gallery|attraction|monument|castle|viewpoint"][$around];\n');
    buf.write('  node[historic~"monument|castle|ruins|archaeological_site|memorial|mosque|church|temple"][$around];\n');

    if (interests.contains(TripInterest.food) || interests.contains(TripInterest.nightlife)) {
      buf.write('  node[amenity~"restaurant|cafe|bar|food_court|fast_food"][$around];\n');
      buf.write('  node[amenity~"nightclub|pub|brewery"][$around];\n');
    }

    if (interests.contains(TripInterest.nature) || interests.contains(TripInterest.adventure)) {
      buf.write('  node[natural~"peak|waterfall|spring|cave_entrance|beach|cliff"][$around];\n');
      buf.write('  node[leisure~"nature_reserve|park|garden"][$around];\n');
      buf.write('  way[leisure~"nature_reserve|park|garden"][$around];\n');
    }

    if (interests.contains(TripInterest.shopping)) {
      buf.write('  node[shop~"mall|market|department_store|souvenir"][$around];\n');
      buf.write('  node[amenity~"marketplace"][$around];\n');
    }

    if (interests.contains(TripInterest.wellness)) {
      buf.write('  node[amenity~"spa|massage|swimming_pool|sauna"][$around];\n');
      buf.write('  node[leisure~"spa|fitness_centre|swimming_pool"][$around];\n');
    }

    buf.write(');\nout center 150;\n');
    return 'data=${Uri.encodeComponent(buf.toString())}';
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _buildDescription(Map<String, dynamic> tags) {
    final parts = <String>[];

    final tourism = tags['tourism'] as String?;
    final historic = tags['historic'] as String?;
    final amenity = tags['amenity'] as String?;
    final leisure = tags['leisure'] as String?;
    final natural = tags['natural'] as String?;

    if (tourism != null) parts.add(_humanize(tourism));
    if (historic != null) parts.add(_humanize(historic));
    if (amenity != null) parts.add(_humanize(amenity));
    if (leisure != null) parts.add(_humanize(leisure));
    if (natural != null) parts.add(_humanize(natural));

    final openingHours = tags['opening_hours'] as String?;
    if (openingHours != null) parts.add('Hours: $openingHours');

    return parts.join(' • ');
  }

  String _humanize(String s) =>
      s.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  String _classifyCategory(
    Map<String, dynamic> tags,
    List<TripInterest> interests,
  ) {
    final tourism = tags['tourism'] as String? ?? '';
    final historic = tags['historic'] as String? ?? '';
    final amenity = tags['amenity'] as String? ?? '';
    final leisure = tags['leisure'] as String? ?? '';
    final natural = tags['natural'] as String? ?? '';
    final shop = tags['shop'] as String? ?? '';

    if (amenity == 'restaurant' || amenity == 'cafe' || amenity == 'fast_food' || amenity == 'food_court') {
      return 'food';
    }
    if (amenity == 'bar' || amenity == 'nightclub' || amenity == 'pub' || amenity == 'brewery') {
      return 'nightlife';
    }
    if (natural.isNotEmpty) return 'nature';
    if (leisure == 'nature_reserve' || leisure == 'park' || leisure == 'garden') return 'nature';
    if (shop.isNotEmpty || amenity == 'marketplace') return 'shopping';
    if (leisure == 'spa' || amenity == 'spa' || amenity == 'massage' || amenity == 'swimming_pool') {
      return 'wellness';
    }
    if (tourism == 'viewpoint' || tourism == 'attraction') return 'culture';
    if (historic.isNotEmpty) return 'culture';
    if (tourism.isNotEmpty) return 'culture';
    return 'culture';
  }
}

final placesServiceProvider = Provider<PlacesService>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 25),
  ));
  return PlacesService(dio);
});
