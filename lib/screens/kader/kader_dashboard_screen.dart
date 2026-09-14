// lib/screens/kader/kader_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/catatan_kegiatan.dart';
import '../../services/catatan_kegiatan_service.dart';
import '../catatan_kegiatan_form_screen.dart';
import '../berita_form_screen.dart';
import 'kader_catatan_kegiatan_screen.dart';
import 'kader_berita_screen.dart';

class KaderDashboardScreen extends StatefulWidget {
  const KaderDashboardScreen({super.key});

  @override
  State<KaderDashboardScreen> createState() => _KaderDashboardScreenState();
}

class _KaderDashboardScreenState extends State<KaderDashboardScreen> {
  final _catatanService = CatatanKegiatanService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CatatanKegiatan>>(
      future: _catatanService.getAll(),
      builder: (context, snapshot) {
        final totalKegiatan = snapshot.data?.length ?? 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D9488),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              tooltip: 'Kembali ke Login',
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ruang Kerja Kader',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'TP-PKK Kab. Tasikmalaya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
                tooltip: 'Info Peran Kader',
                onPressed: () => _showInfoDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Keluar Akun Demo',
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Bertugas, Kader PKK!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Laporkan kegiatan Pokja & bagikan kabar kegiatan terkini.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Dua Fitur Utama Kader
            Text(
              'MENU UTAMA KADER',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),

            // Menu 1: Catatan Kegiatan Pokja
            _buildFeatureCard(
              title: 'Catatan Kegiatan Pokja',
              subtitle: 'Input dan rekap dokumentasi kegiatan Pokja I, II, III, dan IV.',
              icon: Icons.assignment_outlined,
              gradientColors: [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
              badgeText: '$totalKegiatan Kegiatan Tersimpan',
              buttonLabel: 'Buka Catatan Kegiatan',
              quickActionLabel: '+ Input Kegiatan',
              onTapCard: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KaderCatatanKegiatanScreen()),
              ),
              onTapQuickAction: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CatatanKegiatanFormScreen()),
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // Menu 2: Masukan & Tulis Berita
            _buildFeatureCard(
              title: 'Tulis & Publikasi Berita',
              subtitle: 'Tulis kabar berita kegiatan wilayah dan pantau status publikasinya.',
              icon: Icons.newspaper_rounded,
              gradientColors: [const Color(0xFF059669), const Color(0xFF34D399)],
              badgeText: 'Kabar Wilayah',
              buttonLabel: 'Lihat Berita Saya',
              quickActionLabel: '+ Tulis Berita',
              onTapCard: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KaderBeritaScreen()),
              ),
              onTapQuickAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BeritaFormScreen()),
              ),
            ),
            const SizedBox(height: 28),

            // Akses Cepat Pokja
            Text(
              'AKSES CEPAT PER POKJA',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildPokjaButton(PokjaKategori.pokja1, const Color(0xFF2563EB), Icons.groups_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _buildPokjaButton(PokjaKategori.pokja2, const Color(0xFF059669), Icons.school_rounded)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildPokjaButton(PokjaKategori.pokja3, const Color(0xFFD97706), Icons.cottage_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _buildPokjaButton(PokjaKategori.pokja4, const Color(0xFFDC2626), Icons.health_and_safety_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required String badgeText,
    required String buttonLabel,
    required String quickActionLabel,
    required VoidCallback onTapCard,
    required VoidCallback onTapQuickAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapCard,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: gradientColors[0].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: gradientColors[0],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onTapCard,
                        icon: const Icon(Icons.list_alt_rounded, size: 16),
                        label: Text(buttonLabel),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF334155),
                          textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onTapQuickAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradientColors[0],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: Text(
                        quickActionLabel,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPokjaButton(PokjaKategori pokja, Color color, IconData icon) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KaderCatatanKegiatanScreen(pokjaDefault: pokja),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pokja.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Catatan Kegiatan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Ruang Kerja Kader',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Modul ini khusus dirancang untuk kader di lapangan agar dapat dengan mudah:\n\n'
          '1. Melaporkan catatan kegiatan Pokja I - IV beserta data angka kegiatan.\n'
          '2. Menulis & mempublikasikan kabar berita kegiatan dari tingkat desa/kelurahan.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}
