// lib/models/weather.dart
// Model untuk response Open-Meteo current weather
// API: https://api.open-meteo.com/v1/forecast?latitude=-7.55&longitude=108.15&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m&timezone=Asia%2FJakarta

import 'package:flutter/material.dart';

class Weather {
  final double latitude;
  final double longitude;
  final double elevation;
  final String timezone;
  final String time; // iso8601
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;

  const Weather({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.timezone,
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    return Weather(
      latitude: (json['latitude'] as num?)?.toDouble() ?? -7.55,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 108.15,
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
      time: current['time'] as String? ?? '',
      temperature2m: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      relativeHumidity2m: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature: (current['apparent_temperature'] as num?)?.toDouble() ?? 0,
      precipitation: (current['precipitation'] as num?)?.toDouble() ?? 0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed10m: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
    );
  }

  // ── WMO Weather Code → deskripsi Indonesia ──
  String get description {
    switch (weatherCode) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah Berawan';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Mendung';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 56:
      case 57:
        return 'Gerimis Beku';
      case 61:
      case 63:
      case 65:
        return 'Hujan Ringan–Sedang';
      case 66:
      case 67:
        return 'Hujan Beku';
      case 71:
      case 73:
      case 75:
        return 'Salju (jarang)';
      case 77:
        return 'Butiran Salju';
      case 80:
      case 81:
      case 82:
        return 'Hujan Singkat';
      case 85:
      case 86:
        return 'Hujan Salju Singkat';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir + Hujan Es';
      default:
        return 'Berawan';
    }
  }

  IconData get icon {
    if ([0].contains(weatherCode)) return Icons.wb_sunny_rounded;
    if ([1, 2].contains(weatherCode)) return Icons.wb_cloudy_rounded;
    if ([3, 45, 48].contains(weatherCode)) return Icons.cloud_rounded;
    if ([51, 53, 55, 56, 57].contains(weatherCode)) return Icons.grain_rounded;
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(weatherCode)) return Icons.water_drop_rounded; // hujan
    if ([95, 96, 99].contains(weatherCode)) return Icons.thunderstorm_rounded;
    return Icons.cloud_rounded;
  }

  /// Warna gradasi berdasarkan weather code / suhu
  List<Color> get gradient {
    if ([0, 1].contains(weatherCode)) {
      return [const Color(0xFF38BDF8), const Color(0xFF0EA5E9)]; // cerah biru
    }
    if ([2, 3, 45, 48].contains(weatherCode)) {
      return [const Color(0xFF2ED9C3), const Color(0xFF1FBFA8)]; // mendung → selaras admin/kader teal
    }
    if ([51, 53, 55, 56, 57, 61, 63, 65, 80, 81, 82].contains(weatherCode)) {
      return [const Color(0xFF60A5FA), const Color(0xFF2563EB)]; // hujan biru tua
    }
    if ([95, 96, 99].contains(weatherCode)) {
      return [const Color(0xFF475569), const Color(0xFF1E293B)]; // badai gelap
    }
    return [const Color(0xFF0D9488), const Color(0xFF10B981)]; // default teal
  }
}
