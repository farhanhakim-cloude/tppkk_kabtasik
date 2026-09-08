import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kesehatan.dart';
import '../services/keluarga_service.dart';
import '../services/kesehatan_service.dart';

class LaporanScreen extends StatefulWidget {
  final bool embedded;
  const LaporanScreen({super.key, this.embedded = false});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _keluargaService = KeluargaService();
  final _kesehatanService = KesehatanService();

  String _periode = 'Agustus 2026';
  late Future<_LaporanData> _laporanFuture;

  @override
  void initState() {
    super.initState();
    _reloadAll();
  }

  void _reloadAll() {
    setState(() {
      _laporanFuture = _loadData();
    });
  }



  Future<_LaporanData> _loadData() async {
    final keluarga = await _keluargaService.getAll();
    final ibuHamil = await _kesehatanService.getAll(filter: KategoriKesehatan.ibuHamil);
    final ibuMenyusui = await _kesehatanService.getAll(filter: KategoriKesehatan.ibuMenyusui);
    final balita = await _kesehatanService.getAll(filter: KategoriKesehatan.balita);

    return _LaporanData(
      keluarga: keluarga.length,
      anggota: keluarga.fold(0, (sum, k) => sum + k.jumlahAnggota),
      ibuHamil: ibuHamil.length,
      ibuMenyusui: ibuMenyusui.length,
      balita: balita.length,
      balitaGiziKurang: balita.where((b) => b.statusGizi == 'Kurang').length,
    );
  }



  void _exportPdf() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur Export PDF akan aktif saat terhubung ke backend server',
            style: GoogleFonts.plusJakartaSans()),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }



  // ── TAB 1: REKAP LAPORAN ──
  Widget _buildLaporanTab(Color primary) {
    return FutureBuilder<_LaporanData>(
      future: _laporanFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Gagal memuat laporan: ${snapshot.error}',
                style: GoogleFonts.plusJakartaSans()),
          );
        }

        final data = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          children: [
            // Periode Selector
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _periode,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  items: ['Juni 2026', 'Juli 2026', 'Agustus 2026']
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 16, color: Color(0xFF3B82F6)),
                                const SizedBox(width: 10),
                                Text(
                                  'Periode: $p',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _periode = v);
                      _reloadAll();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Summary Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.analytics_rounded, color: primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan Data PKK',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              _periode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  _RowItem('Jumlah Kepala Keluarga (KK)', '${data.keluarga} KK'),
                  _RowItem('Total Jumlah Jiwa / Anggota', '${data.anggota} Orang'),
                  _RowItem('Ibu Hamil Terpantau', '${data.ibuHamil} Orang'),
                  _RowItem('Ibu Menyusui Terdata', '${data.ibuMenyusui} Orang'),
                  _RowItem('Balita Terdata', '${data.balita} Balita'),
                  _RowItem(
                    'Balita Gizi Kurang',
                    '${data.balitaGiziKurang} Anak',
                    isAlert: data.balitaGiziKurang > 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Export Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _exportPdf,
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                label: Text(
                  'Unduh Rekap Laporan (PDF)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text(
                'Laporan Rekapitulasi',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
      body: Column(
        children: [
          if (widget.embedded)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Laporan Rekapitulasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _buildLaporanTab(primary),
          ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlert;

  const _RowItem(this.label, this.value, {this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isAlert ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaporanData {
  final int keluarga;
  final int anggota;
  final int ibuHamil;
  final int ibuMenyusui;
  final int balita;
  final int balitaGiziKurang;

  _LaporanData({
    required this.keluarga,
    required this.anggota,
    required this.ibuHamil,
    required this.ibuMenyusui,
    required this.balita,
    required this.balitaGiziKurang,
  });
}

