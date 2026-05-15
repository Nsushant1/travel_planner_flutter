import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/weather_data.dart';
import '../../../data/services/weather_service.dart';

/// Keyed by destination string. Returns null if API key missing or city unknown.
final weatherProvider =
    FutureProvider.family<WeatherData?, String>((ref, destination) async {
  if (destination.trim().isEmpty) return null;
  return ref
      .watch(weatherServiceProvider)
      .fetchWeather(destination.trim(), 7);
});
