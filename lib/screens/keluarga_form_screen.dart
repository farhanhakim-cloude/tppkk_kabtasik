import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/keluarga.dart';
import '../services/keluarga_service.dart';
import 'map_picker_screen.dart';

class KeluargaFormScreen extends StatefulWidget {
  final Keluarga? keluarga;

  const KeluargaFormScreen({super.key, this.keluarga});

  @override
  State<KeluargaFormScreen> createState() => _KeluargaFormScreenState();
}

class _KeluargaFormScreenState extends State<KeluargaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KeluargaService();
  final _picker = ImagePicker();

  // Header
  late TextEditingController _dasaWismaCtrl;
  late TextEditingController _kepalaRtCtrl;

  // 1-4
  late TextEditingController _noRegCtrl;
  late TextEditingController _noKtpCtrl;
  late TextEditingController _namaCtrl;
  late TextEditingController _jabatanCtrl;

  // 5-8
  String _jenisKelamin = 'Laki-laki';
  late TextEditingController _tempatLahirCtrl;
  late TextEditingController _tglLahirCtrl;
  String _statusPerkawinan = 'Menikah';

  // 9-10
  String _statusKeluarga = 'Kepala Rumah Tangga';
  late TextEditingController _statusAnggotaDetailCtrl;
  String _agama = 'Islam';
  late TextEditingController _agamaLainnyaCtrl;

  // 11
  late TextEditingController _alamatCtrl;
  late TextEditingController _rtCtrl;
  late TextEditingController _rwCtrl;
  late TextEditingController _desaCtrl;
  late TextEditingController _kecamatanCtrl;
  late TextEditingController _kabupatenCtrl;

  // 12-13
  String _pendidikan = 'SMA/SMK/Sederajat';
  String _pekerjaan = 'Swasta';
  late TextEditingController _pekerjaanLainnyaCtrl;
  late TextEditingController _jumlahAnggotaCtrl;

  // 14-20
  bool _akseptorKb = false;
  late TextEditingController _jenisKbCtrl;

  bool _aktifPosyandu = true;
  late TextEditingController _frekuensiPosyanduCtrl;

  bool _mengikutiBkb = false;
  bool _memilikiTabungan = true;

  bool _mengikutiPokjar = false;
  String _jenisPokjar = 'Paket C';

  bool _mengikutiPaud = false;

  bool _mengikutiKoperasi = false;
  late TextEditingController _jenisKoperasiCtrl;

  // Foto & Map
  File? _fotoRumah;
  double? _latitude;
  double? _longitude;
  bool _saving = false;
  bool get _isEdit => widget.keluarga != null;

  @override
  void initState() {
    super.initState();
    final k = widget.keluarga;
    _dasaWismaCtrl = TextEditingController(text: k?.dasaWisma ?? 'Mawar 01');
    _kepalaRtCtrl = TextEditingController(text: k?.namaKepalaRumahTangga ?? '');

    _noRegCtrl = TextEditingController(text: k?.noRegistrasi ?? '');
    _noKtpCtrl = TextEditingController(text: k?.noKtpKk ?? '');
    _namaCtrl = TextEditingController(text: k?.namaKepalaKeluarga ?? '');
    _jabatanCtrl = TextEditingController(text: k?.jabatan ?? 'Anggota');

    _jenisKelamin = k?.jenisKelamin ?? 'Laki-laki';
    _tempatLahirCtrl = TextEditingController(text: k?.tempatLahir ?? '');
    _tglLahirCtrl = TextEditingController(text: k?.tanggalLahir ?? '');
    _statusPerkawinan = k?.statusPerkawinan ?? 'Menikah';

    _statusKeluarga = k?.statusDalamKeluarga ?? 'Kepala Rumah Tangga';
    _statusAnggotaDetailCtrl = TextEditingController(text: k?.statusAnggotaDetail ?? '');
    _agama = k?.agama ?? 'Islam';
    _agamaLainnyaCtrl = TextEditingController(text: k?.agamaLainnya ?? '');

    _alamatCtrl = TextEditingController(text: k?.alamat ?? '');
    _rtCtrl = TextEditingController(text: k?.rt ?? '');
    _rwCtrl = TextEditingController(text: k?.rw ?? '');
    _desaCtrl = TextEditingController(text: k?.desa ?? 'Singaparna');
    _kecamatanCtrl = TextEditingController(text: k?.kecamatan ?? 'Singaparna');
    _kabupatenCtrl = TextEditingController(text: k?.kabupaten ?? 'Kabupaten Tasikmalaya');

    _pendidikan = k?.pendidikan ?? 'SMA/SMK/Sederajat';
    _pekerjaan = k?.pekerjaan ?? 'Swasta';
    _pekerjaanLainnyaCtrl = TextEditingController(text: k?.pekerjaan ?? '');
    _jumlahAnggotaCtrl = TextEditingController(text: k != null ? k.jumlahAnggota.toString() : '4');

    _akseptorKb = k?.akseptorKb ?? false;
    _jenisKbCtrl = TextEditingController(text: k?.jenisAkseptorKb ?? '');

    _aktifPosyandu = k?.aktifPosyandu ?? true;
    _frekuensiPosyanduCtrl = TextEditingController(text: k?.frekuensiPosyandu ?? '1');

    _mengikutiBkb = k?.mengikutiBkb ?? false;
    _memilikiTabungan = k?.memilikiTabungan ?? true;

    _mengikutiPokjar = k?.mengikutiKelompokBelajar ?? false;
    _jenisPokjar = k?.jenisKelompokBelajar ?? 'Paket C';

    _mengikutiPaud = k?.mengikutiPaud ?? false;

    _mengikutiKoperasi = k?.mengikutiKoperasi ?? false;
    _jenisKoperasiCtrl = TextEditingController(text: k?.jenisKoperasi ?? '');

    _latitude = k?.latitude;
    _longitude = k?.longitude;

    if (k?.fotoRumahPath != null) {
      _fotoRumah = File(k!.fotoRumahPath!);
    }
  }

  @override
  void dispose() {
    _dasaWismaCtrl.dispose();
    _kepalaRtCtrl.dispose();
    _noRegCtrl.dispose();
    _noKtpCtrl.dispose();
    _namaCtrl.dispose();
    _jabatanCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _tglLahirCtrl.dispose();
    _statusAnggotaDetailCtrl.dispose();
    _agamaLainnyaCtrl.dispose();
    _alamatCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _desaCtrl.dispose();
    _kecamatanCtrl.dispose();
    _kabupatenCtrl.dispose();
    _pekerjaanLainnyaCtrl.dispose();
    _jumlahAnggotaCtrl.dispose();
    _jenisKbCtrl.dispose();
    _frekuensiPosyanduCtrl.dispose();
    _jenisKoperasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text('Ambil dari Kamera', style: GoogleFonts.plusJakartaSans()),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Pilih dari Galeri', style: GoogleFonts.plusJakartaSans()),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (sumber == null) return;

    final gambar = await _picker.pickImage(source: sumber, imageQuality: 70, maxWidth: 1280);

    if (gambar != null) {
      setState(() => _fotoRumah = File(gambar.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = Keluarga(
      id: widget.keluarga?.id ?? 0,
      dasaWisma: _dasaWismaCtrl.text.trim(),
      namaKepalaRumahTangga: _kepalaRtCtrl.text.trim(),
      noRegistrasi: _noRegCtrl.text.trim(),
      noKtpKk: _noKtpCtrl.text.trim(),
      namaKepalaKeluarga: _namaCtrl.text.trim(),
      jabatan: _jabatanCtrl.text.trim(),
      jenisKelamin: _jenisKelamin,
      tempatLahir: _tempatLahirCtrl.text.trim(),
      tanggalLahir: _tglLahirCtrl.text.trim(),
      statusPerkawinan: _statusPerkawinan,
      statusDalamKeluarga: _statusKeluarga,
      statusAnggotaDetail: _statusAnggotaDetailCtrl.text.trim(),
      agama: _agama,
      agamaLainnya: _agamaLainnyaCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
      rt: _rtCtrl.text.trim(),
      rw: _rwCtrl.text.trim(),
      desa: _desaCtrl.text.trim(),
      kecamatan: _kecamatanCtrl.text.trim(),
      kabupaten: _kabupatenCtrl.text.trim(),
      pendidikan: _pendidikan,
      pekerjaan: _pekerjaan == 'Lainnya' ? _pekerjaanLainnyaCtrl.text.trim() : _pekerjaan,
      jumlahAnggota: int.tryParse(_jumlahAnggotaCtrl.text) ?? 1,
      akseptorKb: _akseptorKb,
      jenisAkseptorKb: _akseptorKb ? _jenisKbCtrl.text.trim() : '',
      aktifPosyandu: _aktifPosyandu,
      frekuensiPosyandu: _aktifPosyandu ? _frekuensiPosyanduCtrl.text.trim() : '',
      mengikutiBkb: _mengikutiBkb,
      memilikiTabungan: _memilikiTabungan,
      mengikutiKelompokBelajar: _mengikutiPokjar,
      jenisKelompokBelajar: _mengikutiPokjar ? _jenisPokjar : '',
      mengikutiPaud: _mengikutiPaud,
      mengikutiKoperasi: _mengikutiKoperasi,
      jenisKoperasi: _mengikutiKoperasi ? _jenisKoperasiCtrl.text.trim() : '',
      fotoRumahPath: _fotoRumah?.path,
      latitude: _latitude,
      longitude: _longitude,
    );

    if (_isEdit) {
      await _service.update(item);
    } else {
      await _service.add(item);
    }

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus data?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text(
          'Data warga "${widget.keluarga!.namaKepalaKeluarga}" akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: GoogleFonts.plusJakartaSans())),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _service.delete(widget.keluarga!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primary),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Data Warga TP PKK' : 'Daftar Warga TP PKK',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          if (_isEdit) IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Header Document Title
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
                      'DAFTAR WARGA TP PKK',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Formulir pendataan warga kelompok Dasa Wisma TP PKK',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── DASA WISMA HEADER ──
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _dasaWismaCtrl,
                        decoration: const InputDecoration(labelText: 'Dasa Wisma'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _kepalaRtCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Kepala Rumah Tangga'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 1 - 4: REGISTRASI & NAMA WARGA ──
              _buildSectionHeader('Identitas Warga (Poin 1-4)', Icons.badge_rounded),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _noRegCtrl,
                        decoration: const InputDecoration(labelText: '1. No. Registrasi'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noKtpCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '2. No. KTP / KK (NIK)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _namaCtrl,
                        decoration: const InputDecoration(labelText: '3. Nama Lengkap *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _jabatanCtrl,
                        decoration: const InputDecoration(labelText: '4. Jabatan di PKK (e.g. Ketua/Sekretaris/Anggota)'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 5 - 8: DATA PRIBADI ──
              _buildSectionHeader('Data Pribadi (Poin 5-8)', Icons.person_rounded),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('5. Jenis Kelamin:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Laki-laki',
                            groupValue: _jenisKelamin,
                            onChanged: (v) => setState(() => _jenisKelamin = v!),
                          ),
                          const Text('Laki-laki'),
                          const SizedBox(width: 16),
                          Radio<String>(
                            value: 'Perempuan',
                            groupValue: _jenisKelamin,
                            onChanged: (v) => setState(() => _jenisKelamin = v!),
                          ),
                          const Text('Perempuan'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tempatLahirCtrl,
                              decoration: const InputDecoration(labelText: '6. Tempat Lahir'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _tglLahirCtrl,
                              decoration: const InputDecoration(labelText: '7. Tanggal Lahir'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('8. Status Perkawinan:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['Menikah', 'Lajang', 'Janda', 'Duda'].map((st) {
                          final isSel = _statusPerkawinan == st;
                          return ChoiceChip(
                            label: Text(st),
                            selected: isSel,
                            selectedColor: primary.withValues(alpha: 0.15),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: isSel ? primary : Colors.grey[700],
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (v) {
                              if (v) setState(() => _statusPerkawinan = st);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 9 - 10: KELUARGA & AGAMA ──
              _buildSectionHeader('Status Keluarga & Agama (Poin 9-10)', Icons.nature_people_rounded),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('9. Status Dalam Keluarga:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['Kepala Rumah Tangga', 'Anggota Keluarga'].map((st) {
                          final isSel = _statusKeluarga == st;
                          return ChoiceChip(
                            label: Text(st),
                            selected: isSel,
                            selectedColor: primary.withValues(alpha: 0.15),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: isSel ? primary : Colors.grey[700],
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (v) {
                              if (v) setState(() => _statusKeluarga = st);
                            },
                          );
                        }).toList(),
                      ),
                      if (_statusKeluarga == 'Anggota Keluarga') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _statusAnggotaDetailCtrl,
                          decoration: const InputDecoration(labelText: 'Status Anggota (e.g. Istri/Anak/Orang tua)'),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text('10. Agama:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Budha', 'Konghuchu', 'Kepercayaan', 'Lain-lain'].map((ag) {
                          final isSel = _agama == ag;
                          return ChoiceChip(
                            label: Text(ag),
                            selected: isSel,
                            selectedColor: primary.withValues(alpha: 0.15),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: isSel ? primary : Colors.grey[700],
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (v) {
                              if (v) setState(() => _agama = ag);
                            },
                          );
                        }).toList(),
                      ),
                      if (_agama == 'Lain-lain') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _agamaLainnyaCtrl,
                          decoration: const InputDecoration(labelText: 'Sebutkan Agama/Kepercayaan'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── 11: ALAMAT LENGKAP ──
              _buildSectionHeader('11. Alamat Lengkap', Icons.location_on_rounded),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _alamatCtrl,
                        decoration: const InputDecoration(labelText: 'Alamat Rumah / Jalan *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rtCtrl,
                              decoration: const InputDecoration(labelText: 'RT'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _rwCtrl,
                              decoration: const InputDecoration(labelText: 'RW'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _desaCtrl,
                              decoration: const InputDecoration(labelText: 'Desa'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _kecamatanCtrl,
                              decoration: const InputDecoration(labelText: 'Kecamatan'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _kabupatenCtrl,
                        decoration: const InputDecoration(labelText: 'Kabupaten'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 12 - 13: PENDIDIKAN & PEKERJAAN ──
              _buildSectionHeader('Pendidikan & Pekerjaan (Poin 12-13)', Icons.school_rounded),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('12. Pendidikan:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          'Tidak Tamat SD',
                          'SD/MI',
                          'SMP/Sederajat',
                          'SMA/SMK/Sederajat',
                          'Diploma',
                          'S1',
                          'S2',
                          'S3',
                        ].map((p) {
                          final isSel = _pendidikan == p;
                          return ChoiceChip(
                            label: Text(p),
                            selected: isSel,
                            selectedColor: primary.withValues(alpha: 0.15),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: isSel ? primary : Colors.grey[700],
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (v) {
                              if (v) setState(() => _pendidikan = p);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text('13. Pekerjaan:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['Petani', 'Pedagang', 'Swasta', 'Wirausaha', 'PNS', 'TNI/Polri', 'Lainnya'].map((pk) {
                          final isSel = _pekerjaan == pk;
                          return ChoiceChip(
                            label: Text(pk),
                            selected: isSel,
                            selectedColor: primary.withValues(alpha: 0.15),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: isSel ? primary : Colors.grey[700],
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (v) {
                              if (v) setState(() => _pekerjaan = pk);
                            },
                          );
                        }).toList(),
                      ),
                      if (_pekerjaan == 'Lainnya') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _pekerjaanLainnyaCtrl,
                          decoration: const InputDecoration(labelText: 'Sebutkan Pekerjaan'),
                        ),
                      ],
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _jumlahAnggotaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Jumlah Anggota Keluarga (KK)'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 14 - 20: AKTIVITAS & PROGRAM PKK ──
              _buildSectionHeader('Aktivitas & Program PKK (Poin 14-20)', Icons.checklist_rtl_rounded),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 14. Akseptor KB
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('14. Akseptor KB?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _akseptorKb,
                        onChanged: (v) => setState(() => _akseptorKb = v),
                      ),
                      if (_akseptorKb)
                        TextFormField(
                          controller: _jenisKbCtrl,
                          decoration: const InputDecoration(labelText: 'Jenis Akseptor KB (e.g. Suntik/IUD/PIL/Implan)'),
                        ),
                      const Divider(),

                      // 15. Posyandu
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('15. Aktif dalam Kegiatan Posyandu?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _aktifPosyandu,
                        onChanged: (v) => setState(() => _aktifPosyandu = v),
                      ),
                      if (_aktifPosyandu)
                        TextFormField(
                          controller: _frekuensiPosyanduCtrl,
                          decoration: const InputDecoration(labelText: 'Frekuensi Volume (kali / bulan)'),
                        ),
                      const Divider(),

                      // 16. BKB
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('16. Mengikuti Program Bina Keluarga Balita (BKB)?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _mengikutiBkb,
                        onChanged: (v) => setState(() => _mengikutiBkb = v),
                      ),
                      const Divider(),

                      // 17. Tabungan
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('17. Memiliki Tabungan?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _memilikiTabungan,
                        onChanged: (v) => setState(() => _memilikiTabungan = v),
                      ),
                      const Divider(),

                      // 18. Kelompok Belajar
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('18. Mengikuti Kelompok Belajar?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _mengikutiPokjar,
                        onChanged: (v) => setState(() => _mengikutiPokjar = v),
                      ),
                      if (_mengikutiPokjar) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: ['Paket A', 'Paket B', 'Paket C', 'KF (Keaksaraan Fungsional)'].map((p) {
                            final isSel = _jenisPokjar == p;
                            return ChoiceChip(
                              label: Text(p),
                              selected: isSel,
                              selectedColor: primary.withValues(alpha: 0.15),
                              labelStyle: GoogleFonts.plusJakartaSans(
                                color: isSel ? primary : Colors.grey[700],
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                              onSelected: (v) {
                                if (v) setState(() => _jenisPokjar = p);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const Divider(),

                      // 19. PAUD
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('19. Mengikuti PAUD / sejenis?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _mengikutiPaud,
                        onChanged: (v) => setState(() => _mengikutiPaud = v),
                      ),
                      const Divider(),

                      // 20. Koperasi
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('20. Ikut dalam Kegiatan Koperasi?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        value: _mengikutiKoperasi,
                        onChanged: (v) => setState(() => _mengikutiKoperasi = v),
                      ),
                      if (_mengikutiKoperasi)
                        TextFormField(
                          controller: _jenisKoperasiCtrl,
                          decoration: const InputDecoration(labelText: 'Jenis Koperasi (e.g. Simpan Pinjam / Produksi)'),
                        ),
                    ],
                  ),
                ),
              ),

              // ── FOTO RUMAH & PETA GPS ──
              _buildSectionHeader('Foto Rumah & Peta Lokasi GPS', Icons.add_location_alt_rounded),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Foto Rumah Warga', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pilihFoto,
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _fotoRumah != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(_fotoRumah!, fit: BoxFit.cover),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black54,
                                          radius: 16,
                                          child: IconButton(
                                            icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                            onPressed: () => setState(() => _fotoRumah = null),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, color: Colors.grey[400], size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ketuk untuk ambil foto rumah',
                                      style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 13),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Peta Lokasi Rumah GPS', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.map_rounded, color: primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _latitude != null && _longitude != null ? 'Lokasi Terpilih' : 'Lokasi belum diatur',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
                                ),
                                Text(
                                  _latitude != null && _longitude != null
                                      ? 'Lat: ${_latitude!.toStringAsFixed(5)}, Lng: ${_longitude!.toStringAsFixed(5)}'
                                      : 'Ketuk tombol untuk atur lokasi di peta',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push<Map<String, double>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPickerScreen(
                                  initialLat: _latitude,
                                  initialLng: _longitude,
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                _latitude = result['lat'];
                                _longitude = result['lng'];
                              });
                            }
                          },
                          icon: const Icon(Icons.pin_drop_rounded, size: 16),
                          label: Text(
                            _latitude != null && _longitude != null ? 'Ubah Titik Peta' : 'Pilih Titik Lokasi Peta',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEdit ? 'Simpan Perubahan Warga' : 'Simpan Data Warga TP PKK',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
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
}
