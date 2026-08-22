import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kesehatan.dart';
import '../services/kesehatan_service.dart';

class KesehatanFormScreen extends StatefulWidget {
  final DataKesehatan? data;
  final KategoriKesehatan kategoriAwal;

  const KesehatanFormScreen({super.key, this.data, required this.kategoriAwal});

  @override
  State<KesehatanFormScreen> createState() => _KesehatanFormScreenState();
}

class _KesehatanFormScreenState extends State<KesehatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KesehatanService();

  late KategoriKesehatan _kategori;
  late final TextEditingController _namaIbuController;
  late final TextEditingController _namaAnakController;
  late final TextEditingController _usiaController;
  late final TextEditingController _statusGiziController;
  late final TextEditingController _rtController;
  late final TextEditingController _rwController;

  bool _saving = false;
  bool get _isEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _kategori = d?.kategori ?? widget.kategoriAwal;
    _namaIbuController = TextEditingController(text: d?.namaIbu ?? '');
    _namaAnakController = TextEditingController(text: d?.namaAnak ?? '');
    _usiaController = TextEditingController(text: d?.usiaKehamilanAtauAnak ?? '');
    _statusGiziController = TextEditingController(text: d?.statusGizi ?? '');
    _rtController = TextEditingController(text: d?.rt ?? '');
    _rwController = TextEditingController(text: d?.rw ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = DataKesehatan(
      id: widget.data?.id ?? 0,
      namaIbu: _namaIbuController.text.trim(),
      namaAnak: _namaAnakController.text.trim(),
      kategori: _kategori,
      usiaKehamilanAtauAnak: _usiaController.text.trim(),
      statusGizi: _statusGiziController.text.trim().isEmpty ? '-' : _statusGiziController.text.trim(),
      rt: _rtController.text.trim(),
      rw: _rwController.text.trim(),
    );

    if (_isEdit) {
      await _service.update(data);
    } else {
      await _service.add(data);
    }

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus data?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Data ini akan dihapus permanen.', style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: GoogleFonts.plusJakartaSans())),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _service.delete(widget.data!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[600]),
      );

  @override
  Widget build(BuildContext context) {
    final isBalita = _kategori == KategoriKesehatan.balita;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Data Kesehatan' : 'Tambah Data Kesehatan',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          if (_isEdit) IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<KategoriKesehatan>(
              value: _kategori,
              decoration: _dec('Kategori'),
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87),
              items: KategoriKesehatan.values
                  .map((k) => DropdownMenuItem(value: k, child: Text(k.label)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _namaIbuController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: _dec('Nama Ibu'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            if (isBalita) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _namaAnakController,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: _dec('Nama Anak'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _usiaController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: _dec(isBalita ? 'Usia Anak (contoh: 18 bulan)' : 'Usia Kehamilan/Menyusui (contoh: 20 minggu)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            if (isBalita) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _statusGiziController,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: _dec('Status Gizi (Normal/Kurang/Lebih)'),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rtController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: _dec('RT'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rwController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: _dec('RW'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(
                        _isEdit ? 'Simpan Perubahan' : 'Tambah Data',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}