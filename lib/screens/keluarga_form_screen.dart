import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/keluarga.dart';
import '../services/keluarga_service.dart';
import 'map_picker_screen.dart';

class KeluargaFormScreen extends StatefulWidget {
  final Keluarga? keluarga;

  const KeluargaFormScreen({super.key, this.keluarga});

  @override
  State<KeluargaFormScreen> createState() => _KeluargaFormScreenState();
}

class _KeluargaFormScreenState extends State<KeluargaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KeluargaService();
  final _picker = ImagePicker();

  late final TextEditingController _namaController;
  late final TextEditingController _alamatController;
  late final TextEditingController _rtController;
  late final TextEditingController _rwController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _pekerjaanController;

  File? _fotoRumah;
  double? _latitude;
  double? _longitude;
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
    _jumlahController = TextEditingController(text: k != null ? k.jumlahAnggota.toString() : '');
    _pekerjaanController = TextEditingController(text: k?.pekerjaan ?? '');
    _latitude = k?.latitude;
    _longitude = k?.longitude;

    if (k?.fotoRumahPath != null) {
      _fotoRumah = File(k!.fotoRumahPath!);
    }
  }

  Future<void> _pilihFoto() async {
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text('Ambil dari Kamera', style: GoogleFonts.plusJakartaSans()),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Pilih dari Galeri', style: GoogleFonts.plusJakartaSans()),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (sumber == null) return;

    final gambar = await _picker.pickImage(source: sumber, imageQuality: 70, maxWidth: 1280);

    if (gambar != null) {
      setState(() => _fotoRumah = File(gambar.path));
    }
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
      fotoRumahPath: _fotoRumah?.path,
      latitude: _latitude,
      longitude: _longitude,
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
        title: Text('Hapus data?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text(
          'Data keluarga "${widget.keluarga!.namaKepalaKeluarga}" akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: GoogleFonts.plusJakartaSans())),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _service.delete(widget.keluarga!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[600]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Data Keluarga' : 'Tambah Data Keluarga',
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
            TextFormField(
              controller: _namaController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: _dec('Nama Kepala Keluarga'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _alamatController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: _dec('Alamat'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rtController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: _dec('RT'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rwController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: _dec('RW'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jumlahController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: _dec('Jumlah Anggota Keluarga'),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pekerjaanController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: _dec('Pekerjaan Kepala Keluarga'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 22),
            Text('Foto Rumah', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pilihFoto,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _fotoRumah != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_fotoRumah!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                  onPressed: () => setState(() => _fotoRumah = null),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: Colors.grey[400], size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Ketuk untuk ambil foto rumah',
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Peta Lokasi Rumah', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.map_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _latitude != null && _longitude != null
                                  ? 'Lokasi Terpilih'
                                  : 'Lokasi belum diatur',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _latitude != null && _longitude != null
                                  ? 'Lat: ${_latitude!.toStringAsFixed(5)}, Lng: ${_longitude!.toStringAsFixed(5)}'
                                  : 'Silakan pilih titik lokasi rumah di peta',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push<Map<String, double>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPickerScreen(
                              initialLat: _latitude,
                              initialLng: _longitude,
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _latitude = result['lat'];
                            _longitude = result['lng'];
                          });
                        }
                      },
                      icon: const Icon(Icons.pin_drop_rounded, size: 16),
                      label: Text(
                        _latitude != null && _longitude != null ? 'Ubah Lokasi' : 'Pilih Lokasi',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
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