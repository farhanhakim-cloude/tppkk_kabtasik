// lib/screens/dasawisma/data_keluarga_dasawisma_list_screen.dart
// Halaman Rekapitulasi Catatan Data dan Kegiatan Warga dengan Pilihan Tingkatan (Dasawisma, RT, RW, Dusun, Desa, Kecamatan)
// Menampilkan Card UI responsif, ringkasan metrics, auto-fill, dan modal form perjenjang sesuai format gambar 1-5

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/data_keluarga_dasawisma.dart';
import '../../models/rekap_kegiatan_warga_berjenjang.dart';
import '../../services/data_keluarga_dasawisma_service.dart';
import '../../services/rekap_kegiatan_warga_berjenjang_service.dart';
import 'data_keluarga_dasawisma_form_screen.dart';
import 'rekap_kegiatan_warga_berjenjang_form_screen.dart';

class DataKeluargaDasawismaListScreen extends StatefulWidget {
  final bool embedded;
  const DataKeluargaDasawismaListScreen({super.key, this.embedded = false});

  @override
  State<DataKeluargaDasawismaListScreen> createState() =>
      _DataKeluargaDasawismaListScreenState();
}

class _DataKeluargaDasawismaListScreenState
    extends State<DataKeluargaDasawismaListScreen> {
  final _serviceDasawisma = DataKeluargaDasawismaService();
  final _serviceBerjenjang = RekapKegiatanWargaBerjenjangService();

  String _selectedTingkat = 'dasawisma'; // 'dasawisma', 'rt', 'rw', 'dusun', 'desa', 'kecamatan'
  final _searchController = TextEditingController();

  late Future<List<DataKeluargaDasawisma>> _futureDasawisma;
  late Future<List<RekapKegiatanWargaBerjenjangItem>> _futureBerjenjang;

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
      _futureBerjenjang = _serviceBerjenjang.getByLevel(_selectedTingkat);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDasawismaForm({DataKeluargaDasawisma? item}) async {
    HapticFeedback.selectionClick();
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DataKeluargaDasawismaFormScreen(data: item)),
    );
    if (res == true) _reload();
  }

  Future<void> _openTierForm({RekapKegiatanWargaBerjenjangItem? item}) async {
    HapticFeedback.selectionClick();
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RekapKegiatanWargaBerjenjangFormScreen(
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
        title: Text('Hitung Otomatis dari Dasawisma?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Text(
            'Sistem akan merekap dan mengkalkulasi otomatis seluruh data warga & kegiatan ke form ${_getTingkatLabel(_selectedTingkat)}.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
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
          const SnackBar(
            content: Text('Data kegiatan warga berhasil dihitung & diisi otomatis!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _deleteTierRow(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Data Rekapitulasi?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _serviceBerjenjang.delete(id);
      _reload();
    }
  }

  String _getTingkatLabel(String level) {
    switch (level) {
      case 'dasawisma':
        return 'Dasawisma';
      case 'rt':
        return 'Kelompok PKK RT';
      case 'rw':
        return 'Kelompok PKK RW';
      case 'dusun':
        return 'PKK Dusun/Lingkungan';
      case 'desa':
        return 'TP PKK Desa';
      case 'kecamatan':
        return 'TP PKK Kecamatan';
      default:
        return level.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8FAFC);

    final content = Column(
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
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF0F172A)),
                ),
              ),
              title: Text('Data & Kegiatan Warga',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800, fontSize: 17, color: const Color(0xFF0F172A))),
              actions: [
                IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0D9488)),
                    onPressed: _reload)
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_kegiatan_warga_input',
        onPressed: () {
          if (_selectedTingkat == 'dasawisma') {
            _openDasawismaForm();
          } else {
            _openTierForm();
          }
        },
        backgroundColor: _primary,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          _selectedTingkat == 'dasawisma'
              ? 'Tambah Data Warga'
              : 'Catat Rekap ${_selectedTingkat.toUpperCase()}',
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5),
        ),
      ),
      body: content,
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
  // 1. TINGKAT DASAWISMA VIEW (DATA PERORANGAN / BINAAN)
  // ===========================================================================
  Widget _buildDasawismaView() {
    return Column(
      children: [
        // Header info bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.holiday_village_rounded, color: _primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data & Kegiatan Warga',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800, fontSize: 15, color: _darkText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Format Binaan Perorangan Kelompok Dasa Wisma',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openDasawismaForm(),
                icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                label: Text('Tambah Data',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700, fontSize: 12.5, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        // Search bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: _darkText),
              decoration: InputDecoration(
                hintText: 'Cari kepala RT, Dasa Wisma, desa...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                        onPressed: () {
                          _searchController.clear();
                          _reload();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) => _reload(),
            ),
          ),
        ),

        // List
        Expanded(
          child: FutureBuilder<List<DataKeluargaDasawisma>>(
            future: _futureDasawisma,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2.4, color: _primary));
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.08), shape: BoxShape.circle),
                        child: const Icon(Icons.home_work_outlined, size: 52, color: _primary),
                      ),
                      const SizedBox(height: 16),
                      Text('Belum ada data Dasawisma',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 16, fontWeight: FontWeight.w800, color: _darkText)),
                      const SizedBox(height: 6),
                      Text('Mulai catat Dasa Wisma, RT/RW dan anggota keluarga',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: const Color(0xFF64748B), height: 1.4)),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () => _openDasawismaForm(),
                        icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                        label: Text('Input Dasawisma',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11)),
                      ),
                    ]),
                  ),
                );
              }

              final totalAnggota = list.fold<int>(0, (p, e) => p + e.anggotaList.length);
              final sehat = list.where((e) => e.kriteriaRumah == 'Sehat').length;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _MetricChip(
                            icon: Icons.holiday_village_rounded,
                            label: '${list.length} Dasawisma',
                            color: _primary,
                            bg: const Color(0xFFECFDF5)),
                        const SizedBox(width: 8),
                        _MetricChip(
                            icon: Icons.people_alt_rounded,
                            label: '$totalAnggota Anggota',
                            color: const Color(0xFF2563EB),
                            bg: const Color(0xFFEFF6FF)),
                        const SizedBox(width: 8),
                        _MetricChip(
                            icon: Icons.verified_rounded,
                            label: '$sehat Rumah Sehat',
                            color: const Color(0xFF059669),
                            bg: const Color(0xFFECFDF5)),
                      ]),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _reload(),
                      color: _primary,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _DasawismaCard(
                            item: list[index],
                            onTap: () => _openDasawismaForm(item: list[index]),
                            primary: _primary),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. TINGKAT RT, RW, DUSUN, DESA, KECAMATAN (KARTU SESUAI GAMBAR 1-5)
  // ===========================================================================
  Widget _buildTieredCardView(String level) {
    return FutureBuilder<List<RekapKegiatanWargaBerjenjangItem>>(
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
                    e.namaDesa.toLowerCase().contains(q) ||
                    e.kecamatan.toLowerCase().contains(q);
              }).toList();

        final tKrt = allItems.fold(0, (p, e) => p + e.jumlahKrt);
        final tKk = allItems.fold(0, (p, e) => p + e.jumlahKk);
        final tWarga = allItems.fold(0, (p, e) => p + e.totalL + e.totalP);
        final tPus = allItems.fold(0, (p, e) => p + e.pus);
        final tWus = allItems.fold(0, (p, e) => p + e.wus);
        final tBumil = allItems.fold(0, (p, e) => p + e.ibuHamil);
        final tRumahSehat = allItems.fold(0, (p, e) => p + e.rumahSehat);
        final tUp2k = allItems.fold(0, (p, e) => p + e.kegiatanUp2k);

        return Column(
          children: [
            // Summary header bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rekapitulasi ${_getTingkatLabel(level)}',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800, fontSize: 13.5, color: _darkText),
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _autoFillFromDasawisma,
                            icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: _primary),
                            label: Text('Auto-Isi',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5, fontWeight: FontWeight.w700, color: _primary)),
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
                            label: Text('Catat Data',
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                    color: Colors.white)),
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
                        _SummaryChip(label: 'Total KRT', val: '$tKrt', color: const Color(0xFF0D9488)),
                        _SummaryChip(label: 'Total KK', val: '$tKk', color: const Color(0xFF0284C7)),
                        _SummaryChip(label: 'Total Jiwa', val: '$tWarga', color: const Color(0xFF6366F1)),
                        _SummaryChip(label: 'PUS / WUS', val: '$tPus / $tWus', color: const Color(0xFF8B5CF6)),
                        _SummaryChip(label: 'Ibu Hamil', val: '$tBumil', color: const Color(0xFFEC4899)),
                        _SummaryChip(label: 'Rumah Sehat', val: '$tRumahSehat', color: const Color(0xFF10B981)),
                        _SummaryChip(label: 'UP2K', val: '$tUp2k', color: const Color(0xFFF59E0B)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Cari nama pengenal, RT, RW, atau dusun...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            // List of cards
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_off_outlined, size: 56, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('Belum ada data rekap untuk ${_getTingkatLabel(level)}',
                              style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _openTierForm(),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: Text('Catat Rekap ${_getTingkatLabel(level)}',
                                style: const TextStyle(color: Colors.white)),
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
                          title = item.namaDasawisma.isNotEmpty
                              ? 'Dasa Wisma ${item.namaDasawisma}'
                              : 'Dasa Wisma Mawar';
                          subtitle = 'RT ${item.rt}/RW ${item.rw} • ${item.dusun}, ${item.desa}';
                        } else if (level == 'rw') {
                          title = 'RT ${item.nomorRt} • ${item.jumlahDasawisma} Dasa Wisma';
                          subtitle = 'RW ${item.rw} • ${item.dusun}, ${item.desa}';
                        } else if (level == 'dusun') {
                          title = 'RW ${item.nomorRw}';
                          subtitle = '${item.jumlahRt} RT • ${item.jumlahDasawisma} Dasa Wisma • Dusun ${item.dusun}';
                        } else if (level == 'desa') {
                          title = 'Dusun ${item.namaDusun}';
                          subtitle = '${item.jumlahRw} RW • ${item.jumlahRt} RT • ${item.jumlahDasawisma} Dasa Wisma';
                        } else if (level == 'kecamatan') {
                          title = 'Desa ${item.namaDesa}';
                          subtitle = '${item.jumlahDusun} Dusun • ${item.jumlahRw} RW • ${item.jumlahRt} RT • ${item.jumlahDasawisma} Dasa Wisma';
                        }

                        final totalWarga = item.totalL + item.totalP;
                        final totalBalita = item.balitaL + item.balitaP;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3))
                            ],
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
                                        decoration: BoxDecoration(
                                            color: _primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12)),
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
                                                    style: GoogleFonts.plusJakartaSans(
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 15,
                                                        color: _darkText),
                                                  ),
                                                ),
                                                _StatusBadge(status: '${item.jumlahKk} KK', primary: _primary),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              subtitle,
                                              style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded,
                                            size: 18, color: Colors.red),
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
                                      _Chip(
                                          text: '👨‍👩‍👧‍👦 $totalWarga Jiwa (${item.totalL}L/${item.totalP}P)',
                                          color: const Color(0xFF6366F1)),
                                      _Chip(
                                          text: '👶 $totalBalita Balita',
                                          color: const Color(0xFF0284C7)),
                                      _Chip(
                                          text: '🤰 ${item.ibuHamil} Bumil',
                                          color: const Color(0xFFEC4899)),
                                      _Chip(
                                          text: '🏡 ${item.rumahSehat} Rumah Sehat',
                                          color: const Color(0xFF10B981)),
                                      _Chip(
                                          text: '🛍️ ${item.kegiatanUp2k} UP2K',
                                          color: const Color(0xFFF59E0B)),
                                      if (item.keterangan.isNotEmpty)
                                        _Chip(text: '📝 ${item.keterangan}', color: const Color(0xFF64748B)),
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

// ── WIDGETS PENDUKUNG DASAWISMA ──
class _DasawismaCard extends StatelessWidget {
  final DataKeluargaDasawisma item;
  final VoidCallback onTap;
  final Color primary;

  const _DasawismaCard({required this.item, required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.home_rounded, color: primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.namaKepalaRumahTangga.isNotEmpty
                                ? item.namaKepalaRumahTangga
                                : 'Kepala Rumah Tangga',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: const Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kelompok ${item.dasaWisma} • RT ${item.rt}/RW ${item.rw}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.kriteriaRumah == 'Sehat'
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.kriteriaRumah,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: item.kriteriaRumah == 'Sehat'
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniBadge(label: '${item.jumlahKk} KK', color: const Color(0xFF2563EB)),
                    _MiniBadge(
                        label: '${item.jumlahLakiLaki + item.jumlahPerempuan} Jiwa',
                        color: const Color(0xFF7C3AED)),
                    _MiniBadge(label: '${item.jumlahBalita} Balita', color: const Color(0xFF059669)),
                    if (item.jumlahIbuHamil > 0)
                      _MiniBadge(
                          label: '${item.jumlahIbuHamil} Bumil', color: const Color(0xFFDB2777)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _MetricChip({required this.icon, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String val;
  final Color color;

  const _SummaryChip({required this.label, required this.val, required this.color});

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
          Text('$label: ',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          Text(val,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, fontWeight: FontWeight.w900, color: color)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w700, color: primary),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
