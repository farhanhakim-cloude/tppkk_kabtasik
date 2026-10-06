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
import '../../services/kegiatan_warga_service.dart';
import '../../services/rekap_ibu_anak_service.dart';
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

  Future<void> _onRefresh() async {
    setState(() => _weatherVersion++);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF10141D) : const Color(0xFFF1F4F9);
    const brandBlue = Color(0xFF0072BC);
    
    final pages = [
      _buildBeranda(bgColor, brandBlue),
      const DataUmumDasawismaScreen(initialIndex: 0),
      const KegiatanWargaMainScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(index: _navIndex, children: pages),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          heroTag: 'fab-dasawisma-dashboard',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const KegiatanWargaMainScreen()));
          },
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add_rounded, size: 28, color: brandBlue),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navItem(0, Icons.home_rounded, 'Beranda'),
                      const SizedBox(width: 4),
                      _navItem(1, Icons.groups_rounded, 'Binaan'),
                    ],
                  ),
                  const SizedBox(width: 60),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navItem(2, Icons.event_note_rounded, 'Kegiatan'),
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
      onTap: () { HapticFeedback.selectionClick(); setState(() => _navIndex = idx); },
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
                size: 22,
                color: isSelected ? const Color(0xFF0072BC) : Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
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
        onRefresh: _onRefresh,
        color: brandBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KOP PROFIL DINAS
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
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
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
                            'Dasawisma • $_desaKecamatan',
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

              // 2. RINGKASAN DATA (Cards Grid)
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

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSimpleCard(
                              title: 'Data Binaan',
                              count: das,
                              icon: Icons.groups_outlined,
                              brandBlue: brandBlue,
                              cardBg: cardBg,
                              textCol: textCol,
                              sub: sub,
                              border: border,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataUmumDasawismaScreen(initialIndex: 0))),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSimpleCard(
                              title: 'Kegiatan Warga',
                              count: keg,
                              icon: Icons.event_note_outlined,
                              brandBlue: brandBlue,
                              cardBg: cardBg,
                              textCol: textCol,
                              sub: sub,
                              border: border,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KegiatanWargaMainScreen())),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSimpleCard(
                              title: 'Rekap Ibu & Anak',
                              count: ibu,
                              icon: Icons.child_care_outlined,
                              brandBlue: brandBlue,
                              cardBg: cardBg,
                              textCol: textCol,
                              sub: sub,
                              border: border,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RekapIbuAnakListScreen())),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSimpleWeatherCard(
                              brandBlue: brandBlue,
                              cardBg: cardBg,
                              textCol: textCol,
                              sub: sub,
                              border: border,
                            ),
                          ),
                        ],
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

  Widget _buildSimpleCard({
    required String title,
    required int count,
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
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: sub, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: brandBlue, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textCol,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSimpleWeatherCard({
    required Color brandBlue,
    required Color cardBg,
    required Color textCol,
    required Color sub,
    required Color border,
  }) {
    return Container(
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
              Expanded(
                child: Text(
                  'Cuaca',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: sub, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.cloud_outlined, color: brandBlue, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Cerah',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }
}

