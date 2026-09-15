import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verifikasi_berita_screen.dart';
import 'verifikasi_laporan_screen.dart';
import '../catatan_kegiatan_form_screen.dart';
import '../berita_form_screen.dart';
import '../../constants/app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// 🟢 WARNA MINT (Sesuai Referensi)
const _kNeonGreen = Color(0xFF8CF1DB);
const _kNeonGreenDark = Color(0xFF5ED6BD);
const _kNeonGreenLight = Color(0xFFC3FBF0);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _pendingBeritaCount = 0;
  int _pendingLaporanCount = 0;
  bool _loadingCount = true;

  // Data cuaca (statis — Tasikmalaya)
  String _weatherCity = 'Tasikmalaya';
  String _weatherCondition = 'Cerah Berawan';
  int _weatherTemp = 28;
  int _weatherFeelsLike = 31;
  int _weatherHumidity = 65;

  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  String _formatDate(DateTime dt) {
    return '${_days[dt.weekday - 1]}, ${dt.day.toString().padLeft(2, '0')} ${_months[dt.month - 1]} ${dt.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadPendingCounts();
    _loadWeather();
  }

  // ============================================================
  // 🌤️ LOAD CUACA DARI API (open-meteo, gratis tanpa API key)
  // ============================================================
  Future<void> _loadWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=-7.3274&longitude=108.2207&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code&timezone=Asia%2FJakarta',
        ),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data['current'];
        final temp = (current['temperature_2m'] as num).round();
        final feelsLike = (current['apparent_temperature'] as num).round();
        final humidity = (current['relative_humidity_2m'] as num).round();
        final code = current['weather_code'] as int;

        String condition;
        if (code == 0) {
          condition = 'Cerah';
        } else if (code <= 3) {
          condition = 'Berawan';
        } else if (code <= 48) {
          condition = 'Berkabut';
        } else if (code <= 67) {
          condition = 'Hujan';
        } else if (code <= 77) {
          condition = 'Salju';
        } else if (code <= 99) {
          condition = 'Badai';
        } else {
          condition = 'Cerah Berawan';
        }

        if (!mounted) return;
        setState(() {
          _weatherTemp = temp;
          _weatherFeelsLike = feelsLike;
          _weatherHumidity = humidity;
          _weatherCondition = condition;
        });
      }
    } catch (_) {
      // Biarkan pakai data default
    }
  }

  // ============================================================
  // 🔥 LOAD PENDING COUNTS DARI API
  // ============================================================
  Future<void> _loadPendingCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey) ?? '';

      if (token.isEmpty) {
        setState(() => _loadingCount = false);
        return;
      }

      // Fetch pending berita
      final beritaRes = await http.get(
        Uri.parse('${AppConstants.baseUrl}admin/berita/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      // Fetch pending laporan
      final laporanRes = await http.get(
        Uri.parse('${AppConstants.baseUrl}laporan-kegiatan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      // Parse berita
      int beritaCount = 0;
      if (beritaRes.statusCode == 200) {
        final data = jsonDecode(beritaRes.body);
        final rawData = data['data'];
        if (rawData is List) {
          beritaCount = rawData.length;
        } else if (rawData is Map && rawData['data'] is List) {
          beritaCount = (rawData['data'] as List).length;
        } else if (data['count'] != null) {
          beritaCount = data['count'] as int;
        }
      }

      // Parse laporan — filter status pending
      int laporanCount = 0;
      if (laporanRes.statusCode == 200) {
        final data = jsonDecode(laporanRes.body);
        final rawData = data['data'];

        List<dynamic> list = [];
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          list = rawData['data'] as List;
        }

        // Filter yang statusnya pending
        laporanCount = list.where((item) {
          final status = item['status']?.toString() ?? '';
          return status == 'pending';
        }).length;
      }

      if (!mounted) return;
      setState(() {
        _pendingBeritaCount = beritaCount;
        _pendingLaporanCount = laporanCount;
        _loadingCount = false;
      });

      print('🔔 Pending — Berita: $beritaCount, Laporan: $laporanCount');
    } catch (e) {
      print('❌ Error load pending count: $e');
      if (mounted) {
        setState(() => _loadingCount = false);
      }
    }
  }

  IconData get _weatherIcon {
    if (_weatherCondition.contains('Hujan')) return Icons.water_drop_rounded;
    if (_weatherCondition.contains('Badai')) return Icons.thunderstorm_rounded;
    if (_weatherCondition.contains('Kabut')) return Icons.cloud_rounded;
    if (_weatherCondition.contains('Berawan')) return Icons.cloud_outlined;
    return Icons.wb_sunny_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate = _formatDate(DateTime.now());
    // Force the exact dark mode styling from the reference image for the admin dashboard
    final bool isDark = true;
    final textPrimary = Colors.white;
    final textSecondary = const Color(0xFF888B98);
    final sectionTitle = Colors.white;
    final cardColor = const Color(0xFF292B34);
    final cardShadow = Colors.black.withOpacity(0.2);
    final bgColor = const Color(0xFF1B1C22);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([_loadPendingCounts(), _loadWeather()]);
          },
          color: _kNeonGreen,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              // ── HEADER ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hey, Admin!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentDate,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _kNeonGreen.withOpacity(isDark ? 0.12 : 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: isDark ? _kNeonGreen : _kNeonGreenDark,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── WIDGET CUACA ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_kNeonGreenLight, _kNeonGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _kNeonGreen.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _weatherIcon,
                                  color: const Color(0xFF0F172A),
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _weatherCondition,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      _weatherCity,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0F172A)
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              '$_weatherTemp°',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 42,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _WeatherStat(label: 'Terasa', value: '$_weatherFeelsLike°'),
                            const SizedBox(width: 24),
                            _WeatherStat(label: 'Kelembapan', value: '$_weatherHumidity%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── SECTION: VERIFIKASI DATA ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Verifikasi Data',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: sectionTitle,
                        ),
                      ),
                      if (!_loadingCount &&
                          (_pendingBeritaCount + _pendingLaporanCount) > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Color(0xFFB45309),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_pendingBeritaCount + _pendingLaporanCount} Menunggu',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // ── 2 KARTU VERIFIKASI ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AdminMenuCard(
                          icon: Icons.article_rounded,
                          label: 'Berita Pending',
                          badgeCount: _pendingBeritaCount,
                          isLoading: _loadingCount,
                          isActive: true,
                          isDark: isDark,
                          cardColor: cardColor,
                          cardShadow: _kNeonGreen.withOpacity(0.3),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VerifikasiBeritaScreen(),
                              ),
                            );
                            // Refresh count setelah kembali
                            _loadPendingCounts();
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _AdminMenuCard(
                          icon: Icons.assignment_turned_in_rounded,
                          label: 'Verifikasi Laporan',
                          badgeCount: _pendingLaporanCount,
                          isLoading: _loadingCount,
                          isActive: true, // Make this neon green too
                          isDark: isDark,
                          cardColor: cardColor,
                          cardShadow: _kNeonGreen.withOpacity(0.3),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VerifikasiLaporanScreen(),
                              ),
                            );
                            _loadPendingCounts();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── SECTION: INPUT LANGSUNG ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Input Langsung',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: sectionTitle,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _AdminListAction(
                        icon: Icons.add_photo_alternate_rounded,
                        title: 'Input Berita Baru',
                        subtitle: 'Tambah berita langsung dari panel admin',
                        color: _kNeonGreen,
                        isDark: isDark,
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardShadow: cardShadow,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const BeritaFormScreen(isAdminMode: true),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _AdminListAction(
                        icon: Icons.post_add_rounded,
                        title: 'Input Laporan Kegiatan',
                        subtitle: 'Tambah laporan kegiatan',
                        color: _kNeonGreen,
                        isDark: isDark,
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardShadow: cardShadow,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CatatanKegiatanFormScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  STAT CUACA KECIL
// ════════════════════════════════════════════════════════════════
class _WeatherStat extends StatelessWidget {
  final String label;
  final String value;
  const _WeatherStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A).withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  KARTU VERIFIKASI
// ════════════════════════════════════════════════════════════════
class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final bool isLoading;
  final bool isActive;
  final bool isDark;
  final Color cardColor;
  final Color cardShadow;
  final VoidCallback onTap;

  const _AdminMenuCard({
    required this.icon,
    required this.label,
    required this.badgeCount,
    required this.isLoading,
    required this.isActive,
    required this.isDark,
    required this.cardColor,
    required this.cardShadow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textMain = isActive
        ? const Color(0xFF0F172A)
        : (isDark ? Colors.white : const Color(0xFF1E293B));
    final Color textSub = isActive
        ? const Color(0xFF0F172A).withOpacity(0.6)
        : (isDark ? Colors.white54 : const Color(0xFF64748B));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isActive ? null : cardColor,
            gradient: isActive
                ? const LinearGradient(
                    colors: [_kNeonGreenLight, _kNeonGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? _kNeonGreen.withOpacity(0.25)
                    : cardShadow,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF0F172A).withOpacity(0.12)
                          : _kNeonGreen.withOpacity(isDark ? 0.1 : 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: isActive ? const Color(0xFF0F172A) : _kNeonGreenDark,
                      size: 24,
                    ),
                  ),
                  if (!isLoading && badgeCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF0F172A).withOpacity(0.15)
                            : const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isActive ? const Color(0xFF0F172A) : Colors.white,
                        ),
                      ),
                    ),
                  if (isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isActive ? const Color(0xFF0F172A) : _kNeonGreenDark,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isLoading ? 'Memuat...' : '$badgeCount Antrean',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textSub,
                ),
              ),
              const SizedBox(height: 14),
              // Toggle switch dekoratif
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_forward_rounded, size: 16, color: textSub),
                  Container(
                    width: 38,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF0F172A)
                          : _kNeonGreen.withOpacity(isDark ? 0.15 : 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Align(
                      alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? _kNeonGreen
                              : (isDark ? Colors.white38 : const Color(0xFFA0AEC0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  LIST ACTION — untuk bagian Input Langsung
// ════════════════════════════════════════════════════════════════
class _AdminListAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardShadow;
  final VoidCallback onTap;

  const _AdminListAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardShadow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: cardShadow, blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}