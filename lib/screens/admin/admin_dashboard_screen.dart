// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print, unnecessary_import, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verifikasi_berita_screen.dart';
import 'verifikasi_laporan_screen.dart';
import '../berita_form_screen.dart';
import '../../constants/app_constants.dart';
import '../../models/catatan_kegiatan.dart';
import '../../main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _pendingBeritaCount = 0;
  int _pendingLaporanCount = 0;

  // Semua nilai enum diinisialisasi 0 (otomatis ikut kalau enum bertambah lagi)
  Map<PokjaKategori, int> _pokjaPending = {
    for (final k in PokjaKategori.values) k: 0,
  };
  bool _loadingCount = true;

  String _weatherCity = 'Tasikmalaya';
  String _weatherCondition = 'Cerah Berawan';
  int _weatherTemp = 28;
  int _weatherHumidity = 65;

  bool _isDarkMode = true;

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
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
      final res = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=-7.3274&longitude=108.2207&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code&timezone=Asia%2FJakarta',
        ),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data['current'];
        final temp = (current['temperature_2m'] as num).round();
        final humidity = (current['relative_humidity_2m'] as num).round();
        final code = current['weather_code'] as int;
        String condition;
        if (code == 0) {
          condition = 'Cerah';
        } else if (code <= 3) condition = 'Berawan';
        else if (code <= 48) condition = 'Berkabut';
        else if (code <= 67) condition = 'Hujan';
        else if (code <= 77) condition = 'Salju';
        else if (code <= 99) condition = 'Badai';
        else condition = 'Cerah Berawan';
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
      final beritaRes = await http.get(
        Uri.parse('${AppConstants.baseUrl}admin/berita/pending'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      // Laporan Pokja pending
      final laporanRes = await http.get(
        Uri.parse('${AppConstants.baseUrl}admin/laporan-kegiatan'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      int beritaCount = 0;
      if (beritaRes.statusCode == 200) {
        final data = jsonDecode(beritaRes.body);
        final rawData = data['data'];
        if (rawData is List) {
          beritaCount = rawData.length;
        } else if (rawData is Map && rawData['data'] is List) beritaCount = (rawData['data'] as List).length;
        else if (data['count'] != null) beritaCount = data['count'] as int;
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
        } else if (rawData is Map && rawData['data'] is List) list = rawData['data'] as List;

        // Filter pending
        final pending = list.where((item) {
          final status = (item['status']?.toString() ?? '').toLowerCase().trim();
          final label = (item['status_label']?.toString() ?? '').toLowerCase().trim();
          return status == 'pending' || status == 'menunggu' || status == 'waiting' || label.contains('menunggu') || label.contains('pending');
        }).toList();

        laporanCount = pending.length;

        // Hitung per Pokja
        for (final item in pending) {
          final kode = (item['kategori_pokja']?.toString() ?? item['kategori']?.toString() ?? '').toString().trim().toUpperCase();
          final kategoriRaw = (item['kategori']?.toString() ?? '').toString().toLowerCase();
          PokjaKategori? kat;

          // 3 sheet Pokja IV dicek dulu, supaya tidak ikut terhitung sebagai pokja4 biasa
          if (kategoriRaw.contains('pyd')) {
            kat = PokjaKategori.pokja4Pyd;
          } else if (kategoriRaw.contains('posyandu')) kat = PokjaKategori.pokja4Posyandu;
          else if (kategoriRaw.contains('rekap')) kat = PokjaKategori.pokja4Rekap;
          else if (kode == 'I' || kategoriRaw.contains('pokja1') || kategoriRaw.contains('pokja 1')) kat = PokjaKategori.pokja1;
          else if (kode == 'II' || kategoriRaw.contains('pokja2') || kategoriRaw.contains('pokja 2')) kat = PokjaKategori.pokja2;
          else if (kode == 'III' || kategoriRaw.contains('pokja3') || kategoriRaw.contains('pokja 3')) kat = PokjaKategori.pokja3;
          else if (kode == 'IV' || kategoriRaw.contains('pokja4') || kategoriRaw.contains('pokja 4')) kat = PokjaKategori.pokja4;
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

  @override
  Widget build(BuildContext context) {
    // Sinkron dengan mode Gelap/Terang
    final bgColor = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF3F5F7);
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    const primaryMint = Color(0xFF2ED9C3);
    final primaryMintAccent = _isDarkMode ? const Color(0xFF2ED9C3) : const Color(0xFF0D9488);
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF14181D);
    final subtextColor = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final borderColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final formattedDate = _getFormattedDate();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => await Future.wait([_loadPendingCounts(), _loadWeather()]),
          color: primaryMintAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w500, color: textColor), children: [const TextSpan(text: 'Hey, '), TextSpan(text: 'Admin', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: primaryMintAccent)), const TextSpan(text: '!')])),
                const SizedBox(height: 3),
                Text(formattedDate, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subtextColor, fontWeight: FontWeight.w500)),
              ]),
              const SizedBox(height: 20),

              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2ED9C3), Color(0xFF1FBFA8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: primaryMint.withValues(alpha: _isDarkMode ? 0.28 : 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: const [
                              Positioned(top: 7, right: 8, child: Icon(Icons.wb_sunny_rounded, color: Color(0xFFFBBF24), size: 18)),
                              Positioned(bottom: 6, left: 7, child: Icon(Icons.cloud_rounded, color: Colors.white, size: 24)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _weatherCondition,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF0D3E38),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Admin Aktif',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF0A2E2A),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_weatherCity â€¢ Kelembapan $_weatherHumidity%',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF0D3E38).withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '$_weatherTempÂ°',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0D3E38),
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Ringkasan Menunggu Verifikasi
              Text('MENUNGGU VERIFIKASI', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: subtextColor)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPendingCard(
                      title: 'Berita',
                      count: _pendingBeritaCount,
                      icon: Icons.article_rounded,
                      color: const Color(0xFFF59E0B),
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPendingCard(
                      title: 'Laporan',
                      count: _pendingLaporanCount,
                      icon: Icons.assignment_rounded,
                      color: const Color(0xFF38BDF8),
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textColor: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Rincian Antrean Pokja
              _buildRincianAntreanCard(
                cardBg: cardBg,
                textColor: textColor,
                subtextColor: subtextColor,
                borderColor: borderColor,
                primaryMintAccent: primaryMintAccent,
              ),
              const SizedBox(height: 24),

              // Aksi Cepat (Quick Actions)
              Text('AKSI CEPAT', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: subtextColor)),
              const SizedBox(height: 12),
              _buildActionTile(
                title: 'Verifikasi Berita',
                subtitle: 'Tinjau berita yang dikirim kader',
                icon: Icons.checklist_rounded,
                color: const Color(0xFF0D9488),
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiBeritaScreen()));
                  _loadPendingCounts();
                },
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                title: 'Verifikasi Laporan',
                subtitle: 'Tinjau laporan kegiatan Pokja 1-4',
                icon: Icons.rule_folder_rounded,
                color: const Color(0xFF0284C7),
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiLaporanScreen()));
                  _loadPendingCounts();
                },
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                title: 'Input Berita Baru',
                subtitle: 'Tambah berita langsung dari panel admin',
                icon: Icons.add_photo_alternate_rounded,
                color: const Color(0xFF059669),
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeritaFormScreen(isAdminMode: true))),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!_isDarkMode)
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (!_isDarkMode)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: subtextColor.withValues(alpha: 0.6),
            ),
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
        return const Color(0xFF38BDF8);
      case PokjaKategori.pokja2:
        return const Color(0xFF10B981);
      case PokjaKategori.pokja3:
        return const Color(0xFFF59E0B);
      case PokjaKategori.pokja4:
        return const Color(0xFFEF4444);
      case PokjaKategori.pokja4Pyd:
        return const Color(0xFF8B5CF6);
      case PokjaKategori.pokja4Posyandu:
        return const Color(0xFF06B6D4);
      case PokjaKategori.pokja4Rekap:
        return const Color(0xFFEC4899);
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
      rows.add(all.sublist(i, i + perRow > all.length ? all.length : i + perRow));
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!_isDarkMode)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: primaryMintAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.dashboard_rounded,
                  size: 14,
                  color: primaryMintAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rincian Antrean Pokja',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: miniBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: miniBorder),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_pokjaIcon(p), size: 16, color: c),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  p.shortLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _loadingCount ? '...' : '$count',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Antrean',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
