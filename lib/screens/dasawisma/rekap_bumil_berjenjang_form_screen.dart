// lib/screens/dasawisma/rekap_bumil_berjenjang_form_screen.dart
// Form Isian Rekap Berjenjang Ibu Hamil & Bayi Sesuai Format Resmi Excel (RT, RW, Dusun, Desa, Kecamatan)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/rekap_bumil_berjenjang.dart';
import '../../services/rekap_bumil_berjenjang_service.dart';
import '../../widgets/kecamatan_dropdown_field.dart';

class RekapBumilBerjenjangFormScreen extends StatefulWidget {
  final String level; // 'rt', 'rw', 'dusun', 'desa', 'kecamatan'
  final RekapBumilBerjenjangItem? item;

  const RekapBumilBerjenjangFormScreen({
    super.key,
    required this.level,
    this.item,
  });

  @override
  State<RekapBumilBerjenjangFormScreen> createState() => _RekapBumilBerjenjangFormScreenState();
}

class _RekapBumilBerjenjangFormScreenState extends State<RekapBumilBerjenjangFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = RekapBumilBerjenjangService();

  static const Color _primary = Color(0xFF0D9488);
  static const Color _darkText = Color(0xFF0F172A);

  // Header controllers
  late TextEditingController _bulanCtrl;
  late TextEditingController _tahunCtrl;
  late TextEditingController _rtCtrl;
  late TextEditingController _rwCtrl;
  late TextEditingController _dusunCtrl;
  late TextEditingController _desaCtrl;
  late TextEditingController _kecCtrl;

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

  // Ibu metrics
  late TextEditingController _ibuHamilCtrl;
  late TextEditingController _ibuMelahirkanCtrl;
  late TextEditingController _ibuNifasCtrl;
  late TextEditingController _ibuMeninggalCtrl;

  // Bayi metrics
  late TextEditingController _bayiLahirLCtrl;
  late TextEditingController _bayiLahirPCtrl;
  late TextEditingController _akteAdaCtrl;
  late TextEditingController _akteTidakAdaCtrl;
  late TextEditingController _bayiMeninggalLCtrl;
  late TextEditingController _bayiMeninggalPCtrl;

  // Balita meninggal
  late TextEditingController _balitaMeninggalLCtrl;
  late TextEditingController _balitaMeninggalPCtrl;

  late TextEditingController _keteranganCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.item;

    _bulanCtrl = TextEditingController(text: d?.bulan ?? 'September');
    _tahunCtrl = TextEditingController(text: d?.tahun ?? '2026');
    _rtCtrl = TextEditingController(text: d?.rt ?? '01');
    _rwCtrl = TextEditingController(text: d?.rw ?? '05');
    _dusunCtrl = TextEditingController(text: d?.dusun ?? 'Cikunir');
    _desaCtrl = TextEditingController(text: d?.desa ?? 'Singaparna');
    _kecCtrl = TextEditingController(text: d?.kecamatan ?? 'Singaparna');

    _namaDasawismaCtrl = TextEditingController(text: d?.namaDasawisma ?? 'Mawar 01');
    _nomorRtCtrl = TextEditingController(text: d?.nomorRt ?? '01');
    _nomorRwCtrl = TextEditingController(text: d?.nomorRw ?? '05');
    _namaDusunCtrl = TextEditingController(text: d?.namaDusun ?? 'Cikunir');
    _namaDesaCtrl = TextEditingController(text: d?.namaDesa ?? 'Singaparna');

    _jumlahDusunCtrl = TextEditingController(text: d != null ? '${d.jumlahDusun}' : '4');
    _jumlahRwCtrl = TextEditingController(text: d != null ? '${d.jumlahRw}' : '5');
    _jumlahRtCtrl = TextEditingController(text: d != null ? '${d.jumlahRt}' : '12');
    _jumlahDasawismaCtrl = TextEditingController(text: d != null ? '${d.jumlahDasawisma}' : '24');

    _ibuHamilCtrl = TextEditingController(text: d != null ? '${d.ibuHamil}' : '0');
    _ibuMelahirkanCtrl = TextEditingController(text: d != null ? '${d.ibuMelahirkan}' : '0');
    _ibuNifasCtrl = TextEditingController(text: d != null ? '${d.ibuNifas}' : '0');
    _ibuMeninggalCtrl = TextEditingController(text: d != null ? '${d.ibuMeninggal}' : '0');

    _bayiLahirLCtrl = TextEditingController(text: d != null ? '${d.bayiLahirL}' : '0');
    _bayiLahirPCtrl = TextEditingController(text: d != null ? '${d.bayiLahirP}' : '0');
    _akteAdaCtrl = TextEditingController(text: d != null ? '${d.akteAda}' : '0');
    _akteTidakAdaCtrl = TextEditingController(text: d != null ? '${d.akteTidakAda}' : '0');
    _bayiMeninggalLCtrl = TextEditingController(text: d != null ? '${d.bayiMeninggalL}' : '0');
    _bayiMeninggalPCtrl = TextEditingController(text: d != null ? '${d.bayiMeninggalP}' : '0');

    _balitaMeninggalLCtrl = TextEditingController(text: d != null ? '${d.balitaMeninggalL}' : '0');
    _balitaMeninggalPCtrl = TextEditingController(text: d != null ? '${d.balitaMeninggalP}' : '0');

    _keteranganCtrl = TextEditingController(text: d?.keterangan ?? '');
  }

  @override
  void dispose() {
    _bulanCtrl.dispose();
    _tahunCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    _desaCtrl.dispose();
    _kecCtrl.dispose();

    _namaDasawismaCtrl.dispose();
    _nomorRtCtrl.dispose();
    _nomorRwCtrl.dispose();
    _namaDusunCtrl.dispose();
    _namaDesaCtrl.dispose();

    _jumlahDusunCtrl.dispose();
    _jumlahRwCtrl.dispose();
    _jumlahRtCtrl.dispose();
    _jumlahDasawismaCtrl.dispose();

    _ibuHamilCtrl.dispose();
    _ibuMelahirkanCtrl.dispose();
    _ibuNifasCtrl.dispose();
    _ibuMeninggalCtrl.dispose();

    _bayiLahirLCtrl.dispose();
    _bayiLahirPCtrl.dispose();
    _akteAdaCtrl.dispose();
    _akteTidakAdaCtrl.dispose();
    _bayiMeninggalLCtrl.dispose();
    _bayiMeninggalPCtrl.dispose();

    _balitaMeninggalLCtrl.dispose();
    _balitaMeninggalPCtrl.dispose();

    _keteranganCtrl.dispose();
    super.dispose();
  }

  String _getLevelTitle() {
    switch (widget.level) {
      case 'rt':
        return 'Tingkat PKK RT (Format 15 Kolom)';
      case 'rw':
        return 'Tingkat PKK RW (Format 16 Kolom)';
      case 'dusun':
        return 'Tingkat PKK Dusun/Lingkungan (Format 17 Kolom)';
      case 'desa':
        return 'Tingkat TP PKK Desa (Format 18 Kolom)';
      case 'kecamatan':
        return 'Tingkat TP PKK Kecamatan (Format 19 Kolom)';
      default:
        return 'Form Rekap Bumil Berjenjang';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = RekapBumilBerjenjangItem(
      id: widget.item?.id ?? 0,
      level: widget.level,
      bulan: _bulanCtrl.text.trim(),
      tahun: _tahunCtrl.text.trim(),
      rt: _rtCtrl.text.trim(),
      rw: _rwCtrl.text.trim(),
      dusun: _dusunCtrl.text.trim(),
      desa: _desaCtrl.text.trim(),
      kecamatan: _kecCtrl.text.trim(),
      namaDasawisma: _namaDasawismaCtrl.text.trim(),
      nomorRt: _nomorRtCtrl.text.trim(),
      nomorRw: _nomorRwCtrl.text.trim(),
      namaDusun: _namaDusunCtrl.text.trim(),
      namaDesa: _namaDesaCtrl.text.trim(),
      jumlahDusun: int.tryParse(_jumlahDusunCtrl.text) ?? 0,
      jumlahRw: int.tryParse(_jumlahRwCtrl.text) ?? 0,
      jumlahRt: int.tryParse(_jumlahRtCtrl.text) ?? 0,
      jumlahDasawisma: int.tryParse(_jumlahDasawismaCtrl.text) ?? 0,
      ibuHamil: int.tryParse(_ibuHamilCtrl.text) ?? 0,
      ibuMelahirkan: int.tryParse(_ibuMelahirkanCtrl.text) ?? 0,
      ibuNifas: int.tryParse(_ibuNifasCtrl.text) ?? 0,
      ibuMeninggal: int.tryParse(_ibuMeninggalCtrl.text) ?? 0,
      bayiLahirL: int.tryParse(_bayiLahirLCtrl.text) ?? 0,
      bayiLahirP: int.tryParse(_bayiLahirPCtrl.text) ?? 0,
      akteAda: int.tryParse(_akteAdaCtrl.text) ?? 0,
      akteTidakAda: int.tryParse(_akteTidakAdaCtrl.text) ?? 0,
      bayiMeninggalL: int.tryParse(_bayiMeninggalLCtrl.text) ?? 0,
      bayiMeninggalP: int.tryParse(_bayiMeninggalPCtrl.text) ?? 0,
      balitaMeninggalL: int.tryParse(_balitaMeninggalLCtrl.text) ?? 0,
      balitaMeninggalP: int.tryParse(_balitaMeninggalPCtrl.text) ?? 0,
      keterangan: _keteranganCtrl.text.trim(),
    );

    await _service.save(item);

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data berhasil disimpan!', style: GoogleFonts.plusJakartaSans()),
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
              widget.item == null ? 'Isi Form Rekap' : 'Edit Data Form',
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
          padding: const EdgeInsets.all(16),
          children: [
            // ── BAGIAN 1: IDENTITAS HEADER WILAYAH ──
            _sectionCard(
              title: 'Identitas Wilayah & Periode',
              icon: Icons.location_on_rounded,
              color: _primary,
              children: [
                Row(
                  children: [
                    Expanded(child: _textInput(_bulanCtrl, 'Bulan *', 'September')),
                    const SizedBox(width: 10),
                    Expanded(child: _textInput(_tahunCtrl, 'Tahun *', '2026')),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.level == 'rt' || widget.level == 'rw') ...[
                  Row(
                    children: [
                      Expanded(child: _textInput(_rtCtrl, 'RT', '01')),
                      const SizedBox(width: 10),
                      Expanded(child: _textInput(_rwCtrl, 'RW', '05')),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (widget.level == 'dusun' || widget.level == 'desa') ...[
                  Row(
                    children: [
                      Expanded(child: _textInput(_dusunCtrl, 'Dusun / Lingkungan', 'Cikunir')),
                      const SizedBox(width: 10),
                      Expanded(child: _textInput(_desaCtrl, 'Desa / Kelurahan', 'Singaparna')),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                KecamatanDropdownField(controller: _kecCtrl),
              ],
            ),
            const SizedBox(height: 16),

            // ── BAGIAN 2: DATA PENGENAL BARIS / ENTRI SESUAI TINGKAT ──
            _sectionCard(
              title: 'Pengenal Kolom / Wilayah Binaan',
              icon: Icons.assignment_ind_rounded,
              color: const Color(0xFF0284C7),
              children: [
                if (widget.level == 'rt') ...[
                  _textInput(_namaDasawismaCtrl, 'Nama Kelompok Dasawisma * (Kolom 2)', 'Mawar 01'),
                ] else if (widget.level == 'rw') ...[
                  Row(
                    children: [
                      Expanded(flex: 1, child: _textInput(_nomorRtCtrl, 'Nomor RT * (Kolom 2)', '01')),
                      const SizedBox(width: 10),
                      Expanded(flex: 2, child: _textInput(_namaDasawismaCtrl, 'Nama Kelompok Dasawisma * (Kolom 3)', 'Mawar 01')),
                    ],
                  ),
                ] else if (widget.level == 'dusun') ...[
                  Row(
                    children: [
                      Expanded(flex: 1, child: _textInput(_nomorRwCtrl, 'Nomor RW * (Kolom 2)', '05')),
                      const SizedBox(width: 8),
                      Expanded(flex: 1, child: _numberInput(_jumlahRtCtrl, 'Jml RT (Kolom 3)', '3')),
                      const SizedBox(width: 8),
                      Expanded(flex: 1, child: _numberInput(_jumlahDasawismaCtrl, 'Jml Dasa Wisma (Kolom 4)', '6')),
                    ],
                  ),
                ] else if (widget.level == 'desa') ...[
                  _textInput(_namaDusunCtrl, 'Nama Dusun/Lingkungan * (Kolom 2)', 'Cikunir'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _numberInput(_jumlahRwCtrl, 'Jml RW (Kolom 3)', '5')),
                      const SizedBox(width: 8),
                      Expanded(child: _numberInput(_jumlahRtCtrl, 'Jml RT (Kolom 4)', '18')),
                      const SizedBox(width: 8),
                      Expanded(child: _numberInput(_jumlahDasawismaCtrl, 'Jml Dasa Wisma (Kolom 5)', '36')),
                    ],
                  ),
                ] else if (widget.level == 'kecamatan') ...[
                  _textInput(_namaDesaCtrl, 'Nama Desa/Kelurahan * (Kolom 2)', 'Singaparna'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _numberInput(_jumlahDusunCtrl, 'Jml Dusun (Kolom 3)', '4')),
                      const SizedBox(width: 6),
                      Expanded(child: _numberInput(_jumlahRwCtrl, 'Jml RW (Kolom 4)', '12')),
                      const SizedBox(width: 6),
                      Expanded(child: _numberInput(_jumlahRtCtrl, 'Jml RT (Kolom 5)', '45')),
                      const SizedBox(width: 6),
                      Expanded(child: _numberInput(_jumlahDasawismaCtrl, 'Jml Dasa Wisma (Kolom 6)', '90')),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // ── BAGIAN 3: JUMLAH IBU ──
            _sectionCard(
              title: 'Jumlah Ibu',
              icon: Icons.pregnant_woman_rounded,
              color: const Color(0xFF8B5CF6),
              children: [
                Row(
                  children: [
                    Expanded(child: _numberInput(_ibuHamilCtrl, 'Hamil', '0')),
                    const SizedBox(width: 8),
                    Expanded(child: _numberInput(_ibuMelahirkanCtrl, 'Melahirkan', '0')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _numberInput(_ibuNifasCtrl, 'Nifas', '0')),
                    const SizedBox(width: 8),
                    Expanded(child: _numberInput(_ibuMeninggalCtrl, 'Meninggal', '0')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── BAGIAN 4: JUMLAH BAYI (LAHIR, AKTE, MENINGGAL) ──
            _sectionCard(
              title: 'Jumlah Bayi',
              icon: Icons.child_care_rounded,
              color: const Color(0xFF10B981),
              children: [
                Text('Kelahiran Bayi (L / P)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: _numberInput(_bayiLahirLCtrl, 'Lahir Laki (L)', '0')),
                    const SizedBox(width: 8),
                    Expanded(child: _numberInput(_bayiLahirPCtrl, 'Lahir Perempuan (P)', '0')),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Akte Kelahiran (Ada / Tidak Ada)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: _numberInput(_akteAdaCtrl, 'Akte Ada', '0')),
                    const SizedBox(width: 8),
                    Expanded(child: _numberInput(_akteTidakAdaCtrl, 'Akte Tidak Ada', '0')),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Kematian Bayi (L / P)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: _numberInput(_bayiMeninggalLCtrl, 'Bayi Meninggal (L)', '0')),
                    const SizedBox(width: 8),
                    Expanded(child: _numberInput(_bayiMeninggalPCtrl, 'Bayi Meninggal (P)', '0')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── BAGIAN 5: JUMLAH BALITA MENINGGAL ──
            _sectionCard(
              title: 'Jumlah Balita Meninggal',
              icon: Icons.heart_broken_rounded,
              color: const Color(0xFFEF4444),
              children: [
                Row(
                  children: [
                    Expanded(child: _numberInput(_balitaMeninggalLCtrl, 'Balita Meninggal (L)', '0')),
                    const SizedBox(width: 8),
                    Expanded(child: _numberInput(_balitaMeninggalPCtrl, 'Balita Meninggal (P)', '0')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── BAGIAN 6: KETERANGAN ──
            _sectionCard(
              title: 'Keterangan',
              icon: Icons.notes_rounded,
              color: const Color(0xFF64748B),
              children: [
                TextFormField(
                  controller: _keteranganCtrl,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  decoration: _inputDeco('Keterangan Tambahan', 'Catatan khusus di lapangan...'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── SUBMIT BUTTON ──
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                label: Text(
                  widget.item == null ? 'Simpan Baris Form' : 'Simpan Perubahan',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: _darkText),
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

  Widget _textInput(TextEditingController ctrl, String label, String hint) {
    return TextFormField(
      controller: ctrl,
      style: GoogleFonts.plusJakartaSans(fontSize: 13),
      decoration: _inputDeco(label, hint),
      validator: (v) => v == null || v.trim().isEmpty ? 'Wajib' : null,
    );
  }

  Widget _numberInput(TextEditingController ctrl, String label, String hint) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
      decoration: _inputDeco(label, hint),
    );
  }

  InputDecoration _inputDeco(String label, String hint) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 1.2)),
      );
}
