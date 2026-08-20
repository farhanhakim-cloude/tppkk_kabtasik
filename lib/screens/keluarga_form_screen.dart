import 'package:flutter/material.dart';
import '../models/keluarga.dart';
import '../services/keluarga_service.dart';

class KeluargaFormScreen extends StatefulWidget {
  final Keluarga? keluarga; // null = mode tambah, ada isi = mode edit

  const KeluargaFormScreen({super.key, this.keluarga});

  @override
  State<KeluargaFormScreen> createState() => _KeluargaFormScreenState();
}

class _KeluargaFormScreenState extends State<KeluargaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KeluargaService();

  late final TextEditingController _namaController;
  late final TextEditingController _alamatController;
  late final TextEditingController _rtController;
  late final TextEditingController _rwController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _pekerjaanController;

  bool _saving = false;
  bool get _isEdit => widget.keluarga != null;

  @override
  void initState() {
    super.initState();
    final k = widget.keluarga;
    _namaController = TextEditingController(text: k?.namaKepalaKeluarga ?? '');
    _alamatController = TextEditingController(text: k?.alamat ?? '');
    _rtController = TextEditingController(text: k?.rt ?? '');
    _rwController = TextEditingController(text: k?.rw ?? '');
    _jumlahController = TextEditingController(text: k?.jumlahAnggota.toString() ?? '');
    _pekerjaanController = TextEditingController(text: k?.pekerjaan ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final keluarga = Keluarga(
      id: widget.keluarga?.id ?? 0,
      namaKepalaKeluarga: _namaController.text.trim(),
      alamat: _alamatController.text.trim(),
      rt: _rtController.text.trim(),
      rw: _rwController.text.trim(),
      jumlahAnggota: int.tryParse(_jumlahController.text) ?? 0,
      pekerjaan: _pekerjaanController.text.trim(),
    );

    if (_isEdit) {
      await _service.update(keluarga);
    } else {
      await _service.add(keluarga);
    }

    setState(() => _saving = false);

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text('Data keluarga "${widget.keluarga!.namaKepalaKeluarga}" akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await _service.delete(widget.keluarga!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Data Keluarga' : 'Tambah Data Keluarga'),
        actions: [
          if (_isEdit)
            IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Kepala Keluarga'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _alamatController,
              decoration: const InputDecoration(labelText: 'Alamat'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rtController,
                    decoration: const InputDecoration(labelText: 'RT'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rwController,
                    decoration: const InputDecoration(labelText: 'RW'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jumlahController,
              decoration: const InputDecoration(labelText: 'Jumlah Anggota Keluarga'),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pekerjaanController,
              decoration: const InputDecoration(labelText: 'Pekerjaan Kepala Keluarga'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _save,
                    child: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Data'),
                  ),
          ],
        ),
      ),
    );
  }
}