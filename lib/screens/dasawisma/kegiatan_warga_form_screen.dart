import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/kegiatan_warga.dart';
import '../../services/kegiatan_warga_service.dart';

class KegiatanWargaFormScreen extends StatefulWidget {
  final KegiatanWarga? data;
  const KegiatanWargaFormScreen({super.key, this.data});
  @override
  State<KegiatanWargaFormScreen> createState() => _KegiatanWargaFormScreenState();
}

class _KegiatanWargaFormScreenState extends State<KegiatanWargaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KegiatanWargaService();
  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryLight = Color(0xFFF0F9FF);

  late final TextEditingController _dasaWismaCtrl,
      _rtCtrl,
      _rwCtrl,
      _dusunCtrl,
      _pesertaCtrl,
      _keteranganCtrl;
  String _kegiatan = 'up2k';
  DateTime? _tanggal;
  bool _saving = false;

  /// Error validasi per field dari server (key = nama field server).
  Map<String, List<String>> _fieldErrors = {};

  bool get _isEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _dasaWismaCtrl = TextEditingController(text: d?.dasaWisma ?? '');
    _rtCtrl = TextEditingController(text: d?.rt ?? '');
    _rwCtrl = TextEditingController(text: d?.rw ?? '');
    _dusunCtrl = TextEditingController(text: d?.dusun ?? '');
    _pesertaCtrl =
        TextEditingController(text: d == null ? '' : '${d.jumlahPeserta}');
    _keteranganCtrl = TextEditingController(text: d?.keterangan ?? '');
    if (d != null && KegiatanWarga.kegiatanLabels.containsKey(d.kegiatan)) {
      _kegiatan = d.kegiatan;
    }
    _tanggal = d?.tanggal ?? DateTime.now();
  }

  @override
  void dispose() {
    _dasaWismaCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    _pesertaCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  String? _serverError(String field) {
    final list = _fieldErrors[field];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
        _fieldErrors.remove('tanggal');
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return; // cegah double submit
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _fieldErrors = {};
    });
    try {
      final payload = KegiatanWarga(
        id: widget.data?.id ?? '0',
        dasaWisma: _dasaWismaCtrl.text.trim(),
        rt: _rtCtrl.text.trim(),
        rw: _rwCtrl.text.trim(),
        dusun: _dusunCtrl.text.trim(),
        kegiatan: _kegiatan,
        jumlahPeserta: int.tryParse(_pesertaCtrl.text.trim()) ?? 0,
        tanggal: _tanggal,
        keterangan: _keteranganCtrl.text.trim(),
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
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      Navigator.pop(context, true); // list refresh setelah sukses
    } on KegiatanWargaValidationException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _fieldErrors = e.errors;
      });
      _formKey.currentState!.validate(); // tampilkan error per field
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', ''),
              style: GoogleFonts.poppins()),
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
                Text(_isEdit ? 'Edit Kegiatan Warga' : 'Tambah Kegiatan Warga',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A))),
                Text('Desa & kecamatan otomatis dari akun login',
                    style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _primary)))
          ]),
      body: Form(
          key: _formKey,
          child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                _section(Icons.location_on_rounded, 'Identitas Wilayah',
                    'Lokasi kelompok dasa wisma'),
                const SizedBox(height: 14),
                _field(
                    ctrl: _dasaWismaCtrl,
                    label: 'Dasa Wisma',
                    hint: 'Mawar 01',
                    icon: Icons.holiday_village_outlined,
                    serverField: 'dasawisma'),
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
                const SizedBox(height: 10),
                _field(
                    ctrl: _dusunCtrl,
                    label: 'Dusun',
                    hint: 'Cikunir',
                    icon: Icons.landscape_outlined,
                    serverField: 'dusun'),
                const SizedBox(height: 28),
                _section(Icons.diversity_3_rounded, 'Kegiatan',
                    'Jenis, peserta & tanggal'),
                const SizedBox(height: 14),
                _kegiatanDropdown(),
                if (_serverError('kegiatan') != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(_serverError('kegiatan')!,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.red[700]))),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _field(
                          ctrl: _pesertaCtrl,
                          label: 'Jumlah Peserta',
                          hint: '0',
                          icon: Icons.groups_outlined,
                          keyboard: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          serverField: 'jumlah_peserta',
                          validator: (v) {
                            final n = int.tryParse((v ?? '').trim());
                            if (n == null || n < 0) {
                              return 'Isi jumlah peserta (angka ≥ 0)';
                            }
                            return null;
                          })),
                  const SizedBox(width: 12),
                  Expanded(child: _tanggalField()),
                ]),
                const SizedBox(height: 10),
                _field(
                    ctrl: _keteranganCtrl,
                    label: 'Keterangan',
                    hint: 'Catatan kegiatan...',
                    icon: Icons.edit_note_rounded,
                    maxLines: 3,
                    serverField: 'keterangan'),
                // Alasan penolakan (info saat edit data yang ditolak)
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
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFB91C1C))),
                            const SizedBox(height: 4),
                            Text(widget.data!.rejectedReason!,
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFF7F1D1D))),
                            const SizedBox(height: 4),
                            Text(
                                'Perbaiki data lalu simpan ulang — status kembali Menunggu.',
                                style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: const Color(0xFF64748B))),
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
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700))))
              ])),
    );
  }

  Widget _kegiatanDropdown() => Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButtonFormField<String>(
          initialValue: _kegiatan,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B)),
          decoration: InputDecoration(
              labelText: 'Jenis Kegiatan',
              prefixIcon:
                  const Icon(Icons.category_outlined, size: 18, color: _primary),
              labelStyle: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFF64748B)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero),
          items: KegiatanWarga.daftarKegiatan
              .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(KegiatanWarga.kegiatanLabels[v]!,
                      style: GoogleFonts.poppins(fontSize: 13.5))))
              .toList(),
          validator: (v) =>
              v == null || v.isEmpty ? 'Pilih jenis kegiatan' : null,
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _kegiatan = v;
              _fieldErrors.remove('kegiatan');
            });
          }));

  Widget _tanggalField() {
    final text = _tanggal == null
        ? 'Pilih tanggal'
        : '${_tanggal!.day}/${_tanggal!.month}/${_tanggal!.year}';
    final err = _serverError('tanggal');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
          onTap: _pickTanggal,
          borderRadius: BorderRadius.circular(12),
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: err != null
                          ? Colors.red[400]!
                          : const Color(0xFFE2E8F0))),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: _primary),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Tanggal',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: const Color(0xFF64748B))),
                      Text(text,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF0F172A))),
                    ])),
              ]))),
      if (err != null)
        Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(err,
                style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A))),
          Text(sub,
              style: GoogleFonts.poppins(
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
    int maxLines = 1,
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
              maxLines: maxLines,
              style: GoogleFonts.poppins(fontSize: 14),
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
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey[400]),
                  labelStyle: GoogleFonts.poppins(
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
