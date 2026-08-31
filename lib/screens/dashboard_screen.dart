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
import 'statistik_screen.dart';

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == currentIndex;
              final item = items[i];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 16 : 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? primary.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isActive ? primary : Colors.grey[400],
                        size: 22,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: GoogleFonts.plusJakartaSans(
                            color: primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
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
  late Future<List<Berita>> _beritaFuture;
  late Future<({int keluarga, int balita})> _statFuture;
  final PageController _beritaPageController = PageController(viewportFraction: 0.88);
  final ScrollController _scrollController = ScrollController();
  int _currentBeritaPage = 0;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
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
    return (keluarga: (results[0] as List).length, balita: (results[1] as List).length);
  }

  Future<void> _onRefresh() async {
    setState(() => _loadAll());
    await Future.wait([_beritaFuture, _statFuture]);
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
          // ── HEADER ──
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primary.withOpacity(0.07), Colors.white],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [primary, primary.withOpacity(0.8)]),
                          boxShadow: [BoxShadow(color: primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: primary.withOpacity(0.1),
                            child: Icon(Icons.person_rounded, color: primary, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Selamat Datang Bapak/Ibu,',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13.5, color: Colors.grey[500])),
                            const SizedBox(height: 2),
                            Text(_getGreeting(),
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 22, color: const Color(0xFF0F172A), letterSpacing: -0.5)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                                  const SizedBox(width: 5),
                                  Text('Kader Dasawisma • Aktif',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF065F46), fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rekap Terkini', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.4)),
                      const SizedBox(height: 3),
                      Text('Pantau perkembangan data', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Total Keluarga',
                              value: '${data?.keluarga ?? 0}',
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
                              value: '${data?.balita ?? 0}',
                              sublabel: 'Gizi terpantau',
                              icon: Icons.child_friendly_rounded,
                              color: const Color(0xFF10B981),
                              trend: '100% Valid',
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
                          Text('Statistik Gizi Balita', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.3)),
                          const SizedBox(height: 2),
                          Text('Tren status gizi 6 bulan terakhir', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[500])),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const StatistikScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text('Detail', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: primary, fontWeight: FontWeight.w700)),
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
                            border: Border.all(color: Colors.grey.withOpacity(0.12)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
                      final beritaList = snapshot.data ?? [];
                      if (beritaList.isEmpty) {
                        return Center(child: Text('Belum ada berita', style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])));
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
                child: Text('TP PKK Kabupaten Tasikmalaya • v1.0.0',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NUTRITION LINE CHART (Custom Painter)
// ─────────────────────────────────────────────────────────────────────────────
class _NutritionChart extends StatelessWidget {
  final Color primary;
  const _NutritionChart({required this.primary});

  @override
  Widget build(BuildContext context) {
    // Mock 6-month data points: [Mar, Apr, May, Jun, Jul, Aug]
    final giziBaik = [12, 14, 13, 16, 15, 17];
    final giziKurang = [5, 4, 6, 3, 4, 3];
    final giziBuruk = [2, 2, 1, 2, 1, 1];
    final months = ['Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Row(
            children: [
              _LegendDot(color: const Color(0xFF10B981), label: 'Gizi Baik'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFFF59E0B), label: 'Gizi Kurang'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFFEF4444), label: 'Gizi Buruk'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(
                giziBaik: giziBaik,
                giziKurang: giziKurang,
                giziBuruk: giziBuruk,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // X Axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: months
                .map((m) => Text(m, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: Colors.grey[400], fontWeight: FontWeight.w600)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[600])),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<int> giziBaik;
  final List<int> giziKurang;
  final List<int> giziBuruk;

  _LineChartPainter({
    required this.giziBaik,
    required this.giziKurang,
    required this.giziBuruk,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final allValues = [...giziBaik, ...giziKurang, ...giziBuruk];
    final maxVal = allValues.reduce((a, b) => a > b ? a : b).toDouble();
    final minVal = 0.0;
    final count = giziBaik.length;

    double xStep = size.width / (count - 1);
    double yRange = maxVal - minVal;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Offset getOffset(int index, int value) {
      final x = index * xStep;
      final y = size.height - ((value - minVal) / yRange) * size.height;
      return Offset(x, y);
    }

    void drawLine(List<int> data, Color color) {
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final dotPaint = Paint()..color = color;
      final dotBorder = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final offset = getOffset(i, data[i]);
        if (i == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          // Smooth curve
          final prev = getOffset(i - 1, data[i - 1]);
          final cp1 = Offset((prev.dx + offset.dx) / 2, prev.dy);
          final cp2 = Offset((prev.dx + offset.dx) / 2, offset.dy);
          path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, offset.dx, offset.dy);
        }
      }
      canvas.drawPath(path, linePaint);

      // Draw dots
      for (int i = 0; i < data.length; i++) {
        final offset = getOffset(i, data[i]);
        canvas.drawCircle(offset, 4.5, dotPaint);
        canvas.drawCircle(offset, 4.5, dotBorder);
      }
    }

    drawLine(giziBaik, const Color(0xFF10B981));
    drawLine(giziKurang, const Color(0xFFF59E0B));
    drawLine(giziBuruk, const Color(0xFFEF4444));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 10, color: Color(0xFF16A34A)),
                      const SizedBox(width: 3),
                      Flexible(child: Text(trend, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF16A34A)))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.6)),
          const SizedBox(height: 1),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
          if (sublabel.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(sublabel, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
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
        height: 108,
        decoration: BoxDecoration(
          color: Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFF1F5F9), _ctrl.value)!,
          borderRadius: BorderRadius.circular(18),
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
    final hasImage = berita.gambar != null && berita.gambar!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BeritaScreen()));
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
                    ? Image.network(
                        berita.gambar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ImageFallback(primary: primary),
                      )
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
                        decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                        child: Text('BERITA RESMI', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: primary, letterSpacing: 0.5)),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time_rounded, size: 11, color: Colors.grey[400]),
                      const SizedBox(width: 3),
                      Text(berita.tanggal, style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 10.5, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(berita.judul, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(berita.ringkasan, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 11.5, height: 1.45)),
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
          colors: [primary, primary.withOpacity(0.7)],
        ),
      ),
      child: Center(child: Icon(Icons.article_rounded, color: Colors.white.withOpacity(0.6), size: 36)),
    );
  }
}