// lib/screens/dasawisma/data_umum_pkk_form_screen.dart
// Form Input / Edit Data Umum PKK untuk Tingkat Desa (20 Kolom) & Kecamatan (21 Kolom)
// Sesuai format excel resmi lampiran dengan UI modern, responsif, dan KecamatanDropdownField

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/data_umum_pkk.dart';
import '../../services/data_umum_pkk_service.dart';
import '../../widgets/kecamatan_dropdown_field.dart';

class DataUmumPkkFormScreen extends StatefulWidget {
  final String level; // 'desa' atau 'kecamatan'
  final DataUmumPkkItem? item;

  const DataUmumPkkFormScreen({
    super.key,
    required this.level,
    this.item,
  });

  @override
  State<DataUmumPkkFormScreen> createState() => _DataUmumPkkFormScreenState();
}

class _DataUmumPkkFormScreenState extends State<DataUmumPkkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = DataUmumPkkService();

  static const Color _primary = Color(0xFF0D9488);
  static const Color _darkText = Color(0xFF0F172A);

  // Controllers Header
  late TextEditingController _tahunCtrl;
  late TextEditingController _kabCtrl;
  late TextEditingController _provCtrl;
  late TextEditingController _kecCtrl;
  late TextEditingController _desaCtrl;

  // Controller Kolom 2 (Pengenal)
  late TextEditingController _namaDusunCtrl;
  late TextEditingController _namaDesaCtrl;

  // Controllers Jumlah Kelompok / Wilayah
  late TextEditingController _jumlahDusunCtrl;
  late TextEditingController _jumlahPkkRwCtrl;
  late TextEditingController _jumlahPkkRtCtrl;
  late TextEditingController _jumlahDasaWismaCtrl;

  // Controllers KRT & KK
  late TextEditingController _jumlahKrtCtrl;
  late TextEditingController _jumlahKkCtrl;

  // Controllers Jiwa
  late TextEditingController _jiwaLCtrl;
  late TextEditingController _jiwaPCtrl;

  // Controllers Kader TP PKK
  late TextEditingController _kaderTpPkkLCtrl;
  late TextEditingController _kaderTpPkkPCtrl;

  // Controllers Kader Umum
  late TextEditingController _kaderUmumLCtrl;
  late TextEditingController _kaderUmumPCtrl;

  // Controllers Kader Khusus
  late TextEditingController _kaderKhususLCtrl;
  late TextEditingController _kaderKhususPCtrl;

  // Controllers Tenaga Sekretariat
  late TextEditingController _sekretariatHonorerLCtrl;
  late TextEditingController _sekretariatHonorerPCtrl;
  late TextEditingController _sekretariatBantuanLCtrl;
  late TextEditingController _sekretariatBantuanPCtrl;

  // Controller Keterangan
  late TextEditingController _keteranganCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final it = widget.item;

    _tahunCtrl = TextEditingController(text: it?.tahun ?? '2026');
    _kabCtrl = TextEditingController(text: it?.kabupaten ?? 'TASIKMALAYA');
    _provCtrl = TextEditingController(text: it?.provinsi ?? 'JAWA BARAT');
    _kecCtrl = TextEditingController(text: it?.kecamatan ?? 'Singaparna');
    _desaCtrl = TextEditingController(text: it?.desa ?? 'Singaparna');

    _namaDusunCtrl = TextEditingController(text: it?.namaDusun ?? '');
    _namaDesaCtrl = TextEditingController(text: it?.namaDesa ?? '');

    _jumlahDusunCtrl = TextEditingController(text: (it?.jumlahDusun ?? 0).toString());
    _jumlahPkkRwCtrl = TextEditingController(text: (it?.jumlahPkkRw ?? 0).toString());
    _jumlahPkkRtCtrl = TextEditingController(text: (it?.jumlahPkkRt ?? 0).toString());
    _jumlahDasaWismaCtrl = TextEditingController(text: (it?.jumlahDasaWisma ?? 0).toString());

    _jumlahKrtCtrl = TextEditingController(text: (it?.jumlahKrt ?? 0).toString());
    _jumlahKkCtrl = TextEditingController(text: (it?.jumlahKk ?? 0).toString());

    _jiwaLCtrl = TextEditingController(text: (it?.jiwaL ?? 0).toString());
    _jiwaPCtrl = TextEditingController(text: (it?.jiwaP ?? 0).toString());

    _kaderTpPkkLCtrl = TextEditingController(text: (it?.kaderTpPkkL ?? 0).toString());
    _kaderTpPkkPCtrl = TextEditingController(text: (it?.kaderTpPkkP ?? 0).toString());

    _kaderUmumLCtrl = TextEditingController(text: (it?.kaderUmumL ?? 0).toString());
    _kaderUmumPCtrl = TextEditingController(text: (it?.kaderUmumP ?? 0).toString());

    _kaderKhususLCtrl = TextEditingController(text: (it?.kaderKhususL ?? 0).toString());
    _kaderKhususPCtrl = TextEditingController(text: (it?.kaderKhususP ?? 0).toString());

    _sekretariatHonorerLCtrl = TextEditingController(text: (it?.sekretariatHonorerL ?? 0).toString());
    _sekretariatHonorerPCtrl = TextEditingController(text: (it?.sekretariatHonorerP ?? 0).toString());
    _sekretariatBantuanLCtrl = TextEditingController(text: (it?.sekretariatBantuanL ?? 0).toString());
    _sekretariatBantuanPCtrl = TextEditingController(text: (it?.sekretariatBantuanP ?? 0).toString());

    _keteranganCtrl = TextEditingController(text: it?.keterangan ?? '');
  }

  @override
  void dispose() {
    _tahunCtrl.dispose();
    _kabCtrl.dispose();
    _provCtrl.dispose();
    _kecCtrl.dispose();
    _desaCtrl.dispose();
    _namaDusunCtrl.dispose();
    _namaDesaCtrl.dispose();
    _jumlahDusunCtrl.dispose();
    _jumlahPkkRwCtrl.dispose();
    _jumlahPkkRtCtrl.dispose();
    _jumlahDasaWismaCtrl.dispose();
    _jumlahKrtCtrl.dispose();
    _jumlahKkCtrl.dispose();
    _jiwaLCtrl.dispose();
    _jiwaPCtrl.dispose();
    _kaderTpPkkLCtrl.dispose();
    _kaderTpPkkPCtrl.dispose();
    _kaderUmumLCtrl.dispose();
    _kaderUmumPCtrl.dispose();
    _kaderKhususLCtrl.dispose();
    _kaderKhususPCtrl.dispose();
    _sekretariatHonorerLCtrl.dispose();
    _sekretariatHonorerPCtrl.dispose();
    _sekretariatBantuanLCtrl.dispose();
    _sekretariatBantuanPCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  int _parseInt(String v) => int.tryParse(v.trim()) ?? 0;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final item = DataUmumPkkItem(
      id: widget.item?.id ?? 0,
      level: widget.level,
      tahun: _tahunCtrl.text.trim(),
      kabupaten: _kabCtrl.text.trim(),
      provinsi: _provCtrl.text.trim(),
      kecamatan: _kecCtrl.text.trim(),
      desa: widget.level == 'desa' ? _desaCtrl.text.trim() : '',
      namaDusun: widget.level == 'desa' ? _namaDusunCtrl.text.trim() : '',
      namaDesa: widget.level == 'kecamatan' ? _namaDesaCtrl.text.trim() : '',
      jumlahDusun: widget.level == 'kecamatan' ? _parseInt(_jumlahDusunCtrl.text) : 0,
      jumlahPkkRw: _parseInt(_jumlahPkkRwCtrl.text),
      jumlahPkkRt: _parseInt(_jumlahPkkRtCtrl.text),
      jumlahDasaWisma: _parseInt(_jumlahDasaWismaCtrl.text),
      jumlahKrt: _parseInt(_jumlahKrtCtrl.text),
      jumlahKk: _parseInt(_jumlahKkCtrl.text),
      jiwaL: _parseInt(_jiwaLCtrl.text),
      jiwaP: _parseInt(_jiwaPCtrl.text),
      kaderTpPkkL: _parseInt(_kaderTpPkkLCtrl.text),
      kaderTpPkkP: _parseInt(_kaderTpPkkPCtrl.text),
      kaderUmumL: _parseInt(_kaderUmumLCtrl.text),
      kaderUmumP: _parseInt(_kaderUmumPCtrl.text),
      kaderKhususL: _parseInt(_kaderKhususLCtrl.text),
      kaderKhususP: _parseInt(_kaderKhususPCtrl.text),
      sekretariatHonorerL: _parseInt(_sekretariatHonorerLCtrl.text),
      sekretariatHonorerP: _parseInt(_sekretariatHonorerPCtrl.text),
      sekretariatBantuanL: _parseInt(_sekretariatBantuanLCtrl.text),
      sekretariatBantuanP: _parseInt(_sekretariatBantuanPCtrl.text),
      keterangan: _keteranganCtrl.text.trim(),
    );

    await _service.save(item);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.item == null
                ? 'Data Umum ${widget.level.toUpperCase()} berhasil ditambahkan!'
                : 'Data Umum berhasil diperbarui!',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesa = widget.level == 'desa';
    final title = isDesa
        ? (widget.item == null ? 'Tambah Data Umum Desa' : 'Edit Data Umum Desa')
        : (widget.item == null ? 'Tambah Data Umum Kecamatan' : 'Edit Data Umum Kecamatan');

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
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: _darkText,
              ),
            ),
            Text(
              isDesa
                  ? 'DATA UMUM PKK • TP PKK DESA (20 Kolom)'
                  : 'DATA UMUM PKK • KECAMATAN (21 Kolom)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  widget.item == null ? 'Simpan Data' : 'Simpan Perubahan',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // ── SECTION 1: HEADER WILAYAH ──
            _buildSectionCard(
              title: 'Informasi Wilayah & Tahun',
              icon: Icons.location_on_rounded,
              color: const Color(0xFF0284C7),
              children: [
                if (isDesa)
                  TextFormField(
                    controller: _desaCtrl,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600),
                    decoration: _inputDecoration('TP PKK Desa', 'Contoh: Singaparna'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                if (isDesa) const SizedBox(height: 12),
                KecamatanDropdownField(
                  value: _kecCtrl.text.isNotEmpty ? _kecCtrl.text : 'Singaparna',
                  controller: _kecCtrl,
                  onChanged: (val) {
                    if (val != null) setState(() => _kecCtrl.text = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _kabCtrl,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                        decoration: _inputDecoration('Kabupaten', 'TASIKMALAYA'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _tahunCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                        decoration: _inputDecoration('Tahun', '2026'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── SECTION 2: IDENTITAS BARIS (KOLOM 2) ──
            _buildSectionCard(
              title: isDesa
                  ? 'Kolom 2: Nama Dusun / Lingkungan / Sebutan Lainnya'
                  : 'Kolom 2: Nama Desa',
              icon: Icons.holiday_village_rounded,
              color: _primary,
              children: [
                if (isDesa)
                  TextFormField(
                    controller: _namaDusunCtrl,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputDecoration('Nama Dusun / Lingkungan', 'Contoh: Dusun Cikunir / Dusun 01'),
                    validator: (v) => v!.isEmpty ? 'Nama Dusun tidak boleh kosong' : null,
                  )
                else
                  TextFormField(
                    controller: _namaDesaCtrl,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputDecoration('Nama Desa', 'Contoh: Desa Singaparna / Desa Cintaraja'),
                    validator: (v) => v!.isEmpty ? 'Nama Desa tidak boleh kosong' : null,
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // ── SECTION 3: JUMLAH KELOMPOK / WILAYAH ──
            _buildSectionCard(
              title: 'Jumlah Kelompok PKK & Binaan',
              icon: Icons.groups_rounded,
              color: const Color(0xFF8B5CF6),
              children: [
                if (!isDesa) ...[
                  TextFormField(
                    controller: _jumlahDusunCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Kolom 3: Jumlah Dusun / Lingkungan', '0'),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _jumlahPkkRwCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 3: PKK RW' : 'Kol 4: PKK RW', '0'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _jumlahPkkRtCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 4: PKK RT' : 'Kol 5: PKK RT', '0'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _jumlahDasaWismaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(isDesa ? 'Kolom 5: Jumlah Kelompok Dasa Wisma' : 'Kolom 6: Jumlah Kelompok Dasa Wisma', '0'),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── SECTION 4: KRT, KK & JIWA ──
            _buildSectionCard(
              title: 'Jumlah KRT, KK & Jiwa Penduduk',
              icon: Icons.people_alt_rounded,
              color: const Color(0xFFEC4899),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _jumlahKrtCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 6: Jumlah KRT' : 'Kol 7: Jumlah KRT', '0'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _jumlahKkCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 7: Jumlah KK' : 'Kol 8: Jumlah KK', '0'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _jiwaLCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 8: Jiwa (L)' : 'Kol 9: Jiwa (L)', '0'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _jiwaPCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 9: Jiwa (P)' : 'Kol 10: Jiwa (P)', '0'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── SECTION 5: JUMLAH KADER ──
            _buildSectionCard(
              title: 'Jumlah Kader',
              icon: Icons.badge_rounded,
              color: const Color(0xFFF59E0B),
              children: [
                _subHeaderTitle('Anggota TP PKK'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _kaderTpPkkLCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 10: L' : 'Kol 11: L', '0'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _kaderTpPkkPCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 11: P' : 'Kol 12: P', '0'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _subHeaderTitle('Kader Umum'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _kaderUmumLCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 12: L' : 'Kol 13: L', '0'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _kaderUmumPCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 13: P' : 'Kol 14: P', '0'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _subHeaderTitle('Kader Khusus'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _kaderKhususLCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 14: L' : 'Kol 15: L', '0'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _kaderKhususPCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 15: P' : 'Kol 16: P', '0'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── SECTION 6: JUMLAH TENAGA SEKRETARIAT ──
            _buildSectionCard(
              title: 'Jumlah Tenaga Sekretariat',
              icon: Icons.work_outline_rounded,
              color: const Color(0xFF10B981),
              children: [
                _subHeaderTitle('Honorer'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sekretariatHonorerLCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 16: L' : 'Kol 17: L', '0'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _sekretariatHonorerPCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 17: P' : 'Kol 18: P', '0'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _subHeaderTitle('Bantuan'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sekretariatBantuanLCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 18: L' : 'Kol 19: L', '0'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _sekretariatBantuanPCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(isDesa ? 'Kol 19: P' : 'Kol 20: P', '0'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── SECTION 7: KETERANGAN ──
            _buildSectionCard(
              title: isDesa ? 'Kolom 20: Keterangan' : 'Kolom 21: Keterangan',
              icon: Icons.notes_rounded,
              color: const Color(0xFF64748B),
              children: [
                TextFormField(
                  controller: _keteranganCtrl,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                  decoration: _inputDecoration('Catatan / Keterangan', 'Tambahkan informasi tambahan bila ada...'),
                ),
              ],
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
        borderRadius: BorderRadius.circular(18),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: _darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _subHeaderTitle(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF94A3B8)),
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
        borderSide: const BorderSide(color: _primary, width: 1.6),
      ),
    );
  }
}
