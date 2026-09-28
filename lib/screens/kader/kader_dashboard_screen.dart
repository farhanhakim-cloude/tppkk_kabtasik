// lib/screens/kader/kader_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../main.dart';

import '../../models/catatan_kegiatan.dart';
import '../../services/catatan_kegiatan_service.dart';
import '../../services/berita_service.dart';
import '../catatan_kegiatan_form_screen.dart';
import '../berita_form_screen.dart';
import 'kader_catatan_kegiatan_screen.dart';
import 'kader_berita_screen.dart';
import '../profile_screen.dart';

class KaderDashboardScreen extends StatefulWidget {
  const KaderDashboardScreen({super.key});

  @override
  State<KaderDashboardScreen> createState() => _KaderDashboardScreenState();
}

class _KaderDashboardScreenState extends State<KaderDashboardScreen> {
  final _catatanService = CatatanKegiatanService();
  final _beritaService = BeritaService();

  String _userName = 'Kader PKK';
  String _desaKecamatan = 'Kab. Tasikmalaya';
  String? _pokjaRole;
  int _navIndex = 0;
  bool _isDarkMode = false;
  
  int _totalKegiatan = 0;
  int _totalBerita = 0;
  bool _isLoading = true;

  String _weatherCity = 'Tasikmalaya';
  String _weatherCondition = 'Cerah Berawan';
  int _weatherTemp = 28;
  int _weatherHumidity = 65;

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  Future<void> _loadWeather() async {
    try {
      final res = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=-7.3274&longitude=108.2207&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code&timezone=Asia%2FJakarta')).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data['current'];
        final temp = (current['temperature_2m'] as num).round();
        final humidity = (current['relative_humidity_2m'] as num).round();
        final code = current['weather_code'] as int;
        String condition;
        if (code == 0) condition = 'Cerah';
        else if (code <= 3) condition = 'Berawan';
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

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _loadUserInfo();
    _loadData();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data') ?? prefs.getString('user') ?? '{}';
      final data = jsonDecode(userDataStr);
      final nama = data['name'] ?? data['nama'] ?? 'Kader PKK';
      final desa = data['desa'] ?? data['kelurahan'] ?? '';
      final kec = data['kecamatan'] ?? prefs.getString('default_kecamatan') ?? 'Tasikmalaya';
      final role = (data['role'] ?? '').toString().toLowerCase();

      setState(() {
        _userName = nama;
        _desaKecamatan = desa.isNotEmpty ? '$desa, $kec' : 'Kec. $kec';
        _pokjaRole = ['pokja1', 'pokja2', 'pokja3', 'pokja4'].contains(role) ? role : null;
      });
    } catch (_) {}
  }
  
  Future<void> _loadData() async {
    _loadWeather();
    try {
      final catatan = await _catatanService.getAll();
      final berita = await _beritaService.getMyBerita();
      if (mounted) {
        setState(() {
          _totalKegiatan = catatan.length;
          _totalBerita = berita.length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF8F9FB);
    final primaryDark = const Color(0xFF0072BC);

    final pages = [
      _buildBeranda(bgColor, primaryDark),
      const KaderCatatanKegiatanScreen(),
      const KaderBeritaScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(index: _navIndex, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatanKegiatanFormScreen()));
          _loadData();
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
            _navItem(1, Icons.assignment_rounded, 'Catatan'),
            const SizedBox(width: 40),
            _navItem(2, Icons.article_rounded, 'Berita'),
            _navItem(3, Icons.person_outline_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final sel = _navIndex == idx;
    final color = sel ? const Color(0xFF0072BC) : const Color(0xFF94A3B8);
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
        onRefresh: _loadData,
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
                  Text('Beranda Kader', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: textCol)),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Stack(
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 20, color: textCol),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Greeting & Cuaca
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi ${_userName.split(' ').first}!', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: textCol)),
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
                          Text('Anda telah mencatat $_totalKegiatan kegiatan.\nTerus semangat!', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: sub, height: 1.4)),
                        ],
                      ),
                    ),
                    Icon(Icons.assignment_ind_rounded, size: 64, color: primaryDark), 
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Menu Utama
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Menu Utama', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: textCol)),
                  Text('Lihat Semua', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: sub)),
                ],
              ),
              const SizedBox(height: 16),

              // Design Cards for Menu
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildDesignCard(
                    title: 'Catatan',
                    subtitle: 'Kegiatan Pokja',
                    count: _totalKegiatan,
                    icon: Icons.assignment_rounded,
                    isActive: true,
                    primaryDark: primaryDark,
                    cardBg: cardBg,
                    textCol: textCol,
                    sub: sub,
                    onTap: () { setState(() => _navIndex = 1); },
                  ),
                  _buildDesignCard(
                    title: 'Kabar',
                    subtitle: 'Berita',
                    count: _totalBerita,
                    icon: Icons.article_rounded,
                    isActive: false,
                    primaryDark: primaryDark,
                    cardBg: cardBg,
                    textCol: textCol,
                    sub: sub,
                    onTap: () { setState(() => _navIndex = 2); },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Akses Cepat Per Pokja
              Text('Akses Cepat Per Pokja', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: textCol)),
              const SizedBox(height: 12),
              _buildPokjaGrid(cardBg: cardBg, textCol: textCol, sub: sub, border: border),
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
    final borderColor = _isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isActive ? Colors.transparent : borderColor),
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
                Text('Total', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: subColor)),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(height: 4, decoration: BoxDecoration(color: subColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                    FractionallySizedBox(widthFactor: count > 0 ? (count > 10 ? 0.8 : count / 10) : 0.1, child: Container(height: 4, decoration: BoxDecoration(color: titleColor, borderRadius: BorderRadius.circular(2)))),
                  ],
                ),
                const SizedBox(height: 6),
                Text('$count Data', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: titleColor)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPokjaGrid({required Color cardBg, required Color textCol, required Color sub, required Color border}) {
    final allPokjas = [
      (PokjaKategori.pokja1, 'Pokja I', const Color(0xFF38BDF8), Icons.groups_rounded, 1),
      (PokjaKategori.pokja2, 'Pokja II', const Color(0xFF10B981), Icons.school_rounded, 2),
      (PokjaKategori.pokja3, 'Pokja III', const Color(0xFFF59E0B), Icons.cottage_rounded, 3),
      (PokjaKategori.pokja4, 'Pokja IV', const Color(0xFFEF4444), Icons.health_and_safety_rounded, 4),
    ];

    final roleIndex = _pokjaRole == null ? null : int.tryParse(_pokjaRole!.substring(5));
    final filtered = roleIndex != null ? allPokjas.where((p) => p.$5 == roleIndex).toList() : allPokjas;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => KaderCatatanKegiatanScreen(pokjaDefault: item.$1)));
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.$3.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.$4, color: item.$3, size: 20),
                ),
                const SizedBox(height: 8),
                Text(item.$2, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: textCol)),
              ],
            ),
          ),
        );
      },
    );
  }
}
