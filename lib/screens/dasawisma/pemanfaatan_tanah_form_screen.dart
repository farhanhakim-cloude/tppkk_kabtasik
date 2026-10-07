import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pemanfaatan_tanah.dart';
import '../../services/pemanfaatan_tanah_service.dart';
import '../../services/api_exception.dart';

class PemanfaatanTanahFormScreen extends StatefulWidget {
  final PemanfaatanTanah? data;
  const PemanfaatanTanahFormScreen({super.key, this.data});
  @override
  State<PemanfaatanTanahFormScreen> createState() =>
      _PemanfaatanTanahFormScreenState();
}

class _PemanfaatanTanahFormScreenState
    extends State<PemanfaatanTanahFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PemanfaatanTanahService();
  static const Color _primary = Color(0xFF0072BC);
  static const Color _primaryLight = Color(0xFFE6F1F9);

  late final TextEditingController _dasaWismaCtrl,
      _rtCtrl,
      _rwCtrl,
      _dusunCtrl,
      _jenisCtrl,
      _luasCtrl,
      _kkCtrl,
      _hasilCtrl;
  bool _saving = false;
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
    _jenisCtrl = TextEditingController(text: d?.jenisTanaman ?? '');
    _luasCtrl = TextEditingController(
        text: d == null || d.luasM2 == 0 ? '' : '${d.luasM2}');
    _kkCtrl = TextEditingController(
        text: d == null || d.jumlahKk == 0 ? '' : '${d.jumlahKk}');
    _hasilCtrl = TextEditingController(text: d?.hasil ?? '');
  }

  @override
  void dispose() {
    _dasaWismaCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    _jenisCtrl.dispose();
    _luasCtrl.dispose();
    _kkCtrl.dispose();
    _hasilCtrl.dispose();
    super.dispose();
  }

  String? _serverError(String field) {
    final list = _fieldErrors[field];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _fieldErrors = {};
    });
    try {
      final payload = PemanfaatanTanah(
        id: widget.data?.id ?? '0',
        dasaWisma: _dasaWismaCtrl.text.trim(),
        rt: _rtCtrl.text.trim(),
        rw: _rwCtrl.text.trim(),
        dusun: _dusunCtrl.text.trim(),
        jenisTanaman: _jenisCtrl.text.trim(),
        luasM2: double.tryParse(_luasCtrl.text.trim().replaceAll(',', '.')) ?? 0,
        jumlahKk: int.tryParse(_kkCtrl.text.trim()) ?? 0,
        hasil: _hasilCtrl.text.trim(),
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
                        ? 'Edit Pemanfaatan Tanah'
                        : 'Tambah Pemanfaatan Tanah',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A))),
                Text('Desa & kecamatan otomatis dari akun login',
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
                _section(Icons.location_on_rounded, 'Identitas Wilayah',
                    'Lokasi pekarangan'),
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
                _section(Icons.grass_rounded, 'Tanaman & Hasil',
                    'Jenis, luas, KK, hasil panen'),
                const SizedBox(height: 14),
                _field(
                    ctrl: _jenisCtrl,
                    label: 'Jenis Tanaman',
                    hint: 'Cabai, tomat, ...',
                    icon: Icons.yard_outlined,
                    serverField: 'jenis_tanaman',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Jenis tanaman wajib diisi'
                        : null),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _field(
                          ctrl: _luasCtrl,
                          label: 'Luas (m²)',
                          hint: '50',
                          icon: Icons.square_foot_outlined,
                          keyboard: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,.]'))
                          ],
                          serverField: 'luas_m2')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(
                          ctrl: _kkCtrl,
                          label: 'Jumlah KK',
                          hint: '10',
                          icon: Icons.groups_outlined,
                          keyboard: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          serverField: 'jumlah_kk',
                          validator: (v) {
                            final n = int.tryParse((v ?? '').trim());
                            if (n == null || n < 0) {
                              return 'Isi jumlah KK (angka ≥ 0)';
                            }
                            return null;
                          })),
                ]),
                const SizedBox(height: 10),
                _field(
                    ctrl: _hasilCtrl,
                    label: 'Hasil',
                    hint: '20 kg cabai...',
                    icon: Icons.shopping_basket_outlined,
                    serverField: 'hasil'),
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
