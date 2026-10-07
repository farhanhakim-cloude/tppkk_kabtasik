// ignore_for_file: unused_local_variable, unused_element
// lib/screens/dasawisma/dasawisma_dashboard_screen.dart
// Dashboard Dasawisma — REKAP ONLY (baca dari API)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../main.dart';
<<<<<<< HEAD
import '../../services/data_keluarga_dasawisma_service.dart';
import '../../services/kegiatan_warga_service.dart';
import '../../services/rekap_ibu_anak_service.dart';
import 'data_umum_dasawisma_screen.dart';
import 'rekap_ibu_anak_list_screen.dart';
=======
import '../../models/data_keluarga_dasawisma.dart';
// ✅ GANTI: dari lokal ke API
import '../../services/daftar_warga_service.dart';
import '../../services/kegiatan_warga_service.dart';
import '../../services/bumil_service.dart';

// ✅ Form input
import 'input_keluarga_dasawisma_screen.dart';
// ✅ Halaman rekap
import 'data_umum_rekap_screen.dart';
>>>>>>> 95a9b9dad2c03998c4d068696e424208dafff536
import 'kegiatan_warga_main_screen.dart';
import 'bumil_ibu_list_screen.dart';
import '../profile_screen.dart';

class DasawismaDashboardScreen extends StatefulWidget {
  const DasawismaDashboardScreen({super.key});

  @override
  State<DasawismaDashboardScreen> createState() => _DasawismaDashboardScreenState();
}

class _DasawismaDashboardScreenState extends State<DasawismaDashboardScreen>
    with SingleTickerProviderStateMixin {
  // ── STATE ───────────────────────────────────────────
  String _userName = 'Dasawisma';
  String _desaKecamatan = 'Kab. Tasikmalaya';
  bool _isDarkMode = false;
  int _navIndex = 0;
  late TabController _tabController;

  bool _loading = true;
  List<DataKeluargaDasawisma> _listKk = [];
  int _totalKk = 0;
  int _totalJiwa = 0;
  int _totalBalita = 0;
  int _totalBumil = 0;
  int _totalKegiatan = 0;

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _tabController = TabController(length: 3, vsync: this);
    _loadUserInfo();
    _loadData();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user_data') ?? prefs.getString('user') ?? '{}';
      final data = jsonDecode(raw);
      if (!mounted) return;
      setState(() {
        _userName = data['name'] ?? data['nama'] ?? 'Dasawisma';
        final desa = data['desa'] ?? data['kelurahan'] ?? '';
        final kec = data['kecamatan'] ?? prefs.getString('default_kecamatan') ?? 'Tasikmalaya';
        _desaKecamatan = desa.isNotEmpty ? '$desa, $kec' : 'Kec. $kec';
      });
    } catch (_) {}
  }

<<<<<<< HEAD
  Future<void> _onRefresh() async {
    setState(() => _weatherVersion++);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() {});
=======
  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // ✅ PAKAI API — dari backend, masing-masing ditangani sendiri agar
      // satu endpoint gagal (mis. 404 saat backend belum siap) tidak
      // mengosongkan seluruh dashboard.
      List<DataKeluargaDasawisma> listKk = [];
      var listKeg = <dynamic>[];
      var listBumil = <dynamic>[];
      try {
        listKk = await DaftarWargaService()
            .getAll(); // ← API /api/daftar-warga
      } catch (e) {
        print('⚠️ dasbor: daftar-warga gagal: $e');
      }
      try {
        listKeg = await KegiatanWargaService().getAll();
      } catch (e) {
        print('⚠️ dasbor: kegiatan-warga gagal: $e');
      }
      try {
        listBumil = await BumilService()
            .getAll(); // ← API /api/dasawisma/bumil (per ibu)
      } catch (e) {
        print('⚠️ dasbor: bumil gagal: $e');
      }

      int totalJiwa = 0;
      int totalBalita = 0;
      for (final kk in listKk) {
        totalJiwa += (kk.jumlahLakiLaki + kk.jumlahPerempuan);
        totalBalita += (kk.jumlahBalitaL + kk.jumlahBalitaP);
      }

      if (!mounted) return;
      setState(() {
        _listKk = listKk;
        _totalKk = listKk.length;
        _totalJiwa = totalJiwa;
        _totalBalita = totalBalita;
        _totalBumil = listBumil.length;
        _totalKegiatan = listKeg.length;
        _loading = false;
      });
    } catch (e) {
      print('❌ _loadData error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi';
    if (h < 15) return 'Selamat Siang';
    if (h < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Future<void> _openInputForm() async {
    HapticFeedback.mediumImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InputKeluargaDasawismaScreen()),
    );
    if (result == true) _loadData();
>>>>>>> 95a9b9dad2c03998c4d068696e424208dafff536
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final bgColor = _isDarkMode ? const Color(0xFF10141D) : const Color(0xFFF1F4F9);
    const brandBlue = Color(0xFF0072BC);
    
    final pages = [
      _buildBeranda(bgColor, brandBlue),
      const DataUmumDasawismaScreen(initialIndex: 0),
=======
    final bg = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF8F9FB);
    const primaryDark = Color(0xFF0F766E);

    final pages = [
      _buildBeranda(primaryDark),
      const DataUmumRekapScreen(),
>>>>>>> 95a9b9dad2c03998c4d068696e424208dafff536
      const KegiatanWargaMainScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(index: _navIndex, children: pages),
<<<<<<< HEAD
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
=======
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
            _navItem(1, Icons.groups_rounded, 'Data Umum'),
            const SizedBox(width: 40),
            _navItem(2, Icons.event_note_rounded, 'Kegiatan'),
            _navItem(3, Icons.person_outline_rounded, 'Profil'),
>>>>>>> 95a9b9dad2c03998c4d068696e424208dafff536
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-dasawisma-dashboard',
        onPressed: _openInputForm,
        backgroundColor: primaryDark,
        shape: const CircleBorder(),
        elevation: 8,
        tooltip: 'Input Data Keluarga',
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
<<<<<<< HEAD
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
=======
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: sel ? FontWeight.w800 : FontWeight.w600, color: color)),
>>>>>>> 95a9b9dad2c03998c4d068696e424208dafff536
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildBeranda(Color bgColor, Color brandBlue) {
    final cardBg = _isDarkMode ? const Color(0xFF1E242F) : Colors.white;
    final textCol = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final sub = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = _isDarkMode ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);
=======
  Widget _buildBeranda(Color primaryDark) {
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final text = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final sub = _isDarkMode ? const Color(0xFF8E9BAE) : const Color(0xFF64748B);
    final border = _isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);
>>>>>>> 95a9b9dad2c03998c4d068696e424208dafff536

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
<<<<<<< HEAD
        onRefresh: _onRefresh,
        color: brandBlue,
=======
        onRefresh: _loadData,
        color: primaryDark,
>>>>>>> 95a9b9dad2c03998c4d068696e424208dafff536
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
<<<<<<< HEAD
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
=======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Icon(Icons.grid_view_rounded, size: 20, color: text),
                  ),
                  Text('Rekap Dasawisma', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Icon(Icons.notifications_none_rounded, size: 20, color: text),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text('Hi ${_userName.split(' ').first}!', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: text)),
              const SizedBox(height: 4),
              Text(_getGreeting(), style: GoogleFonts.poppins(fontSize: 14, color: sub, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),

              // Quick action
              InkWell(
                onTap: _openInputForm,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: primaryDark.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.add_home_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Input Data Keluarga', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text('5 langkah cepat • Kirim ke Desa', style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.9))),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats
              Text('Ringkasan Data', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: text)),
              const SizedBox(height: 12),
              _loading
                  ? GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: List.generate(4, (i) => Container(
                        decoration: BoxDecoration(color: primaryDark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )),
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: [
                        _statCard('Total KK', '$_totalKk', Icons.home_rounded, const Color(0xFF0D9488), cardBg, text, sub),
                        _statCard('Total Jiwa', '$_totalJiwa', Icons.people_rounded, const Color(0xFF3B82F6), cardBg, text, sub),
                        _statCard('Balita', '$_totalBalita', Icons.child_care_rounded, const Color(0xFFF59E0B), cardBg, text, sub),
                        _statCard('Ibu Hamil', '$_totalBumil', Icons.pregnant_woman_rounded, const Color(0xFFEC4899), cardBg, text, sub),
                      ],
                    ),
              const SizedBox(height: 24),

              // Tabs
              Container(
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: primaryDark,
                      unselectedLabelColor: sub,
                      indicatorColor: primaryDark,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700),
                      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                      tabs: const [
                        Tab(text: 'Data Umum'),
                        Tab(text: 'Kegiatan'),
                        Tab(text: 'Bumil'),
                      ],
                    ),
                    SizedBox(
                      height: 320,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _tabDataUmum(text, sub, primaryDark),
                          _tabKegiatan(text, sub, primaryDark),
                          _tabBumil(text, sub, primaryDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
>>>>>>> 95a9b9dad2c03998c4d068696e424208dafff536
            ],
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _statCard(String label, String value, IconData icon, Color color, Color cardBg, Color text, Color sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              Icon(Icons.trending_up_rounded, color: sub.withValues(alpha: 0.5), size: 14),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: text, height: 1)),
              const SizedBox(height: 2),
              Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: sub)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabDataUmum(Color text, Color sub, Color primary) {
    if (_listKk.isEmpty) return _emptyTab('Belum ada data KK', sub, primary);
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _listKk.length,
      itemBuilder: (c, i) {
        final kk = _listKk[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isDarkMode ? const Color(0xFF252540) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isDarkMode ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text('${i + 1}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: primary))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kk.namaKepalaRumahTangga, style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: text)),
                    Text('RT ${kk.rt} / RW ${kk.rw} • ${kk.jumlahLakiLaki + kk.jumlahPerempuan} jiwa', style: GoogleFonts.poppins(fontSize: 11, color: sub)),
                  ],
                ),
              ),
              Text('${kk.jumlahKk} KK', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: primary)),
            ],
          ),
        );
      },
    );
  }

  Widget _tabKegiatan(Color text, Color sub, Color primary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_rounded, size: 48, color: sub.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('$_totalKegiatan Data Kegiatan', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: text)),
            const SizedBox(height: 6),
            Text('Lihat detail di tab Kegiatan', style: GoogleFonts.poppins(fontSize: 12, color: sub)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => setState(() => _navIndex = 2),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text('Buka Halaman Kegiatan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
>>>>>>> 95a9b9dad2c03998c4d068696e424208dafff536
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
  
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

=======

  Widget _tabBumil(Color text, Color sub, Color primary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pregnant_woman_rounded, size: 48, color: sub.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('$_totalBumil Data Ibu & Anak', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: text)),
            const SizedBox(height: 6),
            Text('Lihat detail rekap bumil', style: GoogleFonts.poppins(fontSize: 12, color: sub)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BumilIbuListScreen())),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text('Buka Data Bumil', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyTab(String msg, Color sub, Color primary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: sub.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(msg, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: sub)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _openInputForm,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text('Input Sekarang', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 95a9b9dad2c03998c4d068696e424208dafff536
