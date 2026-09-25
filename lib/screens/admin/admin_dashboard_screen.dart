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

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF8F9FB);
    final primaryDark = const Color(0xFF0F326D);

    final pages = [
      _buildBeranda(bgColor, primaryDark),
      const VerifikasiBeritaScreen(),
      const VerifikasiLaporanScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(index: _navIndex, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BeritaFormScreen(isAdminMode: true)));
        },
        backgroundColor: primaryDark,
        shape: const CircleBorder(),
        elevation: 8,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: _isDarkMode ? const Color(0xFF1E242D) : Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 10,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.grid_view_rounded, 'Beranda'),
            _navItem(1, Icons.article_rounded, 'Berita'),
            const SizedBox(width: 40),
            _navItem(2, Icons.rule_folder_rounded, 'Laporan'),
            _navItem(3, Icons.person_outline_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final sel = _navIndex == idx;
    final color = sel ? const Color(0xFF0F326D) : const Color(0xFF94A3B8);
    return InkWell(
      onTap: () { setState(() => _navIndex = idx); },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: sel ? FontWeight.w800 : FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBeranda(Color bgColor, Color primaryDark) {
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final textCol = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final sub = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final border = _isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => await Future.wait([_loadPendingCounts(), _loadWeather()]),
        color: primaryDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Icon(Icons.grid_view_rounded, size: 20, color: textCol),
                  ),
                  Text('Beranda Admin', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: textCol)),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Stack(
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 20, color: textCol),
                        if (_pendingBeritaCount > 0 || _pendingLaporanCount > 0)
                          Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)))
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              
              // Greeting & Cuaca
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi Admin!', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: textCol)),
                      const SizedBox(height: 4),
                      Text(_getFormattedDate(), style: GoogleFonts.plusJakartaSans(fontSize: 14, color: sub, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryDark.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _weatherCondition.toLowerCase().contains('hujan') ? Icons.cloud_rounded : Icons.wb_sunny_rounded,
                          color: _weatherCondition.toLowerCase().contains('hujan') ? Colors.blueGrey : const Color(0xFFFBBF24),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_weatherTemp°C',
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: textCol, height: 1),
                            ),
                            Text(
                              _weatherCity,
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: sub),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(30), border: Border.all(color: border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari laporan atau berita...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: sub, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: sub),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(minWidth: 40),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primaryDark, width: 1.2),
                  boxShadow: [BoxShadow(color: primaryDark.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selamat Datang!', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: textCol)),
                          const SizedBox(height: 8),
                          Text('Ada ${_pendingBeritaCount + _pendingLaporanCount} antrean yang\nmenunggu verifikasi Anda.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: sub, height: 1.4)),
                        ],
                      ),
                    ),
                    Icon(Icons.admin_panel_settings_rounded, size: 64, color: primaryDark), 
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Menunggu Verifikasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Menunggu Verifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: textCol)),
                  Text('Lihat Semua', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: sub)),
                ],
              ),
              const SizedBox(height: 16),

              // Design Cards for Verifikasi
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildDesignCard(
                    title: 'Verifikasi',
                    subtitle: 'Berita',
                    count: _pendingBeritaCount,
                    icon: Icons.article_rounded,
                    isActive: true,
                    primaryDark: primaryDark,
                    cardBg: cardBg,
                    textCol: textCol,
                    sub: sub,
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiBeritaScreen()));
                      _loadPendingCounts();
                    },
                  ),
                  _buildDesignCard(
                    title: 'Verifikasi',
                    subtitle: 'Laporan Pokja',
                    count: _pendingLaporanCount,
                    icon: Icons.assignment_rounded,
                    isActive: false,
                    primaryDark: primaryDark,
                    cardBg: cardBg,
                    textCol: textCol,
                    sub: sub,
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifikasiLaporanScreen()));
                      _loadPendingCounts();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Rincian Antrean Pokja
              Text('Antrean Per Pokja', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: textCol)),
              const SizedBox(height: 12),
              _buildRincianAntreanCard(
                  cardBg: cardBg,
                  textColor: textCol,
                  subtextColor: sub,
                  borderColor: border,
                  primaryMintAccent: primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesignCard({
    required String title,
    required String subtitle,
    required int count,
    required IconData icon,
    required bool isActive,
    required Color primaryDark,
    required Color cardBg,
    required Color textCol,
    required Color sub,
    required VoidCallback onTap,
  }) {
    final bgColor = isActive ? primaryDark : cardBg;
    final titleColor = isActive ? Colors.white : textCol;
    final subColor = isActive ? Colors.white70 : sub;
    final iconBgColor = isActive ? Colors.white.withValues(alpha: 0.2) : primaryDark.withValues(alpha: 0.1);
    final iconColor = isActive ? Colors.white : primaryDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isActive ? Colors.transparent : (_isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0))),
          boxShadow: [
            if (isActive) BoxShadow(color: primaryDark.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))
            else BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                Icon(Icons.more_vert_rounded, color: subColor, size: 20),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: titleColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: subColor)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Menunggu', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: subColor)),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(height: 4, decoration: BoxDecoration(color: subColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                    FractionallySizedBox(widthFactor: count > 0 ? (count > 10 ? 0.8 : count / 10) : 0.1, child: Container(height: 4, decoration: BoxDecoration(color: titleColor, borderRadius: BorderRadius.circular(2)))),
                  ],
                ),
                const SizedBox(height: 6),
                Text('$count Antrean', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: titleColor)),
              ],
            )
          ],
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
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: AdminElderlyStyle.cardShadow(_isDarkMode),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: AdminElderlyStyle.countBigSize,
              fontWeight: FontWeight.w900,
              color: textColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: _isDarkMode
                  ? AdminElderlyStyle.darkSubtext
                  : AdminElderlyStyle.lightSubtext,
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
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.1),
          boxShadow: AdminElderlyStyle.cardShadow(_isDarkMode),
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
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      height: 1.4,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: subtextColor.withValues(alpha: 0.7),
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
