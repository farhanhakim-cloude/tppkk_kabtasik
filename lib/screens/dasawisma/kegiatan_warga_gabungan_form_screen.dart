import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/kegiatan_warga.dart';
import '../../services/kegiatan_warga_service.dart';
import '../../services/api_exception.dart' show ApiValidationException;

// Form GABUNGAN: isi beberapa jenis kegiatan sekaligus dalam 1 layar,
// sekali tekan Kirim -> 1 POST per jenis yang dicentang.
// (Server tetap simpan per baris: 1 baris = 1 kegiatan.)

class _KegiatanRow {
  final String value;
  final String label;
  final IconData icon;
  bool ikut = false;
  final TextEditingController pesertaCtrl = TextEditingController();
  final TextEditingController keteranganCtrl = TextEditingController();
  DateTime? tanggal;

  _KegiatanRow({required this.value, required this.label, required this.icon});

  void dispose() {
    pesertaCtrl.dispose();
    keteranganCtrl.dispose();
  }
}

class KegiatanWargaGabunganFormScreen extends StatefulWidget {
  const KegiatanWargaGabunganFormScreen({super.key});

  @override
  State<KegiatanWargaGabunganFormScreen> createState() =>
      _KegiatanWargaGabunganFormScreenState();
}

class _KegiatanWargaGabunganFormScreenState
    extends State<KegiatanWargaGabunganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KegiatanWargaService();

  static const Color _primary = Color(0xFF0072BC);
  static const Color _primaryLight = Color(0xFFE6F1F9);

  late final TextEditingController _dasaWismaCtrl;
  late final TextEditingController _rtCtrl;
  late final TextEditingController _rwCtrl;
  late final TextEditingController _dusunCtrl;
  late final List<_KegiatanRow> _rows;

  bool _saving = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _dasaWismaCtrl = TextEditingController();
    _rtCtrl = TextEditingController();
    _rwCtrl = TextEditingController();
    _dusunCtrl = TextEditingController();
    _rows = <_KegiatanRow>[
      _KegiatanRow(
          value: 'up2k', label: 'UP2K', icon: Icons.storefront_outlined),
      _KegiatanRow(
          value: 'pekarangan',
          label: 'Tanah Pekarangan',
          icon: Icons.yard_outlined),
      _KegiatanRow(
          value: 'industri',
          label: 'Industri Rumah Tangga',
          icon: Icons.precision_manufacturing_outlined),
      _KegiatanRow(
          value: 'kesehatan',
          label: 'Kesehatan Lingkungan',
          icon: Icons.health_and_safety_outlined),
    ];
  }

  @override
  void dispose() {
    _dasaWismaCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _dusunCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _toggleRow(_KegiatanRow row, bool v) {
    setState(() {
      row.ikut = v;
      _formError = null;
    });
  }

  Future<void> _pickTanggal(_KegiatanRow row) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: row.tanggal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => row.tanggal = picked);
    }
  }

  String _fmtTanggal(DateTime t) => '${t.day}/${t.month}/${t.year}';

  Future<void> _save() async {
    if (_saving) return;
    final aktif = _rows.where((r) => r.ikut).toList();
    if (aktif.isEmpty) {
      setState(() => _formError = 'Centang minimal 1 jenis kegiatan dulu.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _formError = null;
    });

    var ok = 0;
    final gagal = <String>[];
    for (final r in aktif) {
      final payload = KegiatanWarga(
        id: '0',
        dasaWisma: _dasaWismaCtrl.text.trim(),
        rt: _rtCtrl.text.trim(),
        rw: _rwCtrl.text.trim(),
        dusun: _dusunCtrl.text.trim(),
        kegiatan: r.value,
        jumlahPeserta: int.tryParse(r.pesertaCtrl.text.trim()) ?? 0,
        tanggal: r.tanggal,
        keterangan: r.keteranganCtrl.text.trim(),
      );
      try {
        await _service.add(payload);
        ok++;
      } on ApiValidationException catch (e) {
        gagal.add('${r.label}: ${e.message}');
      } catch (e) {
        gagal.add('${r.label}: ${e.toString().replaceFirst('Exception: ', '')}');
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (gagal.isEmpty) {
      _snack('$ok kegiatan terkirim, menunggu persetujuan Admin Desa',
          ok: true);
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Tambah Kegiatan Warga',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Centang yang diikuti, kirim sekaligus',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
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
              onPressed: _save,
              child: Text(
                'Kirim',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: <Widget>[
            _section(
                Icons.location_on_rounded,
                'Wilayah, sekali isi',
                'Berlaku untuk semua kegiatan di bawah'),
            const SizedBox(height: 14),
            _plainField(
              ctrl: _dasaWismaCtrl,
              label: 'Dasa Wisma',
              hint: 'Mawar 01',
              icon: Icons.holiday_village_outlined,
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _plainField(
                    ctrl: _rtCtrl,
                    label: 'RT',
                    hint: '01',
                    icon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _plainField(
                    ctrl: _rwCtrl,
                    label: 'RW',
                    hint: '05',
                    icon: Icons.location_on_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _plainField(
              ctrl: _dusunCtrl,
              label: 'Dusun',
              hint: 'Cikunir',
              icon: Icons.landscape_outlined,
            ),
            const SizedBox(height: 28),
            _section(
                Icons.diversity_3_rounded,
                'Jenis Kegiatan',
                'Centang yang diikuti kader'),
            if (_formError != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _formError!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
            ],
            const SizedBox(height: 14),
            for (final r in _rows) _rowCard(r),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Kirim Semua',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowCard(_KegiatanRow row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: row.ikut
              ? const Color(0xFF5EEAD4)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          CheckboxListTile(
            value: row.ikut,
            onChanged: _saving ? null : (v) => _toggleRow(row, v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: _primary,
            title: Row(
              children: <Widget>[
                Icon(row.icon, size: 18, color: _primary),
                const SizedBox(width: 8),
                Text(
                  row.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          if (row.ikut)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: _pesertaField(row)),
                      const SizedBox(width: 10),
                      Expanded(child: _tanggalTile(row)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _keteranganField(row),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _pesertaField(_KegiatanRow row) {
    return TextFormField(
      controller: row.pesertaCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      style: GoogleFonts.plusJakartaSans(fontSize: 14),
      validator: (v) {
        if (!row.ikut) return null;
        final n = int.tryParse((v ?? '').trim());
        if (n == null || n <= 0) return 'Isi peserta';
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Jumlah Peserta',
        prefixIcon:
            const Icon(Icons.groups_outlined, size: 18, color: _primary),
        labelStyle:
            GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _tanggalTile(_KegiatanRow row) {
    return InkWell(
      onTap: () => _pickTanggal(row),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: _primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                row.tanggal == null
                    ? 'Tanggal'
                    : _fmtTanggal(row.tanggal!),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keteranganField(_KegiatanRow row) {
    return TextFormField(
      controller: row.keteranganCtrl,
      style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'Keterangan',
        hintStyle:
            GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[400]),
        prefixIcon:
            const Icon(Icons.edit_note_rounded, size: 18, color: _primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _section(IconData icon, String title, String sub) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: _primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: _primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _plainField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: ctrl,
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: _primary),
          hintStyle:
              GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
          labelStyle:
              GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
