import 'dart:convert';
// ignore_for_file: avoid_print, deprecated_member_use, unnecessary_import, unnecessary_null_comparison, dead_code, dead_null_aware_expression
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/berita_service.dart';

import '../models/berita.dart';

class BeritaFormScreen extends StatefulWidget {
  final Berita? berita;
  final bool isAdminMode;

  const BeritaFormScreen({super.key, this.berita, this.isAdminMode = false});

  @override
  State<BeritaFormScreen> createState() => _BeritaFormScreenState();
}

class _BeritaFormScreenState extends State<BeritaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _beritaService = BeritaService();
  final _picker = ImagePicker();

  final _judulController = TextEditingController();
  final _kontenController = TextEditingController();

  String _selectedKategori = 'Kegiatan PKK';
  String? _selectedKecamatan;

  // 🔥 FIX: ganti dari File? (dart:io) jadi Uint8List? — supaya aman
  // dipakai baik di Flutter Web maupun native (Android/iOS/Desktop).
  // dart:io.File tidak pernah bisa jalan di browser sama sekali.
  Uint8List? _fotoBytes;
  String? _fotoBase64;
  bool _isPublishing = false;
  bool _isLoadingKecamatan = true;

  final List<String> _kategoriList = [
    'Kegiatan PKK',
    'Posyandu',
    'Pelatihan & UP2K',
    'Gotong Royong',
    'Sosialisasi',
    'Pengumuman',
  ];

  final List<String> _kecamatanList = [
    'Bantarkalong',
    'Bojongasih',
    'Bojonggambir',
    'Ciawi',
    'Cibalong',
    'Cigalontang',
    'Cikalong',
    'Cikatomas',
    'Cineam',
    'Cipatujah',
    'Cisayong',
    'Culamega',
    'Gunungtanjung',
    'Jamanis',
    'Jatiwaras',
    'Kadipaten',
    'Karangjaya',
    'Karangnunggal',
    'Leuwisari',
    'Mangunreja',
    'Manonjaya',
    'Padakembang',
    'Pagerageung',
    'Pancatengah',
    'Parungponteng',
    'Puspahiang',
    'Rajapolah',
    'Salawu',
    'Salopa',
    'Sariwangi',
    'Singaparna',
    'Sodonghilir',
    'Sukahening',
    'Sukaraja',
    'Sukarame',
    'Sukaratu',
    'Sukaresik',
    'Tanjungjaya',
    'Taraju',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.berita != null) {
      _judulController.text = widget.berita!.judul;
      _kontenController.text =
          widget.berita!.konten ?? widget.berita!.deskripsi ?? '';
      if (widget.berita!.kategori != null &&
          _kategoriList.contains(widget.berita!.kategori)) {
        _selectedKategori = widget.berita!.kategori!;
      }
      if (widget.berita!.kecamatan != null &&
          _kecamatanList.contains(widget.berita!.kecamatan)) {
        _selectedKecamatan = widget.berita!.kecamatan;
      }
    }
    _loadDefaultKecamatan();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
    super.dispose();
  }

  // 🔥 LOAD DEFAULT KECAMATAN DARI SHARED PREFERENCES
  Future<void> _loadDefaultKecamatan() async {
    setState(() => _isLoadingKecamatan = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKecamatan = prefs.getString('default_kecamatan');
      if (savedKecamatan != null && _kecamatanList.contains(savedKecamatan)) {
        setState(() {
          _selectedKecamatan = savedKecamatan;
          _isLoadingKecamatan = false;
        });
      } else {
        setState(() => _isLoadingKecamatan = false);
      }
    } catch (e) {
      setState(() => _isLoadingKecamatan = false);
    }
  }

  // 🔥 PILIH FOTO — FIX: baca bytes langsung dari XFile, TIDAK bungkus
  // pakai dart:io File lagi. picked.readAsBytes() aman dipakai di
  // semua platform (web, Android, iOS, desktop).
  Future<void> _pilihFoto(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64 = base64Encode(bytes);
        setState(() {
          _fotoBytes = bytes;
          _fotoBase64 = base64;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    HapticFeedback.lightImpact();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDarkMode ? Colors.white70 : Colors.grey[500];

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
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
                  color: isDarkMode ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Sumber Foto Berita',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    color: Color(0xFF0D9488),
                  ),
                ),
                title: Text(
                  'Ambil dari Kamera',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  'Gunakan kamera HP untuk foto langsung',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: subtextColor,
                  ),
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
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                title: Text(
                  'Pilih dari Galeri',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  'Unggah gambar dokumentasi yang sudah ada',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: subtextColor,
                  ),
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

  // 🔥 SUBMIT BERITA
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    if (!widget.isAdminMode &&
        (_selectedKecamatan == null || _selectedKecamatan!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih kecamatan terlebih dahulu!',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);
    HapticFeedback.mediumImpact();

    try {
      // 🔥 FIX: fotoFile dihapus (parameter File? dart:io tidak aman
      // dipakai di Web). Upload foto sekarang murni lewat fotoBase64,
      // yang sudah dihasilkan dari bytes — aman di semua platform.
      final berita = await _beritaService.submitBerita(
        judul: _judulController.text.trim(),
        konten: _kontenController.text.trim(),
        kategori: _selectedKategori,
        kecamatan: _selectedKecamatan,
        fotoBase64: _fotoBase64,
      );

      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    berita != null
                        ? '✅ Berita berhasil dikirim! Menunggu persetujuan admin.'
                        : '✅ Berita berhasil dikirim!',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Gagal mengirim berita: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0D9488);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDarkMode
        ? const Color(0xFF14181F)
        : const Color(0xFFF8FAFC);
    final cardBg = isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDarkMode ? Colors.white70 : const Color(0xFF64748B);
    final faintColor = isDarkMode ? Colors.white54 : const Color(0xFF94A3B8);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? cardBg : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: textColor,
          ),
          onPressed: () {
            if (_judulController.text.isNotEmpty ||
                _kontenController.text.isNotEmpty ||
                _fotoBytes != null) {
              _showDiscardDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.berita != null ? 'Edit Berita' : 'Tulis Berita',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: textColor,
              ),
            ),
            Text(
              widget.isAdminMode
                  ? 'Publikasi langsung admin'
                  : 'Diverifikasi admin sebelum tampil',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: subtextColor,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. FOTO SAMPUL ──
              _sectionHeader(
                '1',
                'Foto Sampul',
                'JPG/PNG, opsional',
                primary,
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 8),
              _buildPhotoPicker(
                cardBg,
                borderColor,
                textColor,
                subtextColor,
                faintColor,
                primary,
                isDarkMode,
              ),
              const SizedBox(height: 18),

              // ── 2. LOKASI & KATEGORI ──
              _sectionHeader(
                '2',
                'Lokasi & Kategori',
                'Dari mana berita ini',
                primary,
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    if (!isDarkMode)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.isAdminMode) ...[
                      _fieldLabel('Kecamatan', true, textColor),
                      const SizedBox(height: 8),
                      if (_isLoadingKecamatan)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: _selectedKecamatan,
                          dropdownColor: cardBg,
                          style: GoogleFonts.plusJakartaSans(
                            color: textColor,
                            fontSize: 14,
                          ),
                          decoration: _inputDeco(
                            'Pilih Kecamatan',
                            null,
                            Icon(
                              Icons.location_on_rounded,
                              color: primary,
                              size: 20,
                            ),
                            cardBg,
                            borderColor,
                            subtextColor,
                            primary,
                          ),
                          items: _kecamatanList.map((kec) {
                            return DropdownMenuItem(
                              value: kec,
                              child: Text(
                                kec,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedKecamatan = value),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Pilih kecamatan terlebih dahulu';
                            return null;
                          },
                        ),
                      const SizedBox(height: 16),
                    ],
                    _fieldLabel('Kategori Berita', false, textColor),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _kategoriList.map((kat) {
                        final isSelected = kat == _selectedKategori;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              if (isSelected) const SizedBox(width: 4),
                              Text(kat),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: primary,
                          backgroundColor: isDarkMode
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFF1F5F9),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected ? Colors.white : subtextColor,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          showCheckmark: false,
                          onSelected: (selected) {
                            if (selected) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedKategori = kat);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── 3. JUDUL & ISI ──
              _sectionHeader(
                '3',
                'Judul & Isi',
                'Tulis kabar kegiatan',
                primary,
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    if (!isDarkMode)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Judul Berita', true, textColor),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _judulController,
                      maxLength: 120,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      decoration: _inputDeco(
                        'Contoh: Posyandu Mawar Bulan September',
                        null,
                        Icon(Icons.title_rounded, size: 20, color: primary),
                        cardBg,
                        borderColor,
                        subtextColor,
                        primary,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Judul berita wajib diisi';
                        if (v.trim().length < 5)
                          return 'Judul minimal 5 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel('Isi Lengkap Berita', true, textColor),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _kontenController,
                      maxLines: 7,
                      minLines: 5,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        height: 1.5,
                        color: textColor,
                      ),
                      decoration: _inputDeco(
                        'Tuliskan narasi lengkap: kegiatan, pihak terlibat, lokasi, hasil...',
                        null,
                        null,
                        cardBg,
                        borderColor,
                        subtextColor,
                        primary,
                      ).copyWith(contentPadding: const EdgeInsets.all(14)),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Isi berita wajib diisi';
                        if (v.trim().length < 20)
                          return 'Isi berita minimal 20 karakter';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── BADGE PENERBIT ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? primary.withOpacity(0.1)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDarkMode
                        ? primary.withOpacity(0.2)
                        : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
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
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.isAdminMode
                                ? 'Berita langsung terbit sebagai admin.'
                                : 'Berita diverifikasi admin sebelum tampil di publik.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isPublishing ? null : _handleSubmit,
              icon: _isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_rounded, size: 20),
              label: Text(
                _isPublishing ? 'Mengirim...' : 'Kirim Berita',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Judul seksi bernomor ala langkah form
  Widget _sectionHeader(
    String num,
    String title,
    String subtitle,
    Color primary,
    Color textColor,
    Color subColor,
  ) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
          child: Center(
            child: Text(
              num,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subColor),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label, bool required, Color textColor) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDeco(
    String hint,
    String? counter,
    Widget? prefix,
    Color fill,
    Color border,
    Color hintColor,
    Color primary,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: hintColor),
      prefixIcon: prefix,
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.6),
      ),
    );
  }

  Widget _buildPhotoPicker(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subtextColor,
    Color faintColor,
    Color primary,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: _showImagePickerSheet,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _fotoBytes != null ? primary.withOpacity(0.5) : borderColor,
            width: 1.2,
          ),
          boxShadow: [
            if (!isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: _fotoBytes != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(
                      _fotoBytes!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 13,
                                color: primary,
                              ),
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
                            setState(() {
                              _fotoBytes = null;
                              _fotoBase64 = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
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
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 32,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Ketuk untuk unggah foto sampul',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'JPG / PNG • opsional',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: faintColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // 🔥 DIALOG DISCARD
  void _showDiscardDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDarkMode ? Colors.white70 : const Color(0xFF475569);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Batalkan Penulisan?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        content: Text(
          'Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?',
          style: GoogleFonts.plusJakartaSans(color: subtextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Lanjut Menulis',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'Keluar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
