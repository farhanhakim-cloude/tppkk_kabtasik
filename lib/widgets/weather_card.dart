// lib/widgets/weather_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late Future<Weather> _future;
  final _service = WeatherService();

  @override
  void initState() {
    super.initState();
    _future = _service.fetchCurrentWeather();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _future = _service.fetchCurrentWeather();
    });
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm WIB';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Weather>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeleton();
        }
        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }
        final w = snapshot.data!;
        return _buildContent(w);
      },
    );
  }

  Widget _buildSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 132,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_off_rounded, color: Color(0xFFEF4444), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gagal memuat cuaca',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF0F172A))),
                Text('Tap untuk coba lagi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Weather w) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: w.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: w.gradient.last.withValues(alpha: 0.30),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative cloud icon background
          Positioned(
            right: -14,
            top: -10,
            child: Icon(w.icon, size: 110, color: Colors.white.withValues(alpha: 0.18)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: icon + lokasi + refresh
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(w.icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 12, color: Colors.white),
                              const SizedBox(width: 3),
                              Text('Kab. Tasikmalaya',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(w.description,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(_formatTime(w.time),
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _refresh,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Suhu besar + detail grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${w.temperature2m.toStringAsFixed(1)}°',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Terasa ${w.apparentTemperature.toStringAsFixed(1)}°C',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
                          Text('${w.relativeHumidity2m}% • ${w.windSpeed10m.toStringAsFixed(1)} km/jam',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Precipitation badge
                    if (w.precipitation > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.water_drop_rounded, size: 12, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            Text('${w.precipitation} mm',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF2563EB))),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom chips row
                Row(
                  children: [
                    _chip(Icons.water_drop_outlined, 'Kelembapan ${w.relativeHumidity2m}%'),
                    const SizedBox(width: 7),
                    _chip(Icons.air_rounded, '${w.windSpeed10m.toStringAsFixed(1)} km/jam'),
                    const SizedBox(width: 7),
                    _chip(Icons.thermostat_rounded, 'Feels ${w.apparentTemperature.toStringAsFixed(0)}°'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
