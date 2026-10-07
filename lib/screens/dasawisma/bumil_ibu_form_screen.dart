import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/bumil_ibu.dart';
import '../../services/bumil_service.dart';
import '../../services/api_exception.dart';

class BumilIbuFormScreen extends StatefulWidget {
  final BumilIbu? data;
  const BumilIbuFormScreen({super.key, this.data});
  @override
  State<BumilIbuFormScreen> createState() => _BumilIbuFormScreenState();
}

class _BumilIbuFormScreenState extends State<BumilIbuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = BumilService();
  static const Color _primary = Color(0xFF0072BC);
  static const Color _primaryLight = Color(0xFFE6F1F9);

  late final TextEditingController _namaCtrl,
      _suamiCtrl,
      _umurCtrl,
      _dasaWismaCtrl,
      _rtCtrl,
      _rwCtrl,
      _dusunCtrl,
      _bayiNamaCtrl,
      _kematianUmurCtrl,
      _kematianNamaCtrl,
      _kematianSebabCtrl,
      _keteranganCtrl;

  int _tahun = DateTime.now().year;
  int _bulan = DateTime.now().month;
  String _statusIbu = 'hamil';
  String _bayiJk = 'L';
  DateTime? _bayiTgl;
  bool? _bayiAkta;
  String _matiKategori = 'bayi';
  String _matiJk = 'L';
  DateTime? _matiTgl;
  bool _adaKematian = false;

  bool _saving = false;
  Map<String, List<String>> _fieldErrors = {};

  bool get _isEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _namaCtrl = TextEditingController(text: d?.nama ?? '');
    _suamiCtrl = TextEditingController(text: d?.suamiNama ?? '');
    _umurCtrl = TextEditingController(
        text: d == null || d.umur == 0 ? '' : '${d.umur}');
    _dasaWismaCtrl = TextEditingController(text: d?.dasaWisma ?? '');
    _rtCtrl = TextEditingController(text: d?.rt ?? '');
    _rwCtrl = TextEditingController(text: d?.rw ?? '');
    _dusunCtrl = TextEditingController(text: d?.dusun ?? '');
    _bayiNamaCtrl = TextEditingController(text: d?.bayiNama ?? '');
    _kematianUmurCtrl = TextEditingController(
        text: d?.kematianUmurBulan == null ? '' : '${d!.kematianUmurBulan}');
    _kematianNamaCtrl = TextEditingController(text: d?.kematianNama ?? '');
    _kematianSebabCtrl = TextEditingController(text: d?.kematianSebab ?? '');
    _keteranganCtrl = TextEditingController(text: d?.keterangan ?? '');
    if (d != null) {
      _tahun = d.tahun;
      _bulan = d.bulan;
      if (BumilIbu.statusLabels.containsKey(d.statusIbu)) {
        _statusIbu = d.statusIbu;
      }
      if (d.bayiJenisKelamin == 'L' || d.bayiJenisKelamin == 'P') {
        _bayiJk = d.bayiJenisKelamin;
      }
      _bayiTgl = d.bayiTanggalLahir;
      _bayiAkta = d.bayiAkta;
      if (d.kematianKategori.isNotEmpty) {
        _adaKematian = true;
        _matiKategori = d.kematianKategori;
      }
      if (d.kematianJenisKelamin == 'L' || d.kematianJenisKelamin == 'P') {
        _matiJk = d.kematianJenisKelamin;
      }
      _matiTgl = d.kematianTanggal;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _suamiCtrl.dispose();
    _umurCtrl.dispose();
    _dasaWismaCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    _bayiNamaCtrl.dispose();
    _kematianUmurCtrl.dispose();
    _kematianNamaCtrl.dispose();
    _kematianSebabCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  String? _serverError(String field) {
    final list = _fieldErrors[field];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  /// Kategori otomatis dari umur (bulan): <12 bayi, 12-59 balita.
  /// Kader tetap bisa ubah manual lewat dropdown.
  void _autoKategori() {
    final umur = int.tryParse(_kematianUmurCtrl.text.trim());
    if (umur == null) return;
    if (umur < 12) {
      setState(() => _matiKategori = 'bayi');
    } else if (umur <= 59) {
      setState(() => _matiKategori = 'balita');
    }
  }

  Future<DateTime?> _pickDate(DateTime? initial) async {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    // Aturan kondisional (satu status per bulan, tanpa hitung ganda).
    if (_statusIbu == 'melahirkan' && _bayiNamaCtrl.text.trim().isEmpty) {
      _snack('Isi nama bayi (status Melahirkan).', error: true);
      return;
    }
    if (_adaKematian && _kematianNamaCtrl.text.trim().isEmpty) {
      _snack('Isi nama yang meninggal.', error: true);
      return;
    }
    setState(() {
      _saving = true;
      _fieldErrors = {};
    });
    try {
      final payload = BumilIbu(
        id: widget.data?.id ?? '0',
        tahun: _tahun,
        bulan: _bulan,
        dasaWisma: _dasaWismaCtrl.text.trim(),
        rt: _rtCtrl.text.trim(),
        rw: _rwCtrl.text.trim(),
        dusun: _dusunCtrl.text.trim(),
        nama: _namaCtrl.text.trim(),
        suamiNama: _suamiCtrl.text.trim(),
        umur: int.tryParse(_umurCtrl.text.trim()) ?? 0,
        statusIbu: _statusIbu,
        bayiNama: _statusIbu == 'melahirkan'
            ? _bayiNamaCtrl.text.trim()
            : '',
        bayiJenisKelamin: _statusIbu == 'melahirkan' ? _bayiJk : '',
        bayiTanggalLahir: _statusIbu == 'melahirkan' ? _bayiTgl : null,
        bayiAkta: _statusIbu == 'melahirkan' ? _bayiAkta : null,
        kematianKategori: _adaKematian ? _matiKategori : '',
        kematianUmurBulan: _adaKematian
            ? int.tryParse(_kematianUmurCtrl.text.trim())
            : null,
        kematianNama:
            _adaKematian ? _kematianNamaCtrl.text.trim() : '',
        kematianJenisKelamin: _adaKematian ? _matiJk : '',
        kematianTanggal: _adaKematian ? _matiTgl : null,
        kematianSebab:
            _adaKematian ? _kematianSebabCtrl.text.trim() : '',
        keterangan: _keteranganCtrl.text.trim(),
      );
      final List<String> warnings;
      if (_isEdit) {
        warnings = await _service.update(payload);
      } else {
        warnings = await _service.add(payload);
      }
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              _isEdit
                  ? 'Data diperbarui, menunggu persetujuan'
                  : 'Data terkirim, menunggu persetujuan',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      if (warnings.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Perhatian: ${warnings.join(' ')}',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.orange[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))));
      }
      Navigator.pop(context, true);
    } on ApiValidationException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _fieldErrors = e.errors;
      });
      _formKey.currentState!.validate();
      _snack(e.message, error: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack(e.toString().replaceFirst('Exception: ', ''), error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
      backgroundColor: error ? Colors.red[700] : const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
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
                Text(_isEdit ? 'Edit Data Ibu' : 'Tambah Data Ibu',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A))),
                Text('Satu ibu satu status per bulan',
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
                _section(Icons.calendar_month_rounded, 'Periode',
                    'Bulan pencatatan'),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _bulanDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _tahunDropdown()),
                ]),
                const SizedBox(height: 28),
                _section(Icons.person_rounded, 'Data Ibu', 'Identitas ibu'),
                const SizedBox(height: 14),
                _field(
                    ctrl: _namaCtrl,
                    label: 'Nama Ibu',
                    hint: 'Nama lengkap',
                    icon: Icons.person_outline_rounded,
                    serverField: 'nama',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama wajib diisi'
                        : null),
                const SizedBox(height: 10),
                _field(
                    ctrl: _suamiCtrl,
                    label: 'Nama Suami',
                    hint: 'Nama suami',
                    icon: Icons.person_outline_rounded,
                    serverField: 'suami_nama'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _field(
                          ctrl: _umurCtrl,
                          label: 'Umur',
                          hint: '28',
                          icon: Icons.cake_outlined,
                          keyboard: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          serverField: 'umur')),
                  const SizedBox(width: 12),
                  Expanded(child: _statusDropdown()),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _field(
                          ctrl: _dasaWismaCtrl,
                          label: 'Dasa Wisma',
                          hint: 'Mawar 01',
                          icon: Icons.holiday_village_outlined,
                          serverField: 'dasawisma')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(
                          ctrl: _dusunCtrl,
                          label: 'Dusun',
                          hint: 'Cikunir',
                          icon: Icons.landscape_outlined,
                          serverField: 'dusun')),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _field(
                          ctrl: _rtCtrl,
                          label: 'RT',
                          hint: '01',
                          icon: Icons.location_on_outlined,
                          serverField: 'rt')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(
                          ctrl: _rwCtrl,
                          label: 'RW',
                          hint: '05',
                          icon: Icons.location_on_outlined,
                          serverField: 'rw')),
                ]),
                if (_statusIbu == 'melahirkan') ...[
                  const SizedBox(height: 28),
                  _section(Icons.child_care_rounded, 'Kelahiran Bayi',
                      'Wajib karena status Melahirkan'),
                  const SizedBox(height: 14),
                  _field(
                      ctrl: _bayiNamaCtrl,
                      label: 'Nama Bayi',
                      hint: 'Nama bayi',
                      icon: Icons.baby_changing_station_outlined,
                      serverField: 'bayi_nama'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _jkDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _tglTile(
                        label: 'Tgl Lahir',
                        tanggal: _bayiTgl,
                        onTap: () async {
                          final p = await _pickDate(_bayiTgl);
                          if (p != null) {
                            setState(() => _bayiTgl = p);
                          }
                        })),
                  ]),
                  const SizedBox(height: 10),
                  _aktaPicker(),
                ],
                const SizedBox(height: 28),
                _section(Icons.info_outline_rounded, 'Kematian',
                    'Isi bila ada yang meninggal bulan ini'),
                const SizedBox(height: 14),
                SwitchListTile(
                  value: _adaKematian,
                  onChanged: (v) => setState(() => _adaKematian = v),
                  activeThumbColor: Colors.white,
                  activeTrackColor: _primary,
                  title: Text('Ada kematian',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  contentPadding: EdgeInsets.zero,
                ),
                if (_adaKematian) ...[
                  _kategoriMatiDropdown(),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: _field(
                            ctrl: _kematianUmurCtrl,
                            label: 'Umur (bulan)',
                            hint: 'cth: 8',
                            icon: Icons.cake_outlined,
                            keyboard: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            serverField: 'kematian_umur_bulan',
                            onChanged: (_) => _autoKategori())),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                                color: _primaryLight,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                                'Otomatis: ${_matiKategori == 'bayi'
                                    ? 'Bayi (<12 bln)'
                                    : _matiKategori == 'balita'
                                        ? 'Balita (12-59 bln)'
                                        : 'Ibu'}',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: _primary)))),
                  ]),
                  const SizedBox(height: 10),
                  _field(
                      ctrl: _kematianNamaCtrl,
                      label: 'Nama (ibu/bayi/balita)',
                      hint: 'Nama',
                      icon: Icons.person_outline_rounded,
                      serverField: 'kematian_nama'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _jkMatiDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _tglTile(
                        label: 'Tgl Meninggal',
                        tanggal: _matiTgl,
                        onTap: () async {
                          final p = await _pickDate(_matiTgl);
                          if (p != null) {
                            setState(() => _matiTgl = p);
                          }
                        })),
                  ]),
                  const SizedBox(height: 10),
                  _field(
                      ctrl: _kematianSebabCtrl,
                      label: 'Sebab',
                      hint: 'Sebab meninggal',
                      icon: Icons.notes_outlined,
                      serverField: 'kematian_sebab'),
                ],
                const SizedBox(height: 10),
                _field(
                    ctrl: _keteranganCtrl,
                    label: 'Keterangan',
                    hint: 'Catatan tambahan',
                    icon: Icons.edit_note_rounded,
                    serverField: 'keterangan'),
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
                      child: Text(
                          'Perlu diperbaiki: ${widget.data!.rejectedReason!}',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF7F1D1D)))),
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

  Widget _bulanDropdown() => _wrapDropdown(DropdownButtonFormField<int>(
      initialValue: _bulan,
      isExpanded: true,
      decoration: _ddDecoration('Bulan', Icons.calendar_month_outlined),
      items: BumilIbu.namaBulan.entries
          .map((e) => DropdownMenuItem(
              value: e.key,
              child:
                  Text(e.value, style: GoogleFonts.plusJakartaSans(fontSize: 13.5))))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => _bulan = v);
      }));

  Widget _tahunDropdown() => _wrapDropdown(DropdownButtonFormField<int>(
      initialValue: _tahun,
      isExpanded: true,
      decoration: _ddDecoration('Tahun', Icons.calendar_today_outlined),
      items: [2024, 2025, 2026, 2027]
          .map((y) => DropdownMenuItem(
              value: y,
              child: Text('$y', style: GoogleFonts.plusJakartaSans(fontSize: 13.5))))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => _tahun = v);
      }));

  Widget _statusDropdown() => _wrapDropdown(DropdownButtonFormField<String>(
      initialValue: _statusIbu,
      isExpanded: true,
      decoration: _ddDecoration('Status', Icons.monitor_heart_outlined),
      items: BumilIbu.statusLabels.entries
          .map((e) => DropdownMenuItem(
              value: e.key,
              child: Text(e.value,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5))))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => _statusIbu = v);
      }));

  Widget _jkDropdown() => _wrapDropdown(DropdownButtonFormField<String>(
      initialValue: _bayiJk,
      isExpanded: true,
      decoration: _ddDecoration('L/P Bayi', Icons.wc_outlined),
      items: const [
        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
      ],
      onChanged: (v) {
        if (v == null) return;
        setState(() => _bayiJk = v);
      }));

  Widget _jkMatiDropdown() => _wrapDropdown(DropdownButtonFormField<String>(
      initialValue: _matiJk,
      isExpanded: true,
      decoration: _ddDecoration('L/P', Icons.wc_outlined),
      items: const [
        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
      ],
      onChanged: (v) {
        if (v == null) return;
        setState(() => _matiJk = v);
      }));

  Widget _kategoriMatiDropdown() =>
      _wrapDropdown(DropdownButtonFormField<String>(
          initialValue: _matiKategori,
          isExpanded: true,
          decoration: _ddDecoration('Yang Meninggal', Icons.info_outlined),
          items: const [
            DropdownMenuItem(value: 'ibu', child: Text('Ibu')),
            DropdownMenuItem(value: 'bayi', child: Text('Bayi')),
            DropdownMenuItem(value: 'balita', child: Text('Balita')),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _matiKategori = v);
          }));

  Widget _wrapDropdown(Widget child) => Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: child);

  InputDecoration _ddDecoration(String label, IconData icon) =>
      InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: _primary),
          labelStyle:
              GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero);

  Widget _tglTile(
      {required String label,
      required DateTime? tanggal,
      required VoidCallback onTap}) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0))),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 18, color: _primary),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(label,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, color: const Color(0xFF64748B))),
                    Text(
                        tanggal == null
                            ? 'Pilih'
                            : '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, color: const Color(0xFF0F172A))),
                  ])),
            ])));
  }

  Widget _aktaPicker() {
    Widget opt(String label, bool? v) => Expanded(
            child: InkWell(
          onTap: () => setState(() => _bayiAkta = v),
          borderRadius: BorderRadius.circular(10),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: _bayiAkta == v ? _primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _bayiAkta == v
                          ? _primary
                          : const Color(0xFFE2E8F0))),
              child: Center(
                  child: Text(label,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _bayiAkta == v
                              ? _primary
                              : const Color(0xFF64748B))))),
        ));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Akta Kelahiran',
          style:
              GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B))),
      const SizedBox(height: 8),
      Row(children: [
        opt('Ada', true),
        const SizedBox(width: 10),
        opt('Tidak Ada', false),
      ]),
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
    ValueChanged<String>? onChanged,
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
              onChanged: (v) {
                if (serverField != null &&
                    _fieldErrors.containsKey(serverField)) {
                  setState(() => _fieldErrors.remove(serverField));
                }
                onChanged?.call(v);
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
