import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/data_keluarga_dasawisma.dart';
import '../../models/dasawisma_catatan_keluarga.dart';
import '../../services/daftar_warga_service.dart';
import '../../services/dasawisma_catatan_keluarga_service.dart';
import '../../services/api_exception.dart';

class CatatanKeluargaFormScreen extends StatefulWidget {
  final DasawismaCatatanKeluarga? data;
  const CatatanKeluargaFormScreen({super.key, this.data});
  @override
  State<CatatanKeluargaFormScreen> createState() =>
      _CatatanKeluargaFormScreenState();
}

class _CatatanKeluargaFormScreenState extends State<CatatanKeluargaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = DasawismaCatatanKeluargaService();
  final _kkService = DaftarWargaService();
  static const Color _primary = Color(0xFF0072BC);
  static const Color _primaryLight = Color(0xFFE6F1F9);

  late final TextEditingController _namaCtrl,
      _nikCtrl,
      _umurCtrl,
      _pendidikanCtrl,
      _pekerjaanCtrl,
      _statusKawinCtrl;
  String _jenisKelamin = 'P';
  String _hubungan = 'anak';
  DateTime? _tanggalLahir;
  int? _daftarWargaId;
  List<DataKeluargaDasawisma> _kkList = [];
  bool _kkLoading = true;
  String? _kkError;
  bool _saving = false;
  Map<String, List<String>> _fieldErrors = {};

  bool get _isEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _namaCtrl = TextEditingController(text: d?.namaAnggota ?? '');
    _nikCtrl = TextEditingController(text: d?.nik ?? '');
    _umurCtrl =
        TextEditingController(text: d == null || d.umur == 0 ? '' : '${d.umur}');
    _pendidikanCtrl = TextEditingController(text: d?.pendidikan ?? '');
    _pekerjaanCtrl = TextEditingController(text: d?.pekerjaan ?? '');
    _statusKawinCtrl = TextEditingController(text: d?.statusPerkawinan ?? '');
    if (d != null) {
      if (d.jenisKelamin == 'L' || d.jenisKelamin == 'P') {
        _jenisKelamin = d.jenisKelamin;
      }
      if (DasawismaCatatanKeluarga.hubunganLabels
          .containsKey(d.hubunganKeluarga)) {
        _hubungan = d.hubunganKeluarga;
      }
      if (d.daftarWargaId > 0) _daftarWargaId = d.daftarWargaId;
    }
    _tanggalLahir = d?.tanggalLahir;
    _loadKk();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _umurCtrl.dispose();
    _pendidikanCtrl.dispose();
    _pekerjaanCtrl.dispose();
    _statusKawinCtrl.dispose();
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
        // Pertahankan pilihan saat edit bila KK masih ada di daftar.
        if (_daftarWargaId != null &&
            !_kkList.any((e) => e.id == _daftarWargaId)) {
          _daftarWargaId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _kkLoading = false;
        _kkError =
            'Gagal memuat daftar KK. Pastikan sudah input Daftar Warga dulu.';
      });
    }
  }

  String? _serverError(String field) {
    final list = _fieldErrors[field];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  int _hitungUmur(DateTime lahir) {
    final now = DateTime.now();
    var umur = now.year - lahir.year;
    if (now.month < lahir.month ||
        (now.month == lahir.month && now.day < lahir.day)) {
      umur--;
    }
    return umur < 0 ? 0 : umur;
  }

  Future<void> _pickTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahir = picked;
        _umurCtrl.text = '${_hitungUmur(picked)}';
        _fieldErrors.remove('tanggal_lahir');
        _fieldErrors.remove('umur');
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_daftarWargaId == null) {
      setState(() {
        _fieldErrors = {
          'daftar_warga_id': ['Pilih kepala keluarga dulu']
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Pilih kepala keluarga dulu.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      return;
    }
    setState(() {
      _saving = true;
      _fieldErrors = {};
    });
    try {
      final payload = DasawismaCatatanKeluarga(
        id: widget.data?.id ?? '0',
        daftarWargaId: _daftarWargaId!,
        namaAnggota: _namaCtrl.text.trim(),
        nik: _nikCtrl.text.trim(),
        jenisKelamin: _jenisKelamin,
        tanggalLahir: _tanggalLahir,
        umur: int.tryParse(_umurCtrl.text.trim()) ?? 0,
        hubunganKeluarga: _hubungan,
        pendidikan: _pendidikanCtrl.text.trim(),
        pekerjaan: _pekerjaanCtrl.text.trim(),
        statusPerkawinan: _statusKawinCtrl.text.trim(),
      );
      if (_isEdit) {
        await _service.update(payload);
      } else {
        await _service.add(payload);
      }
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              _isEdit
                  ? 'Data diperbarui, menunggu persetujuan Admin Desa'
                  : 'Data terkirim, menunggu persetujuan Admin Desa',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      Navigator.pop(context, true);
    } on ApiValidationException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _fieldErrors = e.errors;
      });
      _formKey.currentState!.validate();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', ''),
              style: GoogleFonts.plusJakartaSans()),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
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
          iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    _isEdit
                        ? 'Edit Anggota Keluarga'
                        : 'Tambah Anggota Keluarga',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A))),
                Text('Terhubung ke data KK',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: const Color(0xFF64748B)))
              ]),
          actions: [
            if (_saving)
              const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5))))
            else
              TextButton(
                  onPressed: _save,
                  child: Text('Simpan',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _primary)))
          ]),
      body: Form(
          key: _formKey,
          child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                _section(Icons.family_restroom_rounded, 'Kepala Keluarga',
                    'Pilih KK dari Daftar Warga'),
                const SizedBox(height: 14),
                _kkDropdown(),
                if (_serverError('daftar_warga_id') != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(_serverError('daftar_warga_id')!,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: Colors.red[700]))),
                const SizedBox(height: 28),
                _section(Icons.person_rounded, 'Data Anggota',
                    'Identitas anggota keluarga'),
                const SizedBox(height: 14),
                _field(
                    ctrl: _namaCtrl,
                    label: 'Nama Anggota',
                    hint: 'Nama lengkap',
                    icon: Icons.person_outline_rounded,
                    serverField: 'nama_anggota',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama wajib diisi'
                        : null),
                const SizedBox(height: 10),
                _field(
                    ctrl: _nikCtrl,
                    label: 'NIK',
                    hint: '16 digit',
                    icon: Icons.badge_outlined,
                    keyboard: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    serverField: 'nik'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _jenisDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _hubunganDropdown()),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _tanggalField()),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(
                          ctrl: _umurCtrl,
                          label: 'Umur',
                          hint: '0',
                          icon: Icons.cake_outlined,
                          keyboard: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          serverField: 'umur')),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _field(
                          ctrl: _pendidikanCtrl,
                          label: 'Pendidikan',
                          hint: 'SMA',
                          icon: Icons.school_outlined,
                          serverField: 'pendidikan')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(
                          ctrl: _pekerjaanCtrl,
                          label: 'Pekerjaan',
                          hint: 'Petani',
                          icon: Icons.work_outline_rounded,
                          serverField: 'pekerjaan')),
                ]),
                const SizedBox(height: 10),
                _field(
                    ctrl: _statusKawinCtrl,
                    label: 'Status Perkawinan',
                    hint: 'Kawin / Belum Kawin',
                    icon: Icons.favorite_outline_rounded,
                    serverField: 'status_perkawinan'),
                if (_isEdit &&
                    (widget.data?.isRejected ?? false) &&
                    (widget.data?.rejectedReason ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: const Color(0xFFFECACA))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alasan penolakan Admin Desa:',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFB91C1C))),
                            const SizedBox(height: 4),
                            Text(widget.data!.rejectedReason!,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: const Color(0xFF7F1D1D))),
                          ])),
                ],
                const SizedBox(height: 32),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 2),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : Text(_isEdit ? 'Perbarui' : 'Simpan',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700))))
              ])),
    );
  }

  Widget _kkDropdown() {
    if (_kkLoading) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(children: [
            const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text('Memuat daftar KK...',
                style:
                    GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[500])),
          ]));
    }
    if (_kkError != null) {
      return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA))),
          child: Row(children: [
            const Icon(Icons.error_outline_rounded,
                size: 18, color: Color(0xFFB91C1C)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(_kkError!,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5, color: const Color(0xFF7F1D1D)))),
            TextButton(onPressed: _loadKk, child: const Text('Muat ulang')),
          ]));
    }
    // Saat edit, pastikan KK terpilih tetap tampil walau beda halaman.
    final items = <DropdownMenuItem<int>>[];
    if (_isEdit &&
        _daftarWargaId != null &&
        !_kkList.any((e) => e.id == _daftarWargaId)) {
      items.add(DropdownMenuItem(
          value: _daftarWargaId,
          child: Text(widget.data?.kepalaKeluarga ?? 'KK terpilih',
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5))));
    }
    items.addAll(_kkList.map((e) => DropdownMenuItem(
        value: e.id,
        child: Text(
            e.namaKepalaRumahTangga.isEmpty
                ? 'KK #${e.id}'
                : e.namaKepalaRumahTangga,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5)))));

    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: DropdownButtonFormField<int>(
            initialValue: _daftarWargaId,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B)),
            decoration: InputDecoration(
                labelText: 'Kepala Keluarga',
                prefixIcon: const Icon(Icons.home_work_outlined,
                    size: 18, color: _primary),
                labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: const Color(0xFF64748B)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero),
            items: items,
            validator: (v) => v == null ? 'Pilih kepala keluarga' : null,
            onChanged: (v) => setState(() {
                  _daftarWargaId = v;
                  _fieldErrors.remove('daftar_warga_id');
                })));
  }

  Widget _jenisDropdown() => Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButtonFormField<String>(
          initialValue: _jenisKelamin,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B)),
          decoration: InputDecoration(
              labelText: 'L/P',
              prefixIcon: const Icon(Icons.wc_rounded, size: 18, color: _primary),
              labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: const Color(0xFF64748B)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero),
          items: const [
            DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'P', child: Text('Perempuan')),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _jenisKelamin = v;
              _fieldErrors.remove('jenis_kelamin');
            });
          }));

  Widget _hubunganDropdown() => Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButtonFormField<String>(
          initialValue: _hubungan,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B)),
          decoration: InputDecoration(
              labelText: 'Hubungan',
              prefixIcon: const Icon(Icons.group_outlined,
                  size: 18, color: _primary),
              labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: const Color(0xFF64748B)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero),
          items: DasawismaCatatanKeluarga.hubunganLabels.entries
              .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5))))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _hubungan = v;
              _fieldErrors.remove('hubungan_keluarga');
            });
          }));

  Widget _tanggalField() {
    final text = _tanggalLahir == null
        ? 'Pilih tanggal'
        : '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}';
    final err = _serverError('tanggal_lahir');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
          onTap: _pickTanggalLahir,
          borderRadius: BorderRadius.circular(12),
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: err != null
                          ? Colors.red[400]!
                          : const Color(0xFFE2E8F0))),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: _primary),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Tgl Lahir',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: const Color(0xFF64748B))),
                      Text(text,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, color: const Color(0xFF0F172A))),
                    ])),
              ]))),
      if (err != null)
        Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(err,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: Colors.red[700]))),
    ]);
  }

  Widget _section(IconData icon, String title, String sub) => Row(children: [
        Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: _primaryLight, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: _primary)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A))),
          Text(sub,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5, color: const Color(0xFF64748B)))
        ])
      ]);

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    String? serverField,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final serverErr = serverField == null ? null : _serverError(serverField);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: serverErr != null
                      ? Colors.red[400]!
                      : const Color(0xFFE2E8F0))),
          child: TextFormField(
              controller: ctrl,
              keyboardType: keyboard,
              inputFormatters: inputFormatters,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              validator: (v) {
                if (serverErr != null) return serverErr;
                if (validator != null) return validator(v);
                return null;
              },
              onChanged: (_) {
                if (serverField != null &&
                    _fieldErrors.containsKey(serverField)) {
                  setState(() => _fieldErrors.remove(serverField));
                }
              },
              decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(icon, size: 18, color: _primary),
                  hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: Colors.grey[400]),
                  labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: const Color(0xFF64748B)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14)))),
    ]);
  }
}
