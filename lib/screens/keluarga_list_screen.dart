import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/keluarga.dart';
import '../services/keluarga_service.dart';
import 'keluarga_form_screen.dart';
import 'rekap_ibu_anak_list_screen.dart';
import 'rekap_ibu_anak_form_screen.dart';
import 'data_keluarga_dasawisma_list_screen.dart';
import 'data_keluarga_dasawisma_form_screen.dart';

class KeluargaListScreen extends StatefulWidget {
  final bool embedded;
  final int initialIndex;

  const KeluargaListScreen({
    super.key,
    this.embedded = false,
    this.initialIndex = 0,
  });

  @override
  State<KeluargaListScreen> createState() => _KeluargaListScreenState();
}

class _KeluargaListScreenState extends State<KeluargaListScreen> {
  final _service = KeluargaService();
  final _searchController = TextEditingController();
  late Future<List<Keluarga>> _future;

  // 0 = Daftar Warga (KK), 1 = Data Dasawisma, 2 = Ibu & Anak
  late int _subTabIndex;

  @override
  void initState() {
    super.initState();
    _subTabIndex = widget.initialIndex;
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getAll(query: _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({Keluarga? keluarga}) async {
    HapticFeedback.selectionClick();
    if (_subTabIndex == 0) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => KeluargaFormScreen(keluarga: keluarga)),
      );
      if (result == true) _reload();
    } else if (_subTabIndex == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DataKeluargaDasawismaFormScreen()),
      );
      if (result == true) _reload();
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RekapIbuAnakFormScreen()),
      );
      if (result == true) _reload();
    }
  }

  Future<void> _confirmDelete(Keluarga k) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hapus Data Warga?',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data kepala keluarga "${k.namaKepalaKeluarga}"? Data ini tidak dapat dipulihkan.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: const Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.delete(k.id);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data "${k.namaKepalaKeluarga}" berhasil dihapus'),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showDetailSheet(Keluarga k) {
    HapticFeedback.lightImpact();
    final hasLocation = k.latitude != null && k.longitude != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header Rincian
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.family_restroom_rounded,
                      color: Color(0xFF0D9488),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          k.namaKepalaKeluarga,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No. KTP/KK: ${k.noKtpKk.isNotEmpty ? k.noKtpKk : "-"}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF1F5F9), height: 1),

            // Isi Detail Scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Informasi Kependudukan
                    _buildSectionHeader(Icons.badge_outlined, 'Identitas & Kependudukan'),
                    const SizedBox(height: 10),
                    _buildDetailRow('No. Registrasi', k.noRegistrasi.isNotEmpty ? k.noRegistrasi : '-'),
                    _buildDetailRow('Nama Kepala Keluarga', k.namaKepalaKeluarga),
                    _buildDetailRow('No. KTP / NIK', k.noKtpKk.isNotEmpty ? k.noKtpKk : '-'),
                    _buildDetailRow('Jenis Kelamin', k.jenisKelamin),
                    _buildDetailRow('Tempat, Tanggal Lahir', '${k.tempatLahir}, ${k.tanggalLahir}'),
                    _buildDetailRow('Status Perkawinan', k.statusPerkawinan),
                    _buildDetailRow('Status Dalam Keluarga', k.statusDalamKeluarga),
                    _buildDetailRow('Agama', k.agama),
                    _buildDetailRow('Pendidikan', k.pendidikan),
                    _buildDetailRow('Pekerjaan', k.pekerjaan),

                    const SizedBox(height: 20),
                    // Section 2: Domisili & Dasawisma
                    _buildSectionHeader(Icons.holiday_village_outlined, 'Domisili & Wilayah Binaan'),
                    const SizedBox(height: 10),
                    _buildDetailRow('Dasawisma', k.dasaWisma),
                    _buildDetailRow('Kepala Rumah Tangga', k.namaKepalaRumahTangga.isNotEmpty ? k.namaKepalaRumahTangga : '-'),
                    _buildDetailRow('Alamat Lengkap', k.alamat),
                    _buildDetailRow('Wilayah RT / RW', 'RT ${k.rt} / RW ${k.rw}'),
                    _buildDetailRow('Desa / Kelurahan', k.desa),
                    _buildDetailRow('Kecamatan', k.kecamatan),
                    _buildDetailRow('Kabupaten', k.kabupaten),
                    if (hasLocation)
                      _buildDetailRow('Koordinat GPS', '${k.latitude!.toStringAsFixed(5)}, ${k.longitude!.toStringAsFixed(5)}'),

                    const SizedBox(height: 20),
                    // Section 3: Program & Kegiatan PKK
                    _buildSectionHeader(Icons.volunteer_activism_outlined, 'Program Sosial & Kesehatan PKK'),
                    const SizedBox(height: 10),
                    _buildDetailRow('Jumlah Anggota Keluarga', '${k.jumlahAnggota} Jiwa'),
                    _buildDetailRow('Akseptor KB', k.akseptorKb ? 'Ya (${k.jenisAkseptorKb})' : 'Tidak'),
                    _buildDetailRow('Aktif Kegiatan Posyandu', k.aktifPosyandu ? 'Ya (${k.frekuensiPosyandu}x/bln)' : 'Tidak'),
                    _buildDetailRow('Mengikuti BKB', k.mengikutiBkb ? 'Ya' : 'Tidak'),
                    _buildDetailRow('Memiliki Tabungan', k.memilikiTabungan ? 'Ya' : 'Tidak'),
                    _buildDetailRow('Mengikuti Koperasi', k.mengikutiKoperasi ? 'Ya (${k.jenisKoperasi})' : 'Tidak'),
                    _buildDetailRow('Mengikuti PAUD', k.mengikutiPaud ? 'Ya' : 'Tidak'),
                    _buildDetailRow('Kelompok Belajar', k.mengikutiKelompokBelajar ? 'Ya (${k.jenisKelompokBelajar})' : 'Tidak'),

                    const SizedBox(height: 28),
                    // Action Buttons (Edit & Hapus)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _confirmDelete(k);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            label: Text(
                              'Hapus',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _openForm(keluarga: k);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: Text(
                              'Ubah Data',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D9488)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _appBarTitle {
    switch (_subTabIndex) {
      case 0:
        return 'Daftar Warga (KK)';
      case 1:
        return 'Data Dasawisma';
      case 2:
        return 'Data Ibu & Anak';
      default:
        return 'Data Keluarga';
    }
  }

  String get _fabLabel {
    switch (_subTabIndex) {
      case 0:
        return 'Tambah Warga';
      case 1:
        return 'Catat Dasawisma';
      case 2:
        return 'Catat Ibu & Anak';
      default:
        return 'Tambah Data';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _appBarTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Pencatatan Keluarga TP PKK Kab. Tasikmalaya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0D9488)),
                  onPressed: _reload,
                ),
                const SizedBox(width: 4),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_data_main_3tabs',
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF0F172A), // Dark obsidian navy matching modern UI
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          _fabLabel,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          if (widget.embedded)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menu Data PKK',
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

          // ── SEGMENTED 3-SUB-TAB TOGGLE (Ultra Modern Pill) ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _buildSubTabItem(0, 'Daftar Warga', Icons.people_alt_rounded, primary),
                _buildSubTabItem(1, 'Dasawisma', Icons.holiday_village_rounded, primary),
                _buildSubTabItem(2, 'Ibu & Anak', Icons.child_care_rounded, primary),
              ],
            ),
          ),

          // ── TAB CONTENT ──
          Expanded(
            child: IndexedStack(
              index: _subTabIndex,
              children: [
                // SUB-TAB 0: DAFTAR WARGA (KK)
                Column(
                  children: [
                    // Search Field (Pill Modern)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: const Color(0xFF0F172A),
                          ),
                          onChanged: (_) => _reload(),
                          decoration: InputDecoration(
                            hintText: 'Cari nama KK, NIK, alamat, RT/RW...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: Color(0xFF94A3B8),
                            ),
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
                        ),
                      ),
                    ),

                    // List of Warga
                    Expanded(
                      child: FutureBuilder<List<Keluarga>>(
                        future: _future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF0D9488),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Gagal memuat data: ${snapshot.error}',
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFFDC2626)),
                              ),
                            );
                          }

                          final list = snapshot.data ?? [];

                          if (list.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.group_off_rounded,
                                      size: 48,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Belum Ada Data Warga',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Mulai catat keluarga & warga binaan PKK',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  ElevatedButton.icon(
                                    onPressed: () => _openForm(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D9488),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    icon: const Icon(Icons.add_rounded, size: 18),
                                    label: Text(
                                      'Tambah Warga',
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Quick Summary Metrics Bar
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: [
                                      _SummaryMetricChip(
                                        icon: Icons.people_alt_rounded,
                                        label: '${list.length} KK Terdaftar',
                                        color: const Color(0xFF0D9488),
                                        bgColor: const Color(0xFFECFDF5),
                                      ),
                                      const SizedBox(width: 8),
                                      _SummaryMetricChip(
                                        icon: Icons.family_restroom_rounded,
                                        label: '${list.fold<int>(0, (prev, e) => prev + e.jumlahAnggota)} Jiwa',
                                        color: const Color(0xFF2563EB),
                                        bgColor: const Color(0xFFEFF6FF),
                                      ),
                                      const SizedBox(width: 8),
                                      _SummaryMetricChip(
                                        icon: Icons.medication_rounded,
                                        label: '${list.where((e) => e.akseptorKb).length} Akseptor KB',
                                        color: const Color(0xFF059669),
                                        bgColor: const Color(0xFFF0FDF4),
                                      ),
                                      const SizedBox(width: 8),
                                      _SummaryMetricChip(
                                        icon: Icons.location_on_rounded,
                                        label: '${list.where((e) => e.latitude != null && e.longitude != null).length} Lokasi GPS',
                                        color: const Color(0xFF7C3AED),
                                        bgColor: const Color(0xFFF5F3FF),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // List Cards
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () async => _reload(),
                                  color: const Color(0xFF0D9488),
                                  child: ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final k = list[index];
                                      final hasLocation = k.latitude != null && k.longitude != null;

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(18),
                                            onTap: () => _showDetailSheet(k),
                                            child: Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Header Kartu
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: 44,
                                                        height: 44,
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                                                          borderRadius: BorderRadius.circular(14),
                                                        ),
                                                        child: const Icon(
                                                          Icons.family_restroom_rounded,
                                                          color: Color(0xFF0D9488),
                                                          size: 22,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    k.namaKepalaKeluarga,
                                                                    style: GoogleFonts.plusJakartaSans(
                                                                      fontWeight: FontWeight.w800,
                                                                      fontSize: 15.5,
                                                                      color: const Color(0xFF0F172A),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                                                  decoration: BoxDecoration(
                                                                    color: const Color(0xFFF1F5F9),
                                                                    borderRadius: BorderRadius.circular(6),
                                                                  ),
                                                                  child: Text(
                                                                    k.dasaWisma,
                                                                    style: GoogleFonts.plusJakartaSans(
                                                                      fontSize: 11,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: const Color(0xFF475569),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 3),
                                                            Row(
                                                              children: [
                                                                const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                                                                const SizedBox(width: 3),
                                                                Expanded(
                                                                  child: Text(
                                                                    '${k.alamat} • RT ${k.rt}/RW ${k.rw}',
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: GoogleFonts.plusJakartaSans(
                                                                      fontSize: 12,
                                                                      color: const Color(0xFF64748B),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 10),
                                                  Container(height: 1, color: const Color(0xFFF1F5F9)),
                                                  const SizedBox(height: 10),

                                                  // Badges Informasi Data Keluarga
                                                  Wrap(
                                                    spacing: 6,
                                                    runSpacing: 6,
                                                    children: [
                                                      _Chip(
                                                        icon: Icons.badge_outlined,
                                                        text: k.noKtpKk.isNotEmpty ? 'NIK: ${k.noKtpKk}' : 'NIK: -',
                                                        color: const Color(0xFF0D9488),
                                                        bgColor: const Color(0xFFECFDF5),
                                                      ),
                                                      _Chip(
                                                        icon: Icons.work_outline_rounded,
                                                        text: k.pekerjaan,
                                                        color: const Color(0xFF475569),
                                                        bgColor: const Color(0xFFF1F5F9),
                                                      ),
                                                      _Chip(
                                                        icon: Icons.group_outlined,
                                                        text: '${k.jumlahAnggota} Jiwa',
                                                        color: const Color(0xFF7C3AED),
                                                        bgColor: const Color(0xFFF5F3FF),
                                                      ),
                                                      if (k.akseptorKb)
                                                        _Chip(
                                                          icon: Icons.medication_outlined,
                                                          text: 'KB: ${k.jenisAkseptorKb.isNotEmpty ? k.jenisAkseptorKb : "Ya"}',
                                                          color: const Color(0xFF059669),
                                                          bgColor: const Color(0xFFECFDF5),
                                                        ),
                                                      if (k.aktifPosyandu)
                                                        _Chip(
                                                          icon: Icons.favorite_border_rounded,
                                                          text: 'Posyandu Aktif',
                                                          color: const Color(0xFFE11D48),
                                                          bgColor: const Color(0xFFFFF1F2),
                                                        ),
                                                      if (hasLocation)
                                                        _Chip(
                                                          icon: Icons.location_on_rounded,
                                                          text: 'Titik GPS',
                                                          color: const Color(0xFF0284C7),
                                                          bgColor: const Color(0xFFF0F9FF),
                                                        ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 10),
                                                  // Quick Action Footer Row
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Sentuh untuk rincian lengkap',
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontSize: 11.5,
                                                          color: const Color(0xFF94A3B8),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () => _openForm(keluarga: k),
                                                            child: Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFFF1F5F9),
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  const Icon(Icons.edit_rounded, size: 13, color: Color(0xFF475569)),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    'Ubah',
                                                                    style: GoogleFonts.plusJakartaSans(
                                                                      fontSize: 11.5,
                                                                      fontWeight: FontWeight.w700,
                                                                      color: const Color(0xFF475569),
                                                                    ),
                                                                  ),
                                                                ],
                                                             ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 6),
                                                          GestureDetector(
                                                            onTap: () => _confirmDelete(k),
                                                            child: Container(
                                                              padding: const EdgeInsets.all(5),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFFFEF2F2),
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: const Icon(
                                                                Icons.delete_outline_rounded,
                                                                size: 15,
                                                                color: Color(0xFFDC2626),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // SUB-TAB 1: DATA KELUARGA DASAWISMA
                const DataKeluargaDasawismaListScreen(embedded: true),

                // SUB-TAB 2: REKAP IBU & ANAK DASA WISMA
                const RekapIbuAnakListScreen(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabItem(int index, String title, IconData icon, Color primary) {
    final isSelected = _subTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _subTabIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? primary : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? primary : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _SummaryMetricChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color bgColor;
  final IconData? icon;

  const _Chip({
    required this.text,
    required this.color,
    required this.bgColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
