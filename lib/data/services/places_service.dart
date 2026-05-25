import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_planner/core/config/app_config.dart';
import 'package:travel_planner/data/models/place.dart';
import 'package:travel_planner/data/models/trip.dart';

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
  static const _geocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';
  static const _nearbyUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  final Dio _dio;
  PlacesService(this._dio);

  // ─── Geocoding ──────────────────────────────────────────────────────────────

  Future<GeocodedLocation?> geocode(String destination) async {
    try {
      final resp = await _dio.get(
        _geocodeUrl,
        queryParameters: {
          'address': destination,
          'key': AppConfig.googleMapsApiKey,
        },
      );
      final results = (resp.data['results'] as List<dynamic>?) ?? [];
      if (results.isEmpty) return null;
      final first = results.first as Map<String, dynamic>;
      final loc = first['geometry']['location'] as Map<String, dynamic>;
      return GeocodedLocation(
        lat: (loc['lat'] as num).toDouble(),
        lng: (loc['lng'] as num).toDouble(),
        displayName: first['formatted_address'] as String,
      );
    } catch (e, st) {
      debugPrint('PlacesService.geocode error: $e\n$st');
      return null;
    }
  }

  // ─── POI fetching via Google Places Nearby Search ──────────────────────────

  Future<List<Place>> fetchNearbyPois({
    required double lat,
    required double lng,
    required List<TripInterest> interests,
    int radiusMeters = 15000,
    int maxResults = 90,
  }) async {
    final types = _typesForInterests(interests);
    final results = await Future.wait(
      types.map((t) => _fetchByType(lat, lng, radiusMeters, t)),
    );

    final seen = <String>{};
    final places = <Place>[];
    for (final batch in results) {
      for (final p in batch) {
        if (seen.add(p.name.toLowerCase()) && places.length < maxResults) {
          places.add(p);
        }
      }
    }
    return places;
  }

  List<String> _typesForInterests(List<TripInterest> interests) {
    final types = <String>{'tourist_attraction', 'museum'};
    for (final interest in interests) {
      switch (interest) {
        case TripInterest.food:
          types.addAll(['restaurant', 'cafe']);
        case TripInterest.nightlife:
          types.addAll(['bar', 'night_club']);
        case TripInterest.nature:
          types.addAll(['park', 'natural_feature']);
        case TripInterest.shopping:
          types.add('shopping_mall');
        case TripInterest.wellness:
          types.add('spa');
        case TripInterest.adventure:
          types.add('amusement_park');
        case TripInterest.culture:
          types.addAll(['art_gallery', 'church']);
      }
    }
    return types.toList();
  }

  Future<List<Place>> _fetchByType(
    double lat,
    double lng,
    int radius,
    String type,
  ) async {
    try {
      final resp = await _dio.get(
        _nearbyUrl,
        queryParameters: {
          'location': '$lat,$lng',
          'radius': radius,
          'type': type,
          'key': AppConfig.googleMapsApiKey,
        },
      );
      final results = (resp.data['results'] as List<dynamic>?) ?? [];
      final places = <Place>[];
      for (final el in results) {
        final map = el as Map<String, dynamic>;
        final name = (map['name'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;
        final geo = map['geometry']?['location'] as Map<String, dynamic>?;
        final pLat = (geo?['lat'] as num?)?.toDouble();
        final pLng = (geo?['lng'] as num?)?.toDouble();
        if (pLat == null || pLng == null) continue;
        final placeTypes =
            (map['types'] as List<dynamic>?)?.cast<String>() ?? [];
        places.add(Place(
          id: _uuid.v4(),
          name: name,
          description: _buildDescription(placeTypes, map['vicinity'] as String?),
          lat: pLat,
          lng: pLng,
          category: _classifyCategory(placeTypes),
        ));
      }
      return places;
    } catch (e, st) {
      debugPrint('PlacesService._fetchByType($type) error: $e\n$st');
      return [];
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _buildDescription(List<String> types, String? vicinity) {
    final parts = <String>[];
    if (types.isNotEmpty) parts.add(_humanize(types.first));
    if (vicinity != null && vicinity.isNotEmpty) parts.add(vicinity);
    return parts.join(' • ');
  }

  String _humanize(String s) =>
      s.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  String _classifyCategory(List<String> types) {
    for (final t in types) {
      if (t == 'restaurant' || t == 'cafe' || t == 'food' ||
          t == 'bakery' || t == 'meal_takeaway') {
        return 'food';
      }
      if (t == 'bar' || t == 'night_club') { return 'nightlife'; }
      if (t == 'park' || t == 'natural_feature' || t == 'campground') {
        return 'nature';
      }
      if (t == 'shopping_mall' || t == 'store' || t == 'department_store') {
        return 'shopping';
      }
      if (t == 'spa' || t == 'gym' || t == 'beauty_salon') { return 'wellness'; }
    }
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
