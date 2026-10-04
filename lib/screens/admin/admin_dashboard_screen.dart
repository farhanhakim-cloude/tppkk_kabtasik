// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print, unnecessary_import, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verifikasi_berita_screen.dart';
import 'verifikasi_laporan_screen.dart';
import '../berita_form_screen.dart';
import '../../constants/app_constants.dart';
import '../../constants/admin_elderly_style.dart';
import '../../models/catatan_kegiatan.dart';
import '../../main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _pendingBeritaCount = 0;
  int _pendingLaporanCount = 0;
  int _navIndex = 0;

  // Semua nilai enum diinisialisasi 0 (otomatis ikut kalau enum bertambah lagi)
  Map<PokjaKategori, int> _pokjaPending = {
    for (final k in PokjaKategori.values) k: 0,
  };
  bool _loadingCount = true;

  String _weatherCity = 'Tasikmalaya';
  String _weatherCondition = 'Cerah Berawan';
  int _weatherTemp = 28;
  int _weatherHumidity = 65;

  // Default terang: lebih jelas untuk pengguna lansia. Tetap ikut tema global.
  bool _isDarkMode = false;

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, $monthName ${now.day}, ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _loadPendingCounts();
    _loadWeather();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _loadWeather() async {
    try {
      final res = await http
          .get(
            Uri.parse(
              'https://api.open-meteo.com/v1/forecast?latitude=-7.3274&longitude=108.2207&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code&timezone=Asia%2FJakarta',
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data['current'];
        final temp = (current['temperature_2m'] as num).round();
        final humidity = (current['relative_humidity_2m'] as num).round();
        final code = current['weather_code'] as int;
        String condition;
        if (code == 0) {
          condition = 'Cerah';
        } else if (code <= 3)
          condition = 'Berawan';
        else if (code <= 48)
          condition = 'Berkabut';
        else if (code <= 67)
          condition = 'Hujan';
        else if (code <= 77)
          condition = 'Salju';
        else if (code <= 99)
          condition = 'Badai';
        else
          condition = 'Cerah Berawan';
        if (!mounted) return;
        setState(() {
          _weatherTemp = temp;
          _weatherHumidity = humidity;
          _weatherCondition = condition;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadPendingCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey) ?? '';
      if (token.isEmpty) {
        if (mounted) setState(() => _loadingCount = false);
        return;
      }

      // Berita pending
      final beritaRes = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}admin/berita/pending'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      // Laporan Pokja pending
      final laporanRes = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}admin/laporan-kegiatan'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      int beritaCount = 0;
      if (beritaRes.statusCode == 200) {
        final data = jsonDecode(beritaRes.body);
        final rawData = data['data'];
        if (rawData is List) {
          beritaCount = rawData.length;
        } else if (rawData is Map && rawData['data'] is List)
          beritaCount = (rawData['data'] as List).length;
        else if (data['count'] != null)
          beritaCount = data['count'] as int;
      }

      int laporanCount = 0;
      final Map<PokjaKategori, int> pokjaMap = {
        for (final k in PokjaKategori.values) k: 0,
      };

      if (laporanRes.statusCode == 200) {
        final data = jsonDecode(laporanRes.body);
        final rawData = data['data'];
        List<dynamic> list = [];
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map && rawData['data'] is List)
          list = rawData['data'] as List;

        // Filter pending
        final pending = list.where((item) {
          final status = (item['status']?.toString() ?? '')
              .toLowerCase()
              .trim();
          final label = (item['status_label']?.toString() ?? '')
              .toLowerCase()
              .trim();
          return status == 'pending' ||
              status == 'menunggu' ||
              status == 'waiting' ||
              label.contains('menunggu') ||
              label.contains('pending');
        }).toList();

        laporanCount = pending.length;

        // Hitung per Pokja
        for (final item in pending) {
          final kode =
              (item['kategori_pokja']?.toString() ??
                      item['kategori']?.toString() ??
                      '')
                  .toString()
                  .trim()
                  .toUpperCase();
          final kategoriRaw = (item['kategori']?.toString() ?? '')
              .toString()
              .toLowerCase();
          PokjaKategori? kat;

          // 3 sheet Pokja IV dicek dulu, supaya tidak ikut terhitung sebagai pokja4 biasa
          if (kategoriRaw.contains('pyd')) {
            kat = PokjaKategori.pokja4Pyd;
          } else if (kategoriRaw.contains('posyandu'))
            kat = PokjaKategori.pokja4Posyandu;
          else if (kategoriRaw.contains('rekap'))
            kat = PokjaKategori.pokja4Rekap;
          else if (kategoriRaw.contains('datadukung') || kategoriRaw.contains('data_dukung') || kategoriRaw.contains('data dukung'))
            kat = PokjaKategori.pokja4DataDukung;
          else if (kategoriRaw.contains('dataprogram') || kategoriRaw.contains('data_program') || kategoriRaw.contains('data program'))
            kat = PokjaKategori.pokja4DataProgram;
          else if (kode == 'I' ||
              kategoriRaw.contains('pokja1') ||
              kategoriRaw.contains('pokja 1'))
            kat = PokjaKategori.pokja1;
          else if (kode == 'II' ||
              kategoriRaw.contains('pokja2') ||
              kategoriRaw.contains('pokja 2'))
            kat = PokjaKategori.pokja2;
          else if (kode == 'III' ||
              kategoriRaw.contains('pokja3') ||
              kategoriRaw.contains('pokja 3'))
            kat = PokjaKategori.pokja3;
          else if (kode == 'IV' ||
              kategoriRaw.contains('pokja4') ||
              kategoriRaw.contains('pokja 4'))
            kat = PokjaKategori.pokja4;
          else {
            // fallback via CatatanKegiatan.fromJson kategori
            try {
              final c = CatatanKegiatan.fromJson(item);
              kat = c.kategori;
            } catch (_) {}
          }
          if (kat != null) pokjaMap[kat] = (pokjaMap[kat] ?? 0) + 1;
        }
      }

      if (!mounted) return;
      setState(() {
        _pendingBeritaCount = beritaCount;
        _pendingLaporanCount = laporanCount;
        _pokjaPending = pokjaMap;
        _loadingCount = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingCount = false);
    }
  }

  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF10141D) : const Color(0xFFF1F4F9);
    const brandBlue = Color(0xFF0072BC); // Biru resmi TP PKK sesuai tombol login

    final pages = [
      _buildBeranda(bgColor, brandBlue),
      const VerifikasiBeritaScreen(),
      const VerifikasiLaporanScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(index: _navIndex, children: pages),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          heroTag: 'fab-admin-dashboard',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BeritaFormScreen(isAdminMode: true),
              ),
            );
            _loadPendingCounts();
          },
          backgroundColor: brandBlue,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: brandBlue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: brandBlue.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left group
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navItem(0, Icons.home_rounded, 'Beranda'),
                      const SizedBox(width: 4),
                      _navItem(1, Icons.article_outlined, 'Berita'),
                    ],
                  ),
                  // Center gap for FAB (match FAB diameter)
                  const SizedBox(width: 60),
                  // Right group
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navItem(2, Icons.rule_folder_outlined, 'Laporan'),
                      const SizedBox(width: 4),
                      _navItem(3, Icons.person_outline_rounded, 'Profil'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final isSelected = _navIndex == idx;
    return InkWell(
      onTap: () => setState(() => _navIndex = idx),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF0072BC) : Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeranda(Color bgColor, Color brandBlue) {
    final cardBg = _isDarkMode ? const Color(0xFF1E242F) : Colors.white;
    final textCol = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final sub = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = _isDarkMode ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async => await Future.wait([_loadPendingCounts(), _loadWeather()]),
        color: brandBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KOP PROFIL DINAS (Admin TP PKK Kab. Tasikmalaya)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: brandBlue,
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Administrator TP PKK',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textCol,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sekretariat Kab. Tasikmalaya',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: sub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_none_rounded, color: sub, size: 22),
                      onPressed: () {},
                      tooltip: 'Pemberitahuan',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. RINGKASAN ANTREAN RESMI (2 KARTU UTAMA: Laporan & Berita)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VerifikasiLaporanScreen()),
                        );
                        _loadPendingCounts();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Lap. Pending', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: sub, fontWeight: FontWeight.w500)),
                                Icon(Icons.assignment_outlined, color: brandBlue, size: 18),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_pendingLaporanCount',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VerifikasiBeritaScreen()),
                        );
                        _loadPendingCounts();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kbr. Pending', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: sub, fontWeight: FontWeight.w500)),
                                Icon(Icons.newspaper_outlined, color: brandBlue, size: 18),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_pendingBeritaCount',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. ANTREAN VERIFIKASI RESMI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Antrean Verifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: textCol,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _navIndex = 2),
                    child: Text(
                      'Kelola Semua',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: brandBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Kartu 1: Verifikasi Laporan Pokja
              _buildSimpleDinasCard(
                title: 'Verifikasi Laporan Pokja',
                subtitle: 'Laporan kegiatan kader Pokja I - IV',
                badgeText: '$_pendingLaporanCount Pending',
                icon: Icons.assignment_outlined,
                brandBlue: brandBlue,
                cardBg: cardBg,
                textCol: textCol,
                sub: sub,
                border: border,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VerifikasiLaporanScreen()),
                  );
                  _loadPendingCounts();
                },
              ),
              const SizedBox(height: 10),

              // Kartu 2: Verifikasi Berita Warga
              _buildSimpleDinasCard(
                title: 'Verifikasi Berita Warga',
                subtitle: 'Publikasi artikel & agenda kegiatan',
                badgeText: '$_pendingBeritaCount Pending',
                icon: Icons.newspaper_outlined,
                brandBlue: brandBlue,
                cardBg: cardBg,
                textCol: textCol,
                sub: sub,
                border: border,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VerifikasiBeritaScreen()),
                  );
                  _loadPendingCounts();
                },
              ),
              const SizedBox(height: 20),

              // 5. RINCIAN ANTREAN PER POKJA
              Text(
                'Rincian Antrean Pokja',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 10),
              _buildRincianAntreanCard(
                cardBg: cardBg,
                textColor: textCol,
                subtextColor: sub,
                borderColor: border,
                primaryMintAccent: brandBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleDinasCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color brandBlue,
    required Color cardBg,
    required Color textCol,
    required Color sub,
    required Color border,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: brandBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: textCol,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: sub),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: border),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: sub),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // FIX: switch sekarang mencakup semua 7 nilai PokjaKategori
  // ============================================================
  Color _pokjaColor(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return const Color(0xFF0072BC);
      case PokjaKategori.pokja2:
        return const Color(0xFF0284C7);
      case PokjaKategori.pokja3:
        return const Color(0xFF0369A1);
      case PokjaKategori.pokja4:
        return const Color(0xFF075985);
      case PokjaKategori.pokja4Pyd:
        return const Color(0xFF0E7490);
      case PokjaKategori.pokja4Posyandu:
        return const Color(0xFF0891B2);
      case PokjaKategori.pokja4Rekap:
        return const Color(0xFF155E75);
      case PokjaKategori.pokja4DataDukung:
        return const Color(0xFF0C4A6E);
      case PokjaKategori.pokja4DataProgram:
        return const Color(0xFF0F766E);
    }
  }

  IconData _pokjaIcon(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return Icons.groups_rounded;
      case PokjaKategori.pokja2:
        return Icons.school_rounded;
      case PokjaKategori.pokja3:
        return Icons.cottage_rounded;
      case PokjaKategori.pokja4:
        return Icons.health_and_safety_rounded;
      case PokjaKategori.pokja4Pyd:
        return Icons.child_friendly_rounded;
      case PokjaKategori.pokja4Posyandu:
        return Icons.local_hospital_rounded;
      case PokjaKategori.pokja4Rekap:
        return Icons.assignment_rounded;
      case PokjaKategori.pokja4DataDukung:
        return Icons.library_books_rounded;
      case PokjaKategori.pokja4DataProgram:
        return Icons.bar_chart_rounded;
    }
  }

  Widget _buildRincianAntreanCard({
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    required Color primaryMintAccent,
  }) {
    final all = PokjaKategori.values;
    // Bagi jadi baris berisi maks 4 kartu supaya tidak sempit (4 + 3)
    const perRow = 4;
    final rows = <List<PokjaKategori>>[];
    for (var i = 0; i < all.length; i += perRow) {
      rows.add(
        all.sublist(i, i + perRow > all.length ? all.length : i + perRow),
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: AdminElderlyStyle.cardShadow(_isDarkMode),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryMintAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.dashboard_rounded,
                  size: 16,
                  color: primaryMintAccent,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Rincian Antrean Pokja',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < perRow; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: i < rows[r].length
                        ? _pokjaMiniCard(rows[r][i])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _pokjaMiniCard(PokjaKategori p) {
    final c = _pokjaColor(p);
    final count = _pokjaPending[p] ?? 0;
    // Kartu mini selalu terang, jadi teks gelap agar terbaca di dark & light mode.
    final miniBg = _isDarkMode ? Colors.white : const Color(0xFFF8FAFC);
    final miniBorder = _isDarkMode
        ? Colors.transparent
        : Colors.black.withValues(alpha: 0.06);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerifikasiLaporanScreen(pokjaDefault: p),
            ),
          );
          _loadPendingCounts();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
          decoration: BoxDecoration(
            color: miniBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: miniBorder, width: 1.1),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(_pokjaIcon(p), size: 17, color: c),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  p.shortLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _loadingCount ? '...' : '$count',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Antrean',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
