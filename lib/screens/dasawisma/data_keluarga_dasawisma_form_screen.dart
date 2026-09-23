import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/data_keluarga_dasawisma.dart';
import '../../services/data_keluarga_dasawisma_service.dart';
import '../../widgets/kecamatan_dropdown_field.dart';

class DataKeluargaDasawismaFormScreen extends StatefulWidget {
  final DataKeluargaDasawisma? data;
  const DataKeluargaDasawismaFormScreen({super.key, this.data});

  @override
  State<DataKeluargaDasawismaFormScreen> createState() => _DataKeluargaDasawismaFormScreenState();
}

class _DataKeluargaDasawismaFormScreenState extends State<DataKeluargaDasawismaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = DataKeluargaDasawismaService();

  late TextEditingController _dasaWismaCtrl;
  late TextEditingController _rtCtrl;
  late TextEditingController _rwCtrl;
  late TextEditingController _dusunCtrl;
  late TextEditingController _desaCtrl;
  late TextEditingController _kecamatanCtrl;
  late TextEditingController _namaKepalaRtCtrl;
  late TextEditingController _nomorKkCtrl;
  late TextEditingController _nikKepalaCtrl;
  late TextEditingController _alamatCtrl;
  late TextEditingController _jmlLakiCtrl;
  late TextEditingController _jmlPerempuanCtrl;

  late TextEditingController _jmlKkCtrl;
  late TextEditingController _jmlBalitaCtrl;
  late TextEditingController _jmlBalitaLCtrl;
  late TextEditingController _jmlBalitaPCtrl;
  late TextEditingController _jmlAnakCtrl;
  late TextEditingController _jmlPusCtrl;
  late TextEditingController _jmlWusCtrl;
  late TextEditingController _jmlTigaButaCtrl;
  late TextEditingController _jmlTigaButaLCtrl;
  late TextEditingController _jmlTigaButaPCtrl;
  late TextEditingController _jmlBumilCtrl;
  late TextEditingController _jmlBusuiCtrl;
  late TextEditingController _jmlLansiaCtrl;

  List<AnggotaKeluargaItem> _anggotaList = [];

  String _makananPokok = 'Beras';
  bool _mempunyaiMck = true;
  late TextEditingController _jmlMckCtrl;
  String _sumberAir = 'Sumur';
  bool _memilikiTempatSampah = true;
  bool _mempunyaiSpal = true;
  bool _memilikiStikerP4k = false;
  String _kriteriaRumah = 'Sehat';
  bool _aktifitasUp2k = false;
  late TextEditingController _jenisUsahaUp2kCtrl;
  bool _aktifitasKesling = true;
  bool _aktifitasTanahPekarangan = false;
  bool _aktifitasIndustriRumahTangga = false;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _dasaWismaCtrl = TextEditingController(text: d?.dasaWisma ?? '');
    _rtCtrl = TextEditingController(text: d?.rt ?? '');
    _rwCtrl = TextEditingController(text: d?.rw ?? '');
    _dusunCtrl = TextEditingController(text: d?.dusun ?? '');
    _desaCtrl = TextEditingController(text: d?.desa ?? '');
    _kecamatanCtrl = TextEditingController(text: d?.kecamatan ?? '');
    _namaKepalaRtCtrl = TextEditingController(text: d?.namaKepalaRumahTangga ?? '');
    _nomorKkCtrl = TextEditingController(text: d?.nomorKk ?? '');
    _nikKepalaCtrl = TextEditingController(text: d?.nikKepalaKeluarga ?? '');
    _alamatCtrl = TextEditingController(text: d?.alamat ?? '');
    _jmlLakiCtrl = TextEditingController(text: d != null ? d.jumlahLakiLaki.toString() : '');
    _jmlPerempuanCtrl = TextEditingController(text: d != null ? d.jumlahPerempuan.toString() : '');

    _jmlKkCtrl = TextEditingController(text: d != null ? d.jumlahKk.toString() : '');
    _jmlBalitaCtrl = TextEditingController(text: d != null && d.jumlahBalita != 0 ? d.jumlahBalita.toString() : '');
    _jmlBalitaLCtrl = TextEditingController(text: d?.jumlahBalitaL.toString() ?? '0');
    _jmlBalitaPCtrl = TextEditingController(text: d?.jumlahBalitaP.toString() ?? '0');
    _jmlAnakCtrl = TextEditingController(text: d != null && d.jumlahAnak != 0 ? d.jumlahAnak.toString() : '');
    _jmlPusCtrl = TextEditingController(text: d != null && d.jumlahPus != 0 ? d.jumlahPus.toString() : '');
    _jmlWusCtrl = TextEditingController(text: d != null && d.jumlahWus != 0 ? d.jumlahWus.toString() : '');
    _jmlTigaButaCtrl = TextEditingController(text: d != null && d.jumlahTigaButa != 0 ? d.jumlahTigaButa.toString() : '');
    _jmlTigaButaLCtrl = TextEditingController(text: d?.jumlahTigaButaL.toString() ?? '0');
    _jmlTigaButaPCtrl = TextEditingController(text: d?.jumlahTigaButaP.toString() ?? '0');
    _jmlBumilCtrl = TextEditingController(text: d != null && d.jumlahIbuHamil != 0 ? d.jumlahIbuHamil.toString() : '');
    _jmlBusuiCtrl = TextEditingController(text: d != null && d.jumlahIbuMenyusui != 0 ? d.jumlahIbuMenyusui.toString() : '');
    _jmlLansiaCtrl = TextEditingController(text: d != null && d.jumlahLansia != 0 ? d.jumlahLansia.toString() : '');

    _anggotaList = d != null ? List.from(d.anggotaList) : [];

    _makananPokok = d?.makananPokok ?? 'Beras';
    _mempunyaiMck = d?.mempunyaiMck ?? true;
    _jmlMckCtrl = TextEditingController(text: d != null && d.jumlahMckSepticTank != 0 ? d.jumlahMckSepticTank.toString() : '');
    _sumberAir = d?.sumberAir ?? 'Sumur';
    _memilikiTempatSampah = d?.memilikiTempatSampah ?? true;
    _mempunyaiSpal = d?.mempunyaiSpal ?? true;
    _memilikiStikerP4k = d?.memilikiStikerP4k ?? false;
    _kriteriaRumah = d?.kriteriaRumah ?? 'Sehat';
    _aktifitasUp2k = d?.aktifitasUp2k ?? false;
    _jenisUsahaUp2kCtrl = TextEditingController(text: d?.jenisUsahaUp2k ?? '');
    _aktifitasKesling = d?.aktifitasKesehatanLingkungan ?? true;
    _aktifitasTanahPekarangan = d?.aktifitasTanahPekarangan ?? false;
    _aktifitasIndustriRumahTangga = d?.aktifitasIndustriRumahTangga ?? false;
  }

  @override
  void dispose() {
    _dasaWismaCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    _desaCtrl.dispose();
    _kecamatanCtrl.dispose();
    _namaKepalaRtCtrl.dispose();
    _nomorKkCtrl.dispose();
    _nikKepalaCtrl.dispose();
    _alamatCtrl.dispose();
    _jmlLakiCtrl.dispose();
    _jmlPerempuanCtrl.dispose();
    _jmlKkCtrl.dispose();
    _jmlBalitaCtrl.dispose();
    _jmlBalitaLCtrl.dispose();
    _jmlBalitaPCtrl.dispose();
    _jmlAnakCtrl.dispose();
    _jmlPusCtrl.dispose();
    _jmlWusCtrl.dispose();
    _jmlTigaButaCtrl.dispose();
    _jmlTigaButaLCtrl.dispose();
    _jmlTigaButaPCtrl.dispose();
    _jmlBumilCtrl.dispose();
    _jmlBusuiCtrl.dispose();
    _jmlLansiaCtrl.dispose();
    _jmlMckCtrl.dispose();
    _jenisUsahaUp2kCtrl.dispose();
    super.dispose();
  }

  void _tambahAnggotaSheet({int? editIndex}) {
    final item = editIndex != null ? _anggotaList[editIndex] : null;
    final noRegCtrl = TextEditingController(text: item?.noReg ?? '00${_anggotaList.length + 1}');
    final namaCtrl = TextEditingController(text: item?.nama ?? '');
    String statusDalamKeluarga = item?.statusDalamKeluarga ?? 'Suami';
    String statusKawin = item?.statusPerkawinan ?? 'Kawin';
    String jk = item?.jenisKelamin ?? 'L';
    final tglUmurCtrl = TextEditingController(text: item?.tanggalLahirUmur ?? '');
    String pendidikan = item?.pendidikan ?? 'SMA/SMK/Sederajat';
    final pekerjaanCtrl = TextEditingController(text: item?.pekerjaan ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 14),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0D9488).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person_add_rounded, color: Color(0xFF0D9488), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(editIndex == null ? 'Tambah Anggota' : 'Edit Anggota', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF0F172A))),
                  Text('Lengkapi data anggota keluarga', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
                ])),
              ]),
              const SizedBox(height: 18),
              TextField(controller: noRegCtrl, decoration: _inputDeco('No. REG', 'Contoh: 001'), style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
              const SizedBox(height: 12),
              TextField(controller: namaCtrl, decoration: _inputDeco('Nama Lengkap *', 'Nama anggota keluarga'), style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
              const SizedBox(height: 12),
              _sheetDropdown('Status dalam Keluarga', statusDalamKeluarga, ['Suami', 'Istri', 'Anak', 'Menantu', 'Orang Tua', 'Keluarga Lain'], (v) => setSheet(() => statusDalamKeluarga = v!)),
              const SizedBox(height: 12),
              _sheetDropdown('Status Perkawinan', statusKawin, ['Kawin', 'Tidak Kawin'], (v) => setSheet(() => statusKawin = v!)),
              const SizedBox(height: 12),
              Text('Jenis Kelamin', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
              Row(children: [
                _radioPill('L', 'Laki-laki', jk == 'L', () => setSheet(() => jk = 'L')),
                const SizedBox(width: 8),
                _radioPill('P', 'Perempuan', jk == 'P', () => setSheet(() => jk = 'P')),
              ]),
              const SizedBox(height: 12),
              TextField(controller: tglUmurCtrl, decoration: _inputDeco('Tanggal Lahir / Umur', 'DD/MM/YYYY atau umur'), style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
              const SizedBox(height: 12),
              _sheetDropdown('Pendidikan', pendidikan, ['Tidak Tamat SD', 'SD/MI', 'SMP/Sederajat', 'SMA/SMK/Sederajat', 'Diploma', 'S1', 'S2', 'S3'], (v) => setSheet(() => pendidikan = v!)),
              const SizedBox(height: 12),
              TextField(controller: pekerjaanCtrl, decoration: _inputDeco('Pekerjaan', 'Swasta / PNS / ...'), style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: Color(0xFFE2E8F0))), child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(
                  onPressed: () {
                    if (namaCtrl.text.trim().isEmpty) return;
                    final newItem = AnggotaKeluargaItem(
                      noReg: noRegCtrl.text.trim(),
                      nama: namaCtrl.text.trim(),
                      statusDalamKeluarga: statusDalamKeluarga,
                      statusPerkawinan: statusKawin,
                      jenisKelamin: jk,
                      tanggalLahirUmur: tglUmurCtrl.text.trim(),
                      pendidikan: pendidikan,
                      pekerjaan: pekerjaanCtrl.text.trim(),
                    );
                    setState(() {
                      if (editIndex != null) {
                        _anggotaList[editIndex] = newItem;
                      } else {
                        _anggotaList.add(newItem);
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(editIndex == null ? 'Tambah' : 'Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _radioPill(String val, String label, bool sel, VoidCallback tap) => GestureDetector(
        onTap: tap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: sel ? const Color(0xFF0D9488) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0))),
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF475569))),
        ),
      );

  InputDecoration _inputDeco(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.2)),
      );

  Widget _sheetDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
        initialValue: value,
        decoration: _inputDeco(label, ''),
        items: items.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
        onChanged: onChanged,
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    final record = DataKeluargaDasawisma(
      id: widget.data?.id ?? 0,
      dasaWisma: _dasaWismaCtrl.text.trim(),
      rt: _rtCtrl.text.trim(),
      rw: _rwCtrl.text.trim(),
      dusun: _dusunCtrl.text.trim(),
      desa: _desaCtrl.text.trim(),
      kecamatan: _kecamatanCtrl.text.trim(),
      namaKepalaRumahTangga: _namaKepalaRtCtrl.text.trim(),
      nomorKk: _nomorKkCtrl.text.trim(),
      nikKepalaKeluarga: _nikKepalaCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
      jumlahLakiLaki: int.tryParse(_jmlLakiCtrl.text) ?? 0,
      jumlahPerempuan: int.tryParse(_jmlPerempuanCtrl.text) ?? 0,
      jumlahKk: int.tryParse(_jmlKkCtrl.text) ?? 1,
      jumlahBalita: int.tryParse(_jmlBalitaCtrl.text) ?? 0,
      jumlahBalitaL: int.tryParse(_jmlBalitaLCtrl.text) ?? 0,
      jumlahBalitaP: int.tryParse(_jmlBalitaPCtrl.text) ?? 0,
      jumlahAnak: int.tryParse(_jmlAnakCtrl.text) ?? 0,
      jumlahPus: int.tryParse(_jmlPusCtrl.text) ?? 0,
      jumlahWus: int.tryParse(_jmlWusCtrl.text) ?? 0,
      jumlahTigaButa: int.tryParse(_jmlTigaButaCtrl.text) ?? 0,
      jumlahTigaButaL: int.tryParse(_jmlTigaButaLCtrl.text) ?? 0,
      jumlahTigaButaP: int.tryParse(_jmlTigaButaPCtrl.text) ?? 0,
      jumlahIbuHamil: int.tryParse(_jmlBumilCtrl.text) ?? 0,
      jumlahIbuMenyusui: int.tryParse(_jmlBusuiCtrl.text) ?? 0,
      jumlahLansia: int.tryParse(_jmlLansiaCtrl.text) ?? 0,
      anggotaList: _anggotaList,
      makananPokok: _makananPokok,
      mempunyaiMck: _mempunyaiMck,
      jumlahMckSepticTank: int.tryParse(_jmlMckCtrl.text) ?? 1,
      sumberAir: _sumberAir,
      memilikiTempatSampah: _memilikiTempatSampah,
      mempunyaiSpal: _mempunyaiSpal,
      memilikiStikerP4k: _memilikiStikerP4k,
      kriteriaRumah: _kriteriaRumah,
      aktifitasUp2k: _aktifitasUp2k,
      jenisUsahaUp2k: _aktifitasUp2k ? _jenisUsahaUp2kCtrl.text.trim() : '',
      aktifitasKesehatanLingkungan: _aktifitasKesling,
      aktifitasTanahPekarangan: _aktifitasTanahPekarangan,
      aktifitasIndustriRumahTangga: _aktifitasIndustriRumahTangga,
    );
    await _service.save(record);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Icons.check_rounded, color: Colors.white, size: 18), const SizedBox(width: 8), Expanded(child: Text('Tersimpan — ${_dasaWismaCtrl.text}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)))]),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D9488);
    const bg = Color(0xFFF8FAFC);
    final inputFill = const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))), child: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF0F172A))), onPressed: () => Navigator.pop(context)),
        title: Text(widget.data == null ? 'Input Dasawisma' : 'Edit Dasawisma', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF0F172A))),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [const Icon(Icons.holiday_village_rounded, size: 14, color: primary), const SizedBox(width: 5), Text('${_anggotaList.length} Anggota', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: primary))]),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            // hero
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.home_work_rounded, color: primary, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Data Keluarga Dasawisma', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text('Rekap per Dasa Wisma, anggota & kriteria rumah', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B), height: 1.3)),
                ])),
              ]),
            ),
            const SizedBox(height: 16),

            _section('01', 'Identitas Wilayah', Icons.location_on_rounded, primary, [
              TextFormField(controller: _dasaWismaCtrl, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600), decoration: _inputDeco('Dasa Wisma *', 'Mawar 01'), validator: (v) => v!.trim().isEmpty ? 'Wajib' : null),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: TextFormField(controller: _rtCtrl, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('RT', '01'))), const SizedBox(width: 10), Expanded(child: TextFormField(controller: _rwCtrl, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('RW', '05')))]),
              const SizedBox(height: 10),
              TextFormField(controller: _dusunCtrl, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('Dusun', 'Nama dusun')),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: TextFormField(controller: _desaCtrl, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('Desa', 'Singaparna'))), const SizedBox(width: 10), Expanded(child: KecamatanDropdownField(controller: _kecamatanCtrl))]),
              const SizedBox(height: 10),
              TextFormField(controller: _namaKepalaRtCtrl, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600), decoration: _inputDeco('Nama Kepala Rumah Tangga *', 'Nama lengkap'), validator: (v) => v!.trim().isEmpty ? 'Wajib' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _nomorKkCtrl, keyboardType: TextInputType.number, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('Nomor KK', 'Nomor Kartu Keluarga')),
              const SizedBox(height: 10),
              TextFormField(controller: _nikKepalaCtrl, keyboardType: TextInputType.number, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('NIK Kepala Keluarga', 'NIK')),
              const SizedBox(height: 10),
              TextFormField(controller: _alamatCtrl, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('Alamat', 'Alamat lengkap')),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: TextFormField(controller: _jmlLakiCtrl, keyboardType: TextInputType.number, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('Laki-laki', '0'))), const SizedBox(width: 10), Expanded(child: TextFormField(controller: _jmlPerempuanCtrl, keyboardType: TextInputType.number, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('Perempuan', '0')))]),
            ]),

            _section('02', 'Rekapitulasi Anggota', Icons.analytics_rounded, primary, [
              TextFormField(controller: _jmlKkCtrl, keyboardType: TextInputType.number, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('Jumlah KK', '1')),
              const SizedBox(height: 12),
              Text('Kategori Anggota', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
              const SizedBox(height: 8),
              _twoField(_jmlBalitaLCtrl, 'Balita L', _jmlBalitaPCtrl, 'Balita P'),
              const SizedBox(height: 8),
              _twoField(_jmlBalitaCtrl, 'Balita Total', _jmlAnakCtrl, 'Anak'),
              const SizedBox(height: 8),
              _twoField(_jmlPusCtrl, 'PUS', _jmlWusCtrl, 'WUS'),
              const SizedBox(height: 8),
              _twoField(_jmlTigaButaLCtrl, '3 Buta L', _jmlTigaButaPCtrl, '3 Buta P'),
              const SizedBox(height: 8),
              _twoField(_jmlTigaButaCtrl, '3 Buta Total', _jmlBumilCtrl, 'Ibu Hamil'),
              const SizedBox(height: 8),
              _twoField(_jmlBusuiCtrl, 'Ibu Menyusui', _jmlLansiaCtrl, 'Lansia'),
            ]),

            _section('03', 'Daftar Anggota Keluarga', Icons.people_alt_rounded, primary, [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${_anggotaList.length} anggota terdata', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _anggotaList.isEmpty ? const Color(0xFF94A3B8) : primary)),
                InkWell(
                  onTap: () => _tambahAnggotaSheet(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [const Icon(Icons.add_rounded, size: 14, color: Colors.white), const SizedBox(width: 4), Text('Tambah', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))]),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              if (_anggotaList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(color: inputFill, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(children: [
                    const Icon(Icons.people_outline_rounded, size: 36, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 8),
                    Text('Belum ada rincian anggota (Opsional)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                    Text('Jika tidak ada anak/anggota lain, bagian ini dapat dilewati', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF94A3B8))),
                  ]),
                )
              else
                ..._anggotaList.asMap().entries.map((e) {
                  final idx = e.key;
                  final m = e.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: inputFill, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Row(children: [
                      Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0))), child: Center(child: Text('${idx + 1}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, color: primary)))),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(m.nama, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5, color: const Color(0xFF0F172A))),
                        Text('${m.statusDalamKeluarga} • ${m.jenisKelamin} • ${m.pendidikan}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B))),
                      ])),
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)), onPressed: () => _tambahAnggotaSheet(editIndex: idx)),
                      IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)), onPressed: () => setState(() => _anggotaList.removeAt(idx))),
                    ]),
                  );
                }),
            ]),

            _section('04', 'Kriteria Rumah & Lingkungan', Icons.home_work_rounded, primary, [
              Text('Makanan Pokok', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
              const SizedBox(height: 6),
              Row(children: ['Beras', 'Non Beras'].map((m) => Padding(padding: const EdgeInsets.only(right: 8), child: _choicePill(m, _makananPokok == m, () => setState(() => _makananPokok = m), primary))).toList()),
              const SizedBox(height: 12),
              _switchTile('Mempunyai MCK & Septic Tank', _mempunyaiMck, (v) => setState(() => _mempunyaiMck = v)),
              if (_mempunyaiMck) Padding(padding: const EdgeInsets.only(top: 8), child: TextFormField(controller: _jmlMckCtrl, keyboardType: TextInputType.number, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('Jumlah Septic Tank', '1'))),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              Text('Sumber Air', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: ['PDAM', 'Sumur', 'Sungai', 'Lainnya'].map((s) => _choicePill(s, _sumberAir == s, () => setState(() => _sumberAir = s), primary)).toList()),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              _switchTile('Memiliki Tempat Sampah', _memilikiTempatSampah, (v) => setState(() => _memilikiTempatSampah = v)),
              _switchTile('Mempunyai SPAL', _mempunyaiSpal, (v) => setState(() => _mempunyaiSpal = v)),
              _switchTile('Memiliki Stiker P4K', _memilikiStikerP4k, (v) => setState(() => _memilikiStikerP4k = v)),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              Text('Kriteria Rumah', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
              const SizedBox(height: 6),
              Row(children: ['Sehat', 'Kurang Sehat'].map((k) => Padding(padding: const EdgeInsets.only(right: 8), child: _choicePill(k, _kriteriaRumah == k, () => setState(() => _kriteriaRumah = k), primary))).toList()),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              _switchTile('Aktifitas UP2K', _aktifitasUp2k, (v) => setState(() => _aktifitasUp2k = v)),
              if (_aktifitasUp2k) Padding(padding: const EdgeInsets.only(top: 8), child: TextFormField(controller: _jenisUsahaUp2kCtrl, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco('Jenis Usaha UP2K', 'Kerajinan / kuliner'))),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              _switchTile('Kesehatan Lingkungan', _aktifitasKesling, (v) => setState(() => _aktifitasKesling = v)),
              _switchTile('Tanah Pekarangan', _aktifitasTanahPekarangan, (v) => setState(() => _aktifitasTanahPekarangan = v)),
              _switchTile('Industri Rumah Tangga', _aktifitasIndustriRumahTangga, (v) => setState(() => _aktifitasIndustriRumahTangga = v)),
            ]),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(widget.data == null ? 'Simpan Dasawisma' : 'Simpan Perubahan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String num, String title, IconData icon, Color primary, List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: primary)),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5, color: const Color(0xFF0F172A))),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20)), child: Text(num, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: primary))),
          ]),
          const SizedBox(height: 14),
          ...children,
        ]),
      );

  Widget _twoField(TextEditingController a, String la, TextEditingController b, String lb) => Row(children: [
        Expanded(child: TextFormField(controller: a, keyboardType: TextInputType.number, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco(la, '0'))),
        const SizedBox(width: 10),
        Expanded(child: TextFormField(controller: b, keyboardType: TextInputType.number, style: GoogleFonts.plusJakartaSans(fontSize: 13.5), decoration: _inputDeco(lb, '0'))),
      ]);

  Widget _choicePill(String label, bool sel, VoidCallback tap, Color primary) => GestureDetector(
        onTap: tap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(color: sel ? primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? primary : const Color(0xFFE2E8F0))),
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF475569))),
        ),
      );

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)))),
          Switch(value: value, onChanged: onChanged, activeThumbColor: const Color(0xFF0D9488)),
        ]),
      );
}
