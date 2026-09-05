import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/berita_service.dart';

class BeritaFormScreen extends StatefulWidget {
  const BeritaFormScreen({super.key});

  @override
  State<BeritaFormScreen> createState() => _BeritaFormScreenState();
}

class _BeritaFormScreenState extends State<BeritaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _beritaService = BeritaService();
  final _picker = ImagePicker();

  final _judulController = TextEditingController();
  final _ringkasanController = TextEditingController();
  final _kontenController = TextEditingController();

  String _selectedKategori = 'Kegiatan PKK';
  File? _fotoFile;
  bool _isPublishing = false;

  final List<String> _kategoriList = [
    'Kegiatan PKK',
    'Posyandu',
    'Pelatihan & UP2K',
    'Gotong Royong',
    'Sosialisasi',
    'Pengumuman',
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _ringkasanController.dispose();
    _kontenController.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked != null) {
        setState(() {
          _fotoFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Sumber Foto Berita',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_camera_rounded, color: Color(0xFF0D9488)),
                ),
                title: Text(
                  'Ambil dari Kamera',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Gunakan kamera HP untuk foto langsung',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pilihFoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF3B82F6)),
                ),
                title: Text(
                  'Pilih dari Galeri',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Unggah gambar dokumentasi yang sudah ada',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pilihFoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isPublishing = true);
    HapticFeedback.mediumImpact();

    try {
      await _beritaService.publishBerita(
        judul: _judulController.text.trim(),
        ringkasan: _ringkasanController.text.trim(),
        konten: _kontenController.text.trim(),
        kategori: _selectedKategori,
        fotoFile: _fotoFile,
      );

      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Berita berhasil dipublikasikan!',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Publikasikan Berita',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _isPublishing ? null : _handlePublish,
              icon: _isPublishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D9488)),
                    )
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(
                'Publish',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: primary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // ── FOTO BERITA BANNER ──
            GestureDetector(
              onTap: _showImagePickerSheet,
              child: Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _fotoFile != null ? primary.withOpacity(0.4) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _fotoFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: Image.file(
                              _fotoFile!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.55),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded, size: 14, color: primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Ganti Foto',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => _fotoFile = null);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add_photo_alternate_rounded, size: 36, color: primary),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Unggah Foto Sampul Berita',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Format JPG atau PNG (Opsional)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // ── KATEGORI CHIPS ──
            Text(
              'Kategori Berita',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kategoriList.map((kat) {
                final isSelected = kat == _selectedKategori;
                return ChoiceChip(
                  label: Text(kat),
                  selected: isSelected,
                  selectedColor: primary,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                  side: BorderSide(
                    color: isSelected ? primary : const Color(0xFFCBD5E1),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedKategori = kat);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── JUDUL BERITA ──
            Row(
              children: [
                Text(
                  'Judul Berita',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('*', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _judulController,
              maxLength: 120,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Contoh: Pelaksanaan Posyandu Mawar Bulan September',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.title_rounded, size: 20, color: primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primary, width: 1.8),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul berita wajib diisi';
                if (v.trim().length < 5) return 'Judul minimal 5 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── RINGKASAN BERITA ──
            Row(
              children: [
                Text(
                  'Ringkasan Singkat (Lead / Excerpt)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('*', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ringkasanController,
              maxLines: 3,
              maxLength: 250,
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Tuliskan rangkuman 1-2 kalimat yang akan muncul di daftar berita...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primary, width: 1.8),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ringkasan berita wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── KONTEN LENGKAP ──
            Row(
              children: [
                Text(
                  'Isi Lengkap Berita',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('*', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _kontenController,
              maxLines: 8,
              minLines: 5,
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5, height: 1.5),
              decoration: InputDecoration(
                hintText: 'Tuliskan narasi lengkap kegiatan, pihak yang terlibat, lokasi, dan hasil yang dicapai...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primary, width: 1.8),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Isi berita wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── BADGE PENERBIT ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Publikasi Resmi TP PKK',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Berita akan diverifikasi dan tampil di Beranda serta Portal Berita PKK.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── TOMBOL SUBMIT ──
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isPublishing ? null : _handlePublish,
                icon: _isPublishing
                    ? const SizedBox.shrink()
                    : const Icon(Icons.cloud_upload_rounded, size: 20),
                label: _isPublishing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'Publikasikan Berita',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: primary.withOpacity(0.35),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
