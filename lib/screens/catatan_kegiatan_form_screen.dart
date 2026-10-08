// lib/screens/catatan_kegiatan_form_screen.dart
// Redesign: lebih menarik, tidak kaku, tidak terlalu rame — soft, airy, modern

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/catatan_kegiatan.dart';
import '../services/catatan_kegiatan_service.dart';
import '../main.dart';

class CatatanKegiatanFormScreen extends StatefulWidget {
  final CatatanKegiatan? catatan;
  final PokjaKategori? pokjaAwal;

  const CatatanKegiatanFormScreen({super.key, this.catatan, this.pokjaAwal});

  @override
  State<CatatanKegiatanFormScreen> createState() =>
      _CatatanKegiatanFormScreenState();
}

class _CatatanKegiatanFormScreenState extends State<CatatanKegiatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CatatanKegiatanService();
  final _picker = ImagePicker();

  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _desaController = TextEditingController();
  // ✅ Kop Laporan Data Dukung (khusus pokja4DataDukung) — semua opsional
  final _provinsiController = TextEditingController();
  final _kabupatenController = TextEditingController();
  final _programController = TextEditingController();
  final _pjDesaController = TextEditingController();
  final _pjDesaHpController = TextEditingController();
  final _pjKecamatanController = TextEditingController();
  final _pjKecamatanHpController = TextEditingController();
  final _pjKabupatenController = TextEditingController();
  final _pjKabupatenHpController = TextEditingController();
  final _pjProvinsiController = TextEditingController();
  final _pjProvinsiHpController = TextEditingController();
  final Map<String, TextEditingController> _angkaCtrl = {};

  bool _pokjaDipilih = false;
  late PokjaKategori _kategori;
  String _selectedKecamatan = 'Singaparna';

  File? _fotoFile;
  Uint8List? _fotoBytes;

  DateTime _tanggal = DateTime.now();
  bool _isSaving = false;

  bool _isDarkMode = false;
  PokjaKategori? _restrictedPokja;

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _loadTheme();
    _loadRoleRestriction();

    // Pastikan controller Pokja 1 (4 field per program) ada
    for (final k in ['kisah', 'kilas', 'krisan', 'kiat', 'kisak', 'pkbn']) {
      for (final suffix in ['_kegiatan', '_volume', '_metode', '_sasaran']) {
        _angkaCtrl['$k$suffix'] = TextEditingController();
      }

    }

    final allFields = <String>{};
    for (final k in PokjaKategori.values) {
      allFields.addAll(k.fieldAngka);
    }
    for (final k in PokjaKategori.values) {
      for (final s in _getSubItems(k)) {
        allFields.add(s.fieldL);
        if (s.fieldP.isNotEmpty) allFields.add(s.fieldP);
      }
    }
    for (final f in allFields) {
      _angkaCtrl.putIfAbsent(f, () => TextEditingController());
    }

    if (widget.catatan != null) {
      final c = widget.catatan!;
      _kategori = c.kategori;
      _pokjaDipilih = true;
      _judulController.text = c.judul;
      _deskripsiController.text = c.deskripsiSingkat;
      _desaController.text = c.desa ?? '';
      _provinsiController.text = c.provinsi ?? '';
      _kabupatenController.text = c.kabupatenKota ?? '';
      _programController.text = c.program ?? '';
      _pjDesaController.text = c.pjDesa ?? '';
      _pjDesaHpController.text = c.pjDesaHp ?? '';
      _pjKecamatanController.text = c.pjKecamatan ?? '';
      _pjKecamatanHpController.text = c.pjKecamatanHp ?? '';
      _pjKabupatenController.text = c.pjKabupaten ?? '';
      _pjKabupatenHpController.text = c.pjKabupatenHp ?? '';
      _pjProvinsiController.text = c.pjProvinsi ?? '';
      _pjProvinsiHpController.text = c.pjProvinsiHp ?? '';
      _selectedKecamatan = c.kecamatan;
      _tanggal = c.tanggal;
      if (c.fotoPath != null && c.fotoPath!.isNotEmpty) {
        try {
          if (!kIsWeb) _fotoFile = File(c.fotoPath!);
        } catch (_) {}
      }
      for (final f in allFields) {
        final val = c.dataAngka[f];
        if (val != null && val != 0) _angkaCtrl[f]!.text = val.toString();
      }
    } else if (widget.pokjaAwal != null) {
      _kategori = widget.pokjaAwal!;
      _pokjaDipilih = true;
    } else {
      _kategori = PokjaKategori.pokja1;
      _pokjaDipilih = false;
    }
  }

  Future<void> _loadRoleRestriction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user_data');
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final roles = data['roles'] is List ? List<dynamic>.from(data['roles']) : const [];
      final username = (data['username'] ?? '').toString().toLowerCase();
      final role = (data['role'] ??
              (roles.isNotEmpty ? roles.first : '') ??
              (username.startsWith('pokja') ? username : ''))
          .toString()
          .toLowerCase();
      final index = int.tryParse(role.replaceFirst('pokja', ''));
      if (index == null || index < 1 || index > 4) return;

      final pokja = PokjaKategori.values[index - 1];
      if (!mounted) return;
      setState(() {
        _restrictedPokja = pokja;
        if (widget.catatan == null) {
          final requestedCategory = widget.pokjaAwal;
          if (pokja == PokjaKategori.pokja4 &&
              requestedCategory != null &&
              (requestedCategory == PokjaKategori.pokja4 ||
                  requestedCategory.isPokja4Sheet)) {
            _kategori = requestedCategory;
          } else {
            _kategori = pokja;
          }
        }
      });
    } catch (_) {}
  }

  List<PokjaKategori> _availablePokjas() {
    // ✅ 1 FORM GABUNGAN: Data Program (Lama) tidak tampil di picker mana pun.
    if (_restrictedPokja == null) return PokjaKategoriLabel.inputValues;
    if (_restrictedPokja == PokjaKategori.pokja4) {
      return PokjaKategoriLabel.inputPokja4;
    }
    return [_restrictedPokja!];
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    _judulController.dispose();
    _deskripsiController.dispose();
    _desaController.dispose();
    _provinsiController.dispose();
    _kabupatenController.dispose();
    _programController.dispose();
    _pjDesaController.dispose();
    _pjDesaHpController.dispose();
    _pjKecamatanController.dispose();
    _pjKecamatanHpController.dispose();
    _pjKabupatenController.dispose();
    _pjKabupatenHpController.dispose();
    _pjProvinsiController.dispose();
    _pjProvinsiHpController.dispose();
    for (final c in _angkaCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onThemeChanged() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (mounted && _isDarkMode != isDark) setState(() => _isDarkMode = isDark);
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark =
          prefs.getBool('kader_dark_mode') ??
          prefs.getBool('isDarkMode') ??
          (themeNotifier.value == ThemeMode.dark);
      if (mounted && _isDarkMode != isDark)
        setState(() => _isDarkMode = isDark);
      if (themeNotifier.value != (isDark ? ThemeMode.dark : ThemeMode.light))
        themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = themeNotifier.value == ThemeMode.dark;
    if (_isDarkMode != isDark) _isDarkMode = isDark;
  }

  Color _getPokjaColor(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return const Color(0xFF3B82F6);
      case PokjaKategori.pokja2:
        return const Color(0xFF10B981);
      case PokjaKategori.pokja3:
        return const Color(0xFFF59E0B);
      case PokjaKategori.pokja4:
        return const Color(0xFFEF4444);
      case PokjaKategori.pokja4Pyd:
        return const Color(0xFF8B5CF6);
      case PokjaKategori.pokja4Posyandu:
        return const Color(0xFF06B6D4);
      case PokjaKategori.pokja4Rekap:
        return const Color(0xFFEC4899);
      case PokjaKategori.pokja4DataDukung:
        return const Color(0xFFF59E0B);
      case PokjaKategori.pokja4DataProgram:
        return const Color(0xFF14B8A6);
    }
  }

  Color _getPokjaSoft(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return const Color(0xFFEFF6FF);
      case PokjaKategori.pokja2:
        return const Color(0xFFECFDF5);
      case PokjaKategori.pokja3:
        return const Color(0xFFFFFBEB);
      case PokjaKategori.pokja4:
        return const Color(0xFFFEF2F2);
      case PokjaKategori.pokja4Pyd:
        return const Color(0xFFF5F3FF);
      case PokjaKategori.pokja4Posyandu:
        return const Color(0xFFECFEFF);
      case PokjaKategori.pokja4Rekap:
        return const Color(0xFFFDF2F8);
      case PokjaKategori.pokja4DataDukung:
        return const Color(0xFFFFFBEB);
      case PokjaKategori.pokja4DataProgram:
        return const Color(0xFFF0FDFA);
    }
  }

  IconData _getPokjaIcon(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return Icons.groups_rounded;
      case PokjaKategori.pokja2:
        return Icons.school_rounded;
      case PokjaKategori.pokja3:
        return Icons.cottage_rounded;
      case PokjaKategori.pokja4:
        return Icons.health_and_safety_rounded;
      case PokjaKategori.pokja4Pyd:
        return Icons.child_friendly_rounded;
      case PokjaKategori.pokja4Posyandu:
        return Icons.local_hospital_rounded;
      case PokjaKategori.pokja4Rekap:
        return Icons.assignment_rounded;
      case PokjaKategori.pokja4DataDukung:
        return Icons.library_books_rounded;
      case PokjaKategori.pokja4DataProgram:
        return Icons.bar_chart_rounded;
    }
  }

  String _getPokjaSubtitle(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return 'Gotong Royong & Pembinaan Karakter';
      case PokjaKategori.pokja2:
        return 'Pendidikan & Ekonomi Keluarga';
      case PokjaKategori.pokja3:
        return 'Pangan, Sandang & Papan Sehat';
      case PokjaKategori.pokja4:
        return 'Kesehatan & Lingkungan';
      case PokjaKategori.pokja4Pyd:
        return 'Data Kunjungan PYD per Bulan';
      case PokjaKategori.pokja4Posyandu:
        return 'Data Kegiatan Posyandu per Bulan';
      case PokjaKategori.pokja4Rekap:
        return 'Rekap Ibu Hamil, Melahirkan & Nifas';
      case PokjaKategori.pokja4DataDukung:
        return '1 Form • A. Data Dukung (26) + B. Program (9)';
      case PokjaKategori.pokja4DataProgram:
        return 'Data Program Gerakan Keluarga Sehat (Lama)';
    }
  }

  String _getJudulPlaceholder(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return 'Mis. Penyuluhan Pola Asuh Anak';
      case PokjaKategori.pokja2:
        return 'Mis. Pelatihan Olahan Pangan UP2K';
      case PokjaKategori.pokja3:
        return 'Mis. Gerakan HATINYA PKK';
      case PokjaKategori.pokja4:
        return 'Mis. Posyandu & PHBS';
      case PokjaKategori.pokja4Pyd:
        return 'Mis. Kunjungan PYD Januari 2025';
      case PokjaKategori.pokja4Posyandu:
        return 'Mis. Kegiatan Posyandu Januari 2025';
      case PokjaKategori.pokja4Rekap:
        return 'Mis. Rekap Ibu Hamil 2025';
      case PokjaKategori.pokja4DataDukung:
        return 'Mis. Laporan Data Dukung Desa 2025';
      case PokjaKategori.pokja4DataProgram:
        return 'Mis. Data Program Stunting 2025 (Lama)';
    }
  }

  ({Color bg, Color text, Color sub, Color faint, Color fill, Color handle})
  _sheetPalette() {
    if (_isDarkMode) {
      return (
        bg: const Color(0xFF1E242D),
        text: Colors.white,
        sub: const Color(0xFF8E9BAE),
        faint: const Color(0xFF5B6B82),
        fill: const Color(0xFF14181F),
        handle: Colors.white.withValues(alpha: 0.16),
      );
    }
    return (
      bg: Colors.white,
      text: const Color(0xFF0F172A),
      sub: const Color(0xFF64748B),
      faint: const Color(0xFF94A3B8),
      fill: const Color(0xFFF8FAFC),
      handle: const Color(0xFFE2E8F0),
    );
  }

  // ============================================================
  // SUB-ITEMS — Pokja 1 (4 field per program) + Pokja lain
  // ============================================================
  List<_PokjaSubItem> _getSubItems(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return const [
          _PokjaSubItem(title: 'Kader Umum', deskripsi: 'Jumlah kader umum', fieldL: 'kader_umum', fieldP: '', icon: Icons.badge_rounded),
          _PokjaSubItem(title: 'Kader Khusus', deskripsi: 'Jumlah kader khusus', fieldL: 'kader_khusus', fieldP: '', icon: Icons.badge_rounded),
          _PokjaSubItem(title: 'KISAH', deskripsi: 'Kegiatan + Volume + Metode + Sasaran', fieldL: 'kisah', fieldP: '', icon: Icons.groups_rounded),
          _PokjaSubItem(title: 'KILAS', deskripsi: 'Kegiatan + Volume + Metode + Sasaran', fieldL: 'kilas', fieldP: '', icon: Icons.groups_rounded),
          _PokjaSubItem(title: 'KRISAN', deskripsi: 'Kegiatan + Volume + Metode + Sasaran', fieldL: 'krisan', fieldP: '', icon: Icons.groups_rounded),
          _PokjaSubItem(title: 'KIAT', deskripsi: 'Kegiatan + Volume + Metode + Sasaran', fieldL: 'kiat', fieldP: '', icon: Icons.groups_rounded),
          _PokjaSubItem(title: 'KISAK', deskripsi: 'Kegiatan + Volume + Metode + Sasaran', fieldL: 'kisak', fieldP: '', icon: Icons.groups_rounded),
          _PokjaSubItem(title: 'PKBN', deskripsi: 'Kegiatan + Volume + Metode + Sasaran', fieldL: 'pkbn', fieldP: '', icon: Icons.groups_rounded),
        ];

      case PokjaKategori.pokja2:
        return const [
          _PokjaSubItem(
            title: 'Pendidikan Keterampilan',
            deskripsi: 'Warga Buta, Paket A-C, KF, PAUD, Taman Bacaan',
            icon: Icons.school_rounded,
            groupFields: {
              'Warga Buta - Jml KLP': 'kelompok_warga_buta',
              'Jml. Warga Yang Masih 3 Buta': {
                'Laki-laki': 'warga_buta_l',
                'Perempuan': 'warga_buta_p',
              },
              'Paket A - Jml KLP': 'kelompok_belajar_paket_a',
              'Paket A - Warga Belajar': {
                'Laki-laki': 'warga_belajar_paket_a_l',
                'Perempuan': 'warga_belajar_paket_a_p',
              },
              'Paket B - Jml KLP': 'kelompok_belajar_paket_b',
              'Paket B - Warga Belajar': {
                'Laki-laki': 'warga_belajar_paket_b_l',
                'Perempuan': 'warga_belajar_paket_b_p',
              },
              'Paket C - Jml KLP': 'kelompok_belajar_paket_c',
              'Paket C - Warga Belajar': {
                'Laki-laki': 'warga_belajar_paket_c_l',
                'Perempuan': 'warga_belajar_paket_c_p',
              },
              'KF - Jml KLP': 'kf',
              'KF - Warga Belajar': {
                'Laki-laki': 'warga_belajar_kf_l',
                'Perempuan': 'warga_belajar_kf_p',
              },
              'PAUD - Jml KLP': 'kelompok_paud',
              'PAUD Sejenis': {
                'Laki-laki': 'paud_l',
                'Perempuan': 'paud_p',
              },
              'Taman Bacaan - Jml KLP': 'kelompok_taman_bacaan',
              'Taman Bacaan/Perpustakaan': {
                'Laki-laki': 'taman_bacaan_l',
                'Perempuan': 'taman_bacaan_p',
              },
            },
          ),
          _PokjaSubItem(
            title: 'Jumlah Kader Khusus',
            deskripsi: 'BKB, Tutor, Koperasi, Keterampilan, dll',
            icon: Icons.badge_rounded,
            groupFields: {
              'BKB - Jml KLP': 'kelompok_bkb',
              'BKB - Peserta': {
                'Laki-laki': 'peserta_bkb_l',
                'Perempuan': 'peserta_bkb_p',
              },
              'BKB - Jml Ibu (SET)': 'ibu_set_bkb',
              'BKB - Jml APE': 'ape_bkb',
              'BKB - Simulasi Jml KLP': 'kelompok_simulasi_bkb',
              'BKB - Simulasi': {
                'Laki-laki': 'kelompok_simulasi_bkb_l',
                'Perempuan': 'kelompok_simulasi_bkb_p',
              },
              'Tutor - KF Jml': 'tutor_kf',
              'Tutor - KF': {
                'Laki-laki': 'tutor_kf_l',
                'Perempuan': 'tutor_kf_p',
              },
              'Tutor - PAUD Jml': 'tutor_paud',
              'Tutor - PAUD Sejenis': {
                'Laki-laki': 'tutor_paud_l',
                'Perempuan': 'tutor_paud_p',
              },
              'Kader BKB Jml': 'kader_bkb',
              'Kader BKB': {
                'Laki-laki': 'kader_bkb_l',
                'Perempuan': 'kader_bkb_p',
              },
              'Kader Koperasi Jml': 'kader_koperasi',
              'Kader Koperasi': {
                'Laki-laki': 'kader_koperasi_l',
                'Perempuan': 'kader_koperasi_p',
              },
              'Kader Keterampilan Jml': 'kader_keterampilan',
              'Kader Keterampilan': {
                'Laki-laki': 'kader_keterampilan_l',
                'Perempuan': 'kader_keterampilan_p',
              },
              'LP3 PKK Jml': 'lp3_pkk',
              'LP3 PKK': {
                'Laki-laki': 'lp3_pkk_l',
                'Perempuan': 'lp3_pkk_p',
              },
              'TP3 PKK Jml': 'tp3_pkk',
              'TP3 PKK': {
                'Laki-laki': 'tp3_pkk_l',
                'Perempuan': 'tp3_pkk_p',
              },
              'Damas PKK Jml': 'damas_pkk',
              'Damas PKK': {
                'Laki-laki': 'damas_pkk_l',
                'Perempuan': 'damas_pkk_p',
              },
            },
          ),
          _PokjaSubItem(
            title: 'Pengembangan Kehidupan Berkoperasi',
            deskripsi: 'Pemula, Madya, Utama, Mandiri, Berbadan Hukum',
            icon: Icons.storefront_rounded,
            groupFields: {
              'Pemula - Jml KLP': 'up2k_pemula_kelompok',
              'Pemula - Peserta': {
                'Laki-laki': 'up2k_pemula_peserta_l',
                'Perempuan': 'up2k_pemula_peserta_p',
              },
              'Madya - Jml KLP': 'up2k_madya_kelompok',
              'Madya - Peserta': {
                'Laki-laki': 'up2k_madya_peserta_l',
                'Perempuan': 'up2k_madya_peserta_p',
              },
              'Utama - Jml KLP': 'up2k_utama_kelompok',
              'Utama - Peserta': {
                'Laki-laki': 'up2k_utama_peserta_l',
                'Perempuan': 'up2k_utama_peserta_p',
              },
              'Mandiri - Jml KLP': 'up2k_mandiri_kelompok',
              'Mandiri - Peserta': {
                'Laki-laki': 'up2k_mandiri_peserta_l',
                'Perempuan': 'up2k_mandiri_peserta_p',
              },
              'Berbadan Hukum - Jml KLP': 'koperasi_berbadan_hukum',
              'Berbadan Hukum - Jml Anggota': {
                'Laki-laki': 'anggota_koperasi_l',
                'Perempuan': 'anggota_koperasi_p',
              },
            },
          ),
        ];

      case PokjaKategori.pokja3:
        // 17 input angka = kolom 3–19 tabel website persis (kolom 1-2 = NO &
        // Kecamatan otomatis, kolom 20 = Keterangan dari Uraian Singkat).
        return const [
          _PokjaSubItem(
            title: 'Jumlah Kader',
            deskripsi: 'Kolom 3–5 tabel website',
            icon: Icons.badge_rounded,
            groupFields: {
              '3 • Pangan': 'jumlah_kader_pangan',
              '4 • Sandang': 'jumlah_kader_sandang',
              '5 • Tata Laksana Rumah Tangga': 'jumlah_kader_tata_laksana',
            },
          ),
          _PokjaSubItem(
            title: 'Pangan',
            deskripsi: 'Kolom 6–14 tabel website',
            icon: Icons.rice_bowl_rounded,
            groupFields: {
              'Makanan Pokok': {
                '6 • Beras': 'pangan_beras',
                '7 • Non Beras': 'pangan_non_beras',
              },
              'Pemanfaatan Pekarangan / HATINYA PKK': {
                '8 • Peternakan': 'pangan_peternakan',
                '9 • Perikanan': 'pangan_perikanan',
                '10 • Warung Hidup': 'pangan_warung_hidup',
                '11 • Lumbung Hidup': 'pangan_lumbung_hidup',
                '12 • TOGA': 'pangan_toga',
                '13 • Tanaman Keras': 'pangan_tanaman_keras',
                '14 • Tanaman Lainnya': 'pangan_tanaman_lainnya',
              },
            },
          ),
          _PokjaSubItem(
            title: 'Jumlah Industri Rumah Tangga',
            deskripsi: 'Kolom 15–17 tabel website',
            icon: Icons.store_rounded,
            groupFields: {
              '15 • Pangan': 'industri_pangan',
              '16 • Sandang': 'industri_sandang',
              '17 • Jasa': 'industri_jasa',
            },
          ),
          _PokjaSubItem(
            title: 'Jumlah Rumah',
            deskripsi: 'Kolom 18–19 tabel website',
            icon: Icons.house_rounded,
            groupFields: {
              '18 • Sehat dan Layak Huni': 'rumah_sehat',
              '19 • Tidak Sehat dan Tidak Layak Huni': 'rumah_tidak_sehat',
            },
          ),
        ];

      case PokjaKategori.pokja4:
        return const [
          _PokjaSubItem(
            title: 'Kesehatan',
            deskripsi: 'Kader, Posyandu, Imunisasi, PKG, TBC',
            icon: Icons.health_and_safety_rounded,
            groupFields: {
              'Kader Kes.': 'kader_kesehatan',
              'Kader Gizi': 'kader_gizi',
              'Kader Kesling': 'kader_kesling',
              'Kader PHBS': 'kader_phbs',
              'Kader KB': 'kader_kb',
              'Posyandu': 'posyandu',
              'Imunisasi': 'imunisasi',
              'PKG': 'pkg',
              'TBC': 'tbc',
            },
          ),
          _PokjaSubItem(
            title: 'Kelestarian Lingkungan',
            deskripsi: 'Jamban, SPAL, TPS, MCK, Air',
            icon: Icons.park_rounded,
            groupFields: {
              'Rumah Jamban': 'jamban_keluarga',
              'Rumah SPAL': 'spal',
              'Rumah TPS': 'tps',
              'MCK': 'mck',
              'Air PDAM': 'air_pdam',
              'Air Sumur': 'air_sumur',
              'Air Lainnya': 'air_lainnya',
            },
          ),
          _PokjaSubItem(
            title: 'Perencanaan Sehat',
            deskripsi: 'PUS, WUS, Akseptor KB, Tabungan, Asuransi',
            icon: Icons.event_available_rounded,
            groupFields: {
              'PUS': 'jumlah_pus',
              'WUS': 'jumlah_wus',
              'Akseptor KB (L)': 'akseptor_kb_l',
              'Akseptor KB (P)': 'akseptor_kb_p',
              'Tabungan Keluarga': 'tabungan_keluarga',
              'Asuransi Kesehatan': 'asuransi_kesehatan',
            },
          ),
          _PokjaSubItem(
            title: 'Program Unggulan',
            deskripsi: 'Kesehatan, Lingkungan, Perencanaan',
            icon: Icons.star_rounded,
            groupFields: {
              'Kesehatan': 'program_unggulan_kesehatan',
              'Lingkungan': 'program_unggulan_lingkungan',
              'Perencanaan': 'program_unggulan_perencanaan',
            },
          ),
        ];

      case PokjaKategori.pokja4Pyd:
        return const [
          _PokjaSubItem(
            title: 'Kunjungan PYD',
            deskripsi: 'Bayi, Balita, WUS, Ibu, Petugas',
            icon: Icons.groups_rounded,
            groupFields: {
              'Bayi 0-12 L': 'bayi_0_12_l',
              'Bayi 0-12 P': 'bayi_0_12_p',
              'Balita 1-5 L': 'balita_1_5_l',
              'Balita 1-5 P': 'balita_1_5_p',
              'WUS': 'wus',
              'Ibu Hamil': 'ibu_hamil',
              'Menyusui': 'ibu_menyusui',
              'Bayi Lahir': 'bayi_lahir',
              'Bayi Meninggal': 'bayi_meninggal',
              'Kematian Ibu': 'kematian_ibu',
              'Petugas Kader': 'petugas_kader',
              'Petugas PLKB': 'petugas_plkb',
              'Petugas Medis': 'petugas_medis',
            },
          ),
        ];

      case PokjaKategori.pokja4Posyandu:
        return const [
          _PokjaSubItem(title: 'Ibu', deskripsi: 'Hamil, Diperiksa, Dapat Fe, Menyusui', icon: Icons.pregnant_woman_rounded, groupFields: {'Hamil': 'ibu_hamil', 'Diperiksa': 'ibu_hamil_diperiksa', 'Dapat Fe': 'ibu_dapat_fe', 'Menyusui': 'ibu_menyusui'}),
          _PokjaSubItem(title: 'Akseptor KB', deskripsi: 'IUD, MOW, MOP, Implan, Pil, Suntik, Kondom, L, P', icon: Icons.health_and_safety_rounded, groupFields: {'IUD': 'kb_iud', 'MOW': 'kb_mow', 'MOP': 'kb_mop', 'Implan': 'kb_implan', 'Pil': 'kb_pil', 'Suntik': 'kb_suntik', 'Kondom': 'kb_kondom', 'L': 'akseptor_kb_l', 'P': 'akseptor_kb_p'}),
          _PokjaSubItem(
            title: 'Balita',
            deskripsi: 'KIA, Timbang, Naik BB',
            icon: Icons.child_care_rounded,
            groupFields: {
              'KIA L': 'balita_kia_l',
              'KIA P': 'balita_kia_p',
              'Timbang L': 'balita_ditimbang_l',
              'Timbang P': 'balita_ditimbang_p',
              'Naik L': 'balita_naik_l',
              'Naik P': 'balita_naik_p',
            },
          ),
          _PokjaSubItem(title: 'Vit A', deskripsi: 'Vit A-1 & Vit A-2', icon: Icons.medication_rounded, groupFields: {'Vit A-1': 'vit_a_1', 'Vit A-2': 'vit_a_2'}),
          _PokjaSubItem(
            title: 'Imunisasi',
            deskripsi: 'TT, BCG, DPT, Polio, Campak, Hep',
            icon: Icons.vaccines_rounded,
            groupFields: {
              'TT-1': 'imunisasi_tt_1',
              'TT-2': 'imunisasi_tt_2',
              'BCG': 'imunisasi_bcg',
              'DPT-1': 'imunisasi_dpt_1',
              'DPT-2': 'imunisasi_dpt_2',
              'DPT-3': 'imunisasi_dpt_3',
              'Polio-1': 'imunisasi_polio_1',
              'Polio-2': 'imunisasi_polio_2',
              'Polio-3': 'imunisasi_polio_3',
              'Polio-4': 'imunisasi_polio_4',
              'Campak': 'imunisasi_campak',
              'Hep-1': 'imunisasi_hepatitis_1',
              'Hep-2': 'imunisasi_hepatitis_2',
              'Hep-3': 'imunisasi_hepatitis_3',
            },
          ),
          _PokjaSubItem(title: 'Diare', deskripsi: 'Diare & Oralit', icon: Icons.water_drop_rounded, groupFields: {'Diare': 'diare', 'Oralit': 'oralit'}),
        ];

      case PokjaKategori.pokja4Rekap:
        return const [
          // IBU
          _PokjaSubItem(title: 'Ibu', deskripsi: 'Hamil, Melahirkan, Nifas, Meninggal', icon: Icons.pregnant_woman_rounded, groupFields: {'Hamil': 'ibu_hamil', 'Melahirkan': 'ibu_melahirkan', 'Nifas': 'ibu_nifas', 'Meninggal': 'ibu_meninggal'}),
          // BAYI LAHIR
          _PokjaSubItem(title: 'Bayi Lahir', deskripsi: 'L, P, Akte Ada, Akte Tidak', icon: Icons.child_care_rounded, groupFields: {'L': 'bayi_lahir_l', 'P': 'bayi_lahir_p', 'Akte Ada': 'akte_ada', 'Akte Tidak': 'akte_tidak'}),
          // BAYI MENINGGAL
          _PokjaSubItem(title: 'Bayi Meninggal', deskripsi: 'L & P', icon: Icons.sentiment_very_dissatisfied_rounded, groupFields: {'L': 'bayi_meninggal_l', 'P': 'bayi_meninggal_p'}),
          // BALITA MENINGGAL
          _PokjaSubItem(title: 'Balita Meninggal', deskripsi: 'L & P', icon: Icons.sentiment_dissatisfied_rounded, groupFields: {'L': 'balita_meninggal_l', 'P': 'balita_meninggal_p'}),
        ];

      case PokjaKategori.pokja4DataDukung:
        // ✅ 1 FORM: A. Data Dukung (1 kartu, 26 field) + B. Data Program (9 kartu I-IX)
        return const [
          // ===== A. DATA DUKUNG (tabel A no. 1-26) =====
          _PokjaSubItem(
            title: 'A. Data Dukung',
            deskripsi: 'Data Umum • 26 field • Penduduk s/d Posko Bencana',
            icon: Icons.folder_shared_rounded,
            groupFields: {
              'Jumlah Penduduk': 'jumlah_penduduk',
              'Jumlah Kepala Keluarga': 'jumlah_kk',
              'Jumlah Rumah': 'jumlah_rumah',
              'Jumlah Laki-Laki': 'jumlah_laki',
              'Jumlah Perempuan': 'jumlah_perempuan',
              'Jumlah Usia Produktif (15-64 Tahun)': 'jumlah_usia_produktif',
              'Jumlah Pasangan Usia Subur': 'jumlah_pus',
              'Jumlah Ibu Hamil': 'jumlah_ibu_hamil',
              'Jumlah Bayi (0-2 Tahun)': 'jumlah_bayi_0_2',
              'Jumlah Bayi yang mendapatkan ASI Eksklusif (0-6 Bulan)':
                  'jumlah_bayi_asi',
              'Jumlah Balita (>2-5 Tahun)': 'jumlah_balita',
              'Jumlah Anak (6-14 Tahun)': 'jumlah_anak',
              'Jumlah Lansia (≥65 Tahun)': 'jumlah_lansia',
              'Jumlah Peserta KB Aktif': 'jumlah_kb_aktif',
              'Jumlah Ibu Menyusui': 'jumlah_ibu_menyusui',
              'Jumlah Keluarga Sejahtera': 'jumlah_keluarga_sejahtera',
              'Jumlah Keluarga Pra Sejahtera':
                  'jumlah_keluarga_pra_sejahtera',
              'Jumlah Masyarakat Berpenghasilan Rendah (MBR)': 'jumlah_mbr',
              'Jumlah Kader PKK RT/RW': 'jumlah_kader_pkk_rt_rw',
              'Jumlah Kader PKK Bidang Kesehatan':
                  'jumlah_kader_pkk_kesehatan',
              'Jumlah Kelompok Dasa Wisma': 'jumlah_dasa_wisma',
              'Jumlah Kader Dasa Wisma': 'jumlah_kader_dasa_wisma',
              'Jumlah Posyandu Aktif': 'jumlah_posyandu_aktif',
              'Jumlah Bidan Desa': 'jumlah_bidan_desa',
              'Jumlah Bank Sampah': 'jumlah_bank_sampah',
              'Jumlah Posko Bencana': 'jumlah_posko_bencana',
            },
          ),
          // ===== B. DATA PROGRAM (I-IX @ 7 field) =====
          _PokjaSubItem(
            title:
                'I. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Peduli Stunting',
            deskripsi: '7 field • Prematur, BBLR, Gizi, Stunting',
            icon: Icons.monitor_heart_rounded,
            groupFields: {
              'Jumlah Bayi Lahir Prematur': 'bayi_prematur',
              'Jumlah Bayi Lahir Berat Badan Bayi Lahir Rendah (BBLR)':
                  'bayi_bblr',
              'Jumlah Balita Kurang Gizi': 'balita_kurang_gizi',
              'Jumlah Balita Stunting': 'balita_stunting',
              'Jumlah bayi dan balita yang rutin dilakukan pemeriksaan tumbuh kembang setiap bulan':
                  'bayi_balita_periksa',
              'Jumlah Ibu Yang Melahirkan dengan Jarak Terlalu Dekat':
                  'ibu_lahir_jarak_dekat',
              'Jumlah Kehamilan Yang Tidak Direncanakan / Tidak Diinginkan':
                  'hamil_tidak_direncanakan',
            },
          ),
          _PokjaSubItem(
            title:
                'II. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Menuju Perilaku Hidup Bersih Dan Sehat (PHBS)',
            deskripsi: '7 field • TBC, Jamban, Diare, Gizi, BABS',
            icon: Icons.clean_hands_rounded,
            groupFields: {
              'Jumlah penduduk penderita Tuberkulosis (TBC)': 'penduduk_tbc',
              'Jumlah rumah yang memiliki jamban sehat': 'rumah_jamban_sehat',
              'Jumlah rumah yang memiliki fasilitas instalasi atau bak penampung air bersih':
                  'rumah_bak_air',
              'Jumlah kasus penyakit Diare': 'kasus_diare',
              'Jumlah keluarga yang sadar gizi': 'keluarga_sadar_gizi',
              'Jumlah rumah tanpa asap rokok': 'rumah_tanpa_asap_rokok',
              'Jumlah penduduk yang masih Buang Air Besar Sembarangan (BABS)':
                  'penduduk_babs',
            },
          ),
          _PokjaSubItem(
            title:
                'III. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Peduli Kesehatan Keluarga (Ayah, Ibu dan Anak)',
            deskripsi: '7 field • Hamil, Merokok, Kanker, Imunisasi',
            icon: Icons.health_and_safety_rounded,
            groupFields: {
              'Jumlah ibu hamil yang rutin memeriksakan kehamilannya pada tenaga kesehatan secara periodik':
                  'ibu_hamil_periksa',
              'Jumlah Ayah yang merokok': 'ayah_merokok',
              'Jumlah kasus Kematian Ibu nifas': 'kematian_ibu_nifas',
              'Jumlah kasus Kanker Serviks pada Perempuan': 'kanker_serviks',
              'Jumlah bayi dan balita yang mendapat imunisasi dasar lengkap':
                  'bayi_balita_imunisasi',
              'Jumlah bayi dan balita sakit yang terdata pada fasilitas kesehatan':
                  'bayi_balita_sakit',
              'Jumlah kasus Kematian Bayi dan Balita': 'kematian_bayi_balita',
            },
          ),
          _PokjaSubItem(
            title:
                'IV. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Siaga Kebakaran Lingkungan',
            deskripsi: '7 field • Kebakaran, Listrik, APAR, P3K',
            icon: Icons.local_fire_department_rounded,
            groupFields: {
              'Jumlah kasus Kebakaran Rumah Tangga':
                  'kebakaran_rumah_tangga',
              'Jumlah Rumah Tangga Yang Memiliki Instalasi Listrik Yang Sesuai Standar':
                  'rumah_listrik_standar',
              'Jumlah Rumah Tangga Yang Memiliki Alat Pemadam Kebakaran':
                  'rumah_alat_pemadam',
              'Jumlah Rumah Semi Permanen dan rumah kayu':
                  'rumah_semi_permanen',
              'Jumlah Rumah Tangga yang memiliki Kotak P3K':
                  'rumah_kotak_p3k',
              'Jumlah Rumah Tangga Yang Telah Mendapatkan Informasi, Penyuluhan, Atau Sosialisasi Tentang Mitigasi Dan Penanggulangan Kebakaran':
                  'rumah_info_mitigasi_kebakaran',
              'Jumlah Kader PKK Yang Telah Mendapatkan Edukasi Terkait Mitigasi Bencana Kebakaran':
                  'kader_edukasi_kebakaran',
            },
          ),
          _PokjaSubItem(
            title:
                'V. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Mitigasi Bencana Alam',
            deskripsi: '7 field • Relawan, Posko, Tas Siaga',
            icon: Icons.flood_rounded,
            groupFields: {
              'Jumlah Relawan Bencana Alam': 'relawan_bencana_alam',
              'Jumlah Rumah Tangga Yang Telah Mendapatkan Informasi, Penyuluhan, Atau Sosialisasi Tentang Mitigasi Dan Penanggulangan Bencana Alam':
                  'rumah_info_mitigasi_alam',
              'Jumlah Kader PKK Yang Telah Mendapatkan Edukasi Terkait Mitigasi Bencana Alam':
                  'kader_edukasi_alam',
              'Jumlah Fasilitas/Bangunan Yang Ditetapkan Sebagai Alternatif Posko Bila Terjadi Bencana Alam':
                  'fasilitas_posko_bencana',
              'Jumlah Relawan Bencana Alam (2)': 'relawan_bencana_alam_2',
              'Jumlah Rumah Tangga Yang Memiliki Tas Siaga Bencana':
                  'rumah_tas_siaga',
              'Jumlah Kerusakan Fasilitas Umum Yang Diakibatkan Oleh Bencana Alam':
                  'kerusakan_fasilitas_umum',
            },
          ),
          _PokjaSubItem(
            title:
                'VI. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Peduli Lingkungan',
            deskripsi: '7 field • Sampah, SPAL, Banjir, KLB',
            icon: Icons.recycling_rounded,
            groupFields: {
              'Jumlah Keluarga yang memiliki bak sampah':
                  'keluarga_bak_sampah',
              'Jumlah Keluarga sebagai anggota Bank Sampah':
                  'keluarga_anggota_bank_sampah',
              'Jumlah keluarga yang menggunakan Sistem Pembuangan Air Limbah (SPAL)':
                  'keluarga_spal',
              'Jumlah kasus banjir': 'kasus_banjir',
              'Jumlah bak sampah milik desa/kelurahan': 'bak_sampah_desa',
              'Jumlah Rumah sehat': 'rumah_sehat',
              'Jumlah kasus Kejadian Luar Biasa (KLB)': 'kasus_klb',
            },
          ),
          _PokjaSubItem(
            title:
                'VII. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Menuju Keluarga Sehat Berkualitas',
            deskripsi: '7 field • 2 Anak, Berobat, Bayi Sehat',
            icon: Icons.favorite_rounded,
            groupFields: {
              'Jumlah Keluarga dengan 2 anak': 'keluarga_2_anak',
              'Jumlah Penduduk yang berobat ke fasilitas kesehatan berdasarkan data di fasilitas kesehatan':
                  'penduduk_berobat',
              'Jumlah kasus penyakit menular': 'penyakit_menular',
              'Jumlah kasus penyakit tidak menular': 'penyakit_tidak_menular',
              'Jumlah Bayi Lahir Sehat': 'bayi_lahir_sehat',
              'Jumlah Bayi Lahir Cukup Bulan': 'bayi_cukup_bulan',
              'Jumlah keluarga yang memiliki anggota dengan kriteria penyakit gangguan jiwa':
                  'keluarga_gangguan_jiwa',
            },
          ),
          _PokjaSubItem(
            title:
                'VIII. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Menuju Keuangan Sehat',
            deskripsi: '7 field • Asuransi, Tabungan, Aset',
            icon: Icons.savings_rounded,
            groupFields: {
              'Jumlah Keluarga yang memiliki Asuransi Kesehatan':
                  'keluarga_asuransi',
              'Jumlah kepala keluarga yang tidak memiliki pekerjaan / Pengangguran':
                  'kk_pengangguran',
              'Jumlah kepala keluarga yang tidak memiliki pekerjaan tetap':
                  'kk_tidak_tetap',
              'Jumlah Kepala Keluarga yang memiliki penghasilan tetap':
                  'kk_penghasilan_tetap',
              'Jumlah Ibu hamil yang mempunyai tabungan bersalin (TABULIN)':
                  'ibu_hamil_tabulin',
              'Jumlah keluarga yang memiliki tabungan': 'keluarga_tabungan',
              'Jumlah keluarga yang mempunyai aset untuk investasi':
                  'keluarga_aset_investasi',
            },
          ),
          _PokjaSubItem(
            title:
                'IX. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Mewujudkan Keluarga Sehat Pasangan Usia Subur (PUS)',
            deskripsi: '7 field • KB, Reproduksi, Nikah Dini',
            icon: Icons.pregnant_woman_rounded,
            groupFields: {
              'Jumlah Ibu melahirkan Bayi sehat':
                  'ibu_melahirkan_bayi_sehat',
              'Jumlah wanita sebagai peserta KB': 'wanita_peserta_kb',
              'Jumlah pria peserta KB': 'pria_peserta_kb',
              'Jumlah Pasangan Usia Subur (PUS) yang memiliki masalah kesehatan reproduksi':
                  'pus_masalah_reproduksi',
              'Jumlah Pasangan Usia Subur (PUS) yang menikah dengan istri usia dibawah usia 19 Tahun':
                  'pus_nikah_di_bawah_19',
              'Jumlah Wanita Usia Subur dengan kehamilan beresiko':
                  'wus_hamil_beresiko',
              'Jumlah penderita penyakit infeksi menular seksual pada Pasangan Usia Subur (PUS)':
                  'pus_penyakit_seksual',
            },
          ),
          // ===== EVALUASI & KETERANGAN (kolom tabel) =====
          _PokjaSubItem(
            title: 'Evaluasi',
            deskripsi: 'Catatan evaluasi pelaksanaan kegiatan',
            icon: Icons.rate_review_rounded,
            fieldL: 'evaluasi',
            isText: true,
          ),
          _PokjaSubItem(
            title: 'Keterangan',
            deskripsi: 'Keterangan tambahan laporan',
            icon: Icons.sticky_note_2_rounded,
            fieldL: 'keterangan',
            isText: true,
          ),
        ];

      case PokjaKategori.pokja4DataProgram:
        // ⛔ Lama — disembunyikan dari picker, dipertahankan untuk riwayat.
        // Isi disamakan persis dengan 9 kartu B di form gabungan.
        return const [
          _PokjaSubItem(
            title:
                'I. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Peduli Stunting',
            deskripsi: '7 field • Prematur, BBLR, Gizi, Stunting',
            icon: Icons.monitor_heart_rounded,
            groupFields: {
              'Jumlah Bayi Lahir Prematur': 'bayi_prematur',
              'Jumlah Bayi Lahir Berat Badan Bayi Lahir Rendah (BBLR)':
                  'bayi_bblr',
              'Jumlah Balita Kurang Gizi': 'balita_kurang_gizi',
              'Jumlah Balita Stunting': 'balita_stunting',
              'Jumlah bayi dan balita yang rutin dilakukan pemeriksaan tumbuh kembang setiap bulan':
                  'bayi_balita_periksa',
              'Jumlah Ibu Yang Melahirkan dengan Jarak Terlalu Dekat':
                  'ibu_lahir_jarak_dekat',
              'Jumlah Kehamilan Yang Tidak Direncanakan / Tidak Diinginkan':
                  'hamil_tidak_direncanakan',
            },
          ),
          _PokjaSubItem(
            title:
                'II. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Menuju Perilaku Hidup Bersih Dan Sehat (PHBS)',
            deskripsi: '7 field • TBC, Jamban, Diare, Gizi, BABS',
            icon: Icons.clean_hands_rounded,
            groupFields: {
              'Jumlah penduduk penderita Tuberkulosis (TBC)': 'penduduk_tbc',
              'Jumlah rumah yang memiliki jamban sehat': 'rumah_jamban_sehat',
              'Jumlah rumah yang memiliki fasilitas instalasi atau bak penampung air bersih':
                  'rumah_bak_air',
              'Jumlah kasus penyakit Diare': 'kasus_diare',
              'Jumlah keluarga yang sadar gizi': 'keluarga_sadar_gizi',
              'Jumlah rumah tanpa asap rokok': 'rumah_tanpa_asap_rokok',
              'Jumlah penduduk yang masih Buang Air Besar Sembarangan (BABS)':
                  'penduduk_babs',
            },
          ),
          _PokjaSubItem(
            title:
                'III. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Peduli Kesehatan Keluarga (Ayah, Ibu dan Anak)',
            deskripsi: '7 field • Hamil, Merokok, Kanker, Imunisasi',
            icon: Icons.health_and_safety_rounded,
            groupFields: {
              'Jumlah ibu hamil yang rutin memeriksakan kehamilannya pada tenaga kesehatan secara periodik':
                  'ibu_hamil_periksa',
              'Jumlah Ayah yang merokok': 'ayah_merokok',
              'Jumlah kasus Kematian Ibu nifas': 'kematian_ibu_nifas',
              'Jumlah kasus Kanker Serviks pada Perempuan': 'kanker_serviks',
              'Jumlah bayi dan balita yang mendapat imunisasi dasar lengkap':
                  'bayi_balita_imunisasi',
              'Jumlah bayi dan balita sakit yang terdata pada fasilitas kesehatan':
                  'bayi_balita_sakit',
              'Jumlah kasus Kematian Bayi dan Balita': 'kematian_bayi_balita',
            },
          ),
          _PokjaSubItem(
            title:
                'IV. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Siaga Kebakaran Lingkungan',
            deskripsi: '7 field • Kebakaran, Listrik, APAR, P3K',
            icon: Icons.local_fire_department_rounded,
            groupFields: {
              'Jumlah kasus Kebakaran Rumah Tangga':
                  'kebakaran_rumah_tangga',
              'Jumlah Rumah Tangga Yang Memiliki Instalasi Listrik Yang Sesuai Standar':
                  'rumah_listrik_standar',
              'Jumlah Rumah Tangga Yang Memiliki Alat Pemadam Kebakaran':
                  'rumah_alat_pemadam',
              'Jumlah Rumah Semi Permanen dan rumah kayu':
                  'rumah_semi_permanen',
              'Jumlah Rumah Tangga yang memiliki Kotak P3K':
                  'rumah_kotak_p3k',
              'Jumlah Rumah Tangga Yang Telah Mendapatkan Informasi, Penyuluhan, Atau Sosialisasi Tentang Mitigasi Dan Penanggulangan Kebakaran':
                  'rumah_info_mitigasi_kebakaran',
              'Jumlah Kader PKK Yang Telah Mendapatkan Edukasi Terkait Mitigasi Bencana Kebakaran':
                  'kader_edukasi_kebakaran',
            },
          ),
          _PokjaSubItem(
            title:
                'V. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Mitigasi Bencana Alam',
            deskripsi: '7 field • Relawan, Posko, Tas Siaga',
            icon: Icons.flood_rounded,
            groupFields: {
              'Jumlah Relawan Bencana Alam': 'relawan_bencana_alam',
              'Jumlah Rumah Tangga Yang Telah Mendapatkan Informasi, Penyuluhan, Atau Sosialisasi Tentang Mitigasi Dan Penanggulangan Bencana Alam':
                  'rumah_info_mitigasi_alam',
              'Jumlah Kader PKK Yang Telah Mendapatkan Edukasi Terkait Mitigasi Bencana Alam':
                  'kader_edukasi_alam',
              'Jumlah Fasilitas/Bangunan Yang Ditetapkan Sebagai Alternatif Posko Bila Terjadi Bencana Alam':
                  'fasilitas_posko_bencana',
              'Jumlah Relawan Bencana Alam (2)': 'relawan_bencana_alam_2',
              'Jumlah Rumah Tangga Yang Memiliki Tas Siaga Bencana':
                  'rumah_tas_siaga',
              'Jumlah Kerusakan Fasilitas Umum Yang Diakibatkan Oleh Bencana Alam':
                  'kerusakan_fasilitas_umum',
            },
          ),
          _PokjaSubItem(
            title:
                'VI. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Peduli Lingkungan',
            deskripsi: '7 field • Sampah, SPAL, Banjir, KLB',
            icon: Icons.recycling_rounded,
            groupFields: {
              'Jumlah Keluarga yang memiliki bak sampah':
                  'keluarga_bak_sampah',
              'Jumlah Keluarga sebagai anggota Bank Sampah':
                  'keluarga_anggota_bank_sampah',
              'Jumlah keluarga yang menggunakan Sistem Pembuangan Air Limbah (SPAL)':
                  'keluarga_spal',
              'Jumlah kasus banjir': 'kasus_banjir',
              'Jumlah bak sampah milik desa/kelurahan': 'bak_sampah_desa',
              'Jumlah Rumah sehat': 'rumah_sehat',
              'Jumlah kasus Kejadian Luar Biasa (KLB)': 'kasus_klb',
            },
          ),
          _PokjaSubItem(
            title:
                'VII. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Menuju Keluarga Sehat Berkualitas',
            deskripsi: '7 field • 2 Anak, Berobat, Bayi Sehat',
            icon: Icons.favorite_rounded,
            groupFields: {
              'Jumlah Keluarga dengan 2 anak': 'keluarga_2_anak',
              'Jumlah Penduduk yang berobat ke fasilitas kesehatan berdasarkan data di fasilitas kesehatan':
                  'penduduk_berobat',
              'Jumlah kasus penyakit menular': 'penyakit_menular',
              'Jumlah kasus penyakit tidak menular': 'penyakit_tidak_menular',
              'Jumlah Bayi Lahir Sehat': 'bayi_lahir_sehat',
              'Jumlah Bayi Lahir Cukup Bulan': 'bayi_cukup_bulan',
              'Jumlah keluarga yang memiliki anggota dengan kriteria penyakit gangguan jiwa':
                  'keluarga_gangguan_jiwa',
            },
          ),
          _PokjaSubItem(
            title:
                'VIII. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Menuju Keuangan Sehat',
            deskripsi: '7 field • Asuransi, Tabungan, Aset',
            icon: Icons.savings_rounded,
            groupFields: {
              'Jumlah Keluarga yang memiliki Asuransi Kesehatan':
                  'keluarga_asuransi',
              'Jumlah kepala keluarga yang tidak memiliki pekerjaan / Pengangguran':
                  'kk_pengangguran',
              'Jumlah kepala keluarga yang tidak memiliki pekerjaan tetap':
                  'kk_tidak_tetap',
              'Jumlah Kepala Keluarga yang memiliki penghasilan tetap':
                  'kk_penghasilan_tetap',
              'Jumlah Ibu hamil yang mempunyai tabungan bersalin (TABULIN)':
                  'ibu_hamil_tabulin',
              'Jumlah keluarga yang memiliki tabungan': 'keluarga_tabungan',
              'Jumlah keluarga yang mempunyai aset untuk investasi':
                  'keluarga_aset_investasi',
            },
          ),
          _PokjaSubItem(
            title:
                'IX. Program Gerakan Keluarga Sehat Tanggap dan Tangguh Bencana Mewujudkan Keluarga Sehat Pasangan Usia Subur (PUS)',
            deskripsi: '7 field • KB, Reproduksi, Nikah Dini',
            icon: Icons.pregnant_woman_rounded,
            groupFields: {
              'Jumlah Ibu melahirkan Bayi sehat':
                  'ibu_melahirkan_bayi_sehat',
              'Jumlah wanita sebagai peserta KB': 'wanita_peserta_kb',
              'Jumlah pria peserta KB': 'pria_peserta_kb',
              'Jumlah Pasangan Usia Subur (PUS) yang memiliki masalah kesehatan reproduksi':
                  'pus_masalah_reproduksi',
              'Jumlah Pasangan Usia Subur (PUS) yang menikah dengan istri usia dibawah usia 19 Tahun':
                  'pus_nikah_di_bawah_19',
              'Jumlah Wanita Usia Subur dengan kehamilan beresiko':
                  'wus_hamil_beresiko',
              'Jumlah penderita penyakit infeksi menular seksual pada Pasangan Usia Subur (PUS)':
                  'pus_penyakit_seksual',
            },
          ),
        ];
    }
  }

  Future<void> _pilihFoto() async {
    HapticFeedback.lightImpact();
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Kamera',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Ambil foto langsung',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Galeri',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Pilih dari galeri',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (sumber == null) return;
    try {
      final gambar = await _picker.pickImage(
        source: sumber,
        imageQuality: 75,
        maxWidth: 1280,
      );
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
    final c = _getPokjaColor(_kategori);
    final pal = _sheetPalette();
    final searchCtrl = TextEditingController();
    List<String> filtered = List.from(CatatanKegiatan.daftar39Kecamatan);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: pal.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: pal.handle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih Kecamatan',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: pal.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '39 kecamatan Kab. Tasikmalaya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: pal.sub,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: searchCtrl,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: pal.text,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari kecamatan...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: pal.faint,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: pal.faint,
                      ),
                      filled: true,
                      fillColor: pal.fill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setModal(
                      () => filtered = CatatanKegiatan.daftar39Kecamatan
                          .where(
                            (k) => k.toLowerCase().contains(
                              v.toLowerCase().trim(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: _isDarkMode
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF1F5F9),
                      ),
                      itemBuilder: (_, i) {
                        final kec = filtered[i];
                        final sel = kec == _selectedKecamatan;
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          title: Text(
                            kec,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 14,
                              color: sel ? c : pal.text,
                            ),
                          ),
                          trailing: sel
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: c,
                                  size: 20,
                                )
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
      ),
    );
  }

  void _showPokjaPicker() {
    HapticFeedback.selectionClick();
    final pal = _sheetPalette();
    final pokjas = _availablePokjas();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: pal.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: pal.handle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih Pokja',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: pal.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _restrictedPokja == PokjaKategori.pokja4
                      ? '5 kategori Pokja IV'
                      : '${pokjas.length} kategori tersedia',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: pal.sub,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: pokjas.map((p) {
                      final c = _getPokjaColor(p);
                      final soft = _getPokjaSoft(p);
                      final sel = p == _kategori;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: sel
                              ? c.withValues(alpha: 0.08)
                              : pal.fill,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() => _kategori = p);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: sel
                                      ? c.withValues(alpha: 0.22)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? c.withValues(alpha: 0.15)
                                          : (_isDarkMode
                                              ? c.withValues(alpha: 0.12)
                                              : soft),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getPokjaIcon(p),
                                      size: 18,
                                      color: c,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.shortLabel,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: pal.text,
                                          ),
                                        ),
                                        Text(
                                          _getPokjaSubtitle(p),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            color: pal.sub,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (sel)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 20,
                                      color: c,
                                    )
                                  else
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: pal.faint,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM SHEET — INPUT
  // ============================================================
  void _showKegiatanInputSheet(_PokjaSubItem sub, int idx) {
    // Pokja 1 program (4 field) — pakai sheet khusus
    final isPokja1Program = _kategori == PokjaKategori.pokja1 &&
        ['kisah', 'kilas', 'krisan', 'kiat', 'kisak', 'pkbn'].contains(sub.fieldL);
    if (isPokja1Program) {
      _showKegiatanInputSheetPokja1(sub);
      return;
    }

    if (sub.groupFields != null) {
      _showGroupedInputSheet(sub);
      return;
    }

    // ✅ Kartu isian teks (Evaluasi/Keterangan Laporan Data Dukung)
    if (sub.isText) {
      _showTextInputSheet(sub);
      return;
    }

    // Sheet lama (L/P) untuk Pokja 2-4 + Kader Pokja 1
    HapticFeedback.selectionClick();
    final c = _getPokjaColor(_kategori);
    final soft = _getPokjaSoft(_kategori);
    final pal = _sheetPalette();
    final lEmpty = (_angkaCtrl[sub.fieldL]?.text ?? '').isEmpty;
    final pEmpty = sub.fieldP.isNotEmpty &&
        (_angkaCtrl[sub.fieldP]?.text ?? '').isEmpty;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheet) {
          final l = int.tryParse(_angkaCtrl[sub.fieldL]?.text ?? '') ?? 0;
          final p = sub.fieldP.isEmpty
              ? 0
              : int.tryParse(_angkaCtrl[sub.fieldP]?.text ?? '') ?? 0;
          final total = l + p;
          return Container(
            decoration: BoxDecoration(
              color: pal.bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: pal.handle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _isDarkMode
                                ? c.withValues(alpha: 0.14)
                                : soft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(sub.icon, size: 20, color: c),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: pal.text,
                                ),
                              ),
                              Text(
                                sub.deskripsi,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: pal.sub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: pal.fill,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          _numRow(
                            sub.fieldP.isEmpty ? 'Jumlah' : 'Laki-laki (L)',
                            sub.fieldL,
                            c,
                            pal.fill,
                            pal.bg,
                            _isDarkMode
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE2E8F0),
                            pal.text,
                            pal.sub,
                            setSheet,
                            autofocus: lEmpty,
                            textInputAction: sub.fieldP.isEmpty
                                ? TextInputAction.done
                                : TextInputAction.next,
                          ),
                          if (sub.fieldP.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _numRow(
                              'Perempuan (P)',
                              sub.fieldP,
                              c,
                              pal.fill,
                              pal.bg,
                              _isDarkMode
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFE2E8F0),
                              pal.text,
                              pal.sub,
                              setSheet,
                              autofocus: !lEmpty && pEmpty,
                              textInputAction: TextInputAction.done,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: c.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calculate_rounded,
                            color: c,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            sub.fieldP.isEmpty
                                ? 'Total'
                                : 'Total (L + P)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: pal.sub,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            sub.fieldP.isEmpty ? '$l' : '$l + $p = $total',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: c,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Selesai',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTextInputSheet(_PokjaSubItem sub) {
    HapticFeedback.selectionClick();
    final c = _getPokjaColor(_kategori);
    final soft = _getPokjaSoft(_kategori);
    final pal = _sheetPalette();
    _angkaCtrl.putIfAbsent(sub.fieldL, () => TextEditingController());
    final ctrl = _angkaCtrl[sub.fieldL]!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: pal.bg,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: pal.handle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? c.withValues(alpha: 0.14)
                            : soft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(sub.icon, size: 20, color: c),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: pal.text,
                            ),
                          ),
                          Text(
                            sub.deskripsi,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: pal.sub,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  maxLines: 5,
                  minLines: 3,
                  textInputAction: TextInputAction.done,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: pal.text,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis ${sub.title.toLowerCase()} di sini...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: pal.faint,
                    ),
                    filled: true,
                    fillColor: pal.fill,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: c.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Selesai',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGroupedInputSheet(_PokjaSubItem sub) {
    HapticFeedback.selectionClick();
    final c = _getPokjaColor(_kategori);
    final soft = _getPokjaSoft(_kategori);
    final pal = _sheetPalette();

    for (final entry in sub.groupFields!.entries) {
      if (entry.value is String) {
        _angkaCtrl.putIfAbsent(entry.value as String, () => TextEditingController());
      } else if (entry.value is Map) {
        final subMap = entry.value as Map;
        for (final subEntry in subMap.entries) {
          _angkaCtrl.putIfAbsent(subEntry.value as String, () => TextEditingController());
        }
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheet) {
          return Container(
            decoration: BoxDecoration(
              color: pal.bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(color: pal.handle, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: _isDarkMode ? c.withValues(alpha: 0.14) : soft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(sub.icon, size: 20, color: c),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sub.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: pal.text)),
                              Text(sub.deskripsi, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: pal.sub)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...sub.groupFields!.entries.map((entry) {
                      if (entry.value is String) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: pal.fill,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: _numRow(
                              entry.key,
                              entry.value as String,
                              c,
                              pal.fill,
                              pal.bg,
                              _isDarkMode ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                              pal.text,
                              pal.sub,
                              setSheet,
                            ),
                          ),
                        );
                      } else if (entry.value is Map) {
                        final subFields = entry.value as Map;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: pal.fill,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: pal.handle, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.key, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5, color: pal.text)),
                                const SizedBox(height: 12),
                                ...subFields.entries.map((subEntry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _numRow(
                                      subEntry.key,
                                      subEntry.value as String,
                                      c,
                                      pal.bg,
                                      pal.fill,
                                      _isDarkMode ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFCBD5E1),
                                      pal.text,
                                      pal.sub,
                                      setSheet,
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 48,
                      child: ElevatedButton(
                        onPressed: () { setState(() {}); Navigator.pop(ctx); },
                        style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: Text('Selesai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showKegiatanInputSheetPokja1(_PokjaSubItem sub) {
    HapticFeedback.selectionClick();
    final c = _getPokjaColor(_kategori);
    final soft = _getPokjaSoft(_kategori);
    final pal = _sheetPalette();
    final prefix = sub.fieldL;

    for (final suffix in ['_kegiatan', '_volume', '_metode', '_sasaran']) {
      _angkaCtrl.putIfAbsent('$prefix$suffix', () => TextEditingController());
    }

    final kegiatanCtrl = _angkaCtrl['${prefix}_kegiatan']!;
    final volumeCtrl = _angkaCtrl['${prefix}_volume']!;
    final metodeCtrl = _angkaCtrl['${prefix}_metode']!;
    final sasaranCtrl = _angkaCtrl['${prefix}_sasaran']!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheet) {
          return Container(
            decoration: BoxDecoration(
              color: pal.bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(color: pal.handle, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: _isDarkMode ? c.withValues(alpha: 0.14) : soft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(sub.icon, size: 20, color: c),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sub.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: pal.text)),
                              Text(sub.deskripsi, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: pal.sub)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: kegiatanCtrl,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: pal.text),
                      decoration: InputDecoration(
                        labelText: 'Kegiatan',
                        hintText: 'Mis. Sosialisasi CATIN',
                        filled: true, fillColor: pal.fill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: volumeCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: pal.text),
                      decoration: InputDecoration(
                        labelText: 'Volume',
                        hintText: 'Mis. 22',
                        filled: true, fillColor: pal.fill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: metodeCtrl,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: pal.text),
                      decoration: InputDecoration(
                        labelText: 'Metode',
                        hintText: 'Mis. Sosialisasi / Pembinaan',
                        filled: true, fillColor: pal.fill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sasaranCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: pal.text),
                      decoration: InputDecoration(
                        labelText: 'Jumlah Sasaran',
                        hintText: 'Mis. 384',
                        filled: true, fillColor: pal.fill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.withValues(alpha: 0.18)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calculate_rounded, color: c, size: 18),
                          const SizedBox(width: 8),
                          Text('Sasaran', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.sub)),
                          const Spacer(),
                          Text(sasaranCtrl.text.isEmpty ? '0' : sasaranCtrl.text, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: c)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 48,
                      child: ElevatedButton(
                        onPressed: () { setState(() {}); Navigator.pop(ctx); },
                        style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: Text('Selesai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: _isDarkMode
              ? ColorScheme.dark(
                  primary: _getPokjaColor(_kategori),
                  onPrimary: Colors.white,
                  surface: const Color(0xFF1E242D),
                )
              : ColorScheme.light(
                  primary: _getPokjaColor(_kategori),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_desaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desa/Kelurahan wajib diisi'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    try {
      final Map<String, dynamic> dataAngka = {};
      if (_kategori == PokjaKategori.pokja1) {
        for (final k in ['kader_umum', 'kader_khusus']) {
          final v = int.tryParse(_angkaCtrl[k]?.text.trim() ?? '');
          if (v != null && v > 0) dataAngka[k] = v;
        }
        for (final prog in ['kisah', 'kilas', 'krisan', 'kiat', 'kisak', 'pkbn']) {
          final kegiatan = _angkaCtrl['${prog}_kegiatan']?.text.trim() ?? '';
          final volume = int.tryParse(_angkaCtrl['${prog}_volume']?.text.trim() ?? '');
          final metode = _angkaCtrl['${prog}_metode']?.text.trim() ?? '';
          final sasaran = int.tryParse(_angkaCtrl['${prog}_sasaran']?.text.trim() ?? '');
          if (kegiatan.isNotEmpty) dataAngka['${prog}_kegiatan'] = kegiatan;
          if (volume != null && volume > 0) dataAngka['${prog}_volume'] = volume;
          if (metode.isNotEmpty) dataAngka['${prog}_metode'] = metode;
          if (sasaran != null && sasaran > 0) dataAngka['${prog}_sasaran'] = sasaran;
        }
      } else {
        // Hanya kirim field milik kategori aktif — cegah nilai sisa dari
        // Pokja lain (satu form bisa ganti-ganti Pokja) ikut terkirim.
        final allowed = <String>{};
        for (final s in _getSubItems(_kategori)) {
          if (s.groupFields != null) {
            allowed.addAll(_flattenGroupKeys(s.groupFields!));
          } else {
            if (s.fieldL.isNotEmpty) allowed.add(s.fieldL);
            if (s.fieldP.isNotEmpty) allowed.add(s.fieldP);
          }
        }
        // Kunci teks (Evaluasi/Keterangan) — disimpan sebagai string.
        const textKeys = {'evaluasi', 'keterangan'};
        for (final key in allowed) {
          if (textKeys.contains(key)) {
            final t = _angkaCtrl[key]?.text.trim() ?? '';
            if (t.isNotEmpty) dataAngka[key] = t;
            continue;
          }
          final v = int.tryParse(_angkaCtrl[key]?.text.trim() ?? '');
          if (v != null && v > 0) dataAngka[key] = v;
        }
      }

      if (_kategori == PokjaKategori.pokja4Pyd ||
          _kategori == PokjaKategori.pokja4Posyandu) {
        dataAngka['bulan'] = _tanggal.month;
        dataAngka['tahun'] = _tanggal.year;
      }
      if (_kategori == PokjaKategori.pokja4Rekap) {
        dataAngka['tahun'] = _tanggal.year;
      }

      String? emptyToNull(TextEditingController c) {
        final v = c.text.trim();
        return v.isEmpty ? null : v;
      }

      final item = CatatanKegiatan(
        id: widget.catatan?.id ?? 0,
        judul: _judulController.text.trim(),
        deskripsiSingkat: _deskripsiController.text.trim(),
        kategori: _kategori,
        dataAngka: dataAngka,
        kecamatan: _selectedKecamatan,
        desa: _desaController.text.trim(),
        fotoPath: _fotoFile?.path,
        tanggal: _tanggal,
        provinsi: emptyToNull(_provinsiController),
        kabupatenKota: emptyToNull(_kabupatenController),
        program: emptyToNull(_programController),
        pjDesa: emptyToNull(_pjDesaController),
        pjDesaHp: emptyToNull(_pjDesaHpController),
        pjKecamatan: emptyToNull(_pjKecamatanController),
        pjKecamatanHp: emptyToNull(_pjKecamatanHpController),
        pjKabupaten: emptyToNull(_pjKabupatenController),
        pjKabupatenHp: emptyToNull(_pjKabupatenHpController),
        pjProvinsi: emptyToNull(_pjProvinsiController),
        pjProvinsiHp: emptyToNull(_pjProvinsiHpController),
      );
      // ✅ 1 FORM GABUNGAN: split ke 2 tabel backend (Data Dukung + Data Program)
      if (_kategori == PokjaKategori.pokja4DataDukung &&
          widget.catatan == null) {
        final dukung = <String, dynamic>{};
        final program = <String, dynamic>{};
        for (final e in dataAngka.entries) {
          if (PokjaKategoriLabel.dataDukungKeys.contains(e.key)) {
            dukung[e.key] = e.value;
          } else if (PokjaKategoriLabel.dataProgramKeys.contains(e.key)) {
            program[e.key] = e.value;
          }
        }
        // ✅ Evaluasi & Keterangan ikut di kedua POST (kolom tabel).
        for (final k in const ['evaluasi', 'keterangan']) {
          final t = dataAngka[k];
          if (t != null && (t as String).isNotEmpty) {
            dukung[k] = t;
            program[k] = t;
          }
        }
        final baseJudul = _judulController.text.trim();
        if (dukung.isNotEmpty && program.isNotEmpty) {
          await _service.kirim(
            item.copyWith(
              judul: baseJudul,
              kategori: PokjaKategori.pokja4DataDukung,
              dataAngka: dukung,
            ),
          );
          await _service.kirim(
            CatatanKegiatan(
              judul: '$baseJudul - Data Program',
              deskripsiSingkat: _deskripsiController.text.trim(),
              kategori: PokjaKategori.pokja4DataProgram,
              dataAngka: program,
              kecamatan: _selectedKecamatan,
              desa: _desaController.text.trim(),
              fotoPath: _fotoFile?.path,
              tanggal: _tanggal,
              provinsi: item.provinsi,
              kabupatenKota: item.kabupatenKota,
              program: item.program,
              pjDesa: item.pjDesa,
              pjDesaHp: item.pjDesaHp,
              pjKecamatan: item.pjKecamatan,
              pjKecamatanHp: item.pjKecamatanHp,
              pjKabupaten: item.pjKabupaten,
              pjKabupatenHp: item.pjKabupatenHp,
              pjProvinsi: item.pjProvinsi,
              pjProvinsiHp: item.pjProvinsiHp,
            ),
          );
        } else if (program.isNotEmpty && dukung.isEmpty) {
          await _service.kirim(
            item.copyWith(
              kategori: PokjaKategori.pokja4DataProgram,
              dataAngka: program,
            ),
          );
        } else {
          await _service.kirim(
            item.copyWith(
              kategori: PokjaKategori.pokja4DataDukung,
              dataAngka: dukung,
            ),
          );
        }
      } else {
        await _service.kirim(item);
      }
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tersimpan — ${_kategori.shortLabel} • ${_desaController.text.trim()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
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
              'Gagal: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  List<String> _flattenGroupKeys(Map<String, dynamic> group) {
    final keys = <String>[];
    for (final v in group.values) {
      if (v is String) {
        keys.add(v);
      } else if (v is Map) {
        keys.addAll(_flattenGroupKeys(Map<String, dynamic>.from(v)));
      }
    }
    return keys;
  }

  int _hitungTotal() {
    int t = 0;
    for (final s in _getSubItems(_kategori)) {
      if (_kategori == PokjaKategori.pokja1 &&
          ['kisah', 'kilas', 'krisan', 'kiat', 'kisak', 'pkbn'].contains(s.fieldL)) {
        final prefix = s.fieldL;
        t += int.tryParse(_angkaCtrl['${prefix}_sasaran']?.text ?? '') ?? 0;
        continue;
      }
      if (s.groupFields != null) {
        for (final k in _flattenGroupKeys(s.groupFields!)) {
          t += int.tryParse(_angkaCtrl[k]?.text ?? '') ?? 0;
        }
        continue;
      }
      t += int.tryParse(_angkaCtrl[s.fieldL]?.text ?? '') ?? 0;
      if (s.fieldP.isNotEmpty)
        t += int.tryParse(_angkaCtrl[s.fieldP]?.text ?? '') ?? 0;
    }
    return t;
  }

  int _countFilled() {
    int c = 0;
    for (final s in _getSubItems(_kategori)) {
      if (_kategori == PokjaKategori.pokja1 &&
          ['kisah', 'kilas', 'krisan', 'kiat', 'kisak', 'pkbn'].contains(s.fieldL)) {
        final prefix = s.fieldL;
        final kegiatan = _angkaCtrl['${prefix}_kegiatan']?.text ?? '';
        final sasaran = _angkaCtrl['${prefix}_sasaran']?.text ?? '';
        if (kegiatan.isNotEmpty || sasaran.isNotEmpty) c++;
        continue;
      }
      if (s.groupFields != null) {
        for (final k in _flattenGroupKeys(s.groupFields!)) {
          if ((int.tryParse(_angkaCtrl[k]?.text ?? '') ?? 0) > 0) c++;
        }
        continue;
      }
      if (s.isText) {
        if ((_angkaCtrl[s.fieldL]?.text ?? '').trim().isNotEmpty) c++;
        continue;
      }
      if ((int.tryParse(_angkaCtrl[s.fieldL]?.text ?? '') ?? 0) > 0) c++;
      if (s.fieldP.isNotEmpty &&
          (int.tryParse(_angkaCtrl[s.fieldP]?.text ?? '') ?? 0) > 0)
        c++;
    }
    return c;
  }

  int _countCardsFilled() {
    int c = 0;
    for (final s in _getSubItems(_kategori)) {
      bool filled = false;
      if (_kategori == PokjaKategori.pokja1 &&
          ['kisah', 'kilas', 'krisan', 'kiat', 'kisak', 'pkbn'].contains(s.fieldL)) {
        final prefix = s.fieldL;
        final kegiatan = _angkaCtrl['${prefix}_kegiatan']?.text ?? '';
        final sasaran = _angkaCtrl['${prefix}_sasaran']?.text ?? '';
        filled = kegiatan.isNotEmpty || sasaran.isNotEmpty;
      } else if (s.groupFields != null) {
        for (final k in _flattenGroupKeys(s.groupFields!)) {
          if ((int.tryParse(_angkaCtrl[k]?.text ?? '') ?? 0) > 0) {
            filled = true;
            break;
          }
        }
      } else if (s.isText) {
        filled = (_angkaCtrl[s.fieldL]?.text ?? '').trim().isNotEmpty;
      } else {
        filled = (int.tryParse(_angkaCtrl[s.fieldL]?.text ?? '') ?? 0) > 0 ||
            (s.fieldP.isNotEmpty &&
                (int.tryParse(_angkaCtrl[s.fieldP]?.text ?? '') ?? 0) > 0);
      }
      if (filled) c++;
    }
    return c;
  }

  Widget _buildPokjaSelectionScreen() {
    final bg = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF8FAFC);
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final text = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final sub = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = _isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFE2E8F0);

    final pokjas = _availablePokjas();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Catatan Kegiatan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: text,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0072BC).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF0072BC),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Pokja dulu, yuk',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Setiap Pokja punya format isian yang berbeda — pilih yang mau kamu catat hari ini.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          height: 1.4,
                          color: sub,
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
            'Kategori Pokja',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.6,
              color: sub,
            ),
          ),
          const SizedBox(height: 12),
          ...pokjas.map((p) {
            final c = _getPokjaColor(p);
            final soft = _getPokjaSoft(p);
            final ic = _getPokjaIcon(p);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _kategori = p;
                      _pokjaDipilih = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _isDarkMode
                                ? c.withValues(alpha: 0.15)
                                : soft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(ic, color: c, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.shortLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getPokjaSubtitle(p),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: sub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: c,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0072BC).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  size: 16,
                  color: Color(0xFF0072BC),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tips: kamu bisa ganti Pokja lagi nanti lewat tombol di atas form.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF0072BC),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_pokjaDipilih) return _buildPokjaSelectionScreen();

    final c = _getPokjaColor(_kategori);
    final soft = _getPokjaSoft(_kategori);
    final bg = _isDarkMode ? const Color(0xFF14181F) : const Color(0xFFF8FAFC);
    final cardBg = _isDarkMode ? const Color(0xFF1E242D) : Colors.white;
    final text = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final sub = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = _isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFE2E8F0);
    final inputFill = _isDarkMode
        ? const Color(0xFF14181F)
        : const Color(0xFFF8FAFC);
    final subItems = _getSubItems(_kategori);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: text),
          onPressed: () {
            if (widget.catatan == null && widget.pokjaAwal == null) {
              setState(() => _pokjaDipilih = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(_getPokjaIcon(_kategori), size: 14, color: c),
                  const SizedBox(width: 6),
                  Text(
                    _kategori.shortLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: c,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.catatan != null ? 'Edit Kegiatan' : 'Input Kegiatan',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: text,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (widget.catatan == null && widget.pokjaAwal == null)
            TextButton(
              onPressed: _showPokjaPicker,
              child: Text(
                'Ganti Pokja',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: c,
                ),
              ),
            ),
          TextButton(
            onPressed: () => setState(() => _pokjaDipilih = false),
            child: Text(
              'Daftar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: sub,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _isDarkMode ? c.withValues(alpha: 0.15) : soft,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          _getPokjaIcon(_kategori),
                          color: c,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _kategori.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getPokjaSubtitle(_kategori),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: sub,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: inputFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _miniStat(
                          icon: Icons.people_alt_rounded,
                          label: 'Total peserta',
                          value: '${_hitungTotal()}',
                          color: c,
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: border,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        _miniStat(
                          icon: Icons.checklist_rounded,
                          label: 'Terisi',
                          value: '${_countFilled()} item',
                          color: const Color(0xFF10B981),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _countFilled() == 0
                                ? 'Belum diisi'
                                : 'Siap disimpan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: c,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _sectionLabel('Rincian peserta', '01', c, sub)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _countFilled() > 0
                        ? c.withValues(alpha: 0.12)
                        : inputFill,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _countFilled() > 0
                          ? c.withValues(alpha: 0.18)
                          : border,
                    ),
                  ),
                  child: Text(
                    '${_countCardsFilled()}/${subItems.length} terisi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _countFilled() > 0 ? c : sub,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih kartu untuk isi angka peserta',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: sub,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),

            ...subItems.asMap().entries.map((e) {
              final idx = e.key;
              final s = e.value;
              final isPokja1Program = _kategori == PokjaKategori.pokja1 &&
                  ['kisah', 'kilas', 'krisan', 'kiat', 'kisak', 'pkbn'].contains(s.fieldL);
              int sum = 0;
              String ringkas;
              if (isPokja1Program) {
                final prefix = s.fieldL;
                final kegiatan = _angkaCtrl['${prefix}_kegiatan']?.text ?? '';
                final sasaran = _angkaCtrl['${prefix}_sasaran']?.text ?? '';
                final hasValue = kegiatan.isNotEmpty || sasaran.isNotEmpty;
                ringkas = hasValue
                    ? '${kegiatan.isNotEmpty ? kegiatan.substring(0, kegiatan.length.clamp(0, 15)) : "-"}${sasaran.isNotEmpty ? " • $sasaran" : ""}'
                    : 'Isi';
                final hasValueFinal = hasValue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showKegiatanInputSheet(s, idx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasValueFinal ? c.withValues(alpha: 0.18) : border,
                            width: 1,
                          ),
                          boxShadow: [
                            if (!_isDarkMode)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: hasValueFinal
                                    ? c.withValues(alpha: 0.12)
                                    : inputFill,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                s.icon,
                                size: 20,
                                color: hasValueFinal ? c : const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.deskripsi,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: sub,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: hasValueFinal
                                    ? c.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: hasValueFinal ? Colors.transparent : border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ringkas,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: hasValueFinal ? c : sub,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    hasValueFinal
                                        ? Icons.check_circle_rounded
                                        : Icons.chevron_right_rounded,
                                    size: 14,
                                    color: hasValueFinal
                                        ? c
                                        : sub.withValues(alpha: 0.7),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              if (s.groupFields != null) {
                for (final k in _flattenGroupKeys(s.groupFields!)) {
                  if (_angkaCtrl[k]?.text.isNotEmpty == true) {
                    sum += int.tryParse(_angkaCtrl[k]!.text) ?? 0;
                  }
                }
                final hasValue = sum > 0;
                ringkas = hasValue ? '$sum Terisi' : 'Isi';
              } else if (s.isText) {
                final txt = (_angkaCtrl[s.fieldL]?.text ?? '').trim();
                final hasValue = txt.isNotEmpty;
                if (hasValue) sum = 1;
                ringkas = hasValue
                    ? (txt.length > 18 ? '${txt.substring(0, 18)}…' : txt)
                    : 'Isi';
              } else {
                if (_angkaCtrl[s.fieldL]?.text.isNotEmpty == true)
                  sum += int.tryParse(_angkaCtrl[s.fieldL]!.text) ?? 0;
                if (s.fieldP.isNotEmpty &&
                    _angkaCtrl[s.fieldP]?.text.isNotEmpty == true)
                  sum += int.tryParse(_angkaCtrl[s.fieldP]!.text) ?? 0;
                final hasValue = sum > 0;
                if (hasValue) {
                  if (s.fieldP.isEmpty) {
                    ringkas = '$sum';
                  } else {
                    final l = int.tryParse(_angkaCtrl[s.fieldL]?.text ?? '') ?? 0;
                    final p = int.tryParse(_angkaCtrl[s.fieldP]?.text ?? '') ?? 0;
                    ringkas = 'L $l • P $p';
                  }
                } else {
                  ringkas = 'Isi';
                }
              }
              final hasValue = sum > 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showKegiatanInputSheet(s, idx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: hasValue ? c.withValues(alpha: 0.18) : border,
                          width: 1,
                        ),
                        boxShadow: [
                          if (!_isDarkMode)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: hasValue
                                  ? c.withValues(alpha: 0.12)
                                  : inputFill,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              s.icon,
                              size: 20,
                              color: hasValue ? c : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.deskripsi,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: sub,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: hasValue
                                  ? c.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: hasValue ? Colors.transparent : border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ringkas,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: hasValue ? c : sub,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  hasValue
                                      ? Icons.check_circle_rounded
                                      : Icons.chevron_right_rounded,
                                  size: 14,
                                  color: hasValue
                                      ? c
                                      : sub.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                );
            }),

            const SizedBox(height: 18),
            _sectionLabel('Info pelaksanaan', '02', c, sub),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _judulController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Judul kegiatan',
                      hintText: _getJudulPlaceholder(_kategori),
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: sub,
                      ),
                      prefixIcon: Icon(Icons.edit_rounded, size: 18, color: c),
                      filled: true,
                      fillColor: inputFill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: c.withValues(alpha: 0.3)),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Judul wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pilihTanggal,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: inputFill,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: c,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal kegiatan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: sub,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${_tanggal.day} ${_bulan(_tanggal.month)} ${_tanggal.year}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Ganti',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: c,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _showKecamatanPicker,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: inputFill,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: c,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kecamatan',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          color: sub,
                                        ),
                                      ),
                                      Text(
                                        _selectedKecamatan,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                          color: text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: sub,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _desaController,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: text,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Desa / Kel. *',
                            hintText: 'Cipakat',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: sub,
                            ),
                            filled: true,
                            fillColor: inputFill,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: c.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Wajib' : null,
                        ),
                      ),
                    ],
                  ),
                  // ✅ Kop Laporan Data Dukung (Image 2) — khusus form ini
                  if (_kategori == PokjaKategori.pokja4DataDukung) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _kopField(
                            controller: _provinsiController,
                            label: 'Provinsi',
                            hint: 'Jawa Barat',
                            text: text,
                            sub: sub,
                            inputFill: inputFill,
                            c: c,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _kopField(
                            controller: _kabupatenController,
                            label: 'Kabupaten / Kota',
                            hint: 'Tasikmalaya',
                            text: text,
                            sub: sub,
                            inputFill: inputFill,
                            c: c,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _kopField(
                      controller: _programController,
                      label: 'Program',
                      hint: 'Gerakan Keluarga Sehat ...',
                      text: text,
                      sub: sub,
                      inputFill: inputFill,
                      c: c,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _kopField(
                            controller: _pjDesaController,
                            label: 'Penanggung Jawab Desa / Kel.',
                            hint: 'Nama penanggung jawab',
                            text: text,
                            sub: sub,
                            inputFill: inputFill,
                            c: c,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _kopField(
                            controller: _pjDesaHpController,
                            label: 'No. HP (Desa)',
                            hint: '08xx',
                            text: text,
                            sub: sub,
                            inputFill: inputFill,
                            c: c,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _kopField(
                            controller: _pjKecamatanController,
                            label: 'Penanggung Jawab Kecamatan',
                            hint: 'Nama penanggung jawab',
                            text: text,
                            sub: sub,
                            inputFill: inputFill,
                            c: c,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _kopField(
                            controller: _pjKecamatanHpController,
                            label: 'No. HP (Kecamatan)',
                            hint: '08xx',
                            text: text,
                            sub: sub,
                            inputFill: inputFill,
                            c: c,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _kopField(
                            controller: _pjKabupatenController,
                            label: 'Penanggung Jawab Kab. / Kota',
                            hint: 'Nama penanggung jawab',
                            text: text,
                            sub: sub,
                            inputFill: inputFill,
                            c: c,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _kopField(
                            controller: _pjKabupatenHpController,
                            label: 'No. HP (Kab. / Kota)',
                            hint: '08xx',
                            text: text,
                            sub: sub,
                            inputFill: inputFill,
                            c: c,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _kopField(
                            controller: _pjProvinsiController,
                            label: 'Penanggung Jawab Provinsi',
                            hint: 'Nama penanggung jawab',
                            text: text,
                            sub: sub,
                            inputFill: inputFill,
                            c: c,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _kopField(
                            controller: _pjProvinsiHpController,
                            label: 'No. HP (Provinsi)',
                            hint: '08xx',
                            text: text,
                            sub: sub,
                            inputFill: inputFill,
                            c: c,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),
            _sectionLabel('Cerita & dokumentasi', '03', c, sub),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _kategori == PokjaKategori.pokja3
                        ? 'Uraian singkat (Kolom 20 • Keterangan)'
                        : 'Uraian singkat',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _deskripsiController,
                    maxLines: 4,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.45,
                      color: text,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ceritakan hasil dan kesan kegiatan...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: sub,
                      ),
                      filled: true,
                      fillColor: inputFill,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: c.withValues(alpha: 0.3)),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Uraian wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pilihFoto,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 138,
                      decoration: BoxDecoration(
                        color: inputFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (_fotoBytes != null || _fotoFile != null)
                              ? c.withValues(alpha: 0.2)
                              : border,
                        ),
                      ),
                      child: (_fotoBytes != null)
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.memory(
                                    _fotoBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: _gantiFotoBadge(),
                                ),
                              ],
                            )
                          : (_fotoFile != null && !kIsWeb)
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _fotoFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: _gantiFotoBadge(),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    color: c,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tambah foto dokumentasi',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                    color: text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Opsional — jpg / png, maks 5MB',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: sub,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: c.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Simpan ${_kategori.shortLabel}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Pastikan data sudah benar sebelum disimpan',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: sub),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gantiFotoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_rounded, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            'Ganti',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Field teks kop Laporan Data Dukung — gaya mengikuti field Info pelaksanaan.
  Widget _kopField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color text,
    required Color sub,
    required Color inputFill,
    required Color c,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: text,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: sub),
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  String _bulan(int m) {
    const b = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return b[m - 1];
  }

  Widget _sectionLabel(String title, String no, Color c, Color sub) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              no,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: c,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: _isDarkMode ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: _isDarkMode
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFF1F5F9),
          ),
        ),
      ],
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                color: const Color(0xFF94A3B8),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: _isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _numRow(
    String label,
    String fieldKey,
    Color c,
    Color inputFill,
    Color cardBg,
    Color border,
    Color text,
    Color sub,
    void Function(VoidCallback) refresh, {
    bool autofocus = false,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    final ctrl = _angkaCtrl[fieldKey]!;

    void ubah(int delta) {
      final cur = int.tryParse(ctrl.text.trim()) ?? 0;
      final next = (cur + delta).clamp(0, 999999);
      ctrl.text = next == 0 ? '' : next.toString();
      refresh(() {});
      setState(() {});
    }

    Widget stepper({
      required IconData icon,
      required String tooltip,
      required VoidCallback onTap,
    }) {
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Center(child: Icon(icon, size: 20, color: c)),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: sub,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              stepper(
                icon: Icons.remove_rounded,
                tooltip: 'Kurangi $label',
                onTap: () => ubah(-1),
              ),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: ctrl,
                  autofocus: autofocus,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: textInputAction,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) {
                    refresh(() {});
                    setState(() {});
                  },
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: text,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '0',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: sub,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              stepper(
                icon: Icons.add_rounded,
                tooltip: 'Tambah $label',
                onTap: () => ubah(1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PokjaSubItem {
  final String title;
  final String deskripsi;
  final String fieldL;
  final String fieldP;
  final IconData icon;
  final Map<String, dynamic>? groupFields;
  // ✅ Kartu isian teks (Evaluasi/Keterangan) — bukan angka
  final bool isText;

  const _PokjaSubItem({
    required this.title,
    required this.deskripsi,
    this.fieldL = '',
    this.fieldP = '',
    required this.icon,
    this.groupFields,
    this.isText = false,
  });
}

class _KegiatanSubItem {
  final String title;
  final String deskripsi;
  final String fieldKegiatan;
  final String fieldVolume;
  final String fieldMetode;
  final String fieldSasaran;
  final IconData icon;

  const _KegiatanSubItem({
    required this.title,
    required this.deskripsi,
    required this.fieldKegiatan,
    required this.fieldVolume,
    required this.fieldMetode,
    required this.fieldSasaran,
    required this.icon,
  });
}