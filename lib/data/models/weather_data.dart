class DayWeather {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;

  const DayWeather({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });
}

class WeatherData {
  final double currentTemp;
  final double feelsLike;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final List<DayWeather> forecast;

  const WeatherData({
    required this.currentTemp,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.forecast,
  });
}
