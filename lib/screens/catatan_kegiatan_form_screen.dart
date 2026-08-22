import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/catatan_kegiatan.dart';
import '../services/catatan_kegiatan_service.dart';

class CatatanKegiatanFormScreen extends StatefulWidget {
  const CatatanKegiatanFormScreen({super.key});

  @override
  State<CatatanKegiatanFormScreen> createState() => _CatatanKegiatanFormScreenState();
}

class _CatatanKegiatanFormScreenState extends State<CatatanKegiatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CatatanKegiatanService();
  final _picker = ImagePicker();

  final _judulController = TextEditingController();
  final _ceritaController = TextEditingController();

  PokjaKategori? _kategori;
  Map<String, TextEditingController> _angkaControllers = {};
  File? _foto;
  bool _sending = false;

  void _onKategoriChanged(PokjaKategori? kategori) {
    setState(() {
      _kategori = kategori;
      // Regenerasi controller sesuai field yang relevan untuk kategori ini
      _angkaControllers = {
        for (final field in kategori?.fieldAngka ?? <String>[])
          field: TextEditingController(text: '0'),
      };
    });
  }

  Future<void> _pilihFoto() async {
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
    if (gambar != null) setState(() => _foto = File(gambar.path));
  }

  Future<void> _kirim() async {
    if (!_formKey.currentState!.validate()) return;
    if (_kategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih kategori kegiatan terlebih dahulu', style: GoogleFonts.plusJakartaSans())),
      );
      return;
    }

    setState(() => _sending = true);

    final dataAngka = {
      for (final entry in _angkaControllers.entries)
        entry.key: int.tryParse(entry.value.text) ?? 0,
    };

    await _service.kirim(CatatanKegiatan(
      id: 0,
      judul: _judulController.text.trim(),
      ceritaSingkat: _ceritaController.text.trim(),
      kategori: _kategori!,
      dataAngka: dataAngka,
      fotoPath: _foto?.path,
      tanggal: DateTime.now(),
    ));

    setState(() => _sending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan kegiatan terkirim ke Admin Kecamatan', style: GoogleFonts.plusJakartaSans())),
      );
      Navigator.pop(context, true);
    }
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[600]),
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
      );

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Catat Kegiatan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Catatan ini tidak tampil di website publik, hanya masuk ke Admin Kecamatan.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _judulController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: _dec('Judul Kegiatan', hint: 'Contoh: Posyandu Balita Bulan Agustus'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _ceritaController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              maxLines: 4,
              decoration: _dec('Cerita Singkat', hint: 'Apa yang terjadi di kegiatan ini?'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<PokjaKategori>(
              value: _kategori,
              decoration: _dec('Kategori Kegiatan'),
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87),
              items: PokjaKategori.values
                  .map((k) => DropdownMenuItem(value: k, child: Text(k.label, style: GoogleFonts.plusJakartaSans(fontSize: 13))))
                  .toList(),
              onChanged: _onKategoriChanged,
              validator: (v) => v == null ? 'Pilih kategori' : null,
            ),

            if (_kategori != null) ...[
              const SizedBox(height: 20),
              Text('Data Angka Kegiatan', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Isi sesuai kategori "${_kategori!.label}"',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              ..._angkaControllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: _dec(entry.key),
                  ),
                );
              }),
            ],

            const SizedBox(height: 20),
            Text('Foto Kegiatan', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
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
                child: _foto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_foto!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                  onPressed: () => setState(() => _foto = null),
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
                          Text('Ketuk untuk ambil foto kegiatan', style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 13)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            _sending
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _kirim,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: Text('Kirim Catatan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}