import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/berita.dart';
import '../services/berita_service.dart';
import 'keluarga_list_screen.dart';
import 'kesehatan_list_screen.dart';
import 'statistik_screen.dart';
import 'laporan_screen.dart';
import 'profile_screen.dart';
import 'catatan_kegiatan_form_screen.dart';
import 'riwayat_laporan_screen.dart';
import 'berita_screen.dart';
import 'galeri_agenda_screen.dart';

// ────────────────────────────────────────────────
// Helper: Staggered Fade+Slide masuk dari bawah
// ────────────────────────────────────────────────
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index; // urutan: makin besar makin lambat
  final Duration delay;

  const _FadeSlideIn({required this.child, this.index = 0, this.delay = Duration.zero});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay + Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ────────────────────────────────────────────────
// Helper: Press-scale effect untuk menu tile
// ────────────────────────────────────────────────
class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressScale({required this.child, required this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ════════════════════════════════════════════════
// Dashboard Screen
// ════════════════════════════════════════════════
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final _beritaService = BeritaService();
  late Future<List<Berita>> _beritaFuture;
  final PageController _beritaPageController = PageController(viewportFraction: 0.88);
  int _currentBeritaPage = 0;

  // Animated banner gradient
  late AnimationController _bannerController;
  late Animation<AlignmentGeometry> _gradientBegin;
  late Animation<AlignmentGeometry> _gradientEnd;

  @override
  void initState() {
    super.initState();
    _beritaFuture = _beritaService.getBerita();

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _gradientBegin = AlignmentTween(begin: Alignment.topLeft, end: Alignment.centerLeft)
        .animate(CurvedAnimation(parent: _bannerController, curve: Curves.easeInOut));
    _gradientEnd = AlignmentTween(begin: Alignment.bottomRight, end: Alignment.topRight)
        .animate(CurvedAnimation(parent: _bannerController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _beritaPageController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _beritaFuture = _beritaService.getBerita());
        },
        child: CustomScrollView(
          slivers: [
            // ── Top Bar ──
            SliverToBoxAdapter(
              child: _FadeSlideIn(
                delay: const Duration(milliseconds: 50),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/logo.png', width: 34, height: 34),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TP PKK Kab. Tasikmalaya',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              Text(
                                'Kader Dasawisma',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: primary.withOpacity(0.1),
                          child: Icon(Icons.person_rounded, color: primary, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Animated Banner ──
                  _FadeSlideIn(
                    index: 0,
                    delay: const Duration(milliseconds: 100),
                    child: AnimatedBuilder(
                      animation: _bannerController,
                      builder: (context, child) {
                        return Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: _gradientBegin.value,
                              end: _gradientEnd.value,
                              colors: [
                                const Color(0xFF1D4ED8),
                                const Color(0xFF2563EB),
                                const Color(0xFF3B82F6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Icon(Icons.circle_outlined, size: 140, color: Colors.white.withOpacity(0.06)),
                          ),
                          Positioned(
                            right: 16,
                            bottom: -10,
                            child: Icon(Icons.favorite_rounded, size: 90, color: Colors.white.withOpacity(0.09)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'e-PKK Dasawisma',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kabupaten Tasikmalaya',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white.withOpacity(0.80),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Lapor Kegiatan Sekarang →',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Judul Menu ──
                  _FadeSlideIn(
                    index: 1,
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Menu Utama',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Grid Menu dengan animasi staggered ──
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _buildMenuTile(context, index: 0, icon: Icons.send_rounded, label: 'Lapor Kegiatan', color: const Color(0xFF2563EB), onTap: () {
                        Navigator.push(context, _slideRoute(const CatatanKegiatanFormScreen()));
                      }),
                      _buildMenuTile(context, index: 1, icon: Icons.history_rounded, label: 'Riwayat Laporan', color: const Color(0xFF0EA5E9), onTap: () {
                        Navigator.push(context, _slideRoute(const RiwayatLaporanScreen()));
                      }),
                      _buildMenuTile(context, index: 2, icon: Icons.campaign_rounded, label: 'Berita PKK', color: const Color(0xFF6366F1), onTap: () {
                        Navigator.push(context, _slideRoute(const BeritaScreen()));
                      }),
                      _buildMenuTile(context, index: 3, icon: Icons.photo_library_rounded, label: 'Galeri & Agenda', color: const Color(0xFF14B8A6), onTap: () {
                        Navigator.push(context, _slideRoute(const GaleriAgendaScreen()));
                      }),
                      _buildMenuTile(context, index: 4, icon: Icons.home_work_rounded, label: 'Data Keluarga', color: const Color(0xFF3B82F6), onTap: () {
                        Navigator.push(context, _slideRoute(const KeluargaListScreen()));
                      }),
                      _buildMenuTile(context, index: 5, icon: Icons.child_care_rounded, label: 'Kesehatan Ibu & Anak', color: const Color(0xFFEC4899), onTap: () {
                        Navigator.push(context, _slideRoute(const KesehatanListScreen()));
                      }),
                      _buildMenuTile(context, index: 6, icon: Icons.insert_chart_rounded, label: 'Statistik', color: const Color(0xFF8B5CF6), onTap: () {
                        Navigator.push(context, _slideRoute(const StatistikScreen()));
                      }),
                      _buildMenuTile(context, index: 7, icon: Icons.description_rounded, label: 'Laporan', color: const Color(0xFFF59E0B), onTap: () {
                        Navigator.push(context, _slideRoute(const LaporanScreen()));
                      }),
                      _buildMenuTile(context, index: 8, icon: Icons.more_horiz_rounded, label: 'Lainnya', color: const Color(0xFF94A3B8), onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Rekap ──
                  _FadeSlideIn(
                    index: 9,
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Rekap Keseluruhan Data',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FadeSlideIn(
                    index: 10,
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      children: [
                        Expanded(child: _StatCard(label: 'Total Keluarga', value: '128', icon: Icons.home_rounded, color: const Color(0xFF2563EB))),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(label: 'Balita Terpantau', value: '45', icon: Icons.child_friendly_rounded, color: const Color(0xFFF59E0B))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Berita ──
                  _FadeSlideIn(
                    index: 11,
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Berita Terbaru', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, _slideRoute(const BeritaScreen())),
                          child: Text('Lihat semua', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  FutureBuilder<List<Berita>>(
                    future: _beritaFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _ShimmerLoader();
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Gagal memuat berita: ${snapshot.error}', style: GoogleFonts.plusJakartaSans()));
                      }

                      final beritaList = snapshot.data ?? [];
                      if (beritaList.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text('Belum ada berita', style: GoogleFonts.plusJakartaSans())),
                        );
                      }

                      return _FadeSlideIn(
                        index: 12,
                        delay: const Duration(milliseconds: 100),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 160,
                              child: PageView.builder(
                                controller: _beritaPageController,
                                itemCount: beritaList.length,
                                onPageChanged: (index) => setState(() => _currentBeritaPage = index),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: _BeritaCard(berita: beritaList[index]),
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
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: isActive ? 22 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: isActive ? primary : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slide page route transition
  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, _) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _FadeSlideIn(
      index: index + 2,
      delay: const Duration(milliseconds: 100),
      child: _PressScale(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.18), width: 1.2),
              ),
              child: Icon(icon, color: color, size: 27),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Shimmer loading placeholder
// ────────────────────────────────────────────────
class _ShimmerLoader extends StatefulWidget {
  @override
  State<_ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<_ShimmerLoader> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final shimmerColor = Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFC8D4E8), _anim.value)!;
        return Column(
          children: List.generate(2, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 72,
                decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(16)),
              ),
            );
          }),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────
// Stat Card
// ────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Berita Card
// ────────────────────────────────────────────────
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BeritaScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.article_rounded, color: primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        berita.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        berita.ringkasan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(berita.tanggal, style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}