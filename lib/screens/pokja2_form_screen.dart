import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pokja_2_model.dart';
import '../services/pokja2_service.dart';
import '../models/catatan_kegiatan.dart'; // For daftar39Kecamatan

class Pokja2FormScreen extends StatefulWidget {
  final Pokja2Model? item;

  const Pokja2FormScreen({super.key, this.item});

  @override
  State<Pokja2FormScreen> createState() => _Pokja2FormScreenState();
}

class _Pokja2FormScreenState extends State<Pokja2FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = Pokja2Service();
  final _picker = ImagePicker();

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  final _wargaButaLCtrl = TextEditingController();
  final _wargaButaPCtrl = TextEditingController();
  final _paketACtrl = TextEditingController();
  final _paketBCtrl = TextEditingController();
  final _paketCCtrl = TextEditingController();
  final _kfCtrl = TextEditingController();
  final _paudCtrl = TextEditingController();
  final _koperasiCtrl = TextEditingController();

  String _selectedKecamatan = 'Singaparna';

  File? _fotoFile;
  Uint8List? _fotoBytes;

  bool _isSaving = false;
  static const Color _pokja2Color = Color(0xFF059669); // Emerald for Pokja 2

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      final item = widget.item!;
      _selectedKecamatan = item.kecamatan ?? 'Singaparna';
      _wargaButaLCtrl.text = item.wargaButaL.toString();
      _wargaButaPCtrl.text = item.wargaButaP.toString();
      _paketACtrl.text = item.kelompokBelajarPaketA.toString();
      _paketBCtrl.text = item.kelompokBelajarPaketB.toString();
      _paketCCtrl.text = item.kelompokBelajarPaketC.toString();
      _kfCtrl.text = item.kf.toString();
      _paudCtrl.text = item.paud.toString();
      _koperasiCtrl.text = item.koperasiBadanHukum.toString();
      
      // Note: judul and deskripsi are not in Pokja2Model currently, 
      // they might need to be added if they are loaded from an API that provides them.
      // For now, we leave them blank on edit if they aren't in the model.
    } else {
      _wargaButaLCtrl.text = '0';
      _wargaButaPCtrl.text = '0';
      _paketACtrl.text = '0';
      _paketBCtrl.text = '0';
      _paketCCtrl.text = '0';
      _kfCtrl.text = '0';
      _paudCtrl.text = '0';
      _koperasiCtrl.text = '0';
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _wargaButaLCtrl.dispose();
    _wargaButaPCtrl.dispose();
    _paketACtrl.dispose();
    _paketBCtrl.dispose();
    _paketCCtrl.dispose();
    _kfCtrl.dispose();
    _paudCtrl.dispose();
    _koperasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    HapticFeedback.lightImpact();
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF3B82F6)),
                ),
                title: Text('Ambil dari Kamera', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981)),
                ),
                title: Text('Pilih dari Galeri', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (sumber == null) return;
    try {
      final gambar = await _picker.pickImage(source: sumber, imageQuality: 75, maxWidth: 1280);
      if (gambar != null) {
        final bytes = await gambar.readAsBytes();
        setState(() {
          _fotoBytes = bytes;
          if (!kIsWeb) {
            try {
              _fotoFile = File(gambar.path);
            } catch (_) {}
          }
        });
      }
    } catch (_) {}
  }

  void _showKecamatanPicker() {
    HapticFeedback.selectionClick();
    final searchCtrl = TextEditingController();
    List<String> filteredList = List.from(CatatanKegiatan.daftar39Kecamatan);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Pilih Kecamatan',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari kecamatan...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onChanged: (val) {
                    setModalState(() {
                      filteredList = CatatanKegiatan.daftar39Kecamatan
                          .where((k) => k.toLowerCase().contains(val.toLowerCase().trim()))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (ctx, i) {
                      final kec = filteredList[i];
                      final isSel = kec == _selectedKecamatan;
                      return ListTile(
                        title: Text(
                          kec,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                            color: isSel ? _pokja2Color : const Color(0xFF1E293B),
                          ),
                        ),
                        trailing: isSel ? const Icon(Icons.check_circle_rounded, color: _pokja2Color) : null,
                        onTap: () {
                          setState(() => _selectedKecamatan = kec);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      if (widget.item != null) {
        await _service.update(
          id: widget.item!.id,
          kecamatan: _selectedKecamatan,
          judulKegiatan: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          wargaButaL: int.tryParse(_wargaButaLCtrl.text) ?? 0,
          wargaButaP: int.tryParse(_wargaButaPCtrl.text) ?? 0,
          kelompokBelajarPaketA: int.tryParse(_paketACtrl.text) ?? 0,
          kelompokBelajarPaketB: int.tryParse(_paketBCtrl.text) ?? 0,
          kelompokBelajarPaketC: int.tryParse(_paketCCtrl.text) ?? 0,
          kf: int.tryParse(_kfCtrl.text) ?? 0,
          paud: int.tryParse(_paudCtrl.text) ?? 0,
          koperasiBerbadanHukum: int.tryParse(_koperasiCtrl.text) ?? 0,
          foto: _fotoFile,
        );
      } else {
        await _service.submit(
          kecamatan: _selectedKecamatan,
          judulKegiatan: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          wargaButaL: int.tryParse(_wargaButaLCtrl.text) ?? 0,
          wargaButaP: int.tryParse(_wargaButaPCtrl.text) ?? 0,
          kelompokBelajarPaketA: int.tryParse(_paketACtrl.text) ?? 0,
          kelompokBelajarPaketB: int.tryParse(_paketBCtrl.text) ?? 0,
          kelompokBelajarPaketC: int.tryParse(_paketCCtrl.text) ?? 0,
          kf: int.tryParse(_kfCtrl.text) ?? 0,
          paud: int.tryParse(_paudCtrl.text) ?? 0,
          koperasiBerbadanHukum: int.tryParse(_koperasiCtrl.text) ?? 0,
          foto: _fotoFile,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data Pokja II berhasil disimpan', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.item != null ? 'Edit Data Pokja II' : 'Input Data Pokja II',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_pokja2Color, _pokja2Color.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _pokja2Color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pokja II',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rekapitulasi Data Pokja II Tingkat Kecamatan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informasi Umum
            Text(
              'Informasi Umum',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _showKecamatanPicker,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_city_rounded, color: _pokja2Color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kecamatan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[500])),
                          Text(
                            _selectedKecamatan,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _judulController,
              decoration: InputDecoration(
                labelText: 'Judul Kegiatan *',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _deskripsiController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi Singkat',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),

            // Foto
            InkWell(
              onTap: _pilihFoto,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: _fotoBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(_fotoBytes!, fit: BoxFit.cover),
                      )
                    : (_fotoFile != null && !kIsWeb)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(_fotoFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, color: _pokja2Color.withValues(alpha: 0.5), size: 32),
                              const SizedBox(height: 8),
                              Text('Unggah Foto (Opsional)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),

            // Data Angka
            Text(
              'Rekapitulasi Angka',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildNumberField('Warga Buta Aksara L', _wargaButaLCtrl),
                    const Divider(height: 24),
                    _buildNumberField('Warga Buta Aksara P', _wargaButaPCtrl),
                    const Divider(height: 24),
                    _buildNumberField('Kel. Belajar Paket A', _paketACtrl),
                    const Divider(height: 24),
                    _buildNumberField('Kel. Belajar Paket B', _paketBCtrl),
                    const Divider(height: 24),
                    _buildNumberField('Kel. Belajar Paket C', _paketCCtrl),
                    const Divider(height: 24),
                    _buildNumberField('Keaksaraan Fungsional (KF)', _kfCtrl),
                    const Divider(height: 24),
                    _buildNumberField('PAUD / Sejenis', _paudCtrl),
                    const Divider(height: 24),
                    _buildNumberField('Koperasi Berbadan Hukum', _koperasiCtrl),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pokja2Color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan Data',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController ctrl) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () {
                  final cur = int.tryParse(ctrl.text) ?? 0;
                  if (cur > 0) {
                    HapticFeedback.selectionClick();
                    setState(() => ctrl.text = (cur - 1).toString());
                  }
                },
              ),
              SizedBox(
                width: 44,
                child: TextFormField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {
                  final cur = int.tryParse(ctrl.text) ?? 0;
                  HapticFeedback.selectionClick();
                  setState(() => ctrl.text = (cur + 1).toString());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
