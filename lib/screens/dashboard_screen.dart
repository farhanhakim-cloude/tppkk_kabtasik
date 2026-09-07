// lib/screens/dashboard_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/berita.dart';
import '../models/kesehatan.dart';
import '../services/berita_service.dart';
import '../services/keluarga_service.dart';
import '../services/kesehatan_service.dart';
import 'keluarga_list_screen.dart';
import 'kesehatan_list_screen.dart';
import 'laporan_screen.dart';
import 'profile_screen.dart';
import 'berita_screen.dart';
import 'berita_form_screen.dart';
import 'statistik_screen.dart';
import 'galeri_agenda_screen.dart';
import 'rekap_ibu_anak_list_screen.dart';
import 'data_keluarga_dasawisma_list_screen.dart';
import 'kriteria_rumah_list_screen.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SHELL with Bottom Navigation
// ─────────────────────────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.folder_shared_rounded, label: 'Data'),
    _NavItem(icon: Icons.description_rounded, label: 'Laporan'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Kesehatan'),
    _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const _BerandaPage();
      case 1:
        return const KeluargaListScreen(embedded: true);
      case 2:
        return const LaporanScreen(embedded: true);
      case 3:
        return const KesehatanListScreen(embedded: true);
      case 4:
        return const ProfileScreen(embedded: true);
      default:
        return const _BerandaPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(5, (i) => _buildPage(i)),
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        primary: primary,
        items: _navItems,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM BOTTOM NAV BAR
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Color primary;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.primary,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final isActive = i == currentIndex;
              final item = items[i];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            item.icon,
                            color: isActive ? primary : const Color(0xFF94A3B8),
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? primary : const Color(0xFF64748B),
                            letterSpacing: -0.1,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BERANDA PAGE (Home Tab)
// ─────────────────────────────────────────────────────────────────────────────
class _BerandaPage extends StatefulWidget {
  const _BerandaPage();

  @override
  State<_BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<_BerandaPage> {
  final _beritaService = BeritaService();
  final _keluargaService = KeluargaService();
  final _kesehatanService = KesehatanService();
  final _authService = AuthService();
  late Future<List<Berita>> _beritaFuture;
  late Future<({int keluarga, int balita})> _statFuture;
  late Future<User> _userFuture;

  final PageController _beritaPageController = PageController(viewportFraction: 0.88);
  final ScrollController _scrollController = ScrollController();
  int _currentBeritaPage = 0;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.notifications_active_outlined, color: Color(0xFF0D9488), size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemberitahuan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Semua data Posyandu tersinkronisasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tidak ada agenda mendesak hari ini. Tetap semangat melayani masyarakat!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Menu Navigasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.holiday_village_rounded, color: Color(0xFFD97706)),
              ),
              title: Text('Data Keluarga Dasawisma', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text('Formulir rekap anggota & kriteria rumah sehat', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DataKeluargaDasawismaListScreen()));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.child_care_rounded, color: Color(0xFF16A34A)),
              ),
              title: Text('Data Ibu & Anak Dasa Wisma', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text('Buku catatan bumil, kelahiran & kematian', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RekapIbuAnakListScreen()));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_work_rounded, color: Color(0xFF059669)),
              ),
              title: Text('Kriteria Rumah Layak Huni', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text('Penilaian kriteria layak & tidak layak huni', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const KriteriaRumahListScreen()));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF0D9488)),
              ),
              title: Text('Agenda Kegiatan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text('Jadwal & dokumentasi kegiatan', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GaleriAgendaScreen()));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.newspaper_rounded, color: Color(0xFF2563EB)),
              ),
              title: Text('Berita & Informasi PKK', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text('Kumpulan artikel dan pengumuman', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BeritaScreen()));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.person_rounded, color: Color(0xFF475569)),
              ),
              title: Text('Profil Kader', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text('Informasi akun dan data diri', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    _beritaFuture = _beritaService.getBerita();
    _statFuture = _loadStats();
    _userFuture = _authService.getCurrentUser();
  }

  Future<({int keluarga, int balita})> _loadStats() async {
    final results = await Future.wait([
      _keluargaService.getAll(),
      _kesehatanService.getAll(filter: KategoriKesehatan.balita),
    ]);
    return (keluarga: (results[0] as List).length, balita: (results[1] as List).length);
  }

  Future<void> _onRefresh() async {
    setState(() => _loadAll());
    await Future.wait([_beritaFuture, _statFuture, _userFuture]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _beritaPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // ── HEADER TOP BAR (Sesuai Referensi Pengguna) ──
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris 1: Foto Profil (Kiri) & Kapsul Lonceng + Menu (Kanan)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Foto Profil
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileScreen()),
                              );
                            },
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color(0xFFE2E8F0),
                              backgroundImage: const NetworkImage(
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
                              ),
                              onBackgroundImageError: (_, __) {},
                              child: const Icon(Icons.person_rounded, color: Color(0xFF64748B), size: 28),
                            ),
                          ),

                          // Kapsul Aksi: Tombol Lonceng Notifikasi + Menu Hamburger
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tombol Notifikasi (Lonceng dalam lingkaran lembut)
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _showNotificationSheet(context);
                                  },
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_none_rounded,
                                      color: Color(0xFF0F172A),
                                      size: 21,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Tombol Hamburger Menu (3 Garis Horizontal)
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _showQuickMenu(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    child: const Icon(
                                      Icons.menu_rounded,
                                      color: Color(0xFF0F172A),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Baris 2: Sapaan (Bahasa Indonesia) & Nama User
                      FutureBuilder<User>(
                        future: _userFuture,
                        builder: (context, snapshot) {
                          final user = snapshot.data;
                          final displayName = (user != null && user.nama.trim().isNotEmpty)
                              ? user.nama
                              : 'Kader PKK';
                          final greeting = _getGreeting();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF475569),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.6,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── REKAP TERKINI ──
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
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pantau data keluarga & gizi binaan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF0D9488)),
                            const SizedBox(width: 5),
                            Text(
                              'Data Valid',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<({int keluarga, int balita})>(
                    future: _statFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Row(
                          children: [
                            Expanded(child: _StatShimmer()),
                            SizedBox(width: 12),
                            Expanded(child: _StatShimmer()),
                          ],
                        );
                      }
                      final data = snapshot.data;
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Keluarga (KK)',
                              value: '${data?.keluarga ?? 0}',
                              sublabel: 'Binaan Dasawisma',
                              icon: Icons.family_restroom_rounded,
                              color: const Color(0xFF0D9488),
                              trend: '+3 Bln ini',
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const KeluargaListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Balita Terpantau',
                              value: '${data?.balita ?? 0}',
                              sublabel: 'Gizi Terverifikasi',
                              icon: Icons.child_care_rounded,
                              color: const Color(0xFF0284C7),
                              trend: 'Posyandu',
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const KesehatanListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── GRAFIK GIZI BALITA ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                            'Statistik Gizi Balita',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tren status gizi 6 bulan terakhir',
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
                            MaterialPageRoute(builder: (_) => const StatistikScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
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
                              Icon(Icons.arrow_forward_rounded, size: 14, color: primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _NutritionChart(primary: primary),
                ],
              ),
            ),
          ),

          // ── BERITA (paling bawah) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
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
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              HapticFeedback.selectionClick();
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BeritaFormScreen()),
                              );
                              if (res == true) {
                                _onRefresh();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.09),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.edit_note_rounded, size: 15, color: primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tulis',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              HapticFeedback.selectionClick();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BeritaScreen()),
                              );
                              _onRefresh();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
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
                    ],
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<List<Berita>>(
                    future: _beritaFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                        );
                      }
                      final beritaList = snapshot.data ?? [];
                      if (beritaList.isEmpty) {
                        return Center(
                          child: Text(
                            'Belum ada berita',
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: PageView.builder(
                              controller: _beritaPageController,
                              itemCount: beritaList.length,
                              onPageChanged: (index) => setState(() => _currentBeritaPage = index),
                              itemBuilder: (context, index) {
                                final isCenter = index == _currentBeritaPage;
                                return AnimatedScale(
                                  scale: isCenter ? 1.0 : 0.96,
                                  duration: const Duration(milliseconds: 250),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: _BeritaCard(berita: beritaList[index]),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(beritaList.length, (index) {
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
                    },
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Center(
                child: Text(
                  'TP PKK Kabupaten Tasikmalaya • v1.0.0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NUTRITION AREA WAVE CHART (Custom Painter - Persis Gambar Referensi)
// ─────────────────────────────────────────────────────────────────────────────
class _NutritionChart extends StatelessWidget {
  final Color primary;
  const _NutritionChart({required this.primary});

  @override
  Widget build(BuildContext context) {
    const chartBlue = Color(0xFF2563EB); // Biru vibrant persis seperti pada gambar
    const shadowBlue = Color(0xFF60A5FA);
    final yLabels = ['20k', '15k', '10k', '0k'];
    final xLabels = ['0', '5', '10', '15', '20', '25'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header ringkasan metrik
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: chartBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Realisasi Gizi Balita',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: shadowBlue.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Target Pemantauan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Area Chart dengan Y-Axis di sebelah kiri
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y-Axis Labels
              SizedBox(
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: yLabels.map((val) {
                    final isZero = val == '0k';
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isZero)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF43F5E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          val,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isZero
                                ? const Color(0xFFF43F5E)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),

              // Canvas Chart Area Wave
              Expanded(
                child: SizedBox(
                  height: 130,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _AreaWaveChartPainter(
                      foregroundColor: chartBlue,
                      backgroundColor: shadowBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // X-Axis Labels
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: xLabels
                  .map((lbl) => Text(
                        lbl,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter untuk menghasilkan gelombang area bertingkat persis gambar referensi
class _AreaWaveChartPainter extends CustomPainter {
  final Color foregroundColor;
  final Color backgroundColor;

  _AreaWaveChartPainter({
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Garis Grid Horizontal halus
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final y = (i / 3) * h;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 1. LAYER BACKGROUND (Area Bayangan Lembut / Target Projection)
    final bgPath = Path();
    bgPath.moveTo(0, h * 0.85);

    // Titik spline untuk gelombang latar belakang
    bgPath.cubicTo(w * 0.08, h * 0.60, w * 0.12, h * 0.12, w * 0.18, h * 0.12);
    bgPath.cubicTo(w * 0.24, h * 0.12, w * 0.28, h * 0.45, w * 0.35, h * 0.48);
    bgPath.cubicTo(w * 0.42, h * 0.52, w * 0.48, h * 0.38, w * 0.55, h * 0.40);
    bgPath.cubicTo(w * 0.62, h * 0.42, w * 0.68, h * 0.65, w * 0.78, h * 0.70);
    bgPath.cubicTo(w * 0.86, h * 0.75, w * 0.94, h * 0.88, w, h * 0.92);

    bgPath.lineTo(w, h);
    bgPath.lineTo(0, h);
    bgPath.close();

    final bgFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          backgroundColor.withValues(alpha: 0.25),
          backgroundColor.withValues(alpha: 0.04),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(bgPath, bgFillPaint);

    final bgStrokePaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final bgEdgePath = Path();
    bgEdgePath.moveTo(0, h * 0.85);
    bgEdgePath.cubicTo(w * 0.08, h * 0.60, w * 0.12, h * 0.12, w * 0.18, h * 0.12);
    bgEdgePath.cubicTo(w * 0.24, h * 0.12, w * 0.28, h * 0.45, w * 0.35, h * 0.48);
    bgEdgePath.cubicTo(w * 0.42, h * 0.52, w * 0.48, h * 0.38, w * 0.55, h * 0.40);
    bgEdgePath.cubicTo(w * 0.62, h * 0.42, w * 0.68, h * 0.65, w * 0.78, h * 0.70);
    bgEdgePath.cubicTo(w * 0.86, h * 0.75, w * 0.94, h * 0.88, w, h * 0.92);
    canvas.drawPath(bgEdgePath, bgStrokePaint);

    // 2. LAYER FOREGROUND (Gelombang Puncak Biru Utama - Persis Gambar)
    final fgPath = Path();
    fgPath.moveTo(0, h);

    // Puncak pertama yang tajam dan tinggi
    fgPath.cubicTo(w * 0.04, h * 0.95, w * 0.08, h * 0.70, w * 0.12, h * 0.35);
    fgPath.cubicTo(w * 0.13, h * 0.25, w * 0.14, h * 0.25, w * 0.15, h * 0.38);

    // Turun ke lembah
    fgPath.cubicTo(w * 0.17, h * 0.65, w * 0.19, h * 0.82, w * 0.22, h * 0.82);

    // Puncak kedua lebih kecil
    fgPath.cubicTo(w * 0.25, h * 0.82, w * 0.27, h * 0.72, w * 0.30, h * 0.72);
    fgPath.cubicTo(w * 0.33, h * 0.72, w * 0.36, h * 0.88, w * 0.39, h * 0.88);

    // Puncak ketiga
    fgPath.cubicTo(w * 0.43, h * 0.88, w * 0.47, h * 0.62, w * 0.51, h * 0.62);
    fgPath.cubicTo(w * 0.55, h * 0.62, w * 0.58, h * 0.85, w * 0.61, h * 0.85);

    // Puncak keempat
    fgPath.cubicTo(w * 0.64, h * 0.85, w * 0.67, h * 0.75, w * 0.71, h * 0.75);
    fgPath.cubicTo(w * 0.75, h * 0.75, w * 0.79, h * 0.96, w * 0.83, h);

    fgPath.lineTo(0, h);
    fgPath.close();

    final fgFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          foregroundColor,
          foregroundColor.withValues(alpha: 0.92),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fgPath, fgFillPaint);

    // Garis tepi atas gelombang foreground
    final fgEdgePath = Path();
    fgEdgePath.moveTo(0, h);
    fgEdgePath.cubicTo(w * 0.04, h * 0.95, w * 0.08, h * 0.70, w * 0.12, h * 0.35);
    fgEdgePath.cubicTo(w * 0.13, h * 0.25, w * 0.14, h * 0.25, w * 0.15, h * 0.38);
    fgEdgePath.cubicTo(w * 0.17, h * 0.65, w * 0.19, h * 0.82, w * 0.22, h * 0.82);
    fgEdgePath.cubicTo(w * 0.25, h * 0.82, w * 0.27, h * 0.72, w * 0.30, h * 0.72);
    fgEdgePath.cubicTo(w * 0.33, h * 0.72, w * 0.36, h * 0.88, w * 0.39, h * 0.88);
    fgEdgePath.cubicTo(w * 0.43, h * 0.88, w * 0.47, h * 0.62, w * 0.51, h * 0.62);
    fgEdgePath.cubicTo(w * 0.55, h * 0.62, w * 0.58, h * 0.85, w * 0.61, h * 0.85);
    fgEdgePath.cubicTo(w * 0.64, h * 0.85, w * 0.67, h * 0.75, w * 0.71, h * 0.75);
    fgEdgePath.cubicTo(w * 0.75, h * 0.75, w * 0.79, h * 0.96, w * 0.83, h);

    final fgStrokePaint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(fgEdgePath, fgStrokePaint);

    // Garis dasar horizontal bawah
    final axisPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, h), Offset(w, h), axisPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD & SHIMMER
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final String trend;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.sublabel = '',
    this.trend = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris atas: Ikon badge di kiri, badge status / tren di kanan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  if (trend.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
                      ),
                      child: Text(
                        trend,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Nilai angka metrik
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),

              // Judul kartu
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),

              // Keterangan bawah
              if (sublabel.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        sublabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatShimmer extends StatefulWidget {
  const _StatShimmer();

  @override
  State<_StatShimmer> createState() => _StatShimmerState();
}

class _StatShimmerState extends State<_StatShimmer> with SingleTickerProviderStateMixin {
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
        height: 108,
        decoration: BoxDecoration(
          color: Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFF1F5F9), _ctrl.value)!,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BERITA CARD
// ─────────────────────────────────────────────────────────────────────────────
class _BeritaCard extends StatelessWidget {
  final Berita berita;

  const _BeritaCard({required this.berita});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final hasImage = berita.gambar != null && berita.gambar!.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: hasImage
                    ? (berita.gambar!.startsWith('http://') || berita.gambar!.startsWith('https://')
                        ? Image.network(
                            berita.gambar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _ImageFallback(primary: primary),
                          )
                        : (File(berita.gambar!).existsSync()
                            ? Image.file(
                                File(berita.gambar!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _ImageFallback(primary: primary),
                              )
                            : _ImageFallback(primary: primary)))
                    : _ImageFallback(primary: primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
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
                      const Spacer(),
                      Icon(Icons.access_time_rounded, size: 11, color: Colors.grey[400]),
                      const SizedBox(width: 3),
                      Text(
                        berita.tanggal,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[500],
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    berita.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    berita.ringkasan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey[600],
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final Color primary;
  const _ImageFallback({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withValues(alpha: 0.7)],
        ),
      ),
      child: Center(
        child: Icon(Icons.article_rounded, color: Colors.white.withValues(alpha: 0.6), size: 36),
      ),
    );
  }
}


