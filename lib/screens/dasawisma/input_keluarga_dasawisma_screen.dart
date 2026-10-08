// lib/screens/dasawisma/input_keluarga_dasawisma_screen.dart
// FORM INPUT DASAWISMA — 5 STEP
// Simple, cepat, mudah dipakai kader
//
// Step 1: Identitas Wilayah
// Step 2: Kepala Rumah Tangga
// Step 3: Anggota Keluarga (Agregat)
// Step 4: Kondisi Rumah
// Step 5: Kegiatan + Bumil → Kirim

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/data_keluarga_dasawisma.dart';
import '../../services/daftar_warga_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/kecamatan_dropdown_field.dart';
import '../../widgets/wilayah_otomatis.dart';

class InputKeluargaDasawismaScreen extends StatefulWidget {
  final DataKeluargaDasawisma? data;

  const InputKeluargaDasawismaScreen({super.key, this.data});

  @override
  State<InputKeluargaDasawismaScreen> createState() =>
      _InputKeluargaDasawismaScreenState();
}

class _InputKeluargaDasawismaScreenState
    extends State<InputKeluargaDasawismaScreen> {
  static const Color _primary = Color(0xFF0F4C81);
  static const Color _darkText = Color(0xFF1A2B3C);
  static const Color _muted = Color(0xFF5B6B7C);
  static const Color _bg = Color(0xFFF4F6F9);
  static const Color _border = Color(0xFFE1E7EE);

  final _formKey = GlobalKey<FormState>();
  final _service = DaftarWargaService();
  final _pageController = PageController();

  int _currentStep = 0;
  bool _isSaving = false;

  // ── STEP 1: IDENTITAS ────────────────────────────────
  final _dasaWismaCtrl = TextEditingController();
  final _rtCtrl = TextEditingController();
  final _rwCtrl = TextEditingController();
  final _dusunCtrl = TextEditingController();
  final _desaCtrl = TextEditingController();
  final _kecamatanCtrl = TextEditingController();

  // ── STEP 2: KRT ─────────────────────────────────────
  final _namaKrtCtrl = TextEditingController();
  final _nikKepalaCtrl = TextEditingController();
  final _noKkCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _jmlKkCtrl = TextEditingController(text: '1');

  // ── STEP 3: ANGGOTA (AGREGAT) ───────────────────────
  final _jmlLakiCtrl = TextEditingController(text: '0');
  final _jmlPerempuanCtrl = TextEditingController(text: '0');
  final _jmlBalitaLCtrl = TextEditingController(text: '0');
  final _jmlBalitaPCtrl = TextEditingController(text: '0');
  final _jmlPusCtrl = TextEditingController(text: '0');
  final _jmlWusCtrl = TextEditingController(text: '0');
  final _jmlBumilCtrl = TextEditingController(text: '0');
  final _jmlBusuiCtrl = TextEditingController(text: '0');
  final _jmlLansiaCtrl = TextEditingController(text: '0');
  final _jmlTigaButaLCtrl = TextEditingController(text: '0');
  final _jmlTigaButaPCtrl = TextEditingController(text: '0');

  // ── STEP 4: KONDISI RUMAH ───────────────────────────
  String _makananPokok = 'Beras';
  String _kriteriaRumah = 'Sehat';
  String _sumberAir = 'Sumur';
  bool _mempunyaiMck = true;
  bool _memilikiTempatSampah = true;
  bool _mempunyaiSpal = true;
  bool _memilikiStikerP4k = false;

  // ── STEP 5: KEGIATAN + BUMIL ────────────────────────
  bool _up2k = false;
  bool _tanahPekarangan = false;
  bool _industriRt = false;
  bool _kesehatanLingkungan = true;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    if (d != null) {
      _dasaWismaCtrl.text = d.dasaWisma;
      _rtCtrl.text = d.rt;
      _rwCtrl.text = d.rw;
      _dusunCtrl.text = d.dusun;
      _desaCtrl.text = d.desa;
      _kecamatanCtrl.text = d.kecamatan;
      _namaKrtCtrl.text = d.namaKepalaRumahTangga;
      _nikKepalaCtrl.text = d.nikKepalaKeluarga;
      _noKkCtrl.text = d.nomorKk;
      _alamatCtrl.text = d.alamat;
      _jmlKkCtrl.text = d.jumlahKk.toString();
      _jmlLakiCtrl.text = d.jumlahLakiLaki.toString();
      _jmlPerempuanCtrl.text = d.jumlahPerempuan.toString();
      _jmlBalitaLCtrl.text = d.jumlahBalitaL.toString();
      _jmlBalitaPCtrl.text = d.jumlahBalitaP.toString();
      _jmlPusCtrl.text = d.jumlahPus.toString();
      _jmlWusCtrl.text = d.jumlahWus.toString();
      _jmlBumilCtrl.text = d.jumlahIbuHamil.toString();
      _jmlBusuiCtrl.text = d.jumlahIbuMenyusui.toString();
      _jmlLansiaCtrl.text = d.jumlahLansia.toString();
      _jmlTigaButaLCtrl.text = d.jumlahTigaButaL.toString();
      _jmlTigaButaPCtrl.text = d.jumlahTigaButaP.toString();
      _makananPokok = d.makananPokok;
      _kriteriaRumah = d.kriteriaRumah;
      _sumberAir = d.sumberAir;
      _mempunyaiMck = d.mempunyaiMck;
      _memilikiTempatSampah = d.memilikiTempatSampah;
      _mempunyaiSpal = d.mempunyaiSpal;
      _memilikiStikerP4k = d.memilikiStikerP4k;
      _up2k = d.aktifitasUp2k;
      _tanahPekarangan = d.aktifitasTanahPekarangan;
      _industriRt = d.aktifitasIndustriRumahTangga;
      _kesehatanLingkungan = d.aktifitasKesehatanLingkungan;
    } else {
      // Input baru: otomatis isi Desa & Kecamatan dari akun Dasawisma
      _isiWilayahOtomatis();
    }
  }

  Future<void> _isiWilayahOtomatis() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (!mounted) return;
      if (user.desa.isNotEmpty && _desaCtrl.text.trim().isEmpty) {
        _desaCtrl.text = user.desa;
      }
      if (user.kecamatan.isNotEmpty && _kecamatanCtrl.text.trim().isEmpty) {
        _kecamatanCtrl.text = user.kecamatan;
      }
      if (user.hasWilayah) setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in [
      _dasaWismaCtrl, _rtCtrl, _rwCtrl, _dusunCtrl, _desaCtrl, _kecamatanCtrl,
      _namaKrtCtrl, _nikKepalaCtrl, _noKkCtrl, _alamatCtrl, _jmlKkCtrl,
      _jmlLakiCtrl, _jmlPerempuanCtrl, _jmlBalitaLCtrl, _jmlBalitaPCtrl,
      _jmlPusCtrl, _jmlWusCtrl, _jmlBumilCtrl, _jmlBusuiCtrl, _jmlLansiaCtrl,
      _jmlTigaButaLCtrl, _jmlTigaButaPCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int _parseInt(String v) => int.tryParse(v.trim()) ?? 0;

  // ═══════════════════════════════════════════════════════
  // VALIDASI PER STEP
  // ═══════════════════════════════════════════════════════
  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (_dasaWismaCtrl.text.trim().isEmpty) {
          _showError('Nama Dasa Wisma wajib diisi');
          return false;
        }
        if (_desaCtrl.text.trim().isEmpty) {
          _showError('Desa wajib diisi');
          return false;
        }
        if (_kecamatanCtrl.text.trim().isEmpty) {
          _showError('Kecamatan wajib diisi');
          return false;
        }
        return true;
      case 1:
        if (_namaKrtCtrl.text.trim().isEmpty) {
          _showError('Nama Kepala Rumah Tangga wajib diisi');
          return false;
        }
        return true;
      case 2:
        final l = _parseInt(_jmlLakiCtrl.text);
        final p = _parseInt(_jmlPerempuanCtrl.text);
        if (l + p == 0) {
          _showError('Minimal isi 1 anggota keluarga (Laki-laki atau Perempuan)');
          return false;
        }
        return true;
      case 3:
      case 4:
        return true;
      default:
        return true;
    }
  }

  void _showError(String msg) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _nextStep() {
    if (!_validateStep(_currentStep)) return;
    if (_currentStep < 4) {
      HapticFeedback.selectionClick();
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      HapticFeedback.selectionClick();
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  // ═══════════════════════════════════════════════════════
  // SIMPAN — KIRIM KE API
  // ═══════════════════════════════════════════════════════
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final l = _parseInt(_jmlLakiCtrl.text);
    final p = _parseInt(_jmlPerempuanCtrl.text);

    final record = DataKeluargaDasawisma(
      id: widget.data?.id ?? 0,
      dasaWisma: _dasaWismaCtrl.text.trim(),
      rt: _rtCtrl.text.trim(),
      rw: _rwCtrl.text.trim(),
      dusun: _dusunCtrl.text.trim(),
      desa: _desaCtrl.text.trim(),
      kecamatan: _kecamatanCtrl.text.trim(),
      namaKepalaRumahTangga: _namaKrtCtrl.text.trim(),
      nomorKk: _noKkCtrl.text.trim(),
      nikKepalaKeluarga: _nikKepalaCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
      jumlahLakiLaki: l,
      jumlahPerempuan: p,
      jumlahAnggota: l + p,
      jumlahKk: _parseInt(_jmlKkCtrl.text),
      jumlahBalita: _parseInt(_jmlBalitaLCtrl.text) + _parseInt(_jmlBalitaPCtrl.text),
      jumlahBalitaL: _parseInt(_jmlBalitaLCtrl.text),
      jumlahBalitaP: _parseInt(_jmlBalitaPCtrl.text),
      jumlahPus: _parseInt(_jmlPusCtrl.text),
      jumlahWus: _parseInt(_jmlWusCtrl.text),
      jumlahTigaButa: _parseInt(_jmlTigaButaLCtrl.text) + _parseInt(_jmlTigaButaPCtrl.text),
      jumlahTigaButaL: _parseInt(_jmlTigaButaLCtrl.text),
      jumlahTigaButaP: _parseInt(_jmlTigaButaPCtrl.text),
      jumlahIbuHamil: _parseInt(_jmlBumilCtrl.text),
      jumlahIbuMenyusui: _parseInt(_jmlBusuiCtrl.text),
      jumlahLansia: _parseInt(_jmlLansiaCtrl.text),
      anggotaList: widget.data?.anggotaList ?? [],
      makananPokok: _makananPokok,
      mempunyaiMck: _mempunyaiMck,
      jumlahMckSepticTank: _mempunyaiMck ? 1 : 0,
      sumberAir: _sumberAir,
      memilikiTempatSampah: _memilikiTempatSampah,
      mempunyaiSpal: _mempunyaiSpal,
      memilikiStikerP4k: _memilikiStikerP4k,
      kriteriaRumah: _kriteriaRumah,
      aktifitasUp2k: _up2k,
      jenisUsahaUp2k: '',
      aktifitasKesehatanLingkungan: _kesehatanLingkungan,
      aktifitasTanahPekarangan: _tanahPekarangan,
      aktifitasIndustriRumahTangga: _industriRt,
    );

    try {
      await _service.save(record);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Data KK terkirim ke Admin Desa — menunggu persetujuan.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal kirim: ${e.toString().replaceFirst("Exception: ", "")}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _darkText),
          onPressed: _prevStep,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.data == null ? 'Input Data Keluarga' : 'Edit Data Keluarga',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
            Text(
              'Langkah ${_currentStep + 1} dari 5',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _muted),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: _buildStepIndicator(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _stepIdentitas(),
            _stepKrt(),
            _stepAnggota(),
            _stepRumah(),
            _stepKegiatan(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════════════════════════════════════════
  // STEP INDICATOR
  // ═══════════════════════════════════════════════════════
  Widget _buildStepIndicator() {
    final titles = ['Wilayah', 'KRT', 'Anggota', 'Rumah', 'Kegiatan'];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      color: Colors.white,
      child: Row(
        children: List.generate(5, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 4 ? 6 : 0),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDone || isActive ? _primary : _border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    titles[i],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive ? _primary : _muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // STEP 1: IDENTITAS
  // ═══════════════════════════════════════════════════════
  Widget _stepIdentitas() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _stepHeader('1', 'Identitas Wilayah', 'Tentukan lokasi dasawisma', Icons.location_on_rounded),
        const SizedBox(height: 16),
        WilayahOtomatisBanner(desa: _desaCtrl.text, kecamatan: _kecamatanCtrl.text),
        _field(_dasaWismaCtrl, 'Nama Dasa Wisma *', 'Contoh: Mawar 01', Icons.holiday_village_outlined),
        _twoField(_rtCtrl, 'RT', '01', _rwCtrl, 'RW', '05'),
        _field(_dusunCtrl, 'Dusun / Lingkungan', 'Nama dusun', Icons.landscape_outlined),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: DesaTerkunciField(controller: _desaCtrl)),
            const SizedBox(width: 10),
            Expanded(
              child: KecamatanDropdownField(
                controller: _kecamatanCtrl,
                enabled: false,
                lockedHint: 'Otomatis dari akun',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // STEP 2: KRT
  // ═══════════════════════════════════════════════════════
  Widget _stepKrt() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _stepHeader('2', 'Kepala Rumah Tangga', 'Data KRT', Icons.person_rounded),
        const SizedBox(height: 16),
        _field(_namaKrtCtrl, 'Nama Kepala Rumah Tangga *', 'Nama lengkap', Icons.badge_outlined),
        _field(_nikKepalaCtrl, 'NIK Kepala Keluarga', '16 digit', Icons.credit_card_outlined, isNumber: true),
        _field(_noKkCtrl, 'Nomor Kartu Keluarga', '16 digit', Icons.credit_card_rounded, isNumber: true),
        _field(_jmlKkCtrl, 'Jumlah KK dalam rumah ini', '1', Icons.home_outlined, isNumber: true),
        _field(_alamatCtrl, 'Alamat', 'Nama jalan / gang', Icons.map_outlined),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // STEP 3: ANGGOTA (AGREGAT)
  // ═══════════════════════════════════════════════════════
  Widget _stepAnggota() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _stepHeader('3', 'Anggota Keluarga', 'Isi jumlah agregat', Icons.people_rounded),
        const SizedBox(height: 16),
        _sectionLabel('Kategori Umum'),
        _twoField(_jmlLakiCtrl, 'Laki-laki *', '0', _jmlPerempuanCtrl, 'Perempuan *', '0'),
        const SizedBox(height: 14),
        _sectionLabel('Kategori Khusus'),
        _twoField(_jmlBalitaLCtrl, 'Balita L', '0', _jmlBalitaPCtrl, 'Balita P', '0'),
        _twoField(_jmlPusCtrl, 'PUS', '0', _jmlWusCtrl, 'WUS', '0'),
        _twoField(_jmlBumilCtrl, 'Ibu Hamil', '0', _jmlBusuiCtrl, 'Ibu Menyusui', '0'),
        _twoField(_jmlLansiaCtrl, 'Lansia', '0', _jmlTigaButaLCtrl, '3 Buta L', '0'),
        _field(_jmlTigaButaPCtrl, '3 Buta Perempuan', '0', Icons.visibility_off_outlined, isNumber: true),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // STEP 4: RUMAH
  // ═══════════════════════════════════════════════════════
  Widget _stepRumah() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _stepHeader('4', 'Kondisi Rumah', 'Kriteria & fasilitas', Icons.home_work_rounded),
        const SizedBox(height: 16),
        _sectionLabel('Makanan Pokok'),
        _pills(['Beras', 'Non Beras'], _makananPokok, (v) => setState(() => _makananPokok = v)),
        const SizedBox(height: 14),
        _sectionLabel('Kriteria Rumah'),
        _pills(['Sehat', 'Kurang Sehat'], _kriteriaRumah, (v) => setState(() => _kriteriaRumah = v)),
        const SizedBox(height: 14),
        _sectionLabel('Sumber Air'),
        _pills(['PDAM', 'Sumur', 'Sungai', 'Lainnya'], _sumberAir, (v) => setState(() => _sumberAir = v)),
        const SizedBox(height: 14),
        _sectionLabel('Fasilitas Rumah'),
        _switchTile('Mempunyai MCK & Septik Tank', _mempunyaiMck, (v) => setState(() => _mempunyaiMck = v)),
        _switchTile('Memiliki Tempat Sampah', _memilikiTempatSampah, (v) => setState(() => _memilikiTempatSampah = v)),
        _switchTile('Mempunyai SPAL', _mempunyaiSpal, (v) => setState(() => _mempunyaiSpal = v)),
        _switchTile('Memiliki Stiker P4K', _memilikiStikerP4k, (v) => setState(() => _memilikiStikerP4k = v)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // STEP 5: KEGIATAN
  // ═══════════════════════════════════════════════════════
  Widget _stepKegiatan() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _stepHeader('5', 'Kegiatan Warga', 'Pilih kegiatan yang diikuti', Icons.diversity_3_rounded),
        const SizedBox(height: 16),
        _switchTile('UP2K (Usaha Peningkatan Pendapatan Keluarga)', _up2k, (v) => setState(() => _up2k = v)),
        _switchTile('Tanah Pekarangan', _tanahPekarangan, (v) => setState(() => _tanahPekarangan = v)),
        _switchTile('Industri Rumah Tangga', _industriRt, (v) => setState(() => _industriRt = v)),
        _switchTile('Kesehatan Lingkungan', _kesehatanLingkungan, (v) => setState(() => _kesehatanLingkungan = v)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: _primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Setelah dikirim, data akan ditinjau Admin Desa. Kalau disetujui, akan masuk ke rekap Data Umum PKK.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // BOTTOM NAV
  // ═══════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    final isLast = _currentStep == 4;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: _border),
                ),
                child: Text('Kembali', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: _darkText)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : (isLast ? _submit : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      isLast ? 'Kirim ke Desa' : 'Lanjut',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // WIDGET HELPERS
  // ═══════════════════════════════════════════════════════
  Widget _stepHeader(String num, String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(num, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          Icon(icon, color: Colors.white70, size: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: _muted)),
  );

  Widget _field(TextEditingController ctrl, String label, String hint, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: _primary),
          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: _muted),
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _twoField(TextEditingController a, String la, String ha, TextEditingController b, String lb, String hb) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: _field(a, la, ha, Icons.numbers_rounded, isNumber: true)),
          const SizedBox(width: 10),
          Expanded(child: _field(b, lb, hb, Icons.numbers_rounded, isNumber: true)),
        ],
      ),
    );
  }

  Widget _pills(List<String> options, String selected, ValueChanged<String> onSelect) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: options.map((o) {
        final sel = selected == o;
        return GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); onSelect(o); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: sel ? _primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? _primary : _border),
            ),
            child: Text(o, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF475569))),
          ),
        );
      }).toList(),
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? _primary.withValues(alpha: 0.4) : _border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: _darkText))),
          Switch(
            value: value,
            onChanged: (v) { HapticFeedback.selectionClick(); onChanged(v); },
            activeThumbColor: Colors.white,
            activeTrackColor: _primary,
          ),
        ],
      ),
    );
  }
}