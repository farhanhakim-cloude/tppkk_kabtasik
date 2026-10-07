import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/industri_rumah_tangga.dart';
import '../../services/industri_rumah_tangga_service.dart';
import '../../services/api_exception.dart';

class IndustriRumahTanggaFormScreen extends StatefulWidget {
  final IndustriRumahTangga? data;
  const IndustriRumahTanggaFormScreen({super.key, this.data});
  @override
  State<IndustriRumahTanggaFormScreen> createState() =>
      _IndustriRumahTanggaFormScreenState();
}

class _IndustriRumahTanggaFormScreenState
    extends State<IndustriRumahTanggaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = IndustriRumahTanggaService();
  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryLight = Color(0xFFF0F9FF);

  late final TextEditingController _dasaWismaCtrl,
      _rtCtrl,
      _rwCtrl,
      _dusunCtrl,
      _jenisCtrl,
      _pemilikCtrl,
      _tenagaCtrl,
      _omzetCtrl;
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
    _jenisCtrl = TextEditingController(text: d?.jenisIndustri ?? '');
    _pemilikCtrl = TextEditingController(text: d?.pemilik ?? '');
    _tenagaCtrl = TextEditingController(
        text: d == null || d.jumlahTenagaKerja == 0
            ? ''
            : '${d.jumlahTenagaKerja}');
    _omzetCtrl = TextEditingController(
        text: d == null || d.omzet == 0
            ? ''
            : d.omzet.toStringAsFixed(
                d.omzet.truncateToDouble() == d.omzet ? 0 : 2));
  }

  @override
  void dispose() {
    _dasaWismaCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    _jenisCtrl.dispose();
    _pemilikCtrl.dispose();
    _tenagaCtrl.dispose();
    _omzetCtrl.dispose();
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
      final payload = IndustriRumahTangga(
        id: widget.data?.id ?? '0',
        dasaWisma: _dasaWismaCtrl.text.trim(),
        rt: _rtCtrl.text.trim(),
        rw: _rwCtrl.text.trim(),
        dusun: _dusunCtrl.text.trim(),
        jenisIndustri: _jenisCtrl.text.trim(),
        pemilik: _pemilikCtrl.text.trim(),
        jumlahTenagaKerja: int.tryParse(_tenagaCtrl.text.trim()) ?? 0,
        omzet:
            double.tryParse(_omzetCtrl.text.trim().replaceAll('.', '')) ?? 0,
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
                Text(
                    _isEdit
                        ? 'Edit Industri Rumah Tangga'
                        : 'Tambah Industri Rumah Tangga',
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
                    'Lokasi usaha'),
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
                _section(Icons.storefront_rounded, 'Data Usaha',
                    'Jenis, pemilik, tenaga kerja, omzet'),
                const SizedBox(height: 14),
                _field(
                    ctrl: _jenisCtrl,
                    label: 'Jenis Industri',
                    hint: 'Kerupuk, batik, ...',
                    icon: Icons.precision_manufacturing_outlined,
                    serverField: 'jenis_industri',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Jenis industri wajib diisi'
                        : null),
                const SizedBox(height: 10),
                _field(
                    ctrl: _pemilikCtrl,
                    label: 'Pemilik',
                    hint: 'Nama pemilik usaha',
                    icon: Icons.person_outline_rounded,
                    serverField: 'pemilik',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Pemilik wajib diisi'
                        : null),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _field(
                          ctrl: _tenagaCtrl,
                          label: 'Tenaga Kerja',
                          hint: '5',
                          icon: Icons.groups_outlined,
                          keyboard: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          serverField: 'jumlah_tenaga_kerja',
                          validator: (v) {
                            final n = int.tryParse((v ?? '').trim());
                            if (n == null || n < 0) {
                              return 'Isi angka ≥ 0';
                            }
                            return null;
                          })),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(
                          ctrl: _omzetCtrl,
                          label: 'Omzet (Rp)',
                          hint: '2500000',
                          icon: Icons.payments_outlined,
                          keyboard: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          serverField: 'omzet')),
                ]),
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
