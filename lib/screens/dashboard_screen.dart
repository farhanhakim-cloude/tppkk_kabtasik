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
  final _beritaService = BeritaService();
  final _keluargaService = KeluargaService();
  final _kesehatanService = KesehatanService();
  late Future<List<Berita>> _beritaFuture;
  late Future<({int keluarga, int balita})> _statFuture;
  final PageController _beritaPageController = PageController(viewportFraction: 0.88);
  final ScrollController _scrollController = ScrollController();
  int _currentBeritaPage = 0;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 20;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
    }
  }

  void _loadAll() {
    _beritaFuture = _beritaService.getBerita();
    _statFuture = _loadStats();
  }

  Future<({int keluarga, int balita})> _loadStats() async {
    final results = await Future.wait([
      _keluargaService.getAll(),
      _kesehatanService.getAll(filter: KategoriKesehatan.balita),
    ]);
    final keluarga = (results[0] as List).length;
    final balita = (results[1] as List).length;
    return (keluarga: keluarga, balita: balita);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _loadAll();
    });
    await Future.wait([_beritaFuture, _statFuture]);
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: Text('Menu Lainnya', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)))),
              const SizedBox(height: 6),
              Align(alignment: Alignment.centerLeft, child: Text('Akses fitur tambahan PKK', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[500]))),
              const SizedBox(height: 20),
              _SheetTile(
                icon: Icons.photo_library_rounded,
                label: 'Galeri & Agenda',
                subtitle: 'Dokumentasi & jadwal kegiatan PKK',
                color: const Color(0xFF0EA5E9),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GaleriAgendaScreen()));
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BeritaScreen()));
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatLaporanScreen()));
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
    super.dispose();
  }

  Widget _buildHeaderCard(Color primary, {bool isScrolled = false}) {
    // Access by KAI style: biru saat top (menyatu bg), putih saat scroll
    final isBlue = !isScrolled;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: isBlue ? primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isBlue ? null : Border.all(color: Colors.grey.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: (isBlue ? Colors.black : Colors.black).withValues(alpha: isBlue ? 0.12 : 0.08),
            blurRadius: isBlue ? 16 : 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isBlue ? Colors.white.withValues(alpha: 0.25) : primary.withValues(alpha: 0.12), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/logo.png', width: 36, height: 36, errorBuilder: (_, __, ___) => Icon(Icons.groups_rounded, color: isBlue ? Colors.white : primary, size: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TP PKK Kab. Tasikmalaya', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5, color: isBlue ? Colors.white : const Color(0xFF0F172A), letterSpacing: -0.2)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: isBlue ? primary : Colors.white, width: 1.2))),
                    const SizedBox(width: 5),
                    Text('Kader Dasawisma • Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: isBlue ? Colors.white.withValues(alpha: 0.9) : Colors.grey[600], fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: isBlue ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: isBlue ? Colors.white : Colors.grey[700], size: 20),
              onPressed: () {
                HapticFeedback.selectionClick();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Belum ada notifikasi baru', style: GoogleFonts.plusJakartaSans()), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [isBlue ? Colors.white : primary, (isBlue ? Colors.white70 : primary.withValues(alpha: 0.8))]),
                boxShadow: [BoxShadow(color: (isBlue ? Colors.black : primary).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: isBlue ? primary : Colors.white,
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: isBlue ? Colors.white.withValues(alpha: 0.18) : primary.withValues(alpha: 0.10),
                  child: Icon(Icons.person_rounded, color: isBlue ? Colors.white : primary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(Color primary) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary.withValues(alpha: 0.12), primary.withValues(alpha: 0.03)]),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: -10,
            child: Icon(Icons.favorite_rounded, size: 90, color: primary.withValues(alpha: 0.06)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 13, color: primary),
                            const SizedBox(width: 4),
                            Text('TP PKK DIGITAL', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: primary, letterSpacing: 0.6)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('e-PKK Dasawisma', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text('Kabupaten Tasikmalaya', style: GoogleFonts.plusJakartaSans(color: primary, fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('Pendataan keluarga & kesehatan\nterintegrasi dalam genggaman', style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 12.5, height: 1.45, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primary, const Color(0xFF1D4ED8)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: const Icon(Icons.groups_rounded, color: Colors.white, size: 34),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),
      body: Column(
        children: [
          // ---- HEADER PINNED ALA ACCESS BY KAI ----
          // Biru saat top (menyatu dengan banner), putih saat scroll >20px
          // Banner tidak akan ketutup karena header di Column, bukan Stack overlay
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: _isScrolled
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, const Color(0xFF1E40AF)],
                    ),
              color: _isScrolled ? Colors.white : null,
              boxShadow: _isScrolled
                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Stack(
              children: [
                // lingkaran dekorasi hanya saat biru
                if (!_isScrolled) ...[
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(width: 160, height: 160, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), shape: BoxShape.circle)),
                  ),
                  Positioned(
                    top: 40,
                    left: -40,
                    child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle)),
                  ),
                ],
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: _buildHeaderCard(primary, isScrolled: _isScrolled),
                  ),
                ),
              ],
            ),
          ),
          // ---- SCROLLABLE CONTENT (banner tidak ketutup header) ----
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // Banner hero — di dalam scroll, dengan background biru tipis di belakangnya agar menyatu saat top
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        // background biru di belakang banner, menyambung dengan header biru saat belum scroll
                        Container(
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [primary, const Color(0xFF1E40AF)],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: _buildBanner(primary),
                        ),
                      ],
                    ),
                  ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ---- MENU ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Menu Pencatatan', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.3)),
                          const SizedBox(height: 2),
                          Text('Kelola data PKK dengan mudah', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                        child: Text('6 Menu', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: primary, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.86,
                    children: [
                      _MenuTile(
                        icon: Icons.home_work_rounded,
                        label: 'Data Keluarga',
                        subtitle: 'Kelola KK',
                        color: const Color(0xFF0F9E8E),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KeluargaListScreen())),
                      ),
                      _MenuTile(
                        icon: Icons.child_care_rounded,
                        label: 'Kesehatan',
                        subtitle: 'Ibu & Anak',
                        color: const Color(0xFFE91E63),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KesehatanListScreen())),
                      ),
                      _MenuTile(
                        icon: Icons.insert_chart_rounded,
                        label: 'Statistik',
                        subtitle: 'Rekap Data',
                        color: const Color(0xFF3F51B5),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatistikScreen())),
                      ),
                      _MenuTile(
                        icon: Icons.description_rounded,
                        label: 'Laporan',
                        subtitle: 'Export PDF',
                        color: const Color(0xFFFF9800),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanScreen())),
                      ),
                      _MenuTile(
                        icon: Icons.edit_note_rounded,
                        label: 'Catat Kegiatan',
                        subtitle: 'Pokja I-IV',
                        color: const Color(0xFF9C27B0),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatanKegiatanFormScreen())),
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
                  const SizedBox(height: 26),

                  // ---- REKAP ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rekap Terkini', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.3)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatistikScreen())),
                        child: Row(
                          children: [
                            Text('Detail', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: primary, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded, size: 18, color: primary),
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
                        return Row(
                          children: [
                            Expanded(child: _StatShimmer()),
                            const SizedBox(width: 12),
                            Expanded(child: _StatShimmer()),
                          ],
                        );
                      }
                      final data = snapshot.data;
                      final keluargaCount = data?.keluarga ?? 0;
                      final balitaCount = data?.balita ?? 0;
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Total Keluarga',
                              value: '$keluargaCount',
                              sublabel: 'KK terdata',
                              icon: Icons.home_rounded,
                              color: const Color(0xFF0F9E8E),
                              trend: '+3 bulan ini',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Balita Terpantau',
                              value: '$balitaCount',
                              sublabel: 'Status gizi aktif',
                              icon: Icons.child_friendly_rounded,
                              color: const Color(0xFFFF9800),
                              trend: '100% terdata',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 26),

                  // ---- BERITA ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Berita Terbaru', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.3)),
                          const SizedBox(height: 2),
                          Text('Informasi resmi PKK', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[500])),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BeritaScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              Text('Lihat Semua', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 14, color: primary),
                            ],
                          ),
                        ),
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
                      if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Icon(Icons.wifi_off_rounded, color: Colors.grey[400]),
                              const SizedBox(width: 12),
                              Expanded(child: Text('Gagal memuat berita', style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]))),
                              TextButton(onPressed: () => setState(() => _beritaFuture = _beritaService.getBerita()), child: const Text('Coba lagi')),
                            ],
                          ),
                        );
                      }
                      final beritaList = snapshot.data ?? [];
                      if (beritaList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Center(child: Text('Belum ada berita', style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]))),
                        );
                      }
                      return Column(
                        children: [
                          SizedBox(
                            height: 168,
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
                  const SizedBox(height: 8),
                  // footer info
                  Center(
                    child: Text('TP PKK Kabupaten Tasikmalaya • v1.0.0', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500)),
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
}

class _MenuTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isMore;

  const _MenuTile({required this.icon, required this.label, required this.color, required this.onTap, this.subtitle = '', this.isMore = false});

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween(begin: 1.0, end: 0.93).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); HapticFeedback.selectionClick(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: widget.isMore ? Border.all(color: const Color(0xFF64748B).withValues(alpha: 0.12), width: 1.2) : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isMore ? [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)] : [widget.color, Color.lerp(widget.color, Colors.black, 0.18)!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.isMore ? null : [BoxShadow(color: widget.color.withValues(alpha: 0.30), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Icon(widget.icon, color: widget.isMore ? const Color(0xFF64748B) : Colors.white, size: 26),
              ),
              const SizedBox(height: 10),
              Text(widget.label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), letterSpacing: -0.2)),
              if (widget.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(widget.subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: Colors.grey[500], fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final String trend;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, this.sublabel = '', this.trend = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFBBF7D0))),
                child: Row(children: [
                  const Icon(Icons.trending_up_rounded, size: 12, color: Color(0xFF16A34A)),
                  const SizedBox(width: 3),
                  Text(trend, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A))),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.8)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
          if (sublabel.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(sublabel, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

class _StatShimmer extends StatefulWidget {
  @override
  State<_StatShimmer> createState() => _StatShimmerState();
}

class _StatShimmerState extends State<_StatShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        height: 132,
        decoration: BoxDecoration(color: Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFF1F5F9), _ctrl.value)!, borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _SheetTile({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.08))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500])),
            ])),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BeritaScreen()));
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
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primary, primary.withValues(alpha: 0.75)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.article_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                      child: Text('BERITA RESMI', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: primary, letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 8),
                    Text(berita.judul, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14.5, color: const Color(0xFF0F172A))),
                    const SizedBox(height: 5),
                    Text(berita.ringkasan, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 12.5, height: 1.45)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(berita.tanggal, style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text('Baca →', style: GoogleFonts.plusJakartaSans(color: primary, fontSize: 11, fontWeight: FontWeight.w700)),
                    ]),
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
