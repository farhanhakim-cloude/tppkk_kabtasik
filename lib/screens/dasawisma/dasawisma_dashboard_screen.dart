// ignore_for_file: unused_local_variable, unused_element
// lib/screens/dasawisma/dasawisma_dashboard_screen.dart
// Dashboard Dasawisma — selaras dengan Admin & Kader (cuaca + API)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../main.dart';
import '../../services/data_keluarga_dasawisma_service.dart';
import '../../services/kriteria_rumah_service.dart';
import '../../services/keluarga_service.dart';
import '../../services/dasawisma_catatan_keluarga_service.dart';
import '../../services/kegiatan_warga_service.dart';
import '../../services/pemanfaatan_tanah_service.dart';
import '../../services/industri_rumah_tangga_service.dart';
import '../../services/rekap_ibu_anak_service.dart';
import '../../widgets/weather_card.dart';
import 'data_umum_dasawisma_screen.dart';
import 'rekap_ibu_anak_list_screen.dart';
import 'kegiatan_warga_main_screen.dart';
import '../profile_screen.dart';

class DasawismaDashboardScreen extends StatefulWidget {
  const DasawismaDashboardScreen({super.key});

  @override
  State<DasawismaDashboardScreen> createState() => _DasawismaDashboardScreenState();
}

class _DasawismaDashboardScreenState extends State<DasawismaDashboardScreen> {
  String _userName = 'Dasawisma';
  String _desaKecamatan = 'Kab. Tasikmalaya';
  bool _isDarkMode = false;
  int _navIndex = 0;
  int _weatherVersion = 0;

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
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user_data') ?? prefs.getString('user') ?? '{}';
      final data = jsonDecode(raw);
      setState(() {
        _userName = data['name'] ?? data['nama'] ?? 'Dasawisma';
        final desa = data['desa'] ?? data['kelurahan'] ?? '';
        final kec = data['kecamatan'] ?? prefs.getString('default_kecamatan') ?? 'Tasikmalaya';
        _desaKecamatan = desa.isNotEmpty ? '$desa, $kec' : 'Kec. $kec';
      });
    } catch (_) {}
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Future<void> _onRefresh() async {
    setState(() => _weatherVersion++);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF8F9FB);
    final primaryDark = const Color(0xFF0F326D);
    
    final pages = [
      _buildBeranda(bg, primaryDark),
      const DataUmumDasawismaScreen(initialIndex: 0),
      const KegiatanWargaMainScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: IndexedStack(index: _navIndex, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi FAB, mungkin menambah catatan kegiatan atau menuju ke suatu form
          Navigator.push(context, MaterialPageRoute(builder: (_) => const KegiatanWargaMainScreen()));
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
            _navItem(1, Icons.groups_rounded, 'Binaan'),
            const SizedBox(width: 40), // Spacer untuk FloatingActionButton
            _navItem(2, Icons.event_note_rounded, 'Kegiatan'),
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
      onTap: () { HapticFeedback.selectionClick(); setState(() => _navIndex = idx); },
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

  Widget _buildBeranda(Color bg, Color primaryDark) {
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final text = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final sub = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final border = _isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
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
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Icon(Icons.grid_view_rounded, size: 20, color: text),
                  ),
                  Text('Beranda', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Stack(
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 20, color: text),
                        Positioned(
                          right: 0, top: 0,
                          child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              
              // Greeting
              Text('Hi ${_userName.split(' ').first}!', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: text)),
              const SizedBox(height: 4),
              Text(_getGreeting(), style: GoogleFonts.plusJakartaSans(fontSize: 14, color: sub, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: border),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari fitur atau data...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: sub, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: sub),
                    border: InputBorder.none,
                    prefixIconConstraints: const BoxConstraints(minWidth: 40),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Welcome / Info Card
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
                          Text('Selamat Datang!', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: text)),
                          const SizedBox(height: 8),
                          Text('Mari kelola dan jadwalkan\nkegiatan PKK Anda.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: sub, height: 1.4)),
                        ],
                      ),
                    ),
                    Icon(Icons.diversity_3_rounded, size: 64, color: primaryDark), 
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Menu Utama
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Menu Dasawisma', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: text)),
                  Text('Lihat Semua', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: sub)),
                ],
              ),
              const SizedBox(height: 16),

              // Cards Grid
              FutureBuilder(
                future: Future.wait([
                  DataKeluargaDasawismaService().getAll(),
                  KegiatanWargaService().getAll(),
                  RekapIbuAnakService().getAll(),
                ]),
                builder: (c, snap) {
                  final das = (snap.data?[0] as List?)?.length ?? 0;
                  final keg = (snap.data?[1] as List?)?.length ?? 0;
                  final ibu = (snap.data?[2] as List?)?.length ?? 0;

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildDesignCard(
                        title: 'Data Umum',
                        subtitle: 'Data Binaan',
                        count: das,
                        icon: Icons.groups_rounded,
                        isActive: true,
                        primaryDark: primaryDark,
                        cardBg: cardBg,
                        text: text,
                        sub: sub,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataUmumDasawismaScreen())),
                      ),
                      _buildDesignCard(
                        title: 'Kegiatan',
                        subtitle: 'Warga',
                        count: keg,
                        icon: Icons.event_note_rounded,
                        isActive: false,
                        primaryDark: primaryDark,
                        cardBg: cardBg,
                        text: text,
                        sub: sub,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KegiatanWargaMainScreen())),
                      ),
                      _buildDesignCard(
                        title: 'Rekap Ibu',
                        subtitle: '& Anak',
                        count: ibu,
                        icon: Icons.child_care_rounded,
                        isActive: false,
                        primaryDark: primaryDark,
                        cardBg: cardBg,
                        text: text,
                        sub: sub,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RekapIbuAnakListScreen())),
                      ),
                      _buildDesignCard(
                        title: 'Cuaca',
                        subtitle: 'Prakiraan Lokal',
                        count: 0,
                        icon: Icons.cloud_rounded,
                        isActive: false,
                        primaryDark: primaryDark,
                        cardBg: cardBg,
                        text: text,
                        sub: sub,
                        isWeather: true,
                        onTap: () {}, // Optional: arahkan ke halaman cuaca atau tampilkan WeatherCard di dialog
                      ),
                    ],
                  );
                },
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
    required Color text,
    required Color sub,
    required VoidCallback onTap,
    bool isWeather = false,
  }) {
    final bgColor = isActive ? primaryDark : cardBg;
    final titleColor = isActive ? Colors.white : text;
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
            if (!isWeather)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progress', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: subColor)),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(height: 4, decoration: BoxDecoration(color: subColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                      FractionallySizedBox(widthFactor: count > 0 ? (count > 10 ? 0.8 : count / 10) : 0.1, child: Container(height: 4, decoration: BoxDecoration(color: titleColor, borderRadius: BorderRadius.circular(2)))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('$count Data Terkumpul', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: titleColor)),
                ],
              )
            else
              Text('Lihat Detail', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: titleColor)),
          ],
        ),
      ),
    );
  }
}
