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
import '../services/kriteria_rumah_service.dart';
import '../services/rekap_ibu_anak_service.dart';
import 'catatan_kegiatan_form_screen.dart';
import 'keluarga_list_screen.dart';
import 'kesehatan_list_screen.dart';
import 'laporan_screen.dart';
import 'profile_screen.dart';
import 'berita_screen.dart';
import 'berita_form_screen.dart';
import 'statistik_screen.dart';
import 'galeri_agenda_screen.dart';
import 'rekap_ibu_anak_list_screen.dart';
import 'kesehatan_keibuan_screen.dart';
import 'data_keluarga_dasawisma_list_screen.dart';
import 'kriteria_rumah_list_screen.dart';
import 'industri_rumah_tangga_list_screen.dart';
import 'pokja2_form_screen.dart';
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
    _NavItem(icon: Icons.notifications_rounded, label: 'Notifikasi'),
    _NavItem(icon: Icons.description_rounded, label: 'Laporan'),
    _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const _BerandaPage();
      case 1:
        return const _NotifikasiPage();
      case 2:
        return const LaporanScreen(embedded: true);
      case 3:
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
        children: List.generate(4, (i) => _buildPage(i)),
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
// NOTIFIKASI PAGE (Notifikasi Tab)
// ─────────────────────────────────────────────────────────────────────────────
class _NotifikasiPage extends StatelessWidget {
  const _NotifikasiPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemberitahuan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Semua notifikasi dan pembaruan terkini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Column(
                  children: [
                    _NotifItem(
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF10B981),
                      bgColor: const Color(0xFFECFDF5),
                      title: 'Data Posyandu Tersinkronisasi',
                      subtitle: 'Semua data posyandu bulan ini telah berhasil disinkronkan dengan server.',
                      time: 'Hari ini',
                    ),
                    const SizedBox(height: 10),
                    _NotifItem(
                      icon: Icons.assignment_turned_in_rounded,
                      iconColor: const Color(0xFF0D9488),
                      bgColor: const Color(0xFFF0FDFA),
                      title: 'Laporan PKK Siap Diunduh',
                      subtitle: 'Laporan bulanan Pokja I–IV sudah dapat dicetak atau diunduh.',
                      time: 'Kemarin',
                    ),
                    const SizedBox(height: 10),
                    _NotifItem(
                      icon: Icons.notifications_active_rounded,
                      iconColor: const Color(0xFF2563EB),
                      bgColor: const Color(0xFFEFF6FF),
                      title: 'Pengingat Posyandu Balita',
                      subtitle: 'Jadwal posyandu balita minggu ini. Pastikan kader sudah siap bertugas.',
                      time: '2 hari lalu',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String time;

  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5, color: const Color(0xFF0F172A)),
                      ),
                    ),
                    Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MENU NAV CARD (Used in Home page grid)
// ─────────────────────────────────────────────────────────────────────────────
class _MenuNavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final List<Color>? gradient;
  final String? imagePath;

  const _MenuNavCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.gradient,
    this.imagePath,
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 105),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Center(
                  child: imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(imagePath!, fit: BoxFit.cover),
                        )
                      : Icon(icon, color: color, size: 26),
                ),
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    height: 1.25,
                  ),
                ),
              ),
            ],
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
  final _kriteriaRumahService = KriteriaRumahService();
  final _authService = AuthService();
  late Future<List<Berita>> _beritaFuture;
  late Future<({int rumah, int keluarga})> _statFuture;
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

  Future<({int rumah, int keluarga})> _loadStats() async {
    final results = await Future.wait([
      _kriteriaRumahService.getAll(),
      _keluargaService.getAll(),
    ]);
    return (rumah: (results[0] as List).length, keluarga: (results[1] as List).length);
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Sapaan & Nama User di Kiri
                      Expanded(
                        child: FutureBuilder<User>(
                          future: _userFuture,
                          builder: (context, snapshot) {
                            final user = snapshot.data;
                            final displayName = (user != null && user.nama.trim().isNotEmpty)
                                ? user.nama
                                : 'Kader PKK';
                            final greeting = _getGreeting();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  greeting,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Foto Profil di Kanan Atas (Gantikan Posisi Notifikasi)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFE2E8F0),
                            backgroundImage: const NetworkImage(
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
                            ),
                            onBackgroundImageError: (_, __) {},
                            child: const Icon(Icons.person_rounded, color: Color(0xFF64748B), size: 24),
                          ),
                        ),
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
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
                            'Pantau data rumah & keluarga binaan',
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
                  FutureBuilder<({int rumah, int keluarga})>(
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
                              label: 'Data Rumah',
                              value: '${data?.rumah ?? 0}',
                              sublabel: 'Kriteria Kelayakan',
                              icon: Icons.house_rounded,
                              color: const Color(0xFFFF6B35),
                              trend: 'Dasawisma',
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const KriteriaRumahListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Data KK',
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
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── MENU NAVIGASI UTAMA (Di bawah Rekap Terkini) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'MENU',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Menu Pencatatan Data',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text(
                      'Pilih menu untuk mencatat data kegiatan PKK',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Row 1: 3 kolom
                  Row(
                    children: [
                      Expanded(
                        child: _MenuNavCard(
                          imagePath: null,
                          icon: Icons.house_rounded,
                          label: 'Data Rumah\nTinggal',
                          color: const Color(0xFFFF6B35),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KriteriaRumahListScreen())),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MenuNavCard(
                          imagePath: null,
                          icon: Icons.family_restroom_rounded,
                          label: 'Data\nKeluarga',
                          color: const Color(0xFF4CAF50),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KeluargaListScreen())),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MenuNavCard(
                          imagePath: null,
                          icon: Icons.assignment_rounded,
                          label: 'Catatan\nKegiatan',
                          color: const Color(0xFF2196F3),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatanKegiatanFormScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Row 2: 3 kolom
                  Row(
                    children: [
                      Expanded(
                        child: _MenuNavCard(
                          imagePath: null,
                          icon: Icons.eco_rounded,
                          label: 'Pekarangan\nRumah',
                          color: const Color(0xFF8BC34A),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataKeluargaDasawismaListScreen())),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MenuNavCard(
                          imagePath: null,
                          icon: Icons.favorite_rounded,
                          label: 'Kesehatan\n& Keibuan',
                          color: const Color(0xFFE91E63),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KesehatanKeibuanScreen())),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MenuNavCard(
                          imagePath: null,
                          icon: Icons.storefront_rounded,
                          label: 'Industri\nRumah Tangga',
                          color: const Color(0xFF7C3AED),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IndustriRumahTanggaListScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Row 3: 1 kolom tambahan untuk Pokja II
                  Row(
                    children: [
                      Expanded(
                        child: _MenuNavCard(
                          imagePath: null,
                          icon: Icons.school_rounded,
                          label: 'Input Data\nPokja II',
                          color: const Color(0xFF059669), // Emerald
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Pokja2FormScreen())),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Spacer(),
                      const SizedBox(width: 10),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── STATISTIK KESEHATAN IBU & BAYI ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistik Kesehatan Ibu & Bayi',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kelahiran, nifas & keselamatan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const KesehatanKeibuanScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                  _KesehatanIbuBayiChart(primary: primary),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Berita Terbaru',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Informasi resmi PKK',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
class _KesehatanIbuBayiChart extends StatelessWidget {
  final Color primary;
  const _KesehatanIbuBayiChart({required this.primary});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RekapIbuAnakSummary>(
      future: RekapIbuAnakService().getSummary(),
      builder: (context, snapshot) {
        final summary = snapshot.data ??
            RekapIbuAnakSummary(
              jumlahHamil: 2,
              jumlahMelahirkan: 1,
              jumlahNifas: 1,
              jumlahIbuMeninggal: 0,
              jumlahBayiLahir: 2,
              jumlahBayiMeninggal: 0,
              jumlahBalitaMeninggal: 0,
            );

        final items = [
          _ChartBarItem(
            label: 'Ibu Hamil',
            value: summary.jumlahHamil,
            color: const Color(0xFF3B82F6), // Biru
          ),
          _ChartBarItem(
            label: 'Melahirkan',
            value: summary.jumlahMelahirkan,
            color: const Color(0xFF10B981), // Hijau Zamrud
          ),
          _ChartBarItem(
            label: 'Nifas',
            value: summary.jumlahNifas,
            color: const Color(0xFFF59E0B), // Amber / Kuning Emas
          ),
          _ChartBarItem(
            label: 'Bayi Lahir',
            value: summary.jumlahBayiLahir,
            color: const Color(0xFF06B6D4), // Cyan
          ),
          _ChartBarItem(
            label: 'Bayi Wafat',
            value: summary.jumlahBayiMeninggal + summary.jumlahBalitaMeninggal,
            color: const Color(0xFFFB7185), // Rose
          ),
          _ChartBarItem(
            label: 'Ibu Wafat',
            value: summary.jumlahIbuMeninggal,
            color: const Color(0xFFEF4444), // MERAH MENCOLOK KHUSUS
            isWarning: true,
          ),
        ];

        final maxValue = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
        final chartMax = maxValue < 5 ? 5 : maxValue + 1;

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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Ringkasan Atas (Tanpa icon)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Rekapitulasi Pelayanan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Indikator Spesial Ibu Meninggal
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: summary.jumlahIbuMeninggal > 0
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: summary.jumlahIbuMeninggal > 0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ibu Wafat: ${summary.jumlahIbuMeninggal}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: summary.jumlahIbuMeninggal > 0
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── DIAGRAM BATANG VISUAL (Tanpa icon & tanpa teks di bawah batang) ──
              SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: items.map((item) {
                    final ratio = (item.value / chartMax).clamp(0.0, 1.0);
                    final barHeight = 16.0 + (ratio * 64.0);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Angka di atas batang
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.isWarning
                                    ? const Color(0xFFEF4444)
                                    : item.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${item.value}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: item.isWarning ? Colors.white : item.color,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Batang Grafik Polos (Tanpa Icon)
                            Container(
                              height: barHeight,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: item.isWarning
                                      ? [
                                          const Color(0xFFEF4444),
                                          const Color(0xFFB91C1C),
                                        ]
                                      : [
                                          item.color,
                                          item.color.withValues(alpha: 0.75),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: item.isWarning
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: item.color.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                border: item.isWarning
                                    ? Border.all(color: Colors.white, width: 1.5)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),

              // Legend / Tanda Keterangan Bawah (Menggunakan Wrap agar tidak pernah overflow)
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _legendDot(const Color(0xFF3B82F6), 'Ibu Hamil'),
                    _legendDot(const Color(0xFF10B981), 'Melahirkan'),
                    _legendDot(const Color(0xFFF59E0B), 'Nifas'),
                    _legendDot(const Color(0xFF06B6D4), 'Bayi Lahir'),
                    _legendDot(const Color(0xFFFB7185), 'Bayi Wafat'),
                    _legendDot(const Color(0xFFEF4444), 'Ibu Wafat', isRed: true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendDot(Color color, String text, {bool isRed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: isRed ? FontWeight.w800 : FontWeight.w600,
            color: isRed ? const Color(0xFFDC2626) : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

class _ChartBarItem {
  final String label;
  final int value;
  final Color color;
  final bool isWarning;

  const _ChartBarItem({
    required this.label,
    required this.value,
    required this.color,
    this.isWarning = false,
  });
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
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Baris atas: Ikon badge di kiri, badge status / tren di kanan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  if (trend.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
                      ),
                      child: Text(
                        trend,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Nilai angka metrik
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),

              // Judul kartu
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),

              // Keterangan bawah
              if (sublabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sublabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 9,
                      color: color,
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
        height: 118,
        decoration: BoxDecoration(
          color: Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFF1F5F9), _ctrl.value)!,
          borderRadius: BorderRadius.circular(16),
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


