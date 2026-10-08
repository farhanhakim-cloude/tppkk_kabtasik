import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/data_keluarga_dasawisma.dart';
import '../../models/dasawisma_catatan_keluarga.dart';
import '../../models/kegiatan_warga.dart';
import '../../models/pemanfaatan_tanah.dart';
import '../../models/industri_rumah_tangga.dart';
import '../../services/daftar_warga_service.dart';
import '../../services/dasawisma_catatan_keluarga_service.dart';
import '../../services/kegiatan_warga_service.dart';
import '../../services/pemanfaatan_tanah_service.dart';
import '../../services/industri_rumah_tangga_service.dart';
import '../../services/api_exception.dart' show ApiValidationException;
import '../../widgets/skeleton.dart';

// INPUT TERPADU SATU PINTU — ganti 5 tab input satuan.
// Satu layar, satu tombol Kirim:
//  1. Pilih KK (wilayah otomatis ikut dari KK terpilih)
//  2. Tambah anggota (boleh banyak, +Tambah Anggota lagi)
//  3. Centang kegiatan yang diikuti (kirim per jenis)
//  4. Pekarangan + Industri (opsional, centang bila ada)
// Sistem kirim semua POST sekaligus dan laporkan hasilnya.

class _AnggotaDraft {
  final TextEditingController namaCtrl = TextEditingController();
  final TextEditingController nikCtrl = TextEditingController();
  final TextEditingController umurCtrl = TextEditingController();
  final TextEditingController pendidikanCtrl = TextEditingController();
  final TextEditingController pekerjaanCtrl = TextEditingController();
  String jenisKelamin = 'P';
  String hubungan = 'anak';
  DateTime? tanggalLahir;

  void dispose() {
    namaCtrl.dispose();
    nikCtrl.dispose();
    umurCtrl.dispose();
    pendidikanCtrl.dispose();
    pekerjaanCtrl.dispose();
  }
}

class _KegDraft {
  final String value;
  final String label;
  bool ikut = false;
  final TextEditingController pesertaCtrl = TextEditingController();
  DateTime? tanggal;

  _KegDraft({required this.value, required this.label});

  void dispose() => pesertaCtrl.dispose();
}

class InputTerpaduScreen extends StatefulWidget {
  const InputTerpaduScreen({super.key});

  @override
  State<InputTerpaduScreen> createState() => _InputTerpaduScreenState();
}

class _InputTerpaduScreenState extends State<InputTerpaduScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kkService = DaftarWargaService();
  final _anggotaService = DasawismaCatatanKeluargaService();
  final _kegiatanService = KegiatanWargaService();
  final _tanahService = PemanfaatanTanahService();
  final _industriService = IndustriRumahTanggaService();

  static const Color _primary = Color(0xFF0072BC);
  static const Color _ink = Color(0xFF1A2B3C);
  static const Color _muted = Color(0xFF5B6B7C);
  static const Color _line = Color(0xFFE1E7EE);
  static const Color _paper = Color(0xFFF4F6F9);

  List<DataKeluargaDasawisma> _kkList = [];
  bool _kkLoading = true;
  String? _kkError;
  int? _kkId;
  DataKeluargaDasawisma? get _kkDipilih {
    for (final k in _kkList) {
      if (k.id == _kkId) return k;
    }
    return null;
  }

  final List<_AnggotaDraft> _anggota = [_AnggotaDraft()];
  late final List<_KegDraft> _kegiatans = [
    _KegDraft(value: 'up2k', label: 'UP2K'),
    _KegDraft(value: 'pekarangan', label: 'Tanah Pekarangan'),
    _KegDraft(value: 'industri', label: 'Industri RT'),
    _KegDraft(value: 'kesehatan', label: 'Kesling'),
  ];

  late final TextEditingController _dasaWismaCtrl;
  late final TextEditingController _rtCtrl;
  late final TextEditingController _rwCtrl;
  late final TextEditingController _dusunCtrl;

  bool _adaPekarangan = false;
  late final TextEditingController _jenisTanamanCtrl;
  late final TextEditingController _luasCtrl;
  late final TextEditingController _kkTanahCtrl;
  late final TextEditingController _hasilTanahCtrl;

  bool _adaIndustri = false;
  late final TextEditingController _jenisIndustriCtrl;
  late final TextEditingController _pemilikCtrl;
  late final TextEditingController _tenagaCtrl;
  late final TextEditingController _omzetCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dasaWismaCtrl = TextEditingController();
    _rtCtrl = TextEditingController();
    _rwCtrl = TextEditingController();
    _dusunCtrl = TextEditingController();
    _jenisTanamanCtrl = TextEditingController();
    _luasCtrl = TextEditingController();
    _kkTanahCtrl = TextEditingController();
    _hasilTanahCtrl = TextEditingController();
    _jenisIndustriCtrl = TextEditingController();
    _pemilikCtrl = TextEditingController();
    _tenagaCtrl = TextEditingController();
    _omzetCtrl = TextEditingController();
    _loadKk();
  }

  @override
  void dispose() {
    _dasaWismaCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    for (final a in _anggota) {
      a.dispose();
    }
    for (final k in _kegiatans) {
      k.dispose();
    }
    _jenisTanamanCtrl.dispose();
    _luasCtrl.dispose();
    _kkTanahCtrl.dispose();
    _hasilTanahCtrl.dispose();
    _jenisIndustriCtrl.dispose();
    _pemilikCtrl.dispose();
    _tenagaCtrl.dispose();
    _omzetCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadKk() async {
    setState(() {
      _kkLoading = true;
      _kkError = null;
    });
    try {
      final list = await _kkService.getAll();
      if (!mounted) return;
      setState(() {
        _kkList = list;
        _kkLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _kkLoading = false;
        _kkError = 'Gagal memuat daftar KK.';
      });
    }
  }

  void _pilihKk(int? id) {
    setState(() {
      _kkId = id;
      // Wilayah otomatis ikut dari KK terpilih (masih bisa diubah).
      final kk = _kkDipilih;
      if (kk != null) {
        _dasaWismaCtrl.text = kk.dasaWisma;
        _rtCtrl.text = kk.rt;
        _rwCtrl.text = kk.rw;
        _dusunCtrl.text = kk.dusun;
      }
    });
  }

  Future<void> _pickTanggal(_AnggotaDraft a) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          a.tanggalLahir ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        a.tanggalLahir = picked;
        final now = DateTime.now();
        var umur = now.year - picked.year;
        if (now.month < picked.month ||
            (now.month == picked.month && now.day < picked.day)) {
          umur--;
        }
        a.umurCtrl.text = '${umur < 0 ? 0 : umur}';
      });
    }
  }

  Future<void> _pickTanggalKeg(_KegDraft k) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: k.tanggal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => k.tanggal = picked);
  }

  String _err(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<void> _kirim() async {
    if (_saving) return;
    if (_kkId == null) {
      _snack('Pilih KK dulu.', ok: false);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    // Minimal 1 anggota bernama.
    final adaNama =
        _anggota.any((a) => a.namaCtrl.text.trim().isNotEmpty);
    if (!adaNama) {
      _snack('Isi minimal 1 nama anggota.', ok: false);
      return;
    }
    setState(() => _saving = true);

    var ok = 0;
    final gagal = <String>[];

    // 1. Anggota (1 POST per anggota bernama).
    for (final a in _anggota) {
      final nama = a.namaCtrl.text.trim();
      if (nama.isEmpty) continue;
      try {
        await _anggotaService.add(DasawismaCatatanKeluarga(
          id: '0',
          daftarWargaId: _kkId!,
          namaAnggota: nama,
          nik: a.nikCtrl.text.trim(),
          jenisKelamin: a.jenisKelamin,
          tanggalLahir: a.tanggalLahir,
          umur: int.tryParse(a.umurCtrl.text.trim()) ?? 0,
          hubunganKeluarga: a.hubungan,
          pendidikan: a.pendidikanCtrl.text.trim(),
          pekerjaan: a.pekerjaanCtrl.text.trim(),
        ));
        ok++;
      } on ApiValidationException catch (e) {
        gagal.add('Anggota $nama: ${e.message}');
      } catch (e) {
        gagal.add('Anggota $nama: ${_err(e)}');
      }
    }

    // 2. Kegiatan (1 POST per jenis yang dicentang).
    for (final k in _kegiatans.where((e) => e.ikut)) {
      try {
        await _kegiatanService.add(KegiatanWarga(
          id: '0',
          dasaWisma: _dasaWismaCtrl.text.trim(),
          rt: _rtCtrl.text.trim(),
          rw: _rwCtrl.text.trim(),
          dusun: _dusunCtrl.text.trim(),
          kegiatan: k.value,
          jumlahPeserta: int.tryParse(k.pesertaCtrl.text.trim()) ?? 0,
          tanggal: k.tanggal,
        ));
        ok++;
      } on ApiValidationException catch (e) {
        gagal.add('${k.label}: ${e.message}');
      } catch (e) {
        gagal.add('${k.label}: ${_err(e)}');
      }
    }

    // 3. Pekarangan (opsional).
    if (_adaPekarangan) {
      try {
        await _tanahService.add(PemanfaatanTanah(
          id: '0',
          dasaWisma: _dasaWismaCtrl.text.trim(),
          rt: _rtCtrl.text.trim(),
          rw: _rwCtrl.text.trim(),
          dusun: _dusunCtrl.text.trim(),
          jenisTanaman: _jenisTanamanCtrl.text.trim(),
          luasM2:
              double.tryParse(_luasCtrl.text.trim().replaceAll(',', '.')) ?? 0,
          jumlahKk: int.tryParse(_kkTanahCtrl.text.trim()) ?? 0,
          hasil: _hasilTanahCtrl.text.trim(),
        ));
        ok++;
      } on ApiValidationException catch (e) {
        gagal.add('Pekarangan: ${e.message}');
      } catch (e) {
        gagal.add('Pekarangan: ${_err(e)}');
      }
    }

    // 4. Industri (opsional).
    if (_adaIndustri) {
      try {
        await _industriService.add(IndustriRumahTangga(
          id: '0',
          dasaWisma: _dasaWismaCtrl.text.trim(),
          rt: _rtCtrl.text.trim(),
          rw: _rwCtrl.text.trim(),
          dusun: _dusunCtrl.text.trim(),
          jenisIndustri: _jenisIndustriCtrl.text.trim(),
          pemilik: _pemilikCtrl.text.trim(),
          jumlahTenagaKerja: int.tryParse(_tenagaCtrl.text.trim()) ?? 0,
          omzet:
              double.tryParse(_omzetCtrl.text.trim().replaceAll('.', '')) ?? 0,
        ));
        ok++;
      } on ApiValidationException catch (e) {
        gagal.add('Industri: ${e.message}');
      } catch (e) {
        gagal.add('Industri: ${_err(e)}');
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (gagal.isEmpty) {
      _snack('$ok data terkirim, menunggu persetujuan Admin Desa.', ok: true);
      Navigator.pop(context, true);
    } else if (ok > 0) {
      _snack('$ok terkirim, ${gagal.length} gagal. ${gagal.join(' ')}',
          ok: false);
      Navigator.pop(context, true);
    } else {
      _snack('Semua gagal. ${gagal.join(' ')}', ok: false);
    }
  }

  void _snack(String msg, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        backgroundColor: ok ? const Color(0xFF10B981) : Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: _ink),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Input Terpadu Satu Pintu',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
            Text('KK → Anggota → Kegiatan, kirim sekaligus',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: _muted)),
          ],
        ),
        actions: <Widget>[
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _kirim,
              child: Text('Kirim',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primary)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: <Widget>[
            _stepHeader('1', 'Pilih KK', 'Wilayah otomatis ikut dari KK'),
            const SizedBox(height: 10),
            _kkDropdown(),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                    child: _miniField(
                        ctrl: _dasaWismaCtrl,
                        label: 'Dasa Wisma',
                        icon: Icons.holiday_village_outlined)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                    child: _miniField(
                        ctrl: _rtCtrl,
                        label: 'RT',
                        icon: Icons.location_on_outlined,
                        angka: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _miniField(
                        ctrl: _rwCtrl,
                        label: 'RW',
                        icon: Icons.location_on_outlined,
                        angka: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _miniField(
                        ctrl: _dusunCtrl,
                        label: 'Dusun',
                        icon: Icons.landscape_outlined)),
              ],
            ),
            const SizedBox(height: 16),
            _stepHeader('2', 'Anggota Keluarga', 'Isi yang mau dicatat, tambah bila perlu'),
            const SizedBox(height: 10),
            for (var i = 0; i < _anggota.length; i++)
              _anggotaCard(_anggota[i], i),
            OutlinedButton.icon(
              onPressed: _saving
                  ? null
                  : () => setState(() => _anggota.add(_AnggotaDraft())),
              icon: const Icon(Icons.person_add_outlined, color: _primary),
              label: Text('Tambah Anggota Lagi',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700, color: _primary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            _stepHeader('3', 'Kegiatan Diikuti', 'Centang bila ada (boleh kosong)'),
            const SizedBox(height: 10),
            for (final k in _kegiatans) _kegiatanTile(k),
            const SizedBox(height: 16),
            _stepHeader('4', 'Pekarangan & Industri', 'Centang bila ada (boleh kosong)'),
            const SizedBox(height: 10),
            _opsionalCard(
              judul: 'Pemanfaatan Pekarangan',
              icon: Icons.grass_outlined,
              aktif: _adaPekarangan,
              onUbah: (v) => setState(() => _adaPekarangan = v),
              anak: <Widget>[
                _miniField(
                    ctrl: _jenisTanamanCtrl,
                    label: 'Jenis Tanaman',
                    hint: 'Cabai',
                    icon: Icons.yard_outlined,
                    wajib: _adaPekarangan),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: _miniField(
                            ctrl: _luasCtrl,
                            label: 'Luas (m²)',
                            icon: Icons.square_foot_outlined,
                            angka: true,
                            desimal: true)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _miniField(
                            ctrl: _kkTanahCtrl,
                            label: 'Jml KK',
                            icon: Icons.groups_outlined,
                            angka: true)),
                  ],
                ),
                const SizedBox(height: 10),
                _miniField(
                    ctrl: _hasilTanahCtrl,
                    label: 'Hasil',
                    hint: '20 kg',
                    icon: Icons.shopping_basket_outlined),
              ],
            ),
            const SizedBox(height: 10),
            _opsionalCard(
              judul: 'Industri Rumah Tangga',
              icon: Icons.storefront_outlined,
              aktif: _adaIndustri,
              onUbah: (v) => setState(() => _adaIndustri = v),
              anak: <Widget>[
                _miniField(
                    ctrl: _jenisIndustriCtrl,
                    label: 'Jenis Usaha',
                    hint: 'Kerupuk',
                    icon: Icons.precision_manufacturing_outlined,
                    wajib: _adaIndustri),
                const SizedBox(height: 10),
                _miniField(
                    ctrl: _pemilikCtrl,
                    label: 'Pemilik',
                    icon: Icons.person_outline_rounded,
                    wajib: _adaIndustri),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: _miniField(
                            ctrl: _tenagaCtrl,
                            label: 'Tenaga Kerja',
                            icon: Icons.groups_outlined,
                            angka: true)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _miniField(
                            ctrl: _omzetCtrl,
                            label: 'Omzet (Rp)',
                            icon: Icons.payments_outlined,
                            angka: true)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _kirim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text('Kirim Semua Sekaligus',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepHeader(String num, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(num,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(sub,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kkDropdown() {
    if (_kkLoading) {
      return const SkeletonForm();
    }
    if (_kkError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.error_outline_rounded,
                size: 18, color: Color(0xFFB91C1C)),
            const SizedBox(width: 8),
            Expanded(
                child: Text('Belum ada KK. Input Daftar Warga dulu di menu Data Umum.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5, color: const Color(0xFF7F1D1D)))),
            TextButton(onPressed: _loadKk, child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButtonFormField<int>(
        initialValue: _kkId,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: _muted),
        decoration: InputDecoration(
          labelText: 'Kepala Keluarga',
          prefixIcon: const Icon(Icons.home_work_outlined,
              size: 18, color: _primary),
          labelStyle:
              GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        items: _kkList
            .map((e) => DropdownMenuItem(
                  value: e.id,
                  child: Text(
                    e.namaKepalaRumahTangga.isEmpty
                        ? 'KK #${e.id}'
                        : e.namaKepalaRumahTangga,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                  ),
                ))
            .toList(),
        validator: (v) => v == null ? 'Pilih KK dulu' : null,
        onChanged: (v) => _pilihKk(v),
      ),
    );
  }

  Widget _anggotaCard(_AnggotaDraft a, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Anggota ${index + 1}',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _ink)),
              const Spacer(),
              if (_anggota.length > 1)
                IconButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() {
                            a.dispose();
                            _anggota.removeAt(index);
                          }),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _miniField(
              ctrl: a.namaCtrl, label: 'Nama', icon: Icons.person_outline_rounded),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _line),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: DropdownButtonFormField<String>(
                    initialValue: a.jenisKelamin,
                    decoration: InputDecoration(
                      labelText: 'L/P',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                    ],
                    onChanged: (v) =>
                        setState(() => a.jenisKelamin = v ?? 'P'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _line),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: DropdownButtonFormField<String>(
                    initialValue: a.hubungan,
                    decoration: InputDecoration(
                      labelText: 'Hubungan',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'kepala', child: Text('Kepala')),
                      DropdownMenuItem(value: 'istri', child: Text('Istri')),
                      DropdownMenuItem(value: 'anak', child: Text('Anak')),
                    ],
                    onChanged: (v) =>
                        setState(() => a.hubungan = v ?? 'anak'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(child: _tglLahirTile(a)),
              const SizedBox(width: 8),
              Expanded(
                  child: _miniField(
                      ctrl: a.umurCtrl,
                      label: 'Umur',
                      icon: Icons.cake_outlined,
                      angka: true)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                  child: _miniField(
                      ctrl: a.pendidikanCtrl,
                      label: 'Pendidikan',
                      icon: Icons.school_outlined)),
              const SizedBox(width: 8),
              Expanded(
                  child: _miniField(
                      ctrl: a.pekerjaanCtrl,
                      label: 'Pekerjaan',
                      icon: Icons.work_outline_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tglLahirTile(_AnggotaDraft a) {
    return InkWell(
      onTap: () => _pickTanggal(a),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: _primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                a.tanggalLahir == null
                    ? 'Tgl lahir'
                    : '${a.tanggalLahir!.day}/${a.tanggalLahir!.month}/${a.tanggalLahir!.year}',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5, color: _ink),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kegiatanTile(_KegDraft k) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: k.ikut ? _primary : _line),
      ),
      child: Column(
        children: <Widget>[
          CheckboxListTile(
            value: k.ikut,
            onChanged: _saving
                ? null
                : (v) => setState(() => k.ikut = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: _primary,
            dense: true,
            title: Text(k.label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5, fontWeight: FontWeight.w700)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          ),
          if (k.ikut)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: k.pesertaCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                      validator: (v) {
                        if (!k.ikut) return null;
                        final n = int.tryParse((v ?? '').trim());
                        if (n == null || n <= 0) return 'Isi';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Peserta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTanggalKeg(k),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 13),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: _line),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          k.tanggal == null
                              ? 'Tanggal'
                              : '${k.tanggal!.day}/${k.tanggal!.month}/${k.tanggal!.year}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _opsionalCard({
    required String judul,
    required IconData icon,
    required bool aktif,
    required ValueChanged<bool> onUbah,
    required List<Widget> anak,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: aktif ? _primary : _line),
      ),
      child: Column(
        children: <Widget>[
          CheckboxListTile(
            value: aktif,
            onChanged: _saving ? null : (v) => onUbah(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: _primary,
            dense: true,
            title: Row(
              children: <Widget>[
                Icon(icon, size: 18, color: _primary),
                const SizedBox(width: 8),
                Text(judul,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5, fontWeight: FontWeight.w700)),
              ],
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          ),
          if (aktif)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(children: anak),
            ),
        ],
      ),
    );
  }

  Widget _miniField({
    required TextEditingController ctrl,
    required String label,
    String? hint,
    required IconData icon,
    bool angka = false,
    bool desimal = false,
    bool wajib = false,
  }) {
    return TextFormField(
        controller: ctrl,
        keyboardType: angka
            ? (desimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number)
            : null,
        inputFormatters: angka
            ? <TextInputFormatter>[
                desimal
                    ? FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))
                    : FilteringTextInputFormatter.digitsOnly,
              ]
            : null,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _ink),
        validator: (v) {
          if (wajib && (v == null || v.trim().isEmpty)) return 'Wajib';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: _primary),
          hintStyle:
              GoogleFonts.plusJakartaSans(fontSize: 12.5, color: _muted),
          labelStyle:
              GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _line)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _line)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );
  }
}
