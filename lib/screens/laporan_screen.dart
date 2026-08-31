import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kesehatan.dart';
import '../models/catatan_kegiatan.dart';
import '../services/keluarga_service.dart';
import '../services/kesehatan_service.dart';
import '../services/catatan_kegiatan_service.dart';
import 'catatan_kegiatan_form_screen.dart';

class LaporanScreen extends StatefulWidget {
  final bool embedded;
  const LaporanScreen({super.key, this.embedded = false});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen>
    with SingleTickerProviderStateMixin {
  final _keluargaService = KeluargaService();
  final _kesehatanService = KesehatanService();
  final _catatanService = CatatanKegiatanService();

  late TabController _tabController;
  String _periode = 'Agustus 2026';
  late Future<_LaporanData> _laporanFuture;
  late Future<List<CatatanKegiatan>> _catatanFuture;
  PokjaKategori? _filterPokja;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _reloadAll();
  }

  void _reloadAll() {
    setState(() {
      _laporanFuture = _loadData();
      _catatanFuture = _catatanService.getAll(kategori: _filterPokja);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _openCatatanForm({CatatanKegiatan? catatan}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CatatanKegiatanFormScreen(catatan: catatan)),
    );
    if (result == true) _reloadAll();
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

  Color _getPokjaColor(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return const Color(0xFF3B82F6);
      case PokjaKategori.pokja2:
        return const Color(0xFF8B5CF6);
      case PokjaKategori.pokja3:
        return const Color(0xFF10B981);
      case PokjaKategori.pokja4:
        return const Color(0xFFF59E0B);
    }
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
                    color: Colors.black.withOpacity(0.04),
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
                          color: primary.withOpacity(0.1),
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

  // ── TAB 2: CATATAN KEGIATAN POKJA ──
  Widget _buildCatatanPokjaTab(Color primary) {
    return Column(
      children: [
        // Pokja Filter Chips
        Container(
          height: 44,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Semua Pokja'),
                  selected: _filterPokja == null,
                  onSelected: (_) {
                    setState(() => _filterPokja = null);
                    _reloadAll();
                  },
                  backgroundColor: Colors.white,
                  selectedColor: primary.withOpacity(0.15),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: _filterPokja == null ? FontWeight.w700 : FontWeight.w500,
                    color: _filterPokja == null ? primary : Colors.grey[700],
                  ),
                ),
              ),
              ...PokjaKategori.values.map((pokja) {
                final isSelected = _filterPokja == pokja;
                final color = _getPokjaColor(pokja);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(pokja.shortLabel),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _filterPokja = isSelected ? null : pokja);
                      _reloadAll();
                    },
                    backgroundColor: Colors.white,
                    selectedColor: color.withOpacity(0.15),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : Colors.grey[700],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // List of Activities
        Expanded(
          child: FutureBuilder<List<CatatanKegiatan>>(
            future: _catatanFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Gagal memuat catatan: ${snapshot.error}',
                      style: GoogleFonts.plusJakartaSans()),
                );
              }

              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 56, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('Belum ada catatan kegiatan Pokja',
                          style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _openCatatanForm(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Catatan Pokja'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final c = list[index];
                  final pokjaColor = _getPokjaColor(c.kategori);
                  final hasPhoto = c.fotoPath != null && c.fotoPath!.isNotEmpty;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openCatatanForm(catatan: c),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasPhoto)
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(16)),
                              child: SizedBox(
                                height: 130,
                                width: double.infinity,
                                child: Image.file(
                                  File(c.fotoPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: pokjaColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        c.kategori.shortLabel,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: pokjaColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 11, color: Color(0xFF64748B)),
                                          const SizedBox(width: 3),
                                          Text(
                                            'Kec. ${c.kecamatan}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${c.tanggal.day}/${c.tanggal.month}/${c.tanggal.year}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  c.judul,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c.deskripsiSingkat,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text('Laporan & Catatan',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
            ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => _openCatatanForm(),
              backgroundColor: primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Catat Kegiatan',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : null,
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
                      'Laporan & Kegiatan',
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

          // Dual Tab Switcher (1. Laporan | 2. Catatan Kegiatan/Pokja)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF0F172A),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '1. Laporan'),
                Tab(text: '2. Catatan Kegiatan / Pokja'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLaporanTab(primary),
                _buildCatatanPokjaTab(primary),
              ],
            ),
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