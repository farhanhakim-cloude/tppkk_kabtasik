// lib/screens/dasawisma/data_umum_pkk_list_screen.dart
// Halaman Rekapitulasi Data Umum PKK untuk Tingkat Desa (Gambar 1 - 20 Kolom)
// & Tingkat Kecamatan (Gambar 2 - 21 Kolom)
// Dilengkapi Card UI modern, Selector Tingkat (Desa/Kecamatan), Mode Tabel Excel resmi, Auto-Isi, dan Search.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/data_umum_pkk.dart';
import '../../services/data_umum_pkk_service.dart';
import 'data_umum_pkk_form_screen.dart';

class DataUmumPkkListScreen extends StatefulWidget {
  final bool embedded;
  const DataUmumPkkListScreen({super.key, this.embedded = false});

  @override
  State<DataUmumPkkListScreen> createState() => _DataUmumPkkListScreenState();
}

class _DataUmumPkkListScreenState extends State<DataUmumPkkListScreen> {
  final _service = DataUmumPkkService();
  String _selectedLevel = 'desa'; // 'desa' atau 'kecamatan'
  final _searchController = TextEditingController();
  late Future<List<DataUmumPkkItem>> _futureData;
  bool _isTableView = false;

  static const Color _primary = Color(0xFF0D9488);
  static const Color _darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _futureData = _service.getByLevel(_selectedLevel);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({DataUmumPkkItem? item}) async {
    HapticFeedback.selectionClick();
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DataUmumPkkFormScreen(
          level: _selectedLevel,
          item: item,
        ),
      ),
    );
    if (res == true) _reload();
  }

  Future<void> _deleteItem(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Data Umum?',
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
      await _service.delete(id);
      _reload();
    }
  }

  Future<void> _autoFillFromRekap() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tarik & Hitung Otomatis?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Text(
          'Sistem akan mengkalkulasi otomatis seluruh data kelompok, KRT, KK, dan jiwa ke formulir Data Umum ${_selectedLevel.toUpperCase()}.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
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
      await _service.autoGenerateFromRekap(_selectedLevel);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data Umum ${_selectedLevel.toUpperCase()} berhasil disinkronkan & dihitung!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
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
                'Data Umum PKK',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16.5,
                  color: _darkText,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: _isTableView ? 'Tampilan Kartu' : 'Tampilan Tabel Format Excel',
                  icon: Icon(
                    _isTableView ? Icons.grid_view_rounded : Icons.table_chart_rounded,
                    color: _primary,
                  ),
                  onPressed: () => setState(() => _isTableView = !_isTableView),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: _primary),
                  onPressed: _reload,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_data_umum_pkk_desa_kec',
        onPressed: () => _openForm(),
        backgroundColor: _primary,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          'Input Data Umum ${_selectedLevel.toUpperCase()}',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── SELECTOR TINGKAT (DESA & KECAMATAN) ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                _levelPill('desa', 'TP PKK Desa (Gambar 1)'),
                const SizedBox(width: 8),
                _levelPill('kecamatan', 'TP PKK Kecamatan (Gambar 2)'),
                const Spacer(),
                if (widget.embedded)
                  IconButton(
                    tooltip: _isTableView ? 'Tampilan Kartu' : 'Format Tabel Excel',
                    icon: Icon(
                      _isTableView ? Icons.grid_view_rounded : Icons.table_chart_rounded,
                      color: _primary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isTableView = !_isTableView),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // ── ISI DATA ──
          Expanded(
            child: FutureBuilder<List<DataUmumPkkItem>>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _primary));
                }

                final allList = snapshot.data ?? [];
                final q = _searchController.text.trim().toLowerCase();
                final list = q.isEmpty
                    ? allList
                    : allList.where((e) {
                        return e.namaDusun.toLowerCase().contains(q) ||
                            e.namaDesa.toLowerCase().contains(q) ||
                            e.kecamatan.toLowerCase().contains(q);
                      }).toList();

                // Hitung Ringkasan Metrics
                final totalDusun = allList.fold(0, (p, e) => p + e.jumlahDusun);
                final totalRw = allList.fold(0, (p, e) => p + e.jumlahPkkRw);
                final totalRt = allList.fold(0, (p, e) => p + e.jumlahPkkRt);
                final totalDasawisma = allList.fold(0, (p, e) => p + e.jumlahDasaWisma);
                final totalKrt = allList.fold(0, (p, e) => p + e.jumlahKrt);
                final totalKk = allList.fold(0, (p, e) => p + e.jumlahKk);
                final totalJiwa = allList.fold(0, (p, e) => p + e.totalJiwa);
                final totalKader = allList.fold(0, (p, e) => p + e.totalKader);
                final totalSekretariat = allList.fold(0, (p, e) => p + e.totalSekretariat);

                return Column(
                  children: [
                    // Metrics Header
                    Container(
                      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedLevel == 'desa'
                                        ? 'DATA UMUM PKK • TP PKK DESA'
                                        : 'DATA UMUM PKK • KECAMATAN',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: _darkText,
                                    ),
                                  ),
                                  Text(
                                    _selectedLevel == 'desa'
                                        ? 'KABUPATEN: TASIKMALAYA • PROVINSI: JAWA BARAT'
                                        : 'KABUPATEN: TASIKMALAYA • PROVINSI: JAWA BARAT',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _autoFillFromRekap,
                                    icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: _primary),
                                    label: Text(
                                      'Auto-Isi',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: _primary,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: _primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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
                                if (_selectedLevel == 'kecamatan')
                                  _metricBadge('Total Dusun', '$totalDusun', const Color(0xFF0284C7)),
                                _metricBadge('Total RW / RT', '$totalRw / $totalRt', _primary),
                                _metricBadge('Dasa Wisma', '$totalDasawisma', const Color(0xFF8B5CF6)),
                                _metricBadge('Total KRT / KK', '$totalKrt / $totalKk', const Color(0xFFEC4899)),
                                _metricBadge('Total Jiwa', '$totalJiwa', const Color(0xFFF59E0B)),
                                _metricBadge('Total Kader', '$totalKader', const Color(0xFF10B981)),
                                _metricBadge('Sekretariat', '$totalSekretariat', const Color(0xFF6366F1)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search box
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: _selectedLevel == 'desa'
                              ? 'Cari nama dusun / lingkungan...'
                              : 'Cari nama desa / kecamatan...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),

                    // Tampilan Data (Cards atau Format Excel Table)
                    Expanded(
                      child: list.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_late_outlined, size: 52, color: Colors.grey[300]),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Belum ada data umum ${_selectedLevel.toUpperCase()}',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () => _openForm(),
                                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                    label: Text(
                                      'Input Data Umum ${_selectedLevel.toUpperCase()}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(backgroundColor: _primary),
                                  ),
                                ],
                              ),
                            )
                          : (_isTableView
                              ? _buildExcelTableView(list)
                              : _buildCardListView(list)),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelPill(String key, String label) {
    final active = _selectedLevel == key;
    return GestureDetector(
      onTap: () {
        if (_selectedLevel != key) {
          setState(() {
            _selectedLevel = key;
            _reload();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _metricBadge(String label, String val, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          Text(val,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5, fontWeight: FontWeight.w900, color: _darkText)),
        ],
      ),
    );
  }

  // ── 1. TAMPILAN CARD UI BERSIH & MODERN ──
  Widget _buildCardListView(List<DataUmumPkkItem> list) {
    final isDesa = _selectedLevel == 'desa';
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final title = isDesa
            ? (item.namaDusun.isNotEmpty ? item.namaDusun : 'Dusun/Lingkungan ${index + 1}')
            : (item.namaDesa.isNotEmpty ? item.namaDesa : 'Desa ${index + 1}');

        final subtitle = isDesa
            ? 'Desa ${item.desa}, Kec. ${item.kecamatan}'
            : '${item.jumlahDusun} Dusun • Kec. ${item.kecamatan}';

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
                          color: _primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDesa ? Icons.holiday_village_rounded : Icons.apartment_rounded,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: _darkText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.jumlahKk} KK',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                        onPressed: () => _deleteItem(item.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // Data Tag Badges
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (!isDesa)
                        _cardChip('🏞️ ${item.jumlahDusun} Dusun', const Color(0xFF0284C7)),
                      _cardChip('🏘️ ${item.jumlahPkkRw} RW • ${item.jumlahPkkRt} RT', const Color(0xFF0D9488)),
                      _cardChip('🪴 ${item.jumlahDasaWisma} Dasawisma', const Color(0xFF8B5CF6)),
                      _cardChip('🏠 ${item.jumlahKrt} KRT', const Color(0xFFEC4899)),
                      _cardChip('👥 ${item.totalJiwa} Jiwa (${item.jiwaL}L/${item.jiwaP}P)', const Color(0xFFF59E0B)),
                      _cardChip(
                        '🎖️ ${item.totalKader} Kader (TP PKK: ${item.kaderTpPkkL + item.kaderTpPkkP} • Umum: ${item.kaderUmumL + item.kaderUmumP} • Khusus: ${item.kaderKhususL + item.kaderKhususP})',
                        const Color(0xFF10B981),
                      ),
                      _cardChip(
                        '💼 ${item.totalSekretariat} Sekretariat (Honorer: ${item.sekretariatHonorerL + item.sekretariatHonorerP} • Bantuan: ${item.sekretariatBantuanL + item.sekretariatBantuanP})',
                        const Color(0xFF6366F1),
                      ),
                      if (item.keterangan.isNotEmpty)
                        _cardChip('📝 ${item.keterangan}', const Color(0xFF64748B)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cardChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ── 2. TAMPILAN FORMAT TABEL EXCEL RESMI SESUAI GAMBAR ──
  Widget _buildExcelTableView(List<DataUmumPkkItem> list) {
    final isDesa = _selectedLevel == 'desa';

    // Kalkulasi Total Bawah
    final sumDusun = list.fold(0, (p, e) => p + e.jumlahDusun);
    final sumRw = list.fold(0, (p, e) => p + e.jumlahPkkRw);
    final sumRt = list.fold(0, (p, e) => p + e.jumlahPkkRt);
    final sumDasawisma = list.fold(0, (p, e) => p + e.jumlahDasaWisma);
    final sumKrt = list.fold(0, (p, e) => p + e.jumlahKrt);
    final sumKk = list.fold(0, (p, e) => p + e.jumlahKk);
    final sumJiwaL = list.fold(0, (p, e) => p + e.jiwaL);
    final sumJiwaP = list.fold(0, (p, e) => p + e.jiwaP);
    final sumKaderTpL = list.fold(0, (p, e) => p + e.kaderTpPkkL);
    final sumKaderTpP = list.fold(0, (p, e) => p + e.kaderTpPkkP);
    final sumKaderUmL = list.fold(0, (p, e) => p + e.kaderUmumL);
    final sumKaderUmP = list.fold(0, (p, e) => p + e.kaderUmumP);
    final sumKaderKhL = list.fold(0, (p, e) => p + e.kaderKhususL);
    final sumKaderKhP = list.fold(0, (p, e) => p + e.kaderKhususP);
    final sumSekrHonL = list.fold(0, (p, e) => p + e.sekretariatHonorerL);
    final sumSekrHonP = list.fold(0, (p, e) => p + e.sekretariatHonorerP);
    final sumSekrBanL = list.fold(0, (p, e) => p + e.sekretariatBantuanL);
    final sumSekrBanP = list.fold(0, (p, e) => p + e.sekretariatBantuanP);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFE2E8F0)),
            dataRowMinHeight: 38,
            dataRowMaxHeight: 46,
            columnSpacing: 16,
            horizontalMargin: 12,
            columns: [
              const DataColumn(label: Text('No.', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                label: Text(
                  isDesa ? 'NAMA DUSUN/LINGKUNGAN' : 'NAMA DESA',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (!isDesa)
                const DataColumn(label: Text('DUSUN', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('PKK RW', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('PKK RT', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('DASA WISMA', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('KRT', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('KK', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('JIWA (L)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('JIWA (P)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('TP PKK (L)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('TP PKK (P)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('KADER UM (L)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('KADER UM (P)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('KADER KH (L)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('KADER KH (P)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('HONORER (L)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('HONORER (P)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('BANTUAN (L)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('BANTUAN (P)', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('KET', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: [
              ...list.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final e = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text('$idx')),
                    DataCell(
                      InkWell(
                        onTap: () => _openForm(item: e),
                        child: Text(
                          isDesa ? e.namaDusun : e.namaDesa,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: _primary),
                        ),
                      ),
                    ),
                    if (!isDesa) DataCell(Text('${e.jumlahDusun}')),
                    DataCell(Text('${e.jumlahPkkRw}')),
                    DataCell(Text('${e.jumlahPkkRt}')),
                    DataCell(Text('${e.jumlahDasaWisma}')),
                    DataCell(Text('${e.jumlahKrt}')),
                    DataCell(Text('${e.jumlahKk}')),
                    DataCell(Text('${e.jiwaL}')),
                    DataCell(Text('${e.jiwaP}')),
                    DataCell(Text('${e.kaderTpPkkL}')),
                    DataCell(Text('${e.kaderTpPkkP}')),
                    DataCell(Text('${e.kaderUmumL}')),
                    DataCell(Text('${e.kaderUmumP}')),
                    DataCell(Text('${e.kaderKhususL}')),
                    DataCell(Text('${e.kaderKhususP}')),
                    DataCell(Text('${e.sekretariatHonorerL}')),
                    DataCell(Text('${e.sekretariatHonorerP}')),
                    DataCell(Text('${e.sekretariatBantuanL}')),
                    DataCell(Text('${e.sekretariatBantuanP}')),
                    DataCell(Text(e.keterangan)),
                  ],
                );
              }),
              // Row Total / Jumlah
              DataRow(
                color: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                cells: [
                  const DataCell(Text('JUMLAH', style: TextStyle(fontWeight: FontWeight.w900))),
                  const DataCell(Text('')),
                  if (!isDesa) DataCell(Text('$sumDusun', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumRw', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumRt', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumDasawisma', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumKrt', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumKk', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumJiwaL', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumJiwaP', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumKaderTpL', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumKaderTpP', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumKaderUmL', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumKaderUmP', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumKaderKhL', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumKaderKhP', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumSekrHonL', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumSekrHonP', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumSekrBanL', style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataCell(Text('$sumSekrBanP', style: const TextStyle(fontWeight: FontWeight.w900))),
                  const DataCell(Text('')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
