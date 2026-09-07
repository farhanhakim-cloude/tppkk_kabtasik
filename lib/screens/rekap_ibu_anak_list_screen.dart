import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/rekap_ibu_anak.dart';
import '../services/rekap_ibu_anak_service.dart';
import 'rekap_ibu_anak_form_screen.dart';

class RekapIbuAnakListScreen extends StatefulWidget {
  final bool embedded;
  const RekapIbuAnakListScreen({super.key, this.embedded = false});

  @override
  State<RekapIbuAnakListScreen> createState() => _RekapIbuAnakListScreenState();
}

class _RekapIbuAnakListScreenState extends State<RekapIbuAnakListScreen> {
  final _service = RekapIbuAnakService();
  final _searchController = TextEditingController();
  late Future<List<RekapIbuAnak>> _future;
  late Future<RekapIbuAnakSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getAll(query: _searchController.text);
      _summaryFuture = _service.getSummary();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({RekapIbuAnak? item}) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RekapIbuAnakFormScreen(item: item)),
    );
    if (res == true) _reload();
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
                'Data Ibu & Anak (Dasa Wisma)',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_ibu_anak',
        onPressed: () => _openForm(),
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Catat Ibu & Anak',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── REKAP SUMMARY CARDS ──
          FutureBuilder<RekapIbuAnakSummary>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              final summary = snapshot.data;
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
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
                          'Rekapitulasi Dasa Wisma',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Buku Catatan PKK',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _SummaryChip(
                            label: 'Ibu Hamil',
                            val: '${summary?.jumlahHamil ?? 0}',
                            color: const Color(0xFF0D9488),
                          ),
                          _SummaryChip(
                            label: 'Melahirkan',
                            val: '${summary?.jumlahMelahirkan ?? 0}',
                            color: const Color(0xFF0284C7),
                          ),
                          _SummaryChip(
                            label: 'Ibu Nifas',
                            val: '${summary?.jumlahNifas ?? 0}',
                            color: const Color(0xFF8B5CF6),
                          ),
                          _SummaryChip(
                            label: 'Bayi Lahir',
                            val: '${summary?.jumlahBayiLahir ?? 0}',
                            color: const Color(0xFF10B981),
                          ),
                          _SummaryChip(
                            label: 'Ibu Meninggal',
                            val: '${summary?.jumlahIbuMeninggal ?? 0}',
                            color: const Color(0xFFEF4444),
                          ),
                          _SummaryChip(
                            label: 'Bayi Meninggal',
                            val: '${summary?.jumlahBayiMeninggal ?? 0}',
                            color: const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── SEARCH BAR ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari nama ibu, suami, atau Dasa Wisma...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _reload(),
            ),
          ),

          // ── LIST DATA ──
          Expanded(
            child: FutureBuilder<List<RekapIbuAnak>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat data: ${snapshot.error}',
                        style: GoogleFonts.plusJakartaSans()),
                  );
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off_outlined, size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada data Ibu & Anak',
                          style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openForm(item: item),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.face_3_rounded,
                                      color: primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.namaIbu,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                  color: const Color(0xFF0F172A),
                                                ),
                                              ),
                                            ),
                                            _StatusBadge(status: item.statusIbu, primary: primary),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Suami: ${item.namaSuami} • RT ${item.rt}/RW ${item.rw}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                                ],
                              ),
                              if (item.adaKelahiran || item.adaKematian || item.keterangan.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _Chip(text: 'Dasa Wisma: ${item.kelompokDasaWisma}', color: primary),
                                    if (item.adaKelahiran)
                                      _Chip(
                                        text: '👶 Bayi: ${item.namaBayi} (${item.jenisKelaminBayi})',
                                        color: const Color(0xFF0284C7),
                                      ),
                                    if (item.adaKelahiran && item.hasAktaKelahiran)
                                      _Chip(text: '📄 Ada Akta', color: const Color(0xFF10B981)),
                                    if (item.adaKematian)
                                      _Chip(
                                        text: '⚠️ Kematian: ${item.namaMeninggal} (${item.statusMeninggal})',
                                        color: const Color(0xFFBE123C),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String val;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.val,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Text(
            val,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color primary;

  const _StatusBadge({required this.status, required this.primary});

  @override
  Widget build(BuildContext context) {
    Color bg = primary.withValues(alpha: 0.1);
    Color fg = primary;

    if (status.toLowerCase().contains('hamil')) {
      bg = const Color(0xFF0D9488).withValues(alpha: 0.12);
      fg = const Color(0xFF0D9488);
    } else if (status.toLowerCase().contains('lahir')) {
      bg = const Color(0xFF0284C7).withValues(alpha: 0.12);
      fg = const Color(0xFF0284C7);
    } else if (status.toLowerCase().contains('nifas')) {
      bg = const Color(0xFF8B5CF6).withValues(alpha: 0.12);
      fg = const Color(0xFF8B5CF6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;

  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
