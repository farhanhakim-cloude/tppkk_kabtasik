import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/berita.dart';
import '../services/berita_service.dart';
import 'keluarga_list_screen.dart';
import 'kesehatan_list_screen.dart';
import 'statistik_screen.dart';
import 'laporan_screen.dart';
import 'profile_screen.dart';
import 'catatan_kegiatan_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _beritaService = BeritaService();
  late Future<List<Berita>> _beritaFuture;
  final PageController _beritaPageController = PageController(viewportFraction: 0.88);
  int _currentBeritaPage = 0;

  @override
  void initState() {
    super.initState();
    _beritaFuture = _beritaService.getBerita();
  }

  @override
  void dispose() {
    _beritaPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _beritaFuture = _beritaService.getBerita());
        },
        child: CustomScrollView(
          slivers: [
            // Top bar sederhana
            SliverToBoxAdapter(
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

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Banner promo
                  Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, primary.withOpacity(0.75)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(Icons.favorite, size: 130, color: Colors.white.withOpacity(0.08)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'e-PKK Dasawisma',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kabupaten Tasikmalaya',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu Pencatatan Data
                  Text('Menu Pencatatan Data', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _MenuTile(
                        icon: Icons.home_work_rounded,
                        label: 'Data Keluarga',
                        color: const Color(0xFF0F9E8E),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const KeluargaListScreen()));
                        },
                      ),
                      _MenuTile(
                        icon: Icons.child_care_rounded,
                        label: 'Kesehatan Ibu & Anak',
                        color: const Color(0xFFE91E63),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const KesehatanListScreen()));
                        },
                      ),
                      _MenuTile(
                        icon: Icons.insert_chart_rounded,
                        label: 'Statistik',
                        color: const Color(0xFF3F51B5),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const StatistikScreen()));
                        },
                      ),
                      _MenuTile(
                        icon: Icons.description_rounded,
                        label: 'Laporan',
                        color: const Color(0xFFFF9800),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LaporanScreen()));
                        },
                      ),
                      _MenuTile(
                        icon: Icons.edit_note_rounded,
                        label: 'Catat Kegiatan',
                        color: const Color(0xFF9C27B0),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CatatanKegiatanFormScreen()));
                        },
                      ),
                      _MenuTile(
                        icon: Icons.more_horiz_rounded,
                        label: 'Lainnya',
                        color: const Color(0xFF607D8B),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Rekap Keseluruhan Data
                  Text('Rekap Keseluruhan Data', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total Keluarga',
                          value: '128',
                          icon: Icons.home_rounded,
                          color: const Color(0xFF0F9E8E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Balita Terpantau',
                          value: '45',
                          icon: Icons.child_friendly_rounded,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Berita — paling bawah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Berita Terbaru', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                      Icon(Icons.campaign_rounded, color: primary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 14),

                  FutureBuilder<List<Berita>>(
                    future: _beritaFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        );
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

                      return Column(
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
                                duration: const Duration(milliseconds: 200),
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
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, Color.lerp(color, Colors.black, 0.15)!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 9),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2),
          ),
        ],
      ),
    );
  }
}

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
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600])),
        ],
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: primary.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
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
    );
  }
}