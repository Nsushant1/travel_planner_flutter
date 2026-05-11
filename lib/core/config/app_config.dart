// Fill these in once you have your API keys and Supabase project created.
// Never commit real keys to git — use environment variables in production.
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static const googlePlacesApiKey = String.fromEnvironment('GOOGLE_PLACES_API_KEY');

  static const openWeatherApiKey = String.fromEnvironment('OPENWEATHER_API_KEY');
}
