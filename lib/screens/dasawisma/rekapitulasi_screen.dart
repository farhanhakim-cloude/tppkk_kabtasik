import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/rekapitulasi_service.dart';
import '../../widgets/kecamatan_dropdown_field.dart';

class RekapitulasiScreen extends StatefulWidget {
  final String? initialDesa;
  final String? initialKecamatan;
  const RekapitulasiScreen({super.key, this.initialDesa, this.initialKecamatan});

  @override
  State<RekapitulasiScreen> createState() => _RekapitulasiScreenState();
}

class _RekapitulasiScreenState extends State<RekapitulasiScreen> with SingleTickerProviderStateMixin {
  final _service = RekapitulasiService();
  late TabController _tabController;

  // Filter controllers
  final _rtCtrl = TextEditingController();
  final _rwCtrl = TextEditingController();
  final _dusunCtrl = TextEditingController();
  final _desaCtrl = TextEditingController();
  final _kecCtrl = TextEditingController();
  String _tahun = '2026';
  final _tahunList = ['', '2024', '2025', '2026', '2027'];

  // View mode: 'cards' or 'table'
  String _viewMode = 'cards';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _desaCtrl.text = widget.initialDesa ?? '';
    _kecCtrl.text = widget.initialKecamatan ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    _desaCtrl.dispose();
    _kecCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D9488);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rekapitulasi Berjenjang Dasawisma',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            ),
            Text(
              'Otomatis Roll-up RT • RW • Dusun • Desa • Kec • Kab',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _viewMode == 'cards' ? 'Lihat Format Tabel / Cetak' : 'Lihat Mode Kartu Visual',
            icon: Icon(_viewMode == 'cards' ? Icons.table_chart_rounded : Icons.grid_view_rounded, color: primary),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == 'cards' ? 'table' : 'cards';
              });
            },
          ),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
          labelColor: const Color(0xFF0F766E),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: primary,
          tabs: const [
            Tab(text: 'Sheet 7 - Rekap Data & Warga'),
            Tab(text: 'Sheet 8 - Ibu, Bayi & Kematian'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Wilayah Bar (RT/RW/Dusun/Desa/Kec/Tahun)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _miniField(_rtCtrl, 'RT', Icons.location_on_outlined)),
                    const SizedBox(width: 6),
                    Expanded(child: _miniField(_rwCtrl, 'RW', Icons.location_on_outlined)),
                    const SizedBox(width: 6),
                    Expanded(child: _miniField(_dusunCtrl, 'Dusun', Icons.landscape_outlined)),
                    const SizedBox(width: 6),
                    Expanded(child: _miniField(_desaCtrl, 'Desa', Icons.home_work_outlined)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(flex: 3, child: KecamatanDropdownField(controller: _kecCtrl, allowEmpty: true, isCompact: true, prefixIcon: const Icon(Icons.map_outlined, size: 16, color: Color(0xFF0D9488)))),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _tahun,
                            isExpanded: true,
                            hint: Text('Tahun', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                            items: _tahunList
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.isEmpty ? 'Semua Thn' : e, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _tahun = v ?? ''),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.filter_alt_rounded, size: 16),
                      label: Text('Filter', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSheet7Content(),
                _buildSheet8Content(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniField(TextEditingController ctrl, String label, IconData icon) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          controller: ctrl,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF64748B)),
            prefixIcon: Icon(icon, size: 14, color: const Color(0xFF0D9488)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            isDense: true,
          ),
        ),
      );

  // ── SHEET 7 (DATA KELUARGA & KEGIATAN WARGA) ──
  Widget _buildSheet7Content() {
    return FutureBuilder<RekapTotal>(
      future: _service.getTotalSheet7(
        rt: _rtCtrl.text.trim(),
        rw: _rwCtrl.text.trim(),
        dusun: _dusunCtrl.text.trim(),
        desa: _desaCtrl.text.trim(),
        kecamatan: _kecCtrl.text.trim(),
        tahun: _tahun,
      ),
      builder: (context, totalSnap) {
        if (!totalSnap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
        final total = totalSnap.data!;

        return FutureBuilder<List<RekapRow>>(
          future: _service.getRekapSheet7(
            rt: _rtCtrl.text.trim(),
            rw: _rwCtrl.text.trim(),
            dusun: _dusunCtrl.text.trim(),
            desa: _desaCtrl.text.trim(),
            kecamatan: _kecCtrl.text.trim(),
            tahun: _tahun,
          ),
          builder: (context, snap) {
            final rows = snap.data ?? [];

            if (_viewMode == 'table') {
              return _buildSheet7Table(rows, total);
            }

            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              color: const Color(0xFF0D9488),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Info Card Auto-roll up
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFF059669)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Rekapitulasi otomatis dari ${rows.length} Kepala Rumah Tangga',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF047857)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 1. KELOMPOK KEPENDUDUKAN & KELUARGA
                  _buildSectionCard(
                    title: 'Demografi & Kelompok Umur',
                    icon: Icons.groups_rounded,
                    color: const Color(0xFF2563EB),
                    stats: [
                      _StatItem('Total KK', '${total.jumlahKk}', Icons.badge_rounded, const Color(0xFF2563EB)),
                      _StatItem('Jiwa Laki-Laki', '${total.l}', Icons.boy_rounded, const Color(0xFF0284C7)),
                      _StatItem('Jiwa Perempuan', '${total.p}', Icons.girl_rounded, const Color(0xFFEC4899)),
                      _StatItem('Balita', '${total.balitaL + total.balitaP}', Icons.child_care_rounded, const Color(0xFFF59E0B)),
                      _StatItem('Pasangan PUS', '${total.pus}', Icons.favorite_rounded, const Color(0xFFE11D48)),
                      _StatItem('Wanita WUS', '${total.wus}', Icons.woman_rounded, const Color(0xFF8B5CF6)),
                      _StatItem('Ibu Hamil', '${total.ibuHamil}', Icons.pregnant_woman_rounded, const Color(0xFF0D9488)),
                      _StatItem('Ibu Menyusui', '${total.ibuMenyusui}', Icons.child_friendly_rounded, const Color(0xFF06B6D4)),
                      _StatItem('Lansia', '${total.lansia}', Icons.elderly_rounded, const Color(0xFF64748B)),
                      _StatItem('3 Buta', '${total.tigaButaL + total.tigaButaP}', Icons.visibility_off_rounded, const Color(0xFFD97706)),
                      _StatItem('Berkebutuhan Khusus', '${total.berkebutuhanKhusus}', Icons.accessible_rounded, const Color(0xFF7C3AED)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. KRITERIA RUMAH & SANITASI
                  _buildSectionCard(
                    title: 'Fasilitas Rumah & Sanitasi',
                    icon: Icons.home_work_rounded,
                    color: const Color(0xFF059669),
                    stats: [
                      _StatItem('Rumah Tidak Layak', '${total.kriteriaTidakLayak}', Icons.warning_rounded, const Color(0xFFDC2626)),
                      _StatItem('Jamban / MCK', '${total.punyaJamban}', Icons.wc_rounded, const Color(0xFF059669)),
                      _StatItem('Tempat Sampah', '${total.punyaTempatSampah}', Icons.delete_outline_rounded, const Color(0xFF10B981)),
                      _StatItem('Saluran SPAL', '${total.punyaSpal}', Icons.water_rounded, const Color(0xFF0284C7)),
                      _StatItem('Air PDAM', '${total.sumberAirPdam}', Icons.water_drop_rounded, const Color(0xFF2563EB)),
                      _StatItem('Air Sumur', '${total.sumberAirSumur}', Icons.waves_rounded, const Color(0xFF0D9488)),
                      _StatItem('Air Lainnya', '${total.sumberAirLainnya}', Icons.opacity_rounded, const Color(0xFF64748B)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. PANGAN, EKONOMI & LINGKUNGAN
                  _buildSectionCard(
                    title: 'Pangan, Ekonomi & Kegiatan Lingkungan',
                    icon: Icons.storefront_rounded,
                    color: const Color(0xFF7C3AED),
                    stats: [
                      _StatItem('Makanan Beras', '${total.makananBeras}', Icons.rice_bowl_rounded, const Color(0xFFD97706)),
                      _StatItem('Makanan Non-Beras', '${total.makananNonBeras}', Icons.restaurant_rounded, const Color(0xFF059669)),
                      _StatItem('Aktif UP2K', '${total.up2k}', Icons.store_rounded, const Color(0xFFDB2777)),
                      _StatItem('Tanah Pekarangan', '${total.tanahPekarangan}', Icons.grass_rounded, const Color(0xFF16A34A)),
                      _StatItem('Industri Rumah Tangga', '${total.industriRumah}', Icons.precision_manufacturing_rounded, const Color(0xFF7C3AED)),
                      _StatItem('Kesehatan Lingkungan', '${total.kesehatanLingkungan}', Icons.eco_rounded, const Color(0xFF0D9488)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── SHEET 8 (REKAP IBU & ANAK / KEMATIAN) ──
  Widget _buildSheet8Content() {
    return FutureBuilder<IbuBayiRekap>(
      future: _service.getRekapSheet8(
        rt: _rtCtrl.text.trim(),
        rw: _rwCtrl.text.trim(),
        dusun: _dusunCtrl.text.trim(),
        desa: _desaCtrl.text.trim(),
        tahun: _tahun,
      ),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
        final r = snap.data!;

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          color: const Color(0xFF0D9488),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionCard(
                title: 'Kesehatan Ibu & Kelahiran Bayi',
                icon: Icons.child_care_rounded,
                color: const Color(0xFFEC4899),
                stats: [
                  _StatItem('Ibu Hamil', '${r.hamil}', Icons.pregnant_woman_rounded, const Color(0xFF8B5CF6)),
                  _StatItem('Ibu Melahirkan', '${r.melahirkan}', Icons.child_care_rounded, const Color(0xFFEC4899)),
                  _StatItem('Ibu Nifas', '${r.nifas}', Icons.healing_rounded, const Color(0xFF06B6D4)),
                  _StatItem('Bayi Lahir Laki', '${r.bayiLahirL}', Icons.boy_rounded, const Color(0xFF2563EB)),
                  _StatItem('Bayi Lahir Peremp.', '${r.bayiLahirP}', Icons.girl_rounded, const Color(0xFFF43F5E)),
                  _StatItem('Memiliki Akta Lahir', '${r.aktaAda}', Icons.verified_rounded, const Color(0xFF10B981)),
                  _StatItem('Belum Ada Akta', '${r.aktaTidak}', Icons.pending_actions_rounded, const Color(0xFFF59E0B)),
                ],
              ),
              const SizedBox(height: 14),
              _buildSectionCard(
                title: 'Catatan Kematian Ibu & Anak',
                icon: Icons.heart_broken_rounded,
                color: const Color(0xFFDC2626),
                stats: [
                  _StatItem('Ibu Meninggal', '${r.ibuMeninggal}', Icons.warning_amber_rounded, const Color(0xFFDC2626)),
                  _StatItem('Bayi Meninggal (L)', '${r.bayiMeninggalL}', Icons.heart_broken_rounded, const Color(0xFF6366F1)),
                  _StatItem('Bayi Meninggal (P)', '${r.bayiMeninggalP}', Icons.heart_broken_rounded, const Color(0xFFEC4899)),
                  _StatItem('Balita Meninggal', '${r.balitaMeninggal}', Icons.sick_rounded, const Color(0xFFB91C1C)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF92400E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data statistik di atas otomatis terkalkulasi dari form Rekap Ibu & Anak Dasawisma.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF92400E), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── HELPER WIDGETS ──

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<_StatItem> stats,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: stats.map((s) => _buildStatTile(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(_StatItem item) {
    return Container(
      width: 108,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(item.icon, size: 18, color: item.color),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w900, color: item.color),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet7Table(List<RekapRow> rows, RekapTotal? total) {
    if (rows.isEmpty) {
      return Center(
        child: Text('Belum ada data Dasawisma', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B))),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF0F766E)),
          headingTextStyle: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
          dataTextStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF0F172A)),
          columnSpacing: 12,
          horizontalMargin: 12,
          columns: const [
            DataColumn(label: Text('No')),
            DataColumn(label: Text('Nama KRT')),
            DataColumn(label: Text('Dasa Wisma')),
            DataColumn(label: Text('RT/RW')),
            DataColumn(label: Text('Desa')),
            DataColumn(label: Text('KK')),
            DataColumn(label: Text('L')),
            DataColumn(label: Text('P')),
            DataColumn(label: Text('Balita')),
            DataColumn(label: Text('PUS')),
            DataColumn(label: Text('WUS')),
            DataColumn(label: Text('Hamil')),
            DataColumn(label: Text('Menyusui')),
            DataColumn(label: Text('Lansia')),
            DataColumn(label: Text('3Buta')),
            DataColumn(label: Text('Khusus')),
            DataColumn(label: Text('Tidak Layak')),
            DataColumn(label: Text('Jamban')),
            DataColumn(label: Text('Sampah')),
            DataColumn(label: Text('SPAL')),
            DataColumn(label: Text('PDAM')),
            DataColumn(label: Text('Sumur')),
            DataColumn(label: Text('Lain')),
            DataColumn(label: Text('Beras')),
            DataColumn(label: Text('NonBeras')),
            DataColumn(label: Text('UP2K')),
            DataColumn(label: Text('Tanah')),
            DataColumn(label: Text('Industri')),
            DataColumn(label: Text('Kesling')),
          ],
          rows: [
            ...List.generate(rows.length, (i) {
              final r = rows[i];
              return DataRow(cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text(r.namaKepalaRumahTangga)),
                DataCell(Text(r.dasaWisma)),
                DataCell(Text('${r.rt}/${r.rw}')),
                DataCell(Text(r.desa)),
                DataCell(Text('${r.jumlahKk}')),
                DataCell(Text('${r.l}')),
                DataCell(Text('${r.p}')),
                DataCell(Text('${r.balitaL + r.balitaP}')),
                DataCell(Text('${r.pus}')),
                DataCell(Text('${r.wus}')),
                DataCell(Text('${r.ibuHamil}')),
                DataCell(Text('${r.ibuMenyusui}')),
                DataCell(Text('${r.lansia}')),
                DataCell(Text('${r.tigaButaL + r.tigaButaP}')),
                DataCell(Text('${r.berkebutuhanKhusus}')),
                DataCell(Text('${r.kriteriaTidakLayak}')),
                DataCell(Text('${r.punyaJamban}')),
                DataCell(Text('${r.punyaTempatSampah}')),
                DataCell(Text('${r.punyaSpal}')),
                DataCell(Text('${r.sumberAirPdam}')),
                DataCell(Text('${r.sumberAirSumur}')),
                DataCell(Text('${r.sumberAirLainnya}')),
                DataCell(Text('${r.makananBeras}')),
                DataCell(Text('${r.makananNonBeras}')),
                DataCell(Text('${r.up2k}')),
                DataCell(Text('${r.tanahPekarangan}')),
                DataCell(Text('${r.industriRumah}')),
                DataCell(Text('${r.kesehatanLingkungan}')),
              ]);
            }),
            if (total != null)
              DataRow(
                color: WidgetStateProperty.all(const Color(0xFFECFDF5)),
                cells: [
                  const DataCell(Text('')),
                  DataCell(Text('JUMLAH', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  DataCell(Text('${total.jumlahKk}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.l}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.p}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.balitaL + total.balitaP}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.pus}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.wus}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.ibuHamil}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.ibuMenyusui}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.lansia}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.tigaButaL + total.tigaButaP}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.berkebutuhanKhusus}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.kriteriaTidakLayak}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.punyaJamban}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.punyaTempatSampah}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.punyaSpal}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.sumberAirPdam}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.sumberAirSumur}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.sumberAirLainnya}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.makananBeras}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.makananNonBeras}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.up2k}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.tanahPekarangan}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.industriRumah}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                  DataCell(Text('${total.kesehatanLingkungan}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem(this.label, this.value, this.icon, this.color);
}
