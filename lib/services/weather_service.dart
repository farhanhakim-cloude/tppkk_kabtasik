// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  // Koordinat Singaparna (pusat Kab. Tasikmalaya) — SELARAS website
  // (backend app/Services/WeatherService.php).
  static const double _lat = -7.35;
  static const double _lon = 108.10;
  static const String _timezone = 'Asia/Jakarta';

  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch cuaca terkini Kab. Tasikmalaya (Singaparna — selaras website)
  /// Endpoint: https://api.open-meteo.com/v1/forecast?latitude=-7.35&longitude=108.10&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m&timezone=Asia%2FJakarta
  Future<Weather> fetchCurrentWeather() async {
    final uri = Uri.parse(
      '$_baseUrl?latitude=$_lat&longitude=$_lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m&timezone=$_timezone',
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Weather.fromJson(data);
    } else {
      throw Exception('Gagal load cuaca: ${response.statusCode} ${response.body}');
    }
  }

  void dispose() => _client.close();
}
