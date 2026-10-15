import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:convert';

/// Pilih titik GPS rumah.
/// - Buka dengan posisi awal = data tersimpan, atau GPS asli HP, atau
///   fallback Tasikmalaya bila GPS mati/ditolak.
/// - Peta asli OpenStreetMap (gratis, tanpa API key). Pin = tengah peta.
class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const LatLng _tasikDefault = LatLng(-7.3274, 108.2207);

  final MapController _mapCtrl = MapController();
  late LatLng _center;
  bool _loadingGps = false;
  bool _fromGps = false;
  String? _gpsNote;
  // Alamat saran dari reverse-geocode (Nominatim/OSM, gratis tanpa API key).
  String? _alamatSaran;
  bool _alamatLoading = false;
  Timer? _alamatDebounce;
  String? _lookupKey;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _center = LatLng(widget.initialLat!, widget.initialLng!);
      _gpsNote = 'Titik tersimpan sebelumnya';
      _scheduleAlamatLookup();
    } else {
      _center = _tasikDefault;
      _ambilGpsAwal();
    }
  }

  @override
  void dispose() {
    _alamatDebounce?.cancel();
    _mapCtrl.dispose();
    super.dispose();
  }

  /// Jadwalkan reverse-geocode dengan debounce (kebijakan Nominatim: maks 1 req/detik).
  void _scheduleAlamatLookup() {
    _alamatDebounce?.cancel();
    _alamatDebounce = Timer(const Duration(milliseconds: 900), () {
      _lookupAlamat(_center);
    });
  }

  Future<void> _lookupAlamat(LatLng p) async {
    final key = '${p.latitude.toStringAsFixed(4)},${p.longitude.toStringAsFixed(4)}';
    if (key == _lookupKey) return;
    _lookupKey = key;
    setState(() => _alamatLoading = true);
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': p.latitude.toString(),
        'lon': p.longitude.toString(),
        'zoom': '18',
        'addressdetails': '1',
      });
      final res = await http
          .get(uri, headers: {'User-Agent': 'tppkk_kabtasik/1.0'})
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final addr = json['address'] as Map<String, dynamic>?;
        setState(() => _alamatSaran = _rangkaiAlamat(addr, json['display_name'] as String?));
      }
    } catch (_) {
      // Gagal jaringan / timeout: abaikan, koordinat tetap bisa dipakai.
    } finally {
      if (mounted) setState(() => _alamatLoading = false);
    }
  }

  /// Rangkai alamat pendek: Jalan, Dusun/Desa, Kecamatan/Kabupaten.
  String? _rangkaiAlamat(Map<String, dynamic>? a, String? display) {
    if (a == null) {
      if (display == null || display.isEmpty) return null;
      return display.split(',').take(3).join(',').trim();
    }
    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = a[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return null;
    }
    final parts = [
      pick(['road', 'pedestrian', 'footway', 'cycleway', 'neighbourhood']),
      pick(['hamlet', 'village', 'suburb', 'town']),
      pick(['city_district', 'city', 'county', 'municipality']),
    ].whereType<String>().toList();
    if (parts.isEmpty) {
      if (display == null || display.isEmpty) return null;
      return display.split(',').take(3).join(',').trim();
    }
    return parts.join(', ');
  }

  Future<void> _ambilGpsAwal() async {
    setState(() => _loadingGps = true);
    final pos = await _posisiGps();
    if (!mounted) return;
    setState(() {
      _loadingGps = false;
      if (pos != null) {
        _center = LatLng(pos.latitude, pos.longitude);
        _fromGps = true;
        _gpsNote = 'GPS HP (±${pos.accuracy.toStringAsFixed(0)} m)';
        _mapCtrl.move(_center, 17);
        _scheduleAlamatLookup();
      } else {
        _gpsNote = _gpsNote ?? 'GPS tidak tersedia — tampilkan pusat Tasikmalaya';
      }
    });
  }

  /// null = GPS tak bisa dipakai (service mati / izin ditolak).
  Future<Position?> _posisiGps() async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      if (mounted) {
        setState(() => _gpsNote = 'GPS HP mati — nyalakan GPS lalu ketuk ikon target');
      }
      return null;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _gpsNote = 'Izin lokasi ditolak — geser peta manual ke rumah');
      }
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _keGpsSaya() async {
    setState(() => _loadingGps = true);
    final pos = await _posisiGps();
    if (!mounted) return;
    setState(() {
      _loadingGps = false;
      if (pos != null) {
        _center = LatLng(pos.latitude, pos.longitude);
        _fromGps = true;
        _gpsNote = 'GPS HP (±${pos.accuracy.toStringAsFixed(0)} m)';
        _mapCtrl.move(_center, 17);
        _scheduleAlamatLookup();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pilih Lokasi Rumah',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Ke posisi GPS saya',
            icon: _loadingGps
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.gps_fixed_rounded),
            onPressed: _loadingGps ? null : _keGpsSaya,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 16,
              minZoom: 5,
              maxZoom: 19,
              onPositionChanged: (pos, _) {
                final c = pos.center;
                if (c != null && c != _center) {
                  setState(() {
                    _center = c;
                    if (_fromGps) {
                      // Pengguna menggeser setelah GPS: bukan murni GPS lagi.
                      _fromGps = false;
                      _gpsNote = 'Digeser manual dari GPS';
                    }
                  });
                  _scheduleAlamatLookup();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'tppkk_kabtasik',
              ),
            ],
          ),

          // Pin tengah (tetap).
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded, size: 44, color: Color(0xFF0072BC)),
                    SizedBox(height: 44),
                  ],
                ),
              ),
            ),
          ),

          if (_loadingGps)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Mengambil GPS HP…',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Panel koordinat (naik di atas nav HP).
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _fromGps
                              ? Icons.satellite_alt_rounded
                              : Icons.my_location_rounded,
                          color: primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Koordinat Terpilih',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _gpsNote ??
                                  'Geser peta / ketuk ikon target untuk GPS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lat: ${_center.latitude.toStringAsFixed(6)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        Text(
                          'Lng: ${_center.longitude.toStringAsFixed(6)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_alamatLoading || _alamatSaran != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (_alamatLoading)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(
                              Icons.place_outlined,
                              size: 16,
                              color: Color(0xFF0072BC),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _alamatLoading
                                  ? 'Mencari alamat…'
                                  : 'Kira-kira: $_alamatSaran',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_alamatLoading || _alamatSaran != null)
                    const SizedBox(height: 8),
                  Text(
                    'Pastikan pin tepat di rumah yang didata — di depan rumah, ketuk ikon target.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'lat': _center.latitude,
                          'lng': _center.longitude,
                          'alamat': _alamatSaran,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Gunakan Lokasi Ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
