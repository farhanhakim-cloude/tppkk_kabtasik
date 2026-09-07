// lib/screens/kriteria_rumah_form_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kriteria_rumah.dart';
import '../services/kriteria_rumah_service.dart';

class KriteriaRumahFormScreen extends StatefulWidget {
  final KriteriaRumah? existing;
  const KriteriaRumahFormScreen({super.key, this.existing});

  @override
  State<KriteriaRumahFormScreen> createState() => _KriteriaRumahFormScreenState();
}

class _KriteriaRumahFormScreenState extends State<KriteriaRumahFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KriteriaRumahService();
  bool _isSaving = false;

  // Identitas controllers
  final _namaCtrl = TextEditingController();
  final _noKkCtrl = TextEditingController();
  final _rtCtrl = TextEditingController();
  final _rwCtrl = TextEditingController();
  final _desaCtrl = TextEditingController();
  final _kecCtrl = TextEditingController();
  final _kabCtrl = TextEditingController();
  final _dasaCtrl = TextEditingController();
  final _tglCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();

  // ── LAYAK HUNI ────────────────────────────────────────
  bool _strukturAmanKokoh = false;
  bool _atapTidakBocor = false;
  bool _lantaiPadat = false;
  bool _dindingKokoh = false;
  bool _luasMinimalPerOrang = false;
  bool _ketinggianRuangCukup = false;
  bool _airMinumTerlindungi = false;
  bool _sanitasiLayak = false;
  bool _pencahayaanVentilasi = false;
  bool _legalitasTanah = false;

  // ── TIDAK LAYAK HUNI ──────────────────────────────────
  bool _luasDiBawah9m2 = false;
  bool _konstruksiBuruk = false;
  bool _sirkulasiUdaraKurang = false;
  bool _kurangPencahayaanAlami = false;
  bool _kelembapanTinggi = false;
  bool _sanitasiBuruk = false;
  bool _sulitAirBersih = false;
  bool _lokasiMembahayakan = false;

  @override
  void initState() {
    super.initState();
    final d = widget.existing;
    if (d != null) {
      _namaCtrl.text = d.namaKepalaKeluarga;
      _noKkCtrl.text = d.noKk;
      _rtCtrl.text = d.rt;
      _rwCtrl.text = d.rw;
      _desaCtrl.text = d.desa;
      _kecCtrl.text = d.kecamatan;
      _kabCtrl.text = d.kabupaten;
      _dasaCtrl.text = d.dasaWisma;
      _tglCtrl.text = d.tanggalPenilaian;
      _catatanCtrl.text = d.catatan;
      _strukturAmanKokoh = d.strukturAmanKokoh;
      _atapTidakBocor = d.atapTidakBocor;
      _lantaiPadat = d.lantaiPadat;
      _dindingKokoh = d.dindingKokoh;
      _luasMinimalPerOrang = d.luasMinimalPerOrang;
      _ketinggianRuangCukup = d.ketinggianRuangCukup;
      _airMinumTerlindungi = d.airMinumTerlindungi;
      _sanitasiLayak = d.sanitasiLayak;
      _pencahayaanVentilasi = d.pencahayaanVentilasi;
      _legalitasTanah = d.legalitasTanah;
      _luasDiBawah9m2 = d.luasDiBawah9m2;
      _konstruksiBuruk = d.konstruksiBuruk;
      _sirkulasiUdaraKurang = d.sirkulasiUdaraKurang;
      _kurangPencahayaanAlami = d.kurangPencahayaanAlami;
      _kelembapanTinggi = d.kelembapanTinggi;
      _sanitasiBuruk = d.sanitasiBuruk;
      _sulitAirBersih = d.sulitAirBersih;
      _lokasiMembahayakan = d.lokasiMembahayakan;
    } else {
      _tglCtrl.text = _fmtDate(DateTime.now());
      _kabCtrl.text = 'Kabupaten Tasikmalaya';
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  @override
  void dispose() {
    for (final c in [
      _namaCtrl, _noKkCtrl, _rtCtrl, _rwCtrl, _desaCtrl,
      _kecCtrl, _kabCtrl, _dasaCtrl, _tglCtrl, _catatanCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2099),
    );
    if (picked != null) {
      _tglCtrl.text = _fmtDate(picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = KriteriaRumah(
      id: widget.existing?.id ?? '',
      namaKepalaKeluarga: _namaCtrl.text.trim(),
      noKk: _noKkCtrl.text.trim(),
      rt: _rtCtrl.text.trim(),
      rw: _rwCtrl.text.trim(),
      desa: _desaCtrl.text.trim(),
      kecamatan: _kecCtrl.text.trim(),
      kabupaten: _kabCtrl.text.trim(),
      dasaWisma: _dasaCtrl.text.trim(),
      tanggalPenilaian: _tglCtrl.text.trim(),
      strukturAmanKokoh: _strukturAmanKokoh,
      atapTidakBocor: _atapTidakBocor,
      lantaiPadat: _lantaiPadat,
      dindingKokoh: _dindingKokoh,
      luasMinimalPerOrang: _luasMinimalPerOrang,
      ketinggianRuangCukup: _ketinggianRuangCukup,
      airMinumTerlindungi: _airMinumTerlindungi,
      sanitasiLayak: _sanitasiLayak,
      pencahayaanVentilasi: _pencahayaanVentilasi,
      legalitasTanah: _legalitasTanah,
      luasDiBawah9m2: _luasDiBawah9m2,
      konstruksiBuruk: _konstruksiBuruk,
      sirkulasiUdaraKurang: _sirkulasiUdaraKurang,
      kurangPencahayaanAlami: _kurangPencahayaanAlami,
      kelembapanTinggi: _kelembapanTinggi,
      sanitasiBuruk: _sanitasiBuruk,
      sulitAirBersih: _sulitAirBersih,
      lokasiMembahayakan: _lokasiMembahayakan,
      catatan: _catatanCtrl.text.trim(),
    );
    await _service.save(data);
    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existing == null ? 'Penilaian Kriteria Rumah' : 'Edit Penilaian Rumah',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF1F5F9)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            // ── INFO HEADER ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Formulir Penilaian Rumah',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Kriteria layak huni & tidak layak huni\n(Kementerian PUPR / Kemensos RI)',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── IDENTITAS KELUARGA ─────────────────────────
            _SectionHeader(title: 'Identitas Keluarga', icon: Icons.badge_rounded, color: primary),
            const SizedBox(height: 10),
            _buildTextField(_namaCtrl, 'Nama Kepala Keluarga *', Icons.person_rounded, required: true),
            _buildTextField(_noKkCtrl, 'No. KK', Icons.credit_card_rounded),
            _buildTextField(_dasaCtrl, 'Dasa Wisma', Icons.holiday_village_rounded),
            Row(
              children: [
                Expanded(child: _buildTextField(_rtCtrl, 'RT *', Icons.location_on_rounded, required: true)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(_rwCtrl, 'RW *', Icons.location_on_rounded, required: true)),
              ],
            ),
            _buildTextField(_desaCtrl, 'Desa/Kelurahan', Icons.apartment_rounded),
            _buildTextField(_kecCtrl, 'Kecamatan', Icons.map_rounded),
            _buildTextField(_kabCtrl, 'Kabupaten/Kota', Icons.location_city_rounded),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: _buildTextField(
                  _tglCtrl,
                  'Tanggal Penilaian *',
                  Icons.calendar_today_rounded,
                  required: true,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── KRITERIA LAYAK HUNI ─────────────────────────
            _SectionHeader(
              title: 'A. Kriteria Rumah LAYAK HUNI',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF059669),
              subtitle: 'Centang semua kondisi yang TERPENUHI di rumah ini',
            ),
            const SizedBox(height: 4),
            _SubSectionLabel(
              label: '1. Ketahanan Bangunan (Keselamatan)',
              color: const Color(0xFF059669),
            ),
            _CheckTile(
              value: _strukturAmanKokoh,
              label: 'Struktur bangunan aman & kokoh (tidak membahayakan)',
              onChanged: (v) => setState(() => _strukturAmanKokoh = v!),
              activeColor: const Color(0xFF059669),
            ),
            _CheckTile(
              value: _atapTidakBocor,
              label: 'Atap tidak bocor (genteng / seng / beton)',
              onChanged: (v) => setState(() => _atapTidakBocor = v!),
              activeColor: const Color(0xFF059669),
            ),
            _CheckTile(
              value: _lantaiPadat,
              label: 'Lantai padat & aman (ubin / semen / keramik / kayu/papan)',
              onChanged: (v) => setState(() => _lantaiPadat = v!),
              activeColor: const Color(0xFF059669),
            ),
            _CheckTile(
              value: _dindingKokoh,
              label: 'Dinding kokoh & tidak lapuk (tembok / plesteran / kayu)',
              onChanged: (v) => setState(() => _dindingKokoh = v!),
              activeColor: const Color(0xFF059669),
            ),
            _SubSectionLabel(
              label: '2. Kecukupan Luas (Kenyamanan)',
              color: const Color(0xFF059669),
            ),
            _CheckTile(
              value: _luasMinimalPerOrang,
              label: 'Luas minimal tempat tinggal ≥ 7,2 m² per orang',
              onChanged: (v) => setState(() => _luasMinimalPerOrang = v!),
              activeColor: const Color(0xFF059669),
            ),
            _CheckTile(
              value: _ketinggianRuangCukup,
              label: 'Ketinggian ruang ≥ 2,8 m (sirkulasi udara baik)',
              onChanged: (v) => setState(() => _ketinggianRuangCukup = v!),
              activeColor: const Color(0xFF059669),
            ),
            _SubSectionLabel(
              label: '3. Akses Air Minum & Sanitasi (Kesehatan)',
              color: const Color(0xFF059669),
            ),
            _CheckTile(
              value: _airMinumTerlindungi,
              label: 'Akses mudah ke sumber air minum terlindungi & berkelanjutan',
              onChanged: (v) => setState(() => _airMinumTerlindungi = v!),
              activeColor: const Color(0xFF059669),
            ),
            _CheckTile(
              value: _sanitasiLayak,
              label: 'Memiliki jamban/toilet dengan septic tank (tidak mencemari)',
              onChanged: (v) => setState(() => _sanitasiLayak = v!),
              activeColor: const Color(0xFF059669),
            ),
            _SubSectionLabel(
              label: '4. Kesehatan Lingkungan Rumah',
              color: const Color(0xFF059669),
            ),
            _CheckTile(
              value: _pencahayaanVentilasi,
              label: 'Jendela/bukaan cukup untuk cahaya matahari & sirkulasi udara',
              onChanged: (v) => setState(() => _pencahayaanVentilasi = v!),
              activeColor: const Color(0xFF059669),
            ),
            _SubSectionLabel(
              label: '5. Legalitas Kepemilikan',
              color: const Color(0xFF059669),
            ),
            _CheckTile(
              value: _legalitasTanah,
              label: 'Dibangun di atas tanah legal dengan surat kepemilikan sah',
              onChanged: (v) => setState(() => _legalitasTanah = v!),
              activeColor: const Color(0xFF059669),
            ),
            const SizedBox(height: 16),

            // ── KRITERIA TIDAK LAYAK HUNI ──────────────────
            _SectionHeader(
              title: 'B. Kriteria Rumah TIDAK LAYAK HUNI',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFDC2626),
              subtitle: 'Centang kondisi yang DIALAMI di rumah ini (Kemensos RI)',
            ),
            const SizedBox(height: 4),
            _CheckTile(
              value: _luasDiBawah9m2,
              label: '1. Luas ruangan < 9 m² per orang',
              onChanged: (v) => setState(() => _luasDiBawah9m2 = v!),
              activeColor: const Color(0xFFDC2626),
              isWarning: true,
            ),
            _CheckTile(
              value: _konstruksiBuruk,
              label: '2. Konstruksi bangunan buruk / membahayakan penghuni',
              onChanged: (v) => setState(() => _konstruksiBuruk = v!),
              activeColor: const Color(0xFFDC2626),
              isWarning: true,
            ),
            _CheckTile(
              value: _sirkulasiUdaraKurang,
              label: '3. Sistem sirkulasi udara kurang baik',
              onChanged: (v) => setState(() => _sirkulasiUdaraKurang = v!),
              activeColor: const Color(0xFFDC2626),
              isWarning: true,
            ),
            _CheckTile(
              value: _kurangPencahayaanAlami,
              label: '4. Kurang pencahayaan alami',
              onChanged: (v) => setState(() => _kurangPencahayaanAlami = v!),
              activeColor: const Color(0xFFDC2626),
              isWarning: true,
            ),
            _CheckTile(
              value: _kelembapanTinggi,
              label: '5. Tingkat kelembapan tinggi',
              onChanged: (v) => setState(() => _kelembapanTinggi = v!),
              activeColor: const Color(0xFFDC2626),
              isWarning: true,
            ),
            _CheckTile(
              value: _sanitasiBuruk,
              label: '6. Sistem sanitasi buruk (tidak ada jamban/septic tank)',
              onChanged: (v) => setState(() => _sanitasiBuruk = v!),
              activeColor: const Color(0xFFDC2626),
              isWarning: true,
            ),
            _CheckTile(
              value: _sulitAirBersih,
              label: '7. Sulit mendapat suplai air bersih / air minum yang baik',
              onChanged: (v) => setState(() => _sulitAirBersih = v!),
              activeColor: const Color(0xFFDC2626),
              isWarning: true,
            ),
            _CheckTile(
              value: _lokasiMembahayakan,
              label: '8. Lokasi berada di daerah yang membahayakan',
              onChanged: (v) => setState(() => _lokasiMembahayakan = v!),
              activeColor: const Color(0xFFDC2626),
              isWarning: true,
            ),
            const SizedBox(height: 16),

            // ── CATATAN ────────────────────────────────────
            _SectionHeader(title: 'Catatan Tambahan', icon: Icons.notes_rounded, color: primary),
            const SizedBox(height: 10),
            TextFormField(
              controller: _catatanCtrl,
              maxLines: 3,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Catatan kondisi rumah, rekomendasi, atau keterangan lain...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_rounded, color: Colors.white),
            label: Text(
              _isSaving ? 'Menyimpan...' : 'Simpan Penilaian',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[600]),
          prefixIcon: Icon(icon, size: 19, color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: color.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubSectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SubSectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 0, 4),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;
  final Color activeColor;
  final bool isWarning;

  const _CheckTile({
    required this.value,
    required this.label,
    required this.onChanged,
    required this.activeColor,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withValues(alpha: 0.07)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value ? activeColor.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        title: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: value ? FontWeight.w600 : FontWeight.w500,
            color: value
                ? (isWarning ? const Color(0xFFDC2626) : const Color(0xFF059669))
                : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}
