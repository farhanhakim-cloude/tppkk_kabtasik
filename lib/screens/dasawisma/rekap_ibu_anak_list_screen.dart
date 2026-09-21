// lib/screens/dasawisma/rekap_ibu_anak_list_screen.dart
// Halaman Rekap Ibu Hamil & Bayi dengan Tingkatan (Dasawisma, RT, RW, Dusun, Desa, Kecamatan)
// Menggunakan tampilan Kartu & Ringkasan sesuai preferensi pengguna (bukan tabel spreadsheet Excel)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/rekap_ibu_anak.dart';
import '../../models/rekap_bumil_berjenjang.dart';
import '../../services/rekap_ibu_anak_service.dart';
import '../../services/rekap_bumil_berjenjang_service.dart';
import 'rekap_ibu_anak_form_screen.dart';
import 'rekap_bumil_berjenjang_form_screen.dart';

class RekapIbuAnakListScreen extends StatefulWidget {
  final bool embedded;
  const RekapIbuAnakListScreen({super.key, this.embedded = false});

  @override
  State<RekapIbuAnakListScreen> createState() => _RekapIbuAnakListScreenState();
}

class _RekapIbuAnakListScreenState extends State<RekapIbuAnakListScreen> {
  final _serviceDasawisma = RekapIbuAnakService();
  final _serviceBerjenjang = RekapBumilBerjenjangService();

  String _selectedTingkat = 'dasawisma'; // 'dasawisma', 'rt', 'rw', 'dusun', 'desa', 'kecamatan'
  final _searchController = TextEditingController();

  late Future<List<RekapIbuAnak>> _futureDasawisma;
  late Future<RekapIbuAnakSummary> _summaryFuture;
  late Future<List<RekapBumilBerjenjangItem>> _futureBerjenjang;

  static const Color _primary = Color(0xFF0D9488);
  static const Color _darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _futureDasawisma = _serviceDasawisma.getAll(query: _searchController.text);
      _summaryFuture = _serviceDasawisma.getSummary();
      _futureBerjenjang = _serviceBerjenjang.getByLevel(_selectedTingkat);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDasawismaForm({RekapIbuAnak? item}) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RekapIbuAnakFormScreen(item: item)),
    );
    if (res == true) _reload();
  }

  Future<void> _openTierForm({RekapBumilBerjenjangItem? item}) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RekapBumilBerjenjangFormScreen(
          level: _selectedTingkat,
          item: item,
        ),
      ),
    );
    if (res == true) _reload();
  }

  Future<void> _autoFillFromDasawisma() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hitung Otomatis dari Dasawisma?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Text('Sistem akan merekap dan mengisi data otomatis ke form ${_getTingkatLabel(_selectedTingkat)}.', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _primary),
            child: const Text('Tarik & Hitung', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _serviceBerjenjang.autoGenerateFromDasawisma(_selectedTingkat);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diisi otomatis dari Dasawisma!'), backgroundColor: Color(0xFF10B981)),
        );
      }
    }
  }

  Future<void> _deleteTierRow(int id) async {
    await _serviceBerjenjang.delete(id);
    _reload();
  }

  String _getTingkatLabel(String k) {
    switch (k) {
      case 'dasawisma':
        return 'Dasawisma';
      case 'rt':
        return 'Tingkat RT';
      case 'rw':
        return 'Tingkat RW';
      case 'dusun':
        return 'Tingkat Dusun';
      case 'desa':
        return 'Tingkat Desa';
      case 'kecamatan':
        return 'Tingkat Kecamatan';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                'Rekap Ibu Hamil & Bayi',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: _darkText),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.refresh_rounded, color: _primary), onPressed: _reload),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_ibu_anak_main',
        onPressed: () {
          if (_selectedTingkat == 'dasawisma') {
            _openDasawismaForm();
          } else {
            _openTierForm();
          }
        },
        backgroundColor: _primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _selectedTingkat == 'dasawisma' ? 'Catat Ibu & Anak' : 'Catat Data ${_selectedTingkat.toUpperCase()}',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // ── TINGKAT SELECTOR PILLS (Dasawisma, RT, RW, Dusun, Desa, Kecamatan) ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _tingkatChip('dasawisma', 'Dasawisma'),
                  const SizedBox(width: 6),
                  _tingkatChip('rt', 'PKK RT'),
                  const SizedBox(width: 6),
                  _tingkatChip('rw', 'PKK RW'),
                  const SizedBox(width: 6),
                  _tingkatChip('dusun', 'PKK Dusun'),
                  const SizedBox(width: 6),
                  _tingkatChip('desa', 'TP PKK Desa'),
                  const SizedBox(width: 6),
                  _tingkatChip('kecamatan', 'TP PKK Kecamatan'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // ── SWITCH VIEW BASED ON TINGKAT ──
          Expanded(
            child: _selectedTingkat == 'dasawisma'
                ? _buildDasawismaView()
                : _buildTieredCardView(_selectedTingkat),
          ),
        ],
      ),
    );
  }

  Widget _tingkatChip(String key, String label) {
    final sel = _selectedTingkat == key;
    return InkWell(
      onTap: () {
        setState(() => _selectedTingkat = key);
        _reload();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
            color: sel ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TINGKAT DASAWISMA VIEW (DATA PERORANGAN SESUAI GAMBAR 2)
  // ===========================================================================
  Widget _buildDasawismaView() {
    return Column(
      children: [
        // Summary Cards
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
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rekapitulasi Dasa Wisma',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: _darkText),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openDasawismaForm(),
                        icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        label: Text('Catat Data', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 11.5, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _SummaryChip(label: 'Ibu Hamil', val: '${summary?.jumlahHamil ?? 0}', color: const Color(0xFF0D9488)),
                        _SummaryChip(label: 'Melahirkan', val: '${summary?.jumlahMelahirkan ?? 0}', color: const Color(0xFF0284C7)),
                        _SummaryChip(label: 'Ibu Nifas', val: '${summary?.jumlahNifas ?? 0}', color: const Color(0xFF8B5CF6)),
                        _SummaryChip(label: 'Bayi Lahir', val: '${summary?.jumlahBayiLahir ?? 0}', color: const Color(0xFF10B981)),
                        _SummaryChip(label: 'Ibu Meninggal', val: '${summary?.jumlahIbuMeninggal ?? 0}', color: const Color(0xFFEF4444)),
                        _SummaryChip(label: 'Bayi Meninggal', val: '${summary?.jumlahBayiMeninggal ?? 0}', color: const Color(0xFFF59E0B)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Cari nama ibu, suami, atau Dasa Wisma...',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
            onChanged: (_) => _reload(),
          ),
        ),

        // List Data Dasawisma
        Expanded(
          child: FutureBuilder<List<RekapIbuAnak>>(
            future: _futureDasawisma,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _primary));
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_off_outlined, size: 56, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('Belum ada data Ibu & Anak di Dasawisma', style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _openDasawismaForm(),
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: const Text('Catat Ibu & Anak', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: _primary),
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
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openDasawismaForm(item: item),
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
                                  decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.face_3_rounded, color: _primary),
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
                                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: _darkText),
                                            ),
                                          ),
                                          _StatusBadge(status: item.statusIbu, primary: _primary),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Suami: ${item.namaSuami} • RT ${item.rt}/RW ${item.rw}',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600]),
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
                                  _Chip(text: 'Dasa Wisma: ${item.kelompokDasaWisma}', color: _primary),
                                  if (item.adaKelahiran) _Chip(text: '👶 Bayi: ${item.namaBayi} (${item.jenisKelaminBayi})', color: const Color(0xFF0284C7)),
                                  if (item.adaKelahiran && item.hasAktaKelahiran) _Chip(text: '📄 Ada Akta', color: const Color(0xFF10B981)),
                                  if (item.adaKematian) _Chip(text: '⚠️ Kematian: ${item.namaMeninggal} (${item.statusMeninggal})', color: const Color(0xFFBE123C)),
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
    );
  }

  // ===========================================================================
  // 2. TINGKAT RT, RW, DUSUN, DESA, KECAMATAN (KARTU SESUAI GAMBAR 2)
  // ===========================================================================
  Widget _buildTieredCardView(String level) {
    return FutureBuilder<List<RekapBumilBerjenjangItem>>(
      future: _futureBerjenjang,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _primary));
        }
        final allItems = snapshot.data ?? [];
        final q = _searchController.text.trim().toLowerCase();
        final list = q.isEmpty
            ? allItems
            : allItems.where((e) {
                return e.namaDasawisma.toLowerCase().contains(q) ||
                    e.nomorRt.toLowerCase().contains(q) ||
                    e.nomorRw.toLowerCase().contains(q) ||
                    e.namaDusun.toLowerCase().contains(q) ||
                    e.namaDesa.toLowerCase().contains(q);
              }).toList();

        // Totals for top summary chips
        final tHamil = allItems.fold(0, (p, e) => p + e.ibuHamil);
        final tLahir = allItems.fold(0, (p, e) => p + e.ibuMelahirkan);
        final tNifas = allItems.fold(0, (p, e) => p + e.ibuNifas);
        final tBayiLahir = allItems.fold(0, (p, e) => p + e.bayiLahirL + e.bayiLahirP);
        final tMatiIbu = allItems.fold(0, (p, e) => p + e.ibuMeninggal);
        final tMatiBayi = allItems.fold(0, (p, e) => p + e.bayiMeninggalL + e.bayiMeninggalP);
        final tMatiBalita = allItems.fold(0, (p, e) => p + e.balitaMeninggalL + e.balitaMeninggalP);

        return Column(
          children: [
            // ── TOP SUMMARY BOX (SAMA PERSIS DENGAN GAMBAR 2) ──
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rekapitulasi ${_getTingkatLabel(level)}',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5, color: _darkText),
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _autoFillFromDasawisma,
                            icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: _primary),
                            label: Text('Auto-Isi', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: _primary)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: () => _openTierForm(),
                            icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                            label: Text('Catat Data', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 11.5, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _SummaryChip(label: 'Ibu Hamil', val: '$tHamil', color: const Color(0xFF0D9488)),
                        _SummaryChip(label: 'Melahirkan', val: '$tLahir', color: const Color(0xFF0284C7)),
                        _SummaryChip(label: 'Ibu Nifas', val: '$tNifas', color: const Color(0xFF8B5CF6)),
                        _SummaryChip(label: 'Bayi Lahir', val: '$tBayiLahir', color: const Color(0xFF10B981)),
                        _SummaryChip(label: 'Ibu Meninggal', val: '$tMatiIbu', color: const Color(0xFFEF4444)),
                        _SummaryChip(label: 'Bayi Meninggal', val: '$tMatiBayi', color: const Color(0xFFF59E0B)),
                        _SummaryChip(label: 'Balita Meninggal', val: '$tMatiBalita', color: const Color(0xFFDC2626)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── SEARCH BAR ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Cari nama pengenal, RT, RW, atau wilayah...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            // ── LIST DATA CARD (SAMA PERSIS DENGAN GAMBAR 2) ──
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_off_outlined, size: 56, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('Belum ada data untuk ${_getTingkatLabel(level)}', style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _openTierForm(),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: Text('Catat Data ${_getTingkatLabel(level)}', style: const TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: _primary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];

                        String title = '';
                        String subtitle = '';

                        if (level == 'rt') {
                          title = item.namaDasawisma.isNotEmpty ? 'Dasa Wisma ${item.namaDasawisma}' : 'Dasa Wisma Mawar';
                          subtitle = 'RT ${item.rt}/RW ${item.rw} • ${item.dusun}, ${item.desa}';
                        } else if (level == 'rw') {
                          title = 'RT ${item.nomorRt} — Dasa Wisma ${item.namaDasawisma}';
                          subtitle = 'RW ${item.rw} • ${item.dusun}, ${item.desa}';
                        } else if (level == 'dusun') {
                          title = 'RW ${item.nomorRw}';
                          subtitle = '${item.jumlahRt} RT • ${item.jumlahDasawisma} Dasa Wisma • ${item.dusun}';
                        } else if (level == 'desa') {
                          title = 'Dusun ${item.namaDusun}';
                          subtitle = '${item.jumlahRw} RW • ${item.jumlahRt} RT • ${item.jumlahDasawisma} Dasa Wisma';
                        } else if (level == 'kecamatan') {
                          title = 'Desa ${item.namaDesa}';
                          subtitle = '${item.jumlahDusun} Dusun • ${item.jumlahRw} RW • ${item.jumlahRt} RT • ${item.jumlahDasawisma} Dasa Wisma';
                        }

                        final totalBayi = item.bayiLahirL + item.bayiLahirP;
                        final totalMati = item.ibuMeninggal + item.bayiMeninggalL + item.bayiMeninggalP + item.balitaMeninggalL + item.balitaMeninggalP;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _openTierForm(item: item),
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
                                        decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                        child: const Icon(Icons.holiday_village_rounded, color: _primary),
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
                                                    title,
                                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: _darkText),
                                                  ),
                                                ),
                                                _StatusBadge(status: '${item.ibuHamil} Bumil', primary: _primary),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              subtitle,
                                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                        onPressed: () => _deleteTierRow(item.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _Chip(text: '🤰 ${item.ibuHamil} Hamil • ${item.ibuMelahirkan} Lahir • ${item.ibuNifas} Nifas', color: _primary),
                                      _Chip(text: '👶 $totalBayi Bayi (${item.bayiLahirL}L/${item.bayiLahirP}P)', color: const Color(0xFF0284C7)),
                                      _Chip(text: '📄 ${item.akteAda} Ada Akte', color: const Color(0xFF10B981)),
                                      if (totalMati > 0) _Chip(text: '⚠️ $totalMati Kematian', color: const Color(0xFFBE123C)),
                                      if (item.keterangan.isNotEmpty) _Chip(text: '📝 ${item.keterangan}', color: const Color(0xFF64748B)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── WIDGETS PENDUKUNG (SESUAI GAMBAR 2) ──
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
          Text('$label: ', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
