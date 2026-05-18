class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const openWeatherApiKey =
      String.fromEnvironment('OPENWEATHER_API_KEY');
}
