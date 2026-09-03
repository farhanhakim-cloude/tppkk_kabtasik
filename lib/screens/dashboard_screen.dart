// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/pokja_1_model.dart';
import '../models/pokja_2_model.dart';
import '../models/pokja_3_model.dart';
import '../models/pokja_4_model.dart';
import '../models/sekretariat_model.dart';
import '../models/berita.dart';
import 'keluarga_list_screen.dart';
import 'kesehatan_list_screen.dart';
import 'statistik_screen.dart';
import 'laporan_screen.dart';
import 'profile_screen.dart';
import 'catatan_kegiatan_form_screen.dart';
import 'berita_screen.dart';
import 'galeri_agenda_screen.dart';
import 'riwayat_laporan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  
  // Data dari API
  Pokja1Response? _pokja1;
  Pokja2Response? _pokja2;
  Pokja3Response? _pokja3;
  Pokja4Response? _pokja4;
  SekretariatResponse? _sekretariat;
  List<Berita> _beritaList = [];
  
  bool _loading = true;
  String _error = '';
  
  final PageController _beritaPageController = PageController(viewportFraction: 0.88);
  final ScrollController _scrollController = ScrollController();
  int _currentBeritaPage = 0;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 20;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
    }
  }

  Future<void> _loadAllData() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final results = await Future.wait([
        _apiService.getPokja1(),
        _apiService.getPokja2(),
        _apiService.getPokja3(),
        _apiService.getPokja4(),
        _apiService.getSekretariat(),
        _apiService.getBerita(),
      ]);

      setState(() {
        _pokja1 = results[0] as Pokja1Response;
        _pokja2 = results[1] as Pokja2Response;
        _pokja3 = results[2] as Pokja3Response;
        _pokja4 = results[3] as Pokja4Response;
        _sekretariat = results[4] as SekretariatResponse;
        _beritaList = results[5] as List<Berita>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadAllData();
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        await _apiService.logout(token);
      }
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Silent logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _showLainnyaSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menu Lainnya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Akses fitur tambahan PKK',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SheetTile(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri & Agenda',
                  subtitle: 'Dokumentasi & jadwal kegiatan PKK',
                  color: const Color(0xFF0EA5E9),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GaleriAgendaScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _SheetTile(
                  icon: Icons.campaign_rounded,
                  label: 'Berita Lengkap',
                  subtitle: 'Informasi & pengumuman resmi',
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BeritaScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _SheetTile(
                  icon: Icons.history_rounded,
                  label: 'Riwayat Laporan',
                  subtitle: 'Laporan kegiatan yang telah dikirim',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RiwayatLaporanScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _beritaPageController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  // ================================================================
  // BUILD HEADER
  // ================================================================
  Widget _buildHeaderCard(Color primary, {bool isScrolled = false}) {
    return Row(
      children: [
        // Logo
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: primary.withOpacity(0.08),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.groups_rounded,
              color: primary,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TP PKK Tasikmalaya',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Kader Aktif',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Notif
        _HeaderIconBtn(
          icon: Icons.notifications_outlined,
          onTap: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Belum ada notifikasi baru',
                  style: GoogleFonts.plusJakartaSans(),
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        // Avatar
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: primary.withOpacity(0.12),
            child: Icon(Icons.person_rounded, color: primary, size: 20),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // BUILD TREND STATISTIC (Pengganti Banner) - DIAGRAM BATANG
  // ================================================================
  Widget _buildTrendStatistic(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Text(
                'Aktivitas Kegiatan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up_rounded, size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '+14%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Bar Chart Custom
          SizedBox(
            height: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarItem(label: 'Jan', value: 0.3, primary: primary),
                _buildBarItem(label: 'Feb', value: 0.5, primary: primary),
                _buildBarItem(label: 'Mar', value: 0.4, primary: primary),
                _buildBarItem(label: 'Apr', value: 0.7, primary: primary),
                _buildBarItem(label: 'Mei', value: 0.6, primary: primary),
                _buildBarItem(label: 'Jun', value: 1.0, primary: primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarItem({required String label, required double value, required Color primary}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: value,
              child: Container(
                width: 26,
                decoration: BoxDecoration(
                  color: value == 1.0 ? primary : primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: value == 1.0 ? const Color(0xFF0F172A) : Colors.grey[400],
            fontWeight: value == 1.0 ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // MAIN BUILD
  // ================================================================
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: _isScrolled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                child: _buildHeaderCard(primary, isScrolled: _isScrolled),
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // =========================
                  // REKAP TERKINI
                  // =========================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rekap Terkini',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Pantau perkembangan data',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StatistikScreen(),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Detail',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 14,
                                        color: primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatCards(),
                        ],
                      ),
                    ),
                  ),

                  // =========================
                  // TREND STATISTIC
                  // =========================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: _buildTrendStatistic(primary),
                    ),
                  ),

                  // =========================
                  // MENU & BERITA
                  // =========================
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildMenuSection(primary),
                        const SizedBox(height: 16),
                        _buildBeritaSection(primary),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'TP PKK Kabupaten Tasikmalaya • v1.0.0',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ]),
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

  // ================================================================
  // BUILD STAT CARDS
  // ================================================================
  Widget _buildStatCards() {
    if (_loading) {
      return Row(
        children: [
          Expanded(child: _StatShimmer()),
          const SizedBox(width: 12),
          Expanded(child: _StatShimmer()),
        ],
      );
    }

    final keluargaCount = _sekretariat?.data?.length ?? 0;
    final balitaCount = _pokja4?.data?.length ?? 0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Keluarga',
            value: '$keluargaCount',
            sublabel: 'KK terdata aktif',
            icon: Icons.family_restroom_rounded,
            color: const Color(0xFF3B82F6),
            trend: '+3 Bulan ini',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Balita Terpantau',
            value: '$balitaCount',
            sublabel: 'Gizi terpantau',
            icon: Icons.child_friendly_rounded,
            color: const Color(0xFF10B981),
            trend: '100% Valid',
          ),
        ),
      ],
    );
  }

  // ================================================================
  // BUILD MENU SECTION
  // ================================================================
  Widget _buildMenuSection(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu Pencatatan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kelola data PKK dengan mudah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '6 Menu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          childAspectRatio: 0.95,
          children: [
            _MenuTile(
              icon: Icons.home_work_rounded,
              label: 'Data Keluarga',
              subtitle: 'Kelola KK',
              color: const Color(0xFF0F9E8E),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KeluargaListScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.child_care_rounded,
              label: 'Kesehatan',
              subtitle: 'Ibu & Anak',
              color: const Color(0xFFE91E63),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KesehatanListScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.insert_chart_rounded,
              label: 'Statistik',
              subtitle: 'Rekap Data',
              color: const Color(0xFF3F51B5),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatistikScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.description_rounded,
              label: 'Laporan',
              subtitle: 'Export PDF',
              color: const Color(0xFFFF9800),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LaporanScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.edit_note_rounded,
              label: 'Catat Kegiatan',
              subtitle: 'Pokja I-IV',
              color: const Color(0xFF9C27B0),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CatatanKegiatanFormScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.apps_rounded,
              label: 'Lainnya',
              subtitle: 'Semua Fitur',
              color: const Color(0xFF64748B),
              isMore: true,
              onTap: _showLainnyaSheet,
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  // BUILD BERITA SECTION
  // ================================================================
  Widget _buildBeritaSection(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Berita Terbaru',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Informasi resmi PKK',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BeritaScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: primary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildBeritaContent(primary),
      ],
    );
  }

  Widget _buildBeritaContent(Color primary) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    if (_error.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Gagal memuat berita',
                style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: _loadAllData,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_beritaList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Belum ada berita',
            style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _beritaPageController,
            itemCount: _beritaList.length,
            onPageChanged: (index) => setState(() => _currentBeritaPage = index),
            itemBuilder: (context, index) {
              final isCenter = index == _currentBeritaPage;
              return AnimatedScale(
                scale: isCenter ? 1.0 : 0.96,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _BeritaCard(berita: _beritaList[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_beritaList.length, (index) {
            final isActive = index == _currentBeritaPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 24 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive ? primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ================================================================
// HEADER ICON BUTTON
// ================================================================
class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
      ),
    );
  }
}

// ================================================================
// MENU TILE
// ================================================================
class _MenuTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isMore;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle = '',
    this.isMore = false,
  });

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.isMore
                      ? const Color(0xFF64748B).withOpacity(0.08)
                      : widget.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isMore ? const Color(0xFF64748B) : widget.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              if (widget.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// STAT CARD
// ================================================================
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final String trend;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.sublabel = '',
    this.trend = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          if (trend.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 11, color: color),
                const SizedBox(width: 3),
                Text(
                  trend,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ================================================================
// STAT SHIMMER
// ================================================================
class _StatShimmer extends StatefulWidget {
  @override
  State<_StatShimmer> createState() => _StatShimmerState();
}

class _StatShimmerState extends State<_StatShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        height: 132,
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFFE2E8F0),
            const Color(0xFFF1F5F9),
            _ctrl.value,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ================================================================
// SHEET TILE
// ================================================================
class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// BERITA CARD
// ================================================================
class _BeritaCard extends StatelessWidget {
  final Berita berita;

  const _BeritaCard({required this.berita});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BeritaScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, primary.withOpacity(0.75)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.article_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'BERITA RESMI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      berita.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      berita.deskripsi ?? 'Klik untuk membaca selengkapnya',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[600],
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          berita.createdAt ?? 'Tanggal tidak tersedia',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey[500],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Baca →',
                          style: GoogleFonts.plusJakartaSans(
                            color: primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}