import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/config/app_config.dart';
import 'package:travel_planner/data/models/weather_data.dart';

class WeatherService {
  static const _base = 'https://api.openweathermap.org/data/2.5';

  final Dio _dio;
  WeatherService(this._dio);

  /// Fetches current weather + up to [numDays] days of daily forecast.
  /// Returns null if the API key is missing or the city is not found.
  Future<WeatherData?> fetchWeather(String destination, int numDays) async {
    final key = AppConfig.openWeatherApiKey;
    if (key.isEmpty) return null;

    try {
      final results = await Future.wait([
        _dio.get('$_base/weather', queryParameters: {
          'q': destination,
          'units': 'metric',
          'appid': key,
        }),
        _dio.get('$_base/forecast', queryParameters: {
          'q': destination,
          'cnt': 40, // 5 days × 8 three-hour slots
          'units': 'metric',
          'appid': key,
        }),
      ]);

      final current = results[0].data as Map<String, dynamic>;
      final forecastRaw = results[1].data as Map<String, dynamic>;

      return WeatherData(
        currentTemp: (current['main']['temp'] as num).toDouble(),
        feelsLike: (current['main']['feels_like'] as num).toDouble(),
        description: (current['weather'][0]['description'] as String),
        iconCode: current['weather'][0]['icon'] as String,
        humidity: current['main']['humidity'] as int,
        windSpeed: (current['wind']['speed'] as num).toDouble(),
        forecast: _parseForecast(forecastRaw['list'] as List<dynamic>, numDays),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null; // city not found
      rethrow;
    }
  }

  List<DayWeather> _parseForecast(List<dynamic> items, int numDays) {
    // Group 3-hour slots by calendar date, compute daily min/max
    final Map<String, List<Map<String, dynamic>>> byDay = {};
    for (final item in items) {
      final map = item as Map<String, dynamic>;
      final dtTxt = map['dt_txt'] as String; // "2024-01-15 12:00:00"
      final day = dtTxt.substring(0, 10); // "2024-01-15"
      byDay.putIfAbsent(day, () => []).add(map);
    }

    return byDay.entries.take(numDays).map((e) {
      final slots = e.value;
      final temps =
          slots.map((s) => (s['main']['temp'] as num).toDouble()).toList();
      final humidities =
          slots.map((s) => s['main']['humidity'] as int).toList();
      final winds =
          slots.map((s) => (s['wind']['speed'] as num).toDouble()).toList();

      // Pick the midday slot (12:00) for icon/description, fall back to first
      final midday = slots.firstWhere(
        (s) => (s['dt_txt'] as String).contains('12:00'),
        orElse: () => slots.first,
      );

      return DayWeather(
        date: DateTime.parse(e.key),
        tempMin: temps.reduce((a, b) => a < b ? a : b),
        tempMax: temps.reduce((a, b) => a > b ? a : b),
        description: midday['weather'][0]['description'] as String,
        iconCode: midday['weather'][0]['icon'] as String,
        humidity:
            (humidities.reduce((a, b) => a + b) / humidities.length).round(),
        windSpeed: winds.reduce((a, b) => a + b) / winds.length,
      );
    }).toList();
  }
}

final weatherServiceProvider = Provider<WeatherService>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));
  return WeatherService(dio);
});
