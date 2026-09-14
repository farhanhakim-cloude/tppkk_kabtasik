import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verifikasi_berita_screen.dart';
import 'verifikasi_laporan_screen.dart';
import '../catatan_kegiatan_form_screen.dart';
import '../berita_form_screen.dart';
import '../../constants/app_constants.dart';
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
  bool _loadingCount = true;

  @override
  void initState() {
    super.initState();
    _loadPendingCounts();
  }

  // ============================================================
  // 🔥 LOAD PENDING COUNTS DARI API
  // ============================================================
  Future<void> _loadPendingCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey) ?? '';

      if (token.isEmpty) {
        setState(() => _loadingCount = false);
        return;
      }

      // Fetch pending berita
      final beritaRes = await http.get(
        Uri.parse('${AppConstants.baseUrl}admin/berita/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      // Fetch pending laporan
      final laporanRes = await http.get(
        Uri.parse('${AppConstants.baseUrl}laporan-kegiatan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      // Parse berita
      int beritaCount = 0;
      if (beritaRes.statusCode == 200) {
        final data = jsonDecode(beritaRes.body);
        final rawData = data['data'];
        if (rawData is List) {
          beritaCount = rawData.length;
        } else if (rawData is Map && rawData['data'] is List) {
          beritaCount = (rawData['data'] as List).length;
        } else if (data['count'] != null) {
          beritaCount = data['count'] as int;
        }
      }

      // Parse laporan — filter status pending
      int laporanCount = 0;
      if (laporanRes.statusCode == 200) {
        final data = jsonDecode(laporanRes.body);
        final rawData = data['data'];

        List<dynamic> list = [];
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          list = rawData['data'] as List;
        }

        // Filter yang statusnya pending
        laporanCount = list.where((item) {
          final status = item['status']?.toString() ?? '';
          return status == 'pending';
        }).length;
      }

      if (!mounted) return;
      setState(() {
        _pendingBeritaCount = beritaCount;
        _pendingLaporanCount = laporanCount;
        _loadingCount = false;
      });

      print('🔔 Pending — Berita: $beritaCount, Laporan: $laporanCount');
    } catch (e) {
      print('❌ Error load pending count: $e');
      if (mounted) {
        setState(() => _loadingCount = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPendingCounts,
          color: const Color(0xFF0D9488),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pusat verifikasi dan manajemen kegiatan',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Verifikasi Data',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      if (!_loadingCount &&
                          (_pendingBeritaCount + _pendingLaporanCount) > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFCD34D),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Color(0xFFB45309),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_pendingBeritaCount + _pendingLaporanCount} Menunggu',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: const SizedBox(height: 12),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AdminMenuCard(
                          icon: Icons.article_rounded,
                          label: 'Berita Pending',
                          color: const Color(0xFF2563EB),
                          badgeCount: _pendingBeritaCount,
                          isLoading: _loadingCount,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VerifikasiBeritaScreen(),
                              ),
                            );
                            // Refresh count setelah kembali
                            _loadPendingCounts();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AdminMenuCard(
                          icon: Icons.assignment_turned_in_rounded,
                          label: 'Verifikasi Laporan',
                          color: const Color(0xFF10B981),
                          badgeCount: _pendingLaporanCount,
                          isLoading: _loadingCount,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VerifikasiLaporanScreen(),
                              ),
                            );
                            _loadPendingCounts();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Input Langsung',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: const SizedBox(height: 12),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _AdminListAction(
                        icon: Icons.add_photo_alternate_rounded,
                        title: 'Input Berita Baru',
                        subtitle: 'Tambah berita langsung dari panel admin',
                        color: const Color(0xFFF59E0B),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BeritaFormScreen(isAdminMode: true),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _AdminListAction(
                        icon: Icons.post_add_rounded,
                        title: 'Input Laporan Kegiatan',
                        subtitle: 'Tambah laporan kegiatan',
                        color: const Color(0xFF8B5CF6),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CatatanKegiatanFormScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int badgeCount;
  final bool isLoading;
  final VoidCallback onTap;

  const _AdminMenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.badgeCount,
    required this.isLoading,
    required this.onTap,
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
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            // 🔔 BADGE COUNT
            if (!isLoading && badgeCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Loading indicator
            if (isLoading)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminListAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminListAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFCBD5E1),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}