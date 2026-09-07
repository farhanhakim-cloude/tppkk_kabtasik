import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/rekap_ibu_anak.dart';
import '../services/rekap_ibu_anak_service.dart';

class RekapIbuAnakFormScreen extends StatefulWidget {
  final RekapIbuAnak? item;
  const RekapIbuAnakFormScreen({super.key, this.item});

  @override
  State<RekapIbuAnakFormScreen> createState() => _RekapIbuAnakFormScreenState();
}

class _RekapIbuAnakFormScreenState extends State<RekapIbuAnakFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = RekapIbuAnakService();

  static const Color _roseRed = Color(0xFFE11D48);
  static const Color _roseBg = Color(0xFFFFE4E6);
  static const Color _roseDark = Color(0xFF9F1239);

  late TextEditingController _dasaWismaCtrl;
  late TextEditingController _rtCtrl;
  late TextEditingController _rwCtrl;
  late TextEditingController _dusunCtrl;
  late TextEditingController _desaCtrl;
  late TextEditingController _bulanCtrl;
  late TextEditingController _tahunCtrl;

  late TextEditingController _namaIbuCtrl;
  late TextEditingController _namaSuamiCtrl;
  String _statusIbu = 'Hamil';

  bool _adaKelahiran = false;
  late TextEditingController _namaBayiCtrl;
  String _jkBayi = 'L';
  late TextEditingController _tglLahirCtrl;
  bool _hasAkta = true;

  bool _adaKematian = false;
  late TextEditingController _namaMeninggalCtrl;
  String _statusMeninggal = 'Ibu';
  String _jkMeninggal = 'P';
  late TextEditingController _tglMeninggalCtrl;
  late TextEditingController _sebabMeninggalCtrl;

  late TextEditingController _keteranganCtrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _dasaWismaCtrl = TextEditingController(text: item?.kelompokDasaWisma ?? 'Mawar 01');
    _rtCtrl = TextEditingController(text: item?.rt ?? '01');
    _rwCtrl = TextEditingController(text: item?.rw ?? '02');
    _dusunCtrl = TextEditingController(text: item?.dusun ?? 'Cikunir');
    _desaCtrl = TextEditingController(text: item?.desa ?? 'Singaparna');
    _bulanCtrl = TextEditingController(text: item?.bulan ?? 'September');
    _tahunCtrl = TextEditingController(text: item?.tahun ?? '2026');

    _namaIbuCtrl = TextEditingController(text: item?.namaIbu ?? '');
    _namaSuamiCtrl = TextEditingController(text: item?.namaSuami ?? '');
    _statusIbu = item?.statusIbu ?? 'Hamil';

    _adaKelahiran = item?.adaKelahiran ?? false;
    _namaBayiCtrl = TextEditingController(text: item?.namaBayi ?? '');
    _jkBayi = item?.jenisKelaminBayi ?? 'L';
    _tglLahirCtrl = TextEditingController(text: item?.tanggalLahir ?? '');
    _hasAkta = item?.hasAktaKelahiran ?? true;

    _adaKematian = item?.adaKematian ?? false;
    _namaMeninggalCtrl = TextEditingController(text: item?.namaMeninggal ?? '');
    _statusMeninggal = item?.statusMeninggal ?? 'Ibu';
    _jkMeninggal = item?.jenisKelaminMeninggal ?? 'P';
    _tglMeninggalCtrl = TextEditingController(text: item?.tanggalMeninggal ?? '');
    _sebabMeninggalCtrl = TextEditingController(text: item?.sebabMeninggal ?? '');

    _keteranganCtrl = TextEditingController(text: item?.keterangan ?? '');
  }

  @override
  void dispose() {
    _dasaWismaCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    _desaCtrl.dispose();
    _bulanCtrl.dispose();
    _tahunCtrl.dispose();
    _namaIbuCtrl.dispose();
    _namaSuamiCtrl.dispose();
    _namaBayiCtrl.dispose();
    _tglLahirCtrl.dispose();
    _namaMeninggalCtrl.dispose();
    _tglMeninggalCtrl.dispose();
    _sebabMeninggalCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final record = RekapIbuAnak(
      id: widget.item?.id ?? 0,
      kelompokDasaWisma: _dasaWismaCtrl.text.trim(),
      rt: _rtCtrl.text.trim(),
      rw: _rwCtrl.text.trim(),
      dusun: _dusunCtrl.text.trim(),
      desa: _desaCtrl.text.trim(),
      bulan: _bulanCtrl.text.trim(),
      tahun: _tahunCtrl.text.trim(),
      namaIbu: _namaIbuCtrl.text.trim(),
      namaSuami: _namaSuamiCtrl.text.trim(),
      statusIbu: _statusIbu,
      adaKelahiran: _adaKelahiran,
      namaBayi: _adaKelahiran ? _namaBayiCtrl.text.trim() : '',
      jenisKelaminBayi: _adaKelahiran ? _jkBayi : 'L',
      tanggalLahir: _adaKelahiran ? _tglLahirCtrl.text.trim() : '',
      hasAktaKelahiran: _adaKelahiran ? _hasAkta : true,
      adaKematian: _adaKematian,
      namaMeninggal: _adaKematian ? _namaMeninggalCtrl.text.trim() : '',
      statusMeninggal: _adaKematian ? _statusMeninggal : 'Ibu',
      jenisKelaminMeninggal: _adaKematian ? _jkMeninggal : 'P',
      tanggalMeninggal: _adaKematian ? _tglMeninggalCtrl.text.trim() : '',
      sebabMeninggal: _adaKematian ? _sebabMeninggalCtrl.text.trim() : '',
      keterangan: _keteranganCtrl.text.trim(),
    );

    await _service.save(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.item == null
                ? 'Data Ibu & Anak berhasil disimpan!'
                : 'Data Ibu & Anak berhasil diperbarui!',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: const Color(0xFF0D9488),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.item == null ? 'Input Data Ibu & Anak' : 'Edit Data Ibu & Anak',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buku Catatan Ibu & Anak',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rekapitulasi Ibu Hamil, Melahirkan, Nifas, Kelahiran Bayi & Kematian Dasa Wisma',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── SECTION 1: WILAYAH / DASA WISMA ──
              _buildSectionTitle(Icons.location_on_rounded, 'Identitas Dasa Wisma / Wilayah', primary),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _dasaWismaCtrl,
                        decoration: const InputDecoration(labelText: 'Kelompok Dasa Wisma'),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rtCtrl,
                              decoration: const InputDecoration(labelText: 'PKK RT'),
                              validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _rwCtrl,
                              decoration: const InputDecoration(labelText: 'PKK RW'),
                              validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dusunCtrl,
                              decoration: const InputDecoration(labelText: 'Dusun / Lingkungan'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _desaCtrl,
                              decoration: const InputDecoration(labelText: 'Desa / Kelurahan'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _bulanCtrl,
                              decoration: const InputDecoration(labelText: 'Bulan'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _tahunCtrl,
                              decoration: const InputDecoration(labelText: 'Tahun'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── SECTION 2: DATA IBU & SUAMI ──
              _buildSectionTitle(Icons.family_restroom_rounded, 'Data Ibu & Suami (Kolom 2-4)', primary),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _namaIbuCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Ibu *',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama ibu wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _namaSuamiCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Suami *',
                          prefixIcon: Icon(Icons.person_rounded),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama suami wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Status Ibu:',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Hamil', 'Melahirkan', 'Nifas', 'Normal'].map((st) {
                          final isSelected = _statusIbu == st;
                          return ChoiceChip(
                            label: Text(st),
                            selected: isSelected,
                            selectedColor: primary.withValues(alpha: 0.15),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: isSelected ? primary : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _statusIbu = st);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── SECTION 3: CATATAN KELAHIRAN ──
              _buildSectionTitle(Icons.child_friendly_rounded, 'Catatan Kelahiran Bayi (Kolom 5-10)', primary),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Ada Kelahiran Bayi?',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        subtitle: Text(
                          'Aktifkan jika ada bayi lahir di periode ini',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600]),
                        ),
                        value: _adaKelahiran,
                        onChanged: (val) => setState(() => _adaKelahiran = val),
                      ),
                      if (_adaKelahiran) ...[
                        const Divider(),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _namaBayiCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Bayi',
                            prefixIcon: Icon(Icons.child_care_rounded),
                          ),
                          validator: (v) {
                            if (_adaKelahiran && (v == null || v.trim().isEmpty)) {
                              return 'Nama bayi wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Jenis Kelamin:',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5, fontWeight: FontWeight.w600)),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'L',
                                        groupValue: _jkBayi,
                                        onChanged: (v) => setState(() => _jkBayi = v!),
                                      ),
                                      const Text('Laki-laki'),
                                      Radio<String>(
                                        value: 'P',
                                        groupValue: _jkBayi,
                                        onChanged: (v) => setState(() => _jkBayi = v!),
                                      ),
                                      const Text('Perempuan'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _tglLahirCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Lahir (DD-MM-YYYY)',
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Memiliki Akta Kelahiran?', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600)),
                          value: _hasAkta,
                          onChanged: (val) => setState(() => _hasAkta = val),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── SECTION 4: CATATAN KEMATIAN ──
              _buildSectionTitle(Icons.sentiment_dissatisfied_rounded, 'Catatan Kematian (Kolom 11-16)', _roseRed),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Ada Catatan Kematian?',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        subtitle: Text(
                          'Aktifkan jika ada kematian ibu/bayi/balita',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600]),
                        ),
                        value: _adaKematian,
                        onChanged: (val) => setState(() => _adaKematian = val),
                      ),
                      if (_adaKematian) ...[
                        const Divider(),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _namaMeninggalCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama yang Meninggal',
                            prefixIcon: Icon(Icons.person_remove_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Status:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: ['Ibu', 'Bayi', 'Balita'].map((s) {
                            final isSel = _statusMeninggal == s;
                            return ChoiceChip(
                              label: Text(s),
                              selected: isSel,
                              selectedColor: _roseBg,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                color: isSel ? _roseDark : Colors.grey[700],
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                              onSelected: (v) {
                                if (v) setState(() => _statusMeninggal = s);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'L',
                              groupValue: _jkMeninggal,
                              onChanged: (v) => setState(() => _jkMeninggal = v!),
                            ),
                            const Text('Laki-laki'),
                            Radio<String>(
                              value: 'P',
                              groupValue: _jkMeninggal,
                              onChanged: (v) => setState(() => _jkMeninggal = v!),
                            ),
                            const Text('Perempuan'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _tglMeninggalCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Meninggal',
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _sebabMeninggalCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Sebab Meninggal',
                            prefixIcon: Icon(Icons.healing_rounded),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── SECTION 5: KETERANGAN ──
              _buildSectionTitle(Icons.notes_rounded, 'Keterangan Tambahan (Kolom 17)', primary),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _keteranganCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Catatan tambahan / kondisi khusus...',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.item == null ? 'Simpan Data Ibu & Anak' : 'Simpan Perubahan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
