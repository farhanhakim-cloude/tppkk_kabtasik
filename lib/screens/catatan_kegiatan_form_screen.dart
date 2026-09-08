// lib/screens/catatan_kegiatan_form_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/catatan_kegiatan.dart';
import '../services/catatan_kegiatan_service.dart';

class CatatanKegiatanFormScreen extends StatefulWidget {
  final CatatanKegiatan? catatan;
  final PokjaKategori? pokjaAwal;

  const CatatanKegiatanFormScreen({super.key, this.catatan, this.pokjaAwal});

  @override
  State<CatatanKegiatanFormScreen> createState() => _CatatanKegiatanFormScreenState();
}

class _CatatanKegiatanFormScreenState extends State<CatatanKegiatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CatatanKegiatanService();
  final _picker = ImagePicker();

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _desaController = TextEditingController();

  // Controllers untuk data angka pokja
  final Map<String, TextEditingController> _angkaCtrl = {};

  // Status apakah Pokja sudah dipilih
  bool _pokjaDipilih = false;
  late PokjaKategori _kategori;
  String _selectedKecamatan = 'Singaparna';

  // State gambar kompatibel Web & Mobile
  File? _fotoFile;
  Uint8List? _fotoBytes;

  DateTime _tanggal = DateTime.now();
  bool _isSaving = false;

  // Sub-kegiatan aktif untuk mode fokus tab per pokja
  final Map<PokjaKategori, int> _selectedSubIndex = {
    PokjaKategori.pokja1: 0,
    PokjaKategori.pokja2: 0,
    PokjaKategori.pokja3: 0,
    PokjaKategori.pokja4: 0,
  };

  @override
  void initState() {
    super.initState();

    // Inisialisasi semua controller untuk seluruh field pokja
    final allFields = [
      ...PokjaKategori.pokja1.fieldAngka,
      ...PokjaKategori.pokja2.fieldAngka,
      ...PokjaKategori.pokja3.fieldAngka,
      ...PokjaKategori.pokja4.fieldAngka,
    ];
    for (final f in allFields) {
      _angkaCtrl[f] = TextEditingController();
    }

    if (widget.catatan != null) {
      final c = widget.catatan!;
      _kategori = c.kategori;
      _pokjaDipilih = true;
      _judulController.text = c.judul;
      _deskripsiController.text = c.deskripsiSingkat;
      _desaController.text = c.desa ?? '';
      _selectedKecamatan = c.kecamatan;
      _tanggal = c.tanggal;
      if (c.fotoPath != null && c.fotoPath!.isNotEmpty) {
        try {
          if (!kIsWeb) {
            _fotoFile = File(c.fotoPath!);
          }
        } catch (_) {}
      }
      for (final f in allFields) {
        final val = c.dataAngka[f];
        if (val != null && val != 0) {
          _angkaCtrl[f]!.text = val.toString();
        }
      }
    } else if (widget.pokjaAwal != null) {
      _kategori = widget.pokjaAwal!;
      _pokjaDipilih = true;
    } else {
      _kategori = PokjaKategori.pokja1;
      _pokjaDipilih = false;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _desaController.dispose();
    for (final c in _angkaCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Color _getPokjaColor(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return const Color(0xFF2563EB); // Royal Blue
      case PokjaKategori.pokja2:
        return const Color(0xFF059669); // Emerald
      case PokjaKategori.pokja3:
        return const Color(0xFFD97706); // Amber
      case PokjaKategori.pokja4:
        return const Color(0xFFDC2626); // Rose/Red
    }
  }

  IconData _getPokjaIcon(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return Icons.groups_rounded;
      case PokjaKategori.pokja2:
        return Icons.school_rounded;
      case PokjaKategori.pokja3:
        return Icons.cottage_rounded;
      case PokjaKategori.pokja4:
        return Icons.health_and_safety_rounded;
    }
  }

  String _getPokjaSubtitle(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return 'Gotong Royong, Pola Asuh (PAAR), PKBN, PKDRT, Lansia';
      case PokjaKategori.pokja2:
        return 'Pendidikan, Keterampilan, Usaha Ekonomi (UP2K), Koperasi';
      case PokjaKategori.pokja3:
        return 'Ketahanan Pangan (HATINYA PKK), Sandang, Perumahan Sehat';
      case PokjaKategori.pokja4:
        return 'Kesehatan, Posyandu, Lingkungan Hidup, Perencanaan Sehat';
    }
  }

  String _getJudulPlaceholder(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return 'Contoh: Penyuluhan Pola Asuh Anak & Remaja (PAAR)';
      case PokjaKategori.pokja2:
        return 'Contoh: Pelatihan Olahan Pangan Lokal Kelompok UP2K';
      case PokjaKategori.pokja3:
        return 'Contoh: Gerakan Menanam Halaman Asri Teratur Indah (HATINYA PKK)';
      case PokjaKategori.pokja4:
        return 'Contoh: Posyandu Balita, Imunisasi & Penyuluhan PHBS';
    }
  }

  // Definisi grup kegiatan data angka sesuai field database
  List<_PokjaSubItem> _getSubItems(PokjaKategori pokja) {
    switch (pokja) {
      case PokjaKategori.pokja1:
        return [
          _PokjaSubItem(
            title: 'PKBN',
            deskripsi: 'Pembinaan Kesadaran Bela Negara',
            fieldL: 'pkbn_l',
            fieldP: 'pkbn_p',
            icon: Icons.shield_rounded,
          ),
          _PokjaSubItem(
            title: 'PKDRT',
            deskripsi: 'Pencegahan Kekerasan Dalam Rumah Tangga',
            fieldL: 'pkdrt_l',
            fieldP: 'pkdrt_p',
            icon: Icons.family_restroom_rounded,
          ),
          _PokjaSubItem(
            title: 'Pola Asuh',
            deskripsi: 'Pola Asuh Anak dan Remaja (PAAR)',
            fieldL: 'pola_asuh_l',
            fieldP: 'pola_asuh_p',
            icon: Icons.child_care_rounded,
          ),
          _PokjaSubItem(
            title: 'Lansia',
            deskripsi: 'Bina Keluarga Lansia (BKL)',
            fieldL: 'lansia_l',
            fieldP: 'lansia_p',
            icon: Icons.elderly_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Pokja I',
            deskripsi: 'Jumlah Kader Pembinaan Pokja I',
            fieldL: 'kader_pokja1_l',
            fieldP: 'kader_pokja1_p',
            icon: Icons.badge_rounded,
          ),
        ];

      case PokjaKategori.pokja2:
        return [
          _PokjaSubItem(
            title: 'Pendidikan',
            deskripsi: 'Warga Belajar & Keaksaraan',
            fieldL: 'pendidikan_l',
            fieldP: 'pendidikan_p',
            icon: Icons.menu_book_rounded,
          ),
          _PokjaSubItem(
            title: 'Keterampilan',
            deskripsi: 'Pelatihan Keterampilan & Kursus Warga',
            fieldL: 'keterampilan_l',
            fieldP: 'keterampilan_p',
            icon: Icons.handyman_rounded,
          ),
          _PokjaSubItem(
            title: 'Koperasi & UP2K',
            deskripsi: 'Kelompok UP2K & Usaha Koperasi',
            fieldL: 'koperasi_l',
            fieldP: 'koperasi_p',
            icon: Icons.storefront_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Pokja II',
            deskripsi: 'Jumlah Kader Pembina Pokja II',
            fieldL: 'kader_pokja2_l',
            fieldP: 'kader_pokja2_p',
            icon: Icons.badge_rounded,
          ),
        ];

      case PokjaKategori.pokja3:
        return [
          _PokjaSubItem(
            title: 'Pangan / HATINYA',
            deskripsi: 'Pemanfaatan Pekarangan & Tanaman Pangan',
            fieldL: 'pangan_l',
            fieldP: 'pangan_p',
            icon: Icons.grass_rounded,
          ),
          _PokjaSubItem(
            title: 'Sandang',
            deskripsi: 'Pemanfaatan Kain & Pelatihan Busana',
            fieldL: 'sandang_l',
            fieldP: 'sandang_p',
            icon: Icons.checkroom_rounded,
          ),
          _PokjaSubItem(
            title: 'Perumahan',
            deskripsi: 'Rumah Layak Huni & Tata Laksana Rumah',
            fieldL: 'perumahan_l',
            fieldP: 'perumahan_p',
            icon: Icons.roofing_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Pokja III',
            deskripsi: 'Jumlah Kader Pembina Pokja III',
            fieldL: 'kader_pokja3_l',
            fieldP: 'kader_pokja3_p',
            icon: Icons.badge_rounded,
          ),
        ];

      case PokjaKategori.pokja4:
        return [
          _PokjaSubItem(
            title: 'Kesehatan & Posyandu',
            deskripsi: 'Posyandu, Imunisasi, Ibu & Balita Sehat',
            fieldL: 'kesehatan_l',
            fieldP: 'kesehatan_p',
            icon: Icons.local_hospital_rounded,
          ),
          _PokjaSubItem(
            title: 'Lingkungan Hidup',
            deskripsi: 'Sanitasi, Jamban Sehat, Air Bersih, PHBS',
            fieldL: 'lingkungan_l',
            fieldP: 'lingkungan_p',
            icon: Icons.eco_rounded,
          ),
          _PokjaSubItem(
            title: 'Perencanaan Sehat / KB',
            deskripsi: 'Penyuluhan KB & Tabungan Keluarga',
            fieldL: 'perencanaan_l',
            fieldP: 'perencanaan_p',
            icon: Icons.savings_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Pokja IV',
            deskripsi: 'Jumlah Kader Posyandu & Pokja IV',
            fieldL: 'kader_pokja4_l',
            fieldP: 'kader_pokja4_p',
            icon: Icons.badge_rounded,
          ),
        ];
    }
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
                title: Text('Ambil dari Kamera',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
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
                title: Text('Pilih dari Galeri',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
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
                  'Pilih Kecamatan (Kabupaten Tasikmalaya)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Daftar 39 kecamatan di Kabupaten Tasikmalaya',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 12),
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari kecamatan...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        title: Text(
                          kec,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                            color: isSel ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
                          ),
                        ),
                        trailing: isSel
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF3B82F6), size: 20)
                            : null,
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

  Future<void> _pilihTanggal() async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _tanggal = picked);
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔥 VALIDASI DESA WAJIB DIISI
    if (_desaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Desa/Kelurahan wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final Map<String, int> dataAngka = {};
      for (final entry in _angkaCtrl.entries) {
        final val = int.tryParse(entry.value.text.trim());
        if (val != null) dataAngka[entry.key] = val;
      }

      // 🔥 PASTIKAN DESA TIDAK NULL
      final String finalDesa = _desaController.text.trim();

      final item = CatatanKegiatan(
        id: widget.catatan?.id ?? 0,
        judul: _judulController.text.trim(),
        deskripsiSingkat: _deskripsiController.text.trim(),
        kategori: _kategori,
        dataAngka: dataAngka,
        kecamatan: _selectedKecamatan,
        desa: finalDesa, // 🔥 WAJIB TERISI!
        fotoPath: _fotoFile?.path,
        tanggal: _tanggal,
      );

      await _service.kirim(item);

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Catatan kegiatan ${_kategori.shortLabel} berhasil disimpan ($finalDesa)',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Gagal: ${e.toString().replaceFirst('Exception: ', '')}',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  // Hitung total peserta yang telah diinput pada pokja aktif
  int _hitungTotalPesertaPokja() {
    int total = 0;
    for (final sub in _getSubItems(_kategori)) {
      final l = int.tryParse(_angkaCtrl[sub.fieldL]?.text.trim() ?? '') ?? 0;
      final p = int.tryParse(_angkaCtrl[sub.fieldP]?.text.trim() ?? '') ?? 0;
      total += (l + p);
    }
    return total;
  }

  // ─────────────────────────────────────────────────────────────
  // 1. TAMPILAN PEMILIHAN POKJA (JIKA BELUM MEMILIH POKJA)
  // ─────────────────────────────────────────────────────────────
  Widget _buildPokjaSelectionScreen() {
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
          'Tulis Catatan Kegiatan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Banner Panduan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_add, color: Color(0xFF0D9488), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Pokja Kegiatan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pilih salah satu Pokja di bawah untuk membuka format blangko isian yang sesuai.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Daftar Kelompok Kerja (Pokja)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          // 4 Kartu Pilihan Pokja
          ...PokjaKategori.values.map((pokja) {
            final color = _getPokjaColor(pokja);
            final icon = _getPokjaIcon(pokja);
            final subtitle = _getPokjaSubtitle(pokja);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _kategori = pokja;
                    _pokjaDipilih = true;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  pokja.label,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey[600],
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  'Buka Format ${pokja.shortLabel}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 14, color: color),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. TAMPILAN FORMAT LENGKAP POKJA TERPILIH
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_pokjaDipilih) {
      return _buildPokjaSelectionScreen();
    }

    final color = _getPokjaColor(_kategori);
    final subItems = _getSubItems(_kategori);
    final activeSubIdx = _selectedSubIndex[_kategori] ?? 0;
    final totalPeserta = _hitungTotalPesertaPokja();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () {
            if (widget.catatan == null && widget.pokjaAwal == null) {
              setState(() => _pokjaDipilih = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          widget.catatan != null ? 'Edit ${_kategori.shortLabel}' : 'Format ${_kategori.shortLabel}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _pokjaDipilih = false);
            },
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text(
              'Ganti',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            style: TextButton.styleFrom(foregroundColor: color),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // ── QUICK POKJA SWITCHER (TABS HORIZONTAL) ──
            Container(
              height: 42,
              margin: const EdgeInsets.only(bottom: 14),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: PokjaKategori.values.map((pokja) {
                  final isSelected = pokja == _kategori;
                  final pColor = _getPokjaColor(pokja);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _kategori = pokja);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? pColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? pColor : const Color(0xFFCBD5E1),
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: pColor.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getPokjaIcon(pokja),
                              size: 16,
                              color: isSelected ? Colors.white : pColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pokja.shortLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── BANNER HEADER FORMAT POKJA TERPILIH ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
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
                    child: Icon(_getPokjaIcon(_kategori), color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _kategori.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getPokjaSubtitle(_kategori),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ══════════════════════════════════════════════════════════════
            // SEKSI 1: FORMAT DATA ANGKAI PESERTA KHUSUS POKJA
            // ══════════════════════════════════════════════════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Format Data Angka & Peserta',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Isi jumlah peserta laki-laki (L) & perempuan (P)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    'Total: $totalPeserta Jiwa',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Selector Sub-kegiatan Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(subItems.length, (i) {
                final sub = subItems[i];
                final isSelected = i == activeSubIdx;
                final countL = int.tryParse(_angkaCtrl[sub.fieldL]?.text.trim() ?? '') ?? 0;
                final countP = int.tryParse(_angkaCtrl[sub.fieldP]?.text.trim() ?? '') ?? 0;
                final hasData = (countL + countP) > 0;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSubIndex[_kategori] = i);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : (hasData ? color.withValues(alpha: 0.5) : const Color(0xFFCBD5E1)),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sub.icon, size: 14, color: isSelected ? Colors.white : color),
                        const SizedBox(width: 6),
                        Text(
                          sub.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                        if (hasData) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withValues(alpha: 0.25) : color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${countL + countP}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            // Kartu Input Angka untuk Sub-kegiatan yang Aktif
            Builder(
              builder: (context) {
                final safeIdx = activeSubIdx < subItems.length ? activeSubIdx : 0;
                final activeSub = subItems[safeIdx];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.25), width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(activeSub.icon, color: color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeSub.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                                Text(
                                  activeSub.deskripsi,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      // Input Laki-laki
                      _buildNumberField(
                        label: 'Jumlah Peserta / Warga Laki-laki (L)',
                        fieldKey: activeSub.fieldL,
                        color: color,
                      ),
                      const SizedBox(height: 12),

                      // Input Perempuan
                      _buildNumberField(
                        label: 'Jumlah Peserta / Warga Perempuan (P)',
                        fieldKey: activeSub.fieldP,
                        color: color,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════
            // SEKSI 2: INFORMASI KEGIATAN (JUDUL, TANGGAL, LOKASI)
            // ══════════════════════════════════════════════════════════════
            Text(
              'Informasi Pelaksanaan Kegiatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Judul, lokasi kecamatan, dan tanggal kegiatan berlangsung',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),

            // Judul Kegiatan
            TextFormField(
              controller: _judulController,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Judul Kegiatan (${_kategori.shortLabel}) *',
                hintText: _getJudulPlaceholder(_kategori),
                prefixIcon: Icon(Icons.title_rounded, color: color, size: 20),
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
                  borderSide: BorderSide(color: color, width: 1.8),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul kegiatan wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // Tanggal Kegiatan
            InkWell(
              onTap: _pilihTanggal,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Kegiatan',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[500])),
                          Text(
                            '${_tanggal.day}/${_tanggal.month}/${_tanggal.year}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Ubah',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Wilayah Kecamatan & Desa
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _showKecamatanPicker,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_city_rounded, color: color, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Kecamatan',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: Colors.grey[400])),
                                Text(
                                  _selectedKecamatan,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _desaController,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Desa wajib diisi';
                      }
                      return null;
                    },
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Desa / Kelurahan *',
                      hintText: 'Cth: Cipakat',
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════
            // SEKSI 3: DOKUMENTASI & DESKRIPSI
            // ══════════════════════════════════════════════════════════════
            Text(
              'Uraian & Dokumentasi Foto',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Deskripsi singkat pelaksanaan kegiatan dan foto dokumentasi',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),

            // Deskripsi Singkat
            TextFormField(
              controller: _deskripsiController,
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5, height: 1.4),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tuliskan rincian hasil yang dicapai, suasana kegiatan, dan keterangan tambahan...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey[400]),
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
                  borderSide: BorderSide(color: color, width: 1.8),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Deskripsi kegiatan wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // Foto Dokumentasi
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
                child: (_fotoBytes != null)
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.memory(_fotoBytes!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ganti Foto',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : (_fotoFile != null && !kIsWeb)
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(_fotoFile!, fit: BoxFit.cover),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit, color: Colors.white, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Ganti Foto',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.add_a_photo_rounded, color: color, size: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Unggah Foto Dokumentasi (Opsional)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Ketuk untuk mengambil foto atau dari galeri',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[400]),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 28),

            // ══════════════════════════════════════════════════════════════
            // SEKSI 4: TOMBOL SIMPAN
            // ══════════════════════════════════════════════════════════════
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _simpan,
                icon: _isSaving
                    ? const SizedBox.shrink()
                    : const Icon(Icons.check_circle_rounded, size: 20),
                label: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'Simpan Catatan ${_kategori.shortLabel}',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk input angka dengan tombol +/-
  Widget _buildNumberField({
    required String label,
    required String fieldKey,
    required Color color,
  }) {
    final ctrl = _angkaCtrl[fieldKey]!;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ),
        const SizedBox(width: 8),
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
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () {
                  final cur = int.tryParse(ctrl.text.trim()) ?? 0;
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                    border: InputBorder.none,
                    hintText: '0',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {
                  final cur = int.tryParse(ctrl.text.trim()) ?? 0;
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

/// Helper data model untuk sub-kegiatan di form pokja
class _PokjaSubItem {
  final String title;
  final String deskripsi;
  final String fieldL;
  final String fieldP;
  final IconData icon;

  const _PokjaSubItem({
    required this.title,
    required this.deskripsi,
    required this.fieldL,
    required this.fieldP,
    required this.icon,
  });
}
