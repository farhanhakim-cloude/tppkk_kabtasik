import 'package:flutter/material.dart';
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
        title: const Text('Hapus data?'),
        content: const Text('Data ini akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await _service.delete(widget.data!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBalita = _kategori == KategoriKesehatan.balita;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Data Kesehatan' : 'Tambah Data Kesehatan'),
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
            DropdownButtonFormField<KategoriKesehatan>(
              value: _kategori,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: KategoriKesehatan.values
                  .map((k) => DropdownMenuItem(value: k, child: Text(k.label)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _namaIbuController,
              decoration: const InputDecoration(labelText: 'Nama Ibu'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            if (isBalita) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _namaAnakController,
                decoration: const InputDecoration(labelText: 'Nama Anak'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _usiaController,
              decoration: InputDecoration(
                labelText: isBalita ? 'Usia Anak (contoh: 18 bulan)' : 'Usia Kehamilan/Menyusui (contoh: 20 minggu)',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            if (isBalita) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _statusGiziController,
                decoration: const InputDecoration(labelText: 'Status Gizi (Normal/Kurang/Lebih)'),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rtController,
                    decoration: const InputDecoration(labelText: 'RT'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rwController,
                    decoration: const InputDecoration(labelText: 'RW'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                  ),
                ),
              ],
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