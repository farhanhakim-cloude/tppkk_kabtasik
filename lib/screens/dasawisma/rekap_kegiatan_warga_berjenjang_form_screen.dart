// lib/screens/dasawisma/rekap_kegiatan_warga_berjenjang_form_screen.dart
// Form Isian Rekap Berjenjang Catatan Data dan Kegiatan Warga (RT, RW, Dusun, Desa, Kecamatan)
// Sesuai format resmi Excel Gambar 1-5 dengan UI Card bersih, responsif, dan KecamatanDropdownField

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/rekap_kegiatan_warga_berjenjang.dart';
import '../../services/rekap_kegiatan_warga_berjenjang_service.dart';
import '../../widgets/kecamatan_dropdown_field.dart';

class RekapKegiatanWargaBerjenjangFormScreen extends StatefulWidget {
  final String level; // 'rt', 'rw', 'dusun', 'desa', 'kecamatan'
  final RekapKegiatanWargaBerjenjangItem? item;

  const RekapKegiatanWargaBerjenjangFormScreen({
    super.key,
    required this.level,
    this.item,
  });

  @override
  State<RekapKegiatanWargaBerjenjangFormScreen> createState() =>
      _RekapKegiatanWargaBerjenjangFormScreenState();
}

class _RekapKegiatanWargaBerjenjangFormScreenState
    extends State<RekapKegiatanWargaBerjenjangFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = RekapKegiatanWargaBerjenjangService();

  static const Color _primary = Color(0xFF0D9488);
  static const Color _darkText = Color(0xFF0F172A);

  // Header controllers
  late TextEditingController _tahunCtrl;
  late TextEditingController _rtCtrl;
  late TextEditingController _rwCtrl;
  late TextEditingController _dusunCtrl;
  late TextEditingController _desaCtrl;
  late TextEditingController _kecCtrl;
  late TextEditingController _dasaWismaCtrl;

  // Specific row controllers
  late TextEditingController _namaDasawismaCtrl;
  late TextEditingController _nomorRtCtrl;
  late TextEditingController _nomorRwCtrl;
  late TextEditingController _namaDusunCtrl;
  late TextEditingController _namaDesaCtrl;

  late TextEditingController _jumlahDusunCtrl;
  late TextEditingController _jumlahRwCtrl;
  late TextEditingController _jumlahRtCtrl;
  late TextEditingController _jumlahDasawismaCtrl;

  // KRT & KK
  late TextEditingController _jumlahKrtCtrl;
  late TextEditingController _jumlahKkCtrl;

  // Anggota Keluarga
  late TextEditingController _totalLCtrl;
  late TextEditingController _totalPCtrl;
  late TextEditingController _balitaLCtrl;
  late TextEditingController _balitaPCtrl;
  late TextEditingController _pusCtrl;
  late TextEditingController _wusCtrl;
  late TextEditingController _ibuHamilCtrl;
  late TextEditingController _ibuMenyusuiCtrl;
  late TextEditingController _lansiaCtrl;
  late TextEditingController _butaLCtrl;
  late TextEditingController _butaPCtrl;
  late TextEditingController _berkebutuhanKhususCtrl;

  // Kriteria Rumah
  late TextEditingController _rumahSehatCtrl;
  late TextEditingController _rumahTidakSehatCtrl;
  late TextEditingController _tempatSampahCtrl;
  late TextEditingController _spalCtrl;
  late TextEditingController _jambanMckCtrl;

  // Sumber Air
  late TextEditingController _airPdamCtrl;
  late TextEditingController _airSumurCtrl;
  late TextEditingController _airSungaiCtrl;
  late TextEditingController _airDllCtrl;

  // Makanan Pokok
  late TextEditingController _makananBerasCtrl;
  late TextEditingController _makananNonBerasCtrl;

  // Warga Mengikuti Kegiatan
  late TextEditingController _kegiatanUp2kCtrl;
  late TextEditingController _kegiatanPekaranganCtrl;
  late TextEditingController _kegiatanIndustriRtCtrl;
  late TextEditingController _kegiatanKeslingCtrl;

  late TextEditingController _keteranganCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final it = widget.item;

    _tahunCtrl = TextEditingController(text: it?.tahun ?? '2026');
    _rtCtrl = TextEditingController(text: it?.rt ?? '01');
    _rwCtrl = TextEditingController(text: it?.rw ?? '05');
    _dusunCtrl = TextEditingController(text: it?.dusun ?? 'Cikunir');
    _desaCtrl = TextEditingController(text: it?.desa ?? 'Singaparna');
    _kecCtrl = TextEditingController(text: it?.kecamatan ?? 'Singaparna');
    _dasaWismaCtrl = TextEditingController(text: it?.dasaWisma ?? 'Mawar 01');

    _namaDasawismaCtrl = TextEditingController(text: it?.namaDasawisma ?? 'Mawar 01');
    _nomorRtCtrl = TextEditingController(text: it?.nomorRt ?? '01');
    _nomorRwCtrl = TextEditingController(text: it?.nomorRw ?? '05');
    _namaDusunCtrl = TextEditingController(text: it?.namaDusun ?? 'Cikunir');
    _namaDesaCtrl = TextEditingController(text: it?.namaDesa ?? 'Singaparna');

    _jumlahDusunCtrl = TextEditingController(text: (it?.jumlahDusun ?? 0).toString());
    _jumlahRwCtrl = TextEditingController(text: (it?.jumlahRw ?? 0).toString());
    _jumlahRtCtrl = TextEditingController(text: (it?.jumlahRt ?? 0).toString());
    _jumlahDasawismaCtrl = TextEditingController(text: (it?.jumlahDasawisma ?? 0).toString());

    _jumlahKrtCtrl = TextEditingController(text: (it?.jumlahKrt ?? 0).toString());
    _jumlahKkCtrl = TextEditingController(text: (it?.jumlahKk ?? 0).toString());

    _totalLCtrl = TextEditingController(text: (it?.totalL ?? 0).toString());
    _totalPCtrl = TextEditingController(text: (it?.totalP ?? 0).toString());
    _balitaLCtrl = TextEditingController(text: (it?.balitaL ?? 0).toString());
    _balitaPCtrl = TextEditingController(text: (it?.balitaP ?? 0).toString());
    _pusCtrl = TextEditingController(text: (it?.pus ?? 0).toString());
    _wusCtrl = TextEditingController(text: (it?.wus ?? 0).toString());
    _ibuHamilCtrl = TextEditingController(text: (it?.ibuHamil ?? 0).toString());
    _ibuMenyusuiCtrl = TextEditingController(text: (it?.ibuMenyusui ?? 0).toString());
    _lansiaCtrl = TextEditingController(text: (it?.lansia ?? 0).toString());
    _butaLCtrl = TextEditingController(text: (it?.butaL ?? 0).toString());
    _butaPCtrl = TextEditingController(text: (it?.butaP ?? 0).toString());
    _berkebutuhanKhususCtrl = TextEditingController(text: (it?.berkebutuhanKhusus ?? 0).toString());

    _rumahSehatCtrl = TextEditingController(text: (it?.rumahSehat ?? 0).toString());
    _rumahTidakSehatCtrl = TextEditingController(text: (it?.rumahTidakSehat ?? 0).toString());
    _tempatSampahCtrl = TextEditingController(text: (it?.tempatSampah ?? 0).toString());
    _spalCtrl = TextEditingController(text: (it?.spal ?? 0).toString());
    _jambanMckCtrl = TextEditingController(text: (it?.jambanMck ?? 0).toString());

    _airPdamCtrl = TextEditingController(text: (it?.airPdam ?? 0).toString());
    _airSumurCtrl = TextEditingController(text: (it?.airSumur ?? 0).toString());
    _airSungaiCtrl = TextEditingController(text: (it?.airSungai ?? 0).toString());
    _airDllCtrl = TextEditingController(text: (it?.airDll ?? 0).toString());

    _makananBerasCtrl = TextEditingController(text: (it?.makananBeras ?? 0).toString());
    _makananNonBerasCtrl = TextEditingController(text: (it?.makananNonBeras ?? 0).toString());

    _kegiatanUp2kCtrl = TextEditingController(text: (it?.kegiatanUp2k ?? 0).toString());
    _kegiatanPekaranganCtrl = TextEditingController(text: (it?.kegiatanPekarangan ?? 0).toString());
    _kegiatanIndustriRtCtrl = TextEditingController(text: (it?.kegiatanIndustriRt ?? 0).toString());
    _kegiatanKeslingCtrl = TextEditingController(text: (it?.kegiatanKesling ?? 0).toString());

    _keteranganCtrl = TextEditingController(text: it?.keterangan ?? '');
  }

  @override
  void dispose() {
    _tahunCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    _desaCtrl.dispose();
    _kecCtrl.dispose();
    _dasaWismaCtrl.dispose();

    _namaDasawismaCtrl.dispose();
    _nomorRtCtrl.dispose();
    _nomorRwCtrl.dispose();
    _namaDusunCtrl.dispose();
    _namaDesaCtrl.dispose();

    _jumlahDusunCtrl.dispose();
    _jumlahRwCtrl.dispose();
    _jumlahRtCtrl.dispose();
    _jumlahDasawismaCtrl.dispose();

    _jumlahKrtCtrl.dispose();
    _jumlahKkCtrl.dispose();

    _totalLCtrl.dispose();
    _totalPCtrl.dispose();
    _balitaLCtrl.dispose();
    _balitaPCtrl.dispose();
    _pusCtrl.dispose();
    _wusCtrl.dispose();
    _ibuHamilCtrl.dispose();
    _ibuMenyusuiCtrl.dispose();
    _lansiaCtrl.dispose();
    _butaLCtrl.dispose();
    _butaPCtrl.dispose();
    _berkebutuhanKhususCtrl.dispose();

    _rumahSehatCtrl.dispose();
    _rumahTidakSehatCtrl.dispose();
    _tempatSampahCtrl.dispose();
    _spalCtrl.dispose();
    _jambanMckCtrl.dispose();

    _airPdamCtrl.dispose();
    _airSumurCtrl.dispose();
    _airSungaiCtrl.dispose();
    _airDllCtrl.dispose();

    _makananBerasCtrl.dispose();
    _makananNonBerasCtrl.dispose();

    _kegiatanUp2kCtrl.dispose();
    _kegiatanPekaranganCtrl.dispose();
    _kegiatanIndustriRtCtrl.dispose();
    _kegiatanKeslingCtrl.dispose();

    _keteranganCtrl.dispose();
    super.dispose();
  }

  String _getLevelTitle() {
    switch (widget.level) {
      case 'rt':
        return 'Rekapitulasi Kelompok PKK RT (Gambar 1)';
      case 'rw':
        return 'Rekapitulasi Kelompok PKK RW (Gambar 2)';
      case 'dusun':
        return 'Rekapitulasi Kelompok PKK Dusun/Lingkungan (Gambar 3)';
      case 'desa':
        return 'Rekapitulasi TP PKK Desa (Gambar 4)';
      case 'kecamatan':
        return 'Rekapitulasi TP PKK Kecamatan (Gambar 5)';
      default:
        return 'Rekap Berjenjang Kegiatan Warga';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = RekapKegiatanWargaBerjenjangItem(
      id: widget.item?.id ?? 0,
      level: widget.level,
      tahun: _tahunCtrl.text.trim(),
      rt: _rtCtrl.text.trim(),
      rw: _rwCtrl.text.trim(),
      dusun: _dusunCtrl.text.trim(),
      desa: _desaCtrl.text.trim(),
      kecamatan: _kecCtrl.text.trim(),
      dasaWisma: _dasaWismaCtrl.text.trim(),
      namaDasawisma: _namaDasawismaCtrl.text.trim(),
      nomorRt: _nomorRtCtrl.text.trim(),
      nomorRw: _nomorRwCtrl.text.trim(),
      namaDusun: _namaDusunCtrl.text.trim(),
      namaDesa: _namaDesaCtrl.text.trim(),
      jumlahDusun: int.tryParse(_jumlahDusunCtrl.text) ?? 0,
      jumlahRw: int.tryParse(_jumlahRwCtrl.text) ?? 0,
      jumlahRt: int.tryParse(_jumlahRtCtrl.text) ?? 0,
      jumlahDasawisma: int.tryParse(_jumlahDasawismaCtrl.text) ?? 0,
      jumlahKrt: int.tryParse(_jumlahKrtCtrl.text) ?? 0,
      jumlahKk: int.tryParse(_jumlahKkCtrl.text) ?? 0,
      totalL: int.tryParse(_totalLCtrl.text) ?? 0,
      totalP: int.tryParse(_totalPCtrl.text) ?? 0,
      balitaL: int.tryParse(_balitaLCtrl.text) ?? 0,
      balitaP: int.tryParse(_balitaPCtrl.text) ?? 0,
      pus: int.tryParse(_pusCtrl.text) ?? 0,
      wus: int.tryParse(_wusCtrl.text) ?? 0,
      ibuHamil: int.tryParse(_ibuHamilCtrl.text) ?? 0,
      ibuMenyusui: int.tryParse(_ibuMenyusuiCtrl.text) ?? 0,
      lansia: int.tryParse(_lansiaCtrl.text) ?? 0,
      butaL: int.tryParse(_butaLCtrl.text) ?? 0,
      butaP: int.tryParse(_butaPCtrl.text) ?? 0,
      berkebutuhanKhusus: int.tryParse(_berkebutuhanKhususCtrl.text) ?? 0,
      rumahSehat: int.tryParse(_rumahSehatCtrl.text) ?? 0,
      rumahTidakSehat: int.tryParse(_rumahTidakSehatCtrl.text) ?? 0,
      tempatSampah: int.tryParse(_tempatSampahCtrl.text) ?? 0,
      spal: int.tryParse(_spalCtrl.text) ?? 0,
      jambanMck: int.tryParse(_jambanMckCtrl.text) ?? 0,
      airPdam: int.tryParse(_airPdamCtrl.text) ?? 0,
      airSumur: int.tryParse(_airSumurCtrl.text) ?? 0,
      airSungai: int.tryParse(_airSungaiCtrl.text) ?? 0,
      airDll: int.tryParse(_airDllCtrl.text) ?? 0,
      makananBeras: int.tryParse(_makananBerasCtrl.text) ?? 0,
      makananNonBeras: int.tryParse(_makananNonBerasCtrl.text) ?? 0,
      kegiatanUp2k: int.tryParse(_kegiatanUp2kCtrl.text) ?? 0,
      kegiatanPekarangan: int.tryParse(_kegiatanPekaranganCtrl.text) ?? 0,
      kegiatanIndustriRt: int.tryParse(_kegiatanIndustriRtCtrl.text) ?? 0,
      kegiatanKesling: int.tryParse(_kegiatanKeslingCtrl.text) ?? 0,
      keterangan: _keteranganCtrl.text.trim(),
    );

    await _service.save(item);

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data rekap berhasil disimpan!', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: _darkText),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item == null ? 'Isi Form Rekap Kegiatan' : 'Edit Form Rekap Kegiatan',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: _darkText),
            ),
            Text(
              _getLevelTitle(),
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // ── CARD 1: WILAYAH ADMINISTRATIF HEADER ──
            _buildSectionCard(
              title: 'Informasi Wilayah',
              icon: Icons.location_city_rounded,
              color: const Color(0xFF0D9488),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller: _tahunCtrl,
                        label: 'Tahun',
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KecamatanDropdownField(
                        controller: _kecCtrl,
                        label: 'Kecamatan',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller: _desaCtrl,
                        label: 'Desa / Kelurahan',
                        icon: Icons.apartment_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _textField(
                        controller: _dusunCtrl,
                        label: 'Dusun / Lingkungan',
                        icon: Icons.landscape_rounded,
                      ),
                    ),
                  ],
                ),
                if (widget.level == 'rt' || widget.level == 'rw') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (widget.level == 'rt') ...[
                        Expanded(
                          child: _textField(
                            controller: _dasaWismaCtrl,
                            label: 'Dasa Wisma',
                            icon: Icons.group_work_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: _textField(
                          controller: _rtCtrl,
                          label: 'RT',
                          icon: Icons.tag_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(
                          controller: _rwCtrl,
                          label: 'RW',
                          icon: Icons.tag_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // ── CARD 2: PENGISIAN BARIS DATA SESUAI TINGKAT ──
            _buildSectionCard(
              title: 'Entitas Baris Rekapitulasi (${widget.level.toUpperCase()})',
              icon: Icons.table_chart_rounded,
              color: const Color(0xFF0284C7),
              children: [
                if (widget.level == 'rt') ...[
                  _textField(
                    controller: _namaDasawismaCtrl,
                    label: 'Nama DasaWisma (Kolom 2)',
                    hint: 'Contoh: Mawar 01',
                    icon: Icons.holiday_village_rounded,
                    required: true,
                  ),
                ] else if (widget.level == 'rw') ...[
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          controller: _nomorRtCtrl,
                          label: 'Nomor RT (Kolom 2)',
                          hint: '01',
                          icon: Icons.tag_rounded,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          controller: _jumlahDasawismaCtrl,
                          label: 'Jml Dasa Wisma (Kolom 3)',
                          icon: Icons.groups_rounded,
                        ),
                      ),
                    ],
                  ),
                ] else if (widget.level == 'dusun') ...[
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          controller: _nomorRwCtrl,
                          label: 'Nomor RW (Kolom 2)',
                          hint: '05',
                          icon: Icons.tag_rounded,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          controller: _jumlahRtCtrl,
                          label: 'Jumlah RT (Kolom 3)',
                          icon: Icons.format_list_numbered_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    controller: _jumlahDasawismaCtrl,
                    label: 'Jumlah Dasa Wisma (Kolom 4)',
                    icon: Icons.groups_rounded,
                  ),
                ] else if (widget.level == 'desa') ...[
                  _textField(
                    controller: _namaDusunCtrl,
                    label: 'Nama Dusun / Lingkungan (Kolom 2)',
                    hint: 'Contoh: Cikunir',
                    icon: Icons.landscape_rounded,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          controller: _jumlahRwCtrl,
                          label: 'Jml RW (Kolom 3)',
                          icon: Icons.format_list_numbered_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          controller: _jumlahRtCtrl,
                          label: 'Jml RT (Kolom 4)',
                          icon: Icons.tag_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          controller: _jumlahDasawismaCtrl,
                          label: 'Jml Dasa Wisma (Kolom 5)',
                          icon: Icons.groups_rounded,
                        ),
                      ),
                    ],
                  ),
                ] else if (widget.level == 'kecamatan') ...[
                  _textField(
                    controller: _namaDesaCtrl,
                    label: 'Nama Desa (Kolom 2)',
                    hint: 'Contoh: Singaparna',
                    icon: Icons.apartment_rounded,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          controller: _jumlahDusunCtrl,
                          label: 'Jml Dusun (Kolom 3)',
                          icon: Icons.landscape_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          controller: _jumlahRwCtrl,
                          label: 'Jml RW (Kolom 4)',
                          icon: Icons.format_list_numbered_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          controller: _jumlahRtCtrl,
                          label: 'Jml RT (Kolom 5)',
                          icon: Icons.tag_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          controller: _jumlahDasawismaCtrl,
                          label: 'Jml Dasa Wisma (Kolom 6)',
                          icon: Icons.groups_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // ── CARD 3: JUMLAH KRT & JUMLAH KK ──
            _buildSectionCard(
              title: 'Jumlah KRT & KK',
              icon: Icons.home_rounded,
              color: const Color(0xFFF59E0B),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _jumlahKrtCtrl,
                        label: 'Jumlah KRT',
                        icon: Icons.home_work_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _jumlahKkCtrl,
                        label: 'Jumlah KK',
                        icon: Icons.badge_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── CARD 4: JUMLAH ANGGOTA KELUARGA ──
            _buildSectionCard(
              title: 'Jumlah Anggota Keluarga',
              icon: Icons.family_restroom_rounded,
              color: const Color(0xFF6366F1),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _totalLCtrl,
                        label: 'Total Laki-laki',
                        icon: Icons.male_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _totalPCtrl,
                        label: 'Total Perempuan',
                        icon: Icons.female_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _balitaLCtrl,
                        label: 'Balita Laki-laki',
                        icon: Icons.child_care_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _balitaPCtrl,
                        label: 'Balita Perempuan',
                        icon: Icons.child_care_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _pusCtrl,
                        label: 'PUS',
                        icon: Icons.people_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _wusCtrl,
                        label: 'WUS',
                        icon: Icons.female_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _ibuHamilCtrl,
                        label: 'Ibu Hamil',
                        icon: Icons.pregnant_woman_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _ibuMenyusuiCtrl,
                        label: 'Ibu Menyusui',
                        icon: Icons.water_drop_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _lansiaCtrl,
                        label: 'Lansia',
                        icon: Icons.elderly_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _berkebutuhanKhususCtrl,
                        label: 'Berkebutuhan Khusus',
                        icon: Icons.accessible_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _butaLCtrl,
                        label: '3 Buta (L)',
                        icon: Icons.visibility_off_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _butaPCtrl,
                        label: '3 Buta (P)',
                        icon: Icons.visibility_off_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── CARD 5: KRITERIA RUMAH ──
            _buildSectionCard(
              title: 'Kriteria Rumah',
              icon: Icons.apartment_rounded,
              color: const Color(0xFF10B981),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _rumahSehatCtrl,
                        label: 'Sehat / Layak Huni',
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _rumahTidakSehatCtrl,
                        label: 'Tdk Sehat / Layak',
                        icon: Icons.cancel_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _tempatSampahCtrl,
                        label: 'Tempat Sampah',
                        icon: Icons.delete_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _spalCtrl,
                        label: 'SPAL / Penyerapan',
                        icon: Icons.waves_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _numberField(
                  controller: _jambanMckCtrl,
                  label: 'Sarana MCK & Septic Tank',
                  icon: Icons.sanitizer_rounded,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── CARD 6: SUMBER AIR KELUARGA ──
            _buildSectionCard(
              title: 'Sumber Air Keluarga',
              icon: Icons.water_drop_rounded,
              color: const Color(0xFF38BDF8),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _airPdamCtrl,
                        label: 'PDAM',
                        icon: Icons.water_damage_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _airSumurCtrl,
                        label: 'Sumur',
                        icon: Icons.water_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _airSungaiCtrl,
                        label: 'Sungai',
                        icon: Icons.tsunami_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _airDllCtrl,
                        label: 'Lainnya (DLL)',
                        icon: Icons.more_horiz_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── CARD 7: MAKANAN POKOK ──
            _buildSectionCard(
              title: 'Makanan Pokok',
              icon: Icons.restaurant_rounded,
              color: const Color(0xFFEC4899),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _makananBerasCtrl,
                        label: 'Pokok Beras',
                        icon: Icons.rice_bowl_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _makananNonBerasCtrl,
                        label: 'Non Beras',
                        icon: Icons.bakery_dining_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── CARD 8: WARGA MENGIKUTI KEGIATAN ──
            _buildSectionCard(
              title: 'Warga Mengikuti Kegiatan',
              icon: Icons.diversity_3_rounded,
              color: const Color(0xFF8B5CF6),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _kegiatanUp2kCtrl,
                        label: 'UP2K',
                        icon: Icons.storefront_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _kegiatanPekaranganCtrl,
                        label: 'Tanah Pekarangan',
                        icon: Icons.yard_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _kegiatanIndustriRtCtrl,
                        label: 'Industri RT',
                        icon: Icons.precision_manufacturing_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _kegiatanKeslingCtrl,
                        label: 'Kesling',
                        icon: Icons.health_and_safety_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── CARD 9: KETERANGAN ──
            _buildSectionCard(
              title: 'Keterangan Tambahan',
              icon: Icons.notes_rounded,
              color: const Color(0xFF64748B),
              children: [
                _textField(
                  controller: _keteranganCtrl,
                  label: 'Keterangan',
                  hint: 'Catatan kondisi warga atau rekapitulasi...',
                  icon: Icons.edit_note_rounded,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: Text(
                  _saving ? 'Menyimpan Data...' : 'Simpan Data Rekapitulasi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _darkText),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null
          : null,
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: _darkText),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }
}
