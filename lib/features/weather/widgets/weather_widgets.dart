import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/weather_data.dart';

// ─── Icon mapping ─────────────────────────────────────────────────────────────

IconData weatherIcon(String owmCode) {
  final code = owmCode.substring(0, 2);
  return switch (code) {
    '01' => Icons.wb_sunny_rounded,
    '02' => Icons.wb_cloudy_rounded,
    '03' || '04' => Icons.cloud_rounded,
    '09' => Icons.grain_rounded,
    '10' => Icons.umbrella_rounded,
    '11' => Icons.bolt_rounded,
    '13' => Icons.ac_unit_rounded,
    '50' => Icons.water_rounded,
    _ => Icons.wb_cloudy_outlined,
  };
}

Color weatherColor(String owmCode) {
  final code = owmCode.substring(0, 2);
  return switch (code) {
    '01' => const Color(0xFFF59E0B),
    '02' || '03' || '04' => const Color(0xFF94A3B8),
    '09' || '10' => const Color(0xFF3B82F6),
    '11' => const Color(0xFF7C3AED),
    '13' => const Color(0xFF67E8F9),
    '50' => const Color(0xFF94A3B8),
    _ => AppColors.primary,
  };
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// ─── Current weather chip (used in SliverAppBar) ──────────────────────────────

/// Compact inline chip: ☀ 24° • Clear sky
class CurrentWeatherChip extends StatelessWidget {
  final WeatherData weather;
  const CurrentWeatherChip({required this.weather, super.key});

  @override
  Widget build(BuildContext context) {
    final icon = weatherIcon(weather.iconCode);
    final color = weatherColor(weather.iconCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            '${weather.currentTemp.round()}°C',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Container(
              width: 1,
              height: 10,
              color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(width: 4),
          Text(
            _capitalize(weather.description),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Day forecast row (used at top of each itinerary day view) ────────────────

class DayForecastRow extends StatelessWidget {
  final DayWeather day;
  const DayForecastRow({required this.day, super.key});

  @override
  Widget build(BuildContext context) {
    final icon = weatherIcon(day.iconCode);
    final color = weatherColor(day.iconCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(day.description),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.thermostat_rounded,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Text(
                      '${day.tempMin.round()}° – ${day.tempMax.round()}°C',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.water_drop_outlined,
                        size: 11, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Text(
                      '${day.humidity}%',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.air_rounded,
                        size: 11, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Text(
                      '${day.windSpeed.toStringAsFixed(1)} m/s',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weather loading / error placeholders ─────────────────────────────────────

class WeatherChipLoading extends StatelessWidget {
  const WeatherChipLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 6),
          Text('Loading weather',
              style: TextStyle(
                  fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
