// lib/screens/catatan_kegiatan_form_screen.dart
// Redesign: lebih menarik, tidak kaku, tidak terlalu rame — soft, airy, modern

import 'dart:io';
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
  final Map<String, TextEditingController> _angkaCtrl = {};

  bool _pokjaDipilih = false;
  late PokjaKategori _kategori;
  String _selectedKecamatan = 'Singaparna';

  File? _fotoFile;
  Uint8List? _fotoBytes;

  DateTime _tanggal = DateTime.now();
  bool _isSaving = false;

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.addListener(_onThemeChanged);
    _loadTheme();

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

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    _judulController.dispose();
    _deskripsiController.dispose();
    _desaController.dispose();
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
    }
  }

  // ============================================================
  // SUB-ITEMS — 7 case — SESUAI BACKEND $pokjaFields
  // ============================================================
  List<_PokjaSubItem> _getSubItems(PokjaKategori p) {
    switch (p) {
      case PokjaKategori.pokja1:
        return const [
          _PokjaSubItem(
            title: 'PKBN',
            deskripsi: 'Bela Negara',
            fieldL: 'pkbn_l',
            fieldP: 'pkbn_p',
            icon: Icons.shield_rounded,
          ),
          _PokjaSubItem(
            title: 'PKDRT',
            deskripsi: 'Cegah KDRT',
            fieldL: 'pkdrt_l',
            fieldP: 'pkdrt_p',
            icon: Icons.family_restroom_rounded,
          ),
          _PokjaSubItem(
            title: 'Pola Asuh',
            deskripsi: 'PAAR',
            fieldL: 'pola_asuh_l',
            fieldP: 'pola_asuh_p',
            icon: Icons.child_care_rounded,
          ),
          _PokjaSubItem(
            title: 'Lansia',
            deskripsi: 'Bina Keluarga Lansia',
            fieldL: 'lansia_l',
            fieldP: 'lansia_p',
            icon: Icons.elderly_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Pokja I',
            deskripsi: 'Kader aktif',
            fieldL: 'kader_pokja1_l',
            fieldP: 'kader_pokja1_p',
            icon: Icons.badge_rounded,
          ),
        ];

      case PokjaKategori.pokja2:
        return const [
          _PokjaSubItem(
            title: 'Warga Buta Aksara',
            deskripsi: 'L & P',
            fieldL: 'warga_buta_l',
            fieldP: 'warga_buta_p',
            icon: Icons.menu_book_rounded,
          ),
          _PokjaSubItem(
            title: 'Kelompok Belajar Paket A',
            deskripsi: 'Jumlah kelompok',
            fieldL: 'kelompok_belajar_paket_a',
            fieldP: '',
            icon: Icons.school_rounded,
          ),
          _PokjaSubItem(
            title: 'Kelompok Belajar Paket B',
            deskripsi: 'Jumlah kelompok',
            fieldL: 'kelompok_belajar_paket_b',
            fieldP: '',
            icon: Icons.school_rounded,
          ),
          _PokjaSubItem(
            title: 'Kelompok Belajar Paket C',
            deskripsi: 'Jumlah kelompok',
            fieldL: 'kelompok_belajar_paket_c',
            fieldP: '',
            icon: Icons.school_rounded,
          ),
          _PokjaSubItem(
            title: 'KF & PAUD',
            deskripsi: 'Keaksaraan & PAUD',
            fieldL: 'kf',
            fieldP: 'paud',
            icon: Icons.child_care_rounded,
          ),
          _PokjaSubItem(
            title: 'Koperasi Berbadan Hukum',
            deskripsi: 'Jumlah koperasi',
            fieldL: 'koperasi_berbadan_hukum',
            fieldP: '',
            icon: Icons.storefront_rounded,
          ),
          _PokjaSubItem(
            title: 'Warga Belajar Paket A',
            deskripsi: 'Jumlah warga',
            fieldL: 'warga_belajar_paket_a',
            fieldP: '',
            icon: Icons.menu_book_rounded,
          ),
          _PokjaSubItem(
            title: 'Warga Belajar Paket B',
            deskripsi: 'Jumlah warga',
            fieldL: 'warga_belajar_paket_b',
            fieldP: '',
            icon: Icons.menu_book_rounded,
          ),
          _PokjaSubItem(
            title: 'Warga Belajar Paket C',
            deskripsi: 'Jumlah warga',
            fieldL: 'warga_belajar_paket_c',
            fieldP: '',
            icon: Icons.menu_book_rounded,
          ),
          _PokjaSubItem(
            title: 'Warga Belajar KF',
            deskripsi: 'Jumlah warga',
            fieldL: 'warga_belajar_kf',
            fieldP: '',
            icon: Icons.menu_book_rounded,
          ),
          _PokjaSubItem(
            title: 'Taman Bacaan',
            deskripsi: 'Jumlah taman bacaan',
            fieldL: 'taman_bacaan',
            fieldP: '',
            icon: Icons.local_library_rounded,
          ),
          _PokjaSubItem(
            title: 'Kelompok BKB',
            deskripsi: 'Jumlah kelompok',
            fieldL: 'kelompok_bkb',
            fieldP: '',
            icon: Icons.family_restroom_rounded,
          ),
          _PokjaSubItem(
            title: 'Peserta BKB',
            deskripsi: 'Jumlah peserta',
            fieldL: 'peserta_bkb',
            fieldP: '',
            icon: Icons.people_rounded,
          ),
          _PokjaSubItem(
            title: 'APE BKB',
            deskripsi: 'Alat Permainan Edukatif',
            fieldL: 'ape_bkb',
            fieldP: '',
            icon: Icons.toys_rounded,
          ),
          _PokjaSubItem(
            title: 'Kelompok Simulasi BKB',
            deskripsi: 'Jumlah kelompok',
            fieldL: 'kelompok_simulasi_bkb',
            fieldP: '',
            icon: Icons.groups_rounded,
          ),
          _PokjaSubItem(
            title: 'Tutor KF',
            deskripsi: 'Jumlah tutor',
            fieldL: 'tutor_kf',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Tutor PAUD',
            deskripsi: 'Jumlah tutor',
            fieldL: 'tutor_paud',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader BKB',
            deskripsi: 'Jumlah kader',
            fieldL: 'kader_bkb',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Kelompok Kader Koperasi',
            deskripsi: 'Jumlah kelompok',
            fieldL: 'kelompok_kader_koperasi',
            fieldP: '',
            icon: Icons.groups_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Keterampilan',
            deskripsi: 'Jumlah kader',
            fieldL: 'kader_keterampilan',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Dilatih Pengelolaan',
            deskripsi: 'Jumlah kader',
            fieldL: 'kader_dilatih_pengelolaan',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Dilatih TP PKK',
            deskripsi: 'Jumlah kader',
            fieldL: 'kader_dilatih_tp_pkk',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Dilatih Damas',
            deskripsi: 'Jumlah kader',
            fieldL: 'kader_dilatih_damas',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'UP2K Pemula Kelompok',
            deskripsi: 'Jumlah kelompok',
            fieldL: 'up2k_pemula_kelompok',
            fieldP: '',
            icon: Icons.workspaces_rounded,
          ),
          _PokjaSubItem(
            title: 'UP2K Pemula Peserta',
            deskripsi: 'Jumlah peserta',
            fieldL: 'up2k_pemula_peserta',
            fieldP: '',
            icon: Icons.people_rounded,
          ),
          _PokjaSubItem(
            title: 'UP2K Madya Kelompok',
            deskripsi: 'Jumlah kelompok',
            fieldL: 'up2k_madya_kelompok',
            fieldP: '',
            icon: Icons.workspaces_rounded,
          ),
          _PokjaSubItem(
            title: 'UP2K Madya Peserta',
            deskripsi: 'Jumlah peserta',
            fieldL: 'up2k_madya_peserta',
            fieldP: '',
            icon: Icons.people_rounded,
          ),
          _PokjaSubItem(
            title: 'UP2K Utama Kelompok',
            deskripsi: 'Jumlah kelompok',
            fieldL: 'up2k_utama_kelompok',
            fieldP: '',
            icon: Icons.workspaces_rounded,
          ),
          _PokjaSubItem(
            title: 'UP2K Utama Peserta',
            deskripsi: 'Jumlah peserta',
            fieldL: 'up2k_utama_peserta',
            fieldP: '',
            icon: Icons.people_rounded,
          ),
          _PokjaSubItem(
            title: 'UP2K Mandiri Kelompok',
            deskripsi: 'Jumlah kelompok',
            fieldL: 'up2k_mandiri_kelompok',
            fieldP: '',
            icon: Icons.workspaces_rounded,
          ),
          _PokjaSubItem(
            title: 'UP2K Mandiri Peserta',
            deskripsi: 'Jumlah peserta',
            fieldL: 'up2k_mandiri_peserta',
            fieldP: '',
            icon: Icons.people_rounded,
          ),
          _PokjaSubItem(
            title: 'Anggota Koperasi',
            deskripsi: 'Jumlah anggota',
            fieldL: 'anggota_koperasi',
            fieldP: '',
            icon: Icons.people_rounded,
          ),
        ];

      case PokjaKategori.pokja3:
        return const [
          _PokjaSubItem(
            title: 'Rumah Sehat',
            deskripsi: 'Jumlah rumah sehat',
            fieldL: 'rumah_sehat',
            fieldP: '',
            icon: Icons.house_rounded,
          ),
          _PokjaSubItem(
            title: 'Rumah Tidak Sehat',
            deskripsi: 'Jumlah rumah tidak sehat',
            fieldL: 'rumah_tidak_sehat',
            fieldP: '',
            icon: Icons.house_siding_rounded,
          ),
          _PokjaSubItem(
            title: 'Pemanfaatan Pekarangan',
            deskripsi: 'Jumlah pekarangan',
            fieldL: 'pemanfaatan_pekarangan',
            fieldP: '',
            icon: Icons.grass_rounded,
          ),
          _PokjaSubItem(
            title: 'Industri Rumah Tangga',
            deskripsi: 'Jumlah industri',
            fieldL: 'industri_rumah_tangga',
            fieldP: '',
            icon: Icons.store_rounded,
          ),
          _PokjaSubItem(
            title: 'Jumlah Kader',
            deskripsi: 'Total kader',
            fieldL: 'jumlah_kader',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Jumlah Kader Perempuan',
            deskripsi: 'Kader perempuan',
            fieldL: 'jumlah_kader_p',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Makanan Pokok',
            deskripsi: 'Jumlah',
            fieldL: 'makanan_pokok',
            fieldP: '',
            icon: Icons.rice_bowl_rounded,
          ),
          _PokjaSubItem(
            title: 'HATINYA PKK',
            deskripsi: 'Jumlah',
            fieldL: 'hatinya_pkk',
            fieldP: '',
            icon: Icons.grass_rounded,
          ),
          _PokjaSubItem(
            title: 'Jumlah Rumah',
            deskripsi: 'Total rumah',
            fieldL: 'jumlah_rumah',
            fieldP: '',
            icon: Icons.home_rounded,
          ),
        ];

      case PokjaKategori.pokja4:
        return const [
          _PokjaSubItem(
            title: 'Posyandu',
            deskripsi: 'Jumlah posyandu',
            fieldL: 'posyandu',
            fieldP: '',
            icon: Icons.local_hospital_rounded,
          ),
          _PokjaSubItem(
            title: 'Akseptor KB',
            deskripsi: 'Jumlah akseptor',
            fieldL: 'akseptor_kb',
            fieldP: '',
            icon: Icons.family_restroom_rounded,
          ),
          _PokjaSubItem(
            title: 'PHBS',
            deskripsi: 'Rumah tangga PHBS',
            fieldL: 'phbs',
            fieldP: '',
            icon: Icons.health_and_safety_rounded,
          ),
          _PokjaSubItem(
            title: 'Jamban Keluarga',
            deskripsi: 'Jumlah jamban',
            fieldL: 'jamban_keluarga',
            fieldP: '',
            icon: Icons.wc_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Kesehatan',
            deskripsi: 'Jumlah kader',
            fieldL: 'kader_kesehatan',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Gizi',
            deskripsi: 'Jumlah kader',
            fieldL: 'kader_gizi',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader Kesling',
            deskripsi: 'Jumlah kader',
            fieldL: 'kader_kesling',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader PHBS',
            deskripsi: 'Jumlah kader',
            fieldL: 'kader_phbs',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Kader KB',
            deskripsi: 'Jumlah kader',
            fieldL: 'kader_kb',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Imunisasi',
            deskripsi: 'Jumlah imunisasi',
            fieldL: 'imunisasi',
            fieldP: '',
            icon: Icons.vaccines_rounded,
          ),
          _PokjaSubItem(
            title: 'PKG',
            deskripsi: 'Penyuluhan Kelompok',
            fieldL: 'pkg',
            fieldP: '',
            icon: Icons.groups_rounded,
          ),
          _PokjaSubItem(
            title: 'TBC',
            deskripsi: 'Jumlah kasus TBC',
            fieldL: 'tbc',
            fieldP: '',
            icon: Icons.medical_services_rounded,
          ),
          _PokjaSubItem(
            title: 'SPAL',
            deskripsi: 'Saluran air limbah',
            fieldL: 'spal',
            fieldP: '',
            icon: Icons.water_damage_rounded,
          ),
          _PokjaSubItem(
            title: 'TPS',
            deskripsi: 'Tempat sampah',
            fieldL: 'tps',
            fieldP: '',
            icon: Icons.delete_rounded,
          ),
          _PokjaSubItem(
            title: 'MCK',
            deskripsi: 'Jumlah MCK',
            fieldL: 'mck',
            fieldP: '',
            icon: Icons.bathtub_rounded,
          ),
          _PokjaSubItem(
            title: 'Air PDAM',
            deskripsi: 'Pengguna PDAM',
            fieldL: 'air_pdam',
            fieldP: '',
            icon: Icons.water_rounded,
          ),
          _PokjaSubItem(
            title: 'Air Sumur',
            deskripsi: 'Pengguna sumur',
            fieldL: 'air_sumur',
            fieldP: '',
            icon: Icons.water_drop_rounded,
          ),
          _PokjaSubItem(
            title: 'Air Lainnya',
            deskripsi: 'Sumber air lain',
            fieldL: 'air_lainnya',
            fieldP: '',
            icon: Icons.water_rounded,
          ),
          _PokjaSubItem(
            title: 'Jumlah PUS',
            deskripsi: 'Pasangan Usia Subur',
            fieldL: 'jumlah_pus',
            fieldP: '',
            icon: Icons.family_restroom_rounded,
          ),
          _PokjaSubItem(
            title: 'Jumlah WUS',
            deskripsi: 'Wanita Usia Subur',
            fieldL: 'jumlah_wus',
            fieldP: '',
            icon: Icons.woman_rounded,
          ),
          _PokjaSubItem(
            title: 'Akseptor KB',
            deskripsi: 'L & P',
            fieldL: 'akseptor_kb_l',
            fieldP: 'akseptor_kb_p',
            icon: Icons.family_restroom_rounded,
          ),
          _PokjaSubItem(
            title: 'Tabungan Keluarga',
            deskripsi: 'Jumlah KK',
            fieldL: 'tabungan_keluarga',
            fieldP: '',
            icon: Icons.savings_rounded,
          ),
          _PokjaSubItem(
            title: 'Asuransi Kesehatan',
            deskripsi: 'Jumlah KK',
            fieldL: 'asuransi_kesehatan',
            fieldP: '',
            icon: Icons.health_and_safety_rounded,
          ),
        ];

      case PokjaKategori.pokja4Pyd:
        return const [
          _PokjaSubItem(
            title: 'Bayi 0-12 Bln',
            deskripsi: 'L & P',
            fieldL: 'bayi_0_12_l',
            fieldP: 'bayi_0_12_p',
            icon: Icons.child_care_rounded,
          ),
          _PokjaSubItem(
            title: 'Balita 1-5 Thn',
            deskripsi: 'L & P',
            fieldL: 'balita_1_5_l',
            fieldP: 'balita_1_5_p',
            icon: Icons.escalator_warning_rounded,
          ),
          _PokjaSubItem(
            title: 'WUS',
            deskripsi: 'Wanita Usia Subur',
            fieldL: 'wus',
            fieldP: '',
            icon: Icons.woman_rounded,
          ),
          _PokjaSubItem(
            title: 'PUS',
            deskripsi: 'Pasangan Usia Subur',
            fieldL: 'pus',
            fieldP: '',
            icon: Icons.family_restroom_rounded,
          ),
          _PokjaSubItem(
            title: 'Ibu Hamil',
            deskripsi: 'Jumlah ibu hamil',
            fieldL: 'ibu_hamil',
            fieldP: '',
            icon: Icons.pregnant_woman_rounded,
          ),
          // ✅ FIX: 'menyusui' → 'ibu_menyusui'
          _PokjaSubItem(
            title: 'Menyusui',
            deskripsi: 'Jumlah ibu menyusui',
            fieldL: 'ibu_menyusui',
            fieldP: '',
            icon: Icons.child_friendly_rounded,
          ),
          _PokjaSubItem(
            title: 'Bayi Lahir',
            deskripsi: 'Jumlah kelahiran',
            fieldL: 'bayi_lahir',
            fieldP: '',
            icon: Icons.celebration_rounded,
          ),
          _PokjaSubItem(
            title: 'Bayi Meninggal',
            deskripsi: 'Jumlah kematian bayi',
            fieldL: 'bayi_meninggal',
            fieldP: '',
            icon: Icons.sentiment_very_dissatisfied_rounded,
          ),
          _PokjaSubItem(
            title: 'Kematian Ibu',
            deskripsi: 'Hamil/melahirkan/nifas',
            fieldL: 'kematian_ibu',
            fieldP: '',
            icon: Icons.warning_rounded,
          ),
          _PokjaSubItem(
            title: 'Petugas Kader',
            deskripsi: 'Jumlah kader hadir',
            fieldL: 'petugas_kader',
            fieldP: '',
            icon: Icons.badge_rounded,
          ),
          _PokjaSubItem(
            title: 'Petugas PLKB',
            deskripsi: 'Jumlah PLKB hadir',
            fieldL: 'petugas_plkb',
            fieldP: '',
            icon: Icons.person_rounded,
          ),
          _PokjaSubItem(
            title: 'Petugas Medis',
            deskripsi: 'Jumlah medis hadir',
            fieldL: 'petugas_medis',
            fieldP: '',
            icon: Icons.medical_services_rounded,
          ),
        ];

      case PokjaKategori.pokja4Posyandu:
        return const [
          _PokjaSubItem(
            title: 'Ibu Hamil',
            deskripsi: 'Jumlah & diperiksa',
            fieldL: 'ibu_hamil',
            fieldP: 'ibu_hamil_diperiksa',
            icon: Icons.pregnant_woman_rounded,
          ),
          // ✅ FIX: 'menyusui' → 'ibu_menyusui'
          _PokjaSubItem(
            title: 'Menyusui',
            deskripsi: 'Jumlah ibu menyusui',
            fieldL: 'ibu_menyusui',
            fieldP: '',
            icon: Icons.child_friendly_rounded,
          ),
          _PokjaSubItem(
            title: 'KB IUD',
            deskripsi: 'Akseptor IUD',
            fieldL: 'kb_iud',
            fieldP: '',
            icon: Icons.health_and_safety_rounded,
          ),
          _PokjaSubItem(
            title: 'KB MOW',
            deskripsi: 'Akseptor MOW',
            fieldL: 'kb_mow',
            fieldP: '',
            icon: Icons.health_and_safety_rounded,
          ),
          _PokjaSubItem(
            title: 'KB MOP',
            deskripsi: 'Akseptor MOP',
            fieldL: 'kb_mop',
            fieldP: '',
            icon: Icons.health_and_safety_rounded,
          ),
          _PokjaSubItem(
            title: 'KB Implan',
            deskripsi: 'Akseptor Implan',
            fieldL: 'kb_implan',
            fieldP: '',
            icon: Icons.health_and_safety_rounded,
          ),
          _PokjaSubItem(
            title: 'KB Pil',
            deskripsi: 'Akseptor Pil',
            fieldL: 'kb_pil',
            fieldP: '',
            icon: Icons.health_and_safety_rounded,
          ),
          _PokjaSubItem(
            title: 'KB Suntik',
            deskripsi: 'Akseptor Suntik',
            fieldL: 'kb_suntik',
            fieldP: '',
            icon: Icons.health_and_safety_rounded,
          ),
          _PokjaSubItem(
            title: 'KB Kondom',
            deskripsi: 'Akseptor Kondom',
            fieldL: 'kb_kondom',
            fieldP: '',
            icon: Icons.health_and_safety_rounded,
          ),
          _PokjaSubItem(
            title: 'Balita',
            deskripsi: 'Jumlah L & P',
            fieldL: 'balita_l',
            fieldP: 'balita_p',
            icon: Icons.child_care_rounded,
          ),
          _PokjaSubItem(
            title: 'Balita KIA',
            deskripsi: 'L & P',
            fieldL: 'balita_kia_l',
            fieldP: 'balita_kia_p',
            icon: Icons.card_membership_rounded,
          ),
          _PokjaSubItem(
            title: 'Ditimbang',
            deskripsi: 'L & P',
            fieldL: 'balita_ditimbang_l',
            fieldP: 'balita_ditimbang_p',
            icon: Icons.monitor_weight_rounded,
          ),
          _PokjaSubItem(
            title: 'Naik BB',
            deskripsi: 'L & P',
            fieldL: 'balita_naik_l',
            fieldP: 'balita_naik_p',
            icon: Icons.trending_up_rounded,
          ),
          _PokjaSubItem(
            title: 'Vit A-1',
            deskripsi: 'Dapat Vit A dosis 1',
            fieldL: 'vit_a_1',
            fieldP: '',
            icon: Icons.medication_rounded,
          ),
          _PokjaSubItem(
            title: 'Vit A-2',
            deskripsi: 'Dapat Vit A dosis 2',
            fieldL: 'vit_a_2',
            fieldP: '',
            icon: Icons.medication_rounded,
          ),
          _PokjaSubItem(
            title: 'TT I & II',
            deskripsi: 'Imunisasi TT',
            fieldL: 'imunisasi_tt_1',
            fieldP: 'imunisasi_tt_2',
            icon: Icons.vaccines_rounded,
          ),
          _PokjaSubItem(
            title: 'BCG',
            deskripsi: 'Imunisasi BCG',
            fieldL: 'imunisasi_bcg',
            fieldP: '',
            icon: Icons.vaccines_rounded,
          ),
          _PokjaSubItem(
            title: 'DPT',
            deskripsi: 'DPT 1, 2, 3',
            fieldL: 'imunisasi_dpt_1',
            fieldP: 'imunisasi_dpt_2',
            icon: Icons.vaccines_rounded,
          ),
          _PokjaSubItem(
            title: 'Polio',
            deskripsi: 'Polio 1-4',
            fieldL: 'imunisasi_polio_1',
            fieldP: 'imunisasi_polio_2',
            icon: Icons.vaccines_rounded,
          ),
          _PokjaSubItem(
            title: 'Campak',
            deskripsi: 'Imunisasi campak',
            fieldL: 'imunisasi_campak',
            fieldP: '',
            icon: Icons.vaccines_rounded,
          ),
          _PokjaSubItem(
            title: 'Hepatitis',
            deskripsi: 'Hep 1, 2, 3',
            fieldL: 'imunisasi_hepatitis_1',
            fieldP: 'imunisasi_hepatitis_2',
            icon: Icons.vaccines_rounded,
          ),
          _PokjaSubItem(
            title: 'Diare',
            deskripsi: 'Jumlah & dapat oralit',
            fieldL: 'balita_diare',
            fieldP: 'balita_oralit',
            icon: Icons.sick_rounded,
          ),
        ];

      case PokjaKategori.pokja4Rekap:
        return const [
          _PokjaSubItem(
            title: 'Ibu Hamil',
            deskripsi: 'Jumlah ibu hamil',
            fieldL: 'ibu_hamil',
            fieldP: '',
            icon: Icons.pregnant_woman_rounded,
          ),
          _PokjaSubItem(
            title: 'Ibu Melahirkan',
            deskripsi: 'Jumlah melahirkan',
            fieldL: 'ibu_melahirkan',
            fieldP: '',
            icon: Icons.child_friendly_rounded,
          ),
          _PokjaSubItem(
            title: 'Ibu Nifas',
            deskripsi: 'Jumlah nifas',
            fieldL: 'ibu_nifas',
            fieldP: '',
            icon: Icons.favorite_rounded,
          ),
          _PokjaSubItem(
            title: 'Ibu Meninggal',
            deskripsi: 'Jumlah kematian ibu',
            fieldL: 'ibu_meninggal',
            fieldP: '',
            icon: Icons.warning_rounded,
          ),
          _PokjaSubItem(
            title: 'Bayi Lahir',
            deskripsi: 'Laki-laki & Perempuan',
            fieldL: 'bayi_lahir_l',
            fieldP: 'bayi_lahir_p',
            icon: Icons.child_care_rounded,
          ),
          _PokjaSubItem(
            title: 'Akte',
            deskripsi: 'Ada & Tidak',
            fieldL: 'akte_ada',
            fieldP: 'akte_tidak',
            icon: Icons.description_rounded,
          ),
          _PokjaSubItem(
            title: 'Bayi Meninggal',
            deskripsi: 'Laki-laki & Perempuan',
            fieldL: 'bayi_meninggal_l',
            fieldP: 'bayi_meninggal_p',
            icon: Icons.sentiment_very_dissatisfied_rounded,
          ),
          _PokjaSubItem(
            title: 'Balita Meninggal',
            deskripsi: 'Laki-laki & Perempuan',
            fieldL: 'balita_meninggal_l',
            fieldP: 'balita_meninggal_p',
            icon: Icons.sentiment_dissatisfied_rounded,
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
    final searchCtrl = TextEditingController();
    List<String> filtered = List.from(CatatanKegiatan.daftar39Kecamatan);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: const Color(0xFFE2E8F0),
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
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '39 kecamatan Kab. Tasikmalaya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari kecamatan...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
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
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                              color: sel
                                  ? const Color(0xFF0D9488)
                                  : const Color(0xFF334155),
                            ),
                          ),
                          trailing: sel
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF0D9488),
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
    final pokjas = PokjaKategori.values;
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      color: const Color(0xFFE2E8F0),
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
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '7 kategori — termasuk 3 sheet Pokja IV',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
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
                              : const Color(0xFFF8FAFC),
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
                                          : soft,
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
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          _getPokjaSubtitle(p),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            color: const Color(0xFF64748B),
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
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: Color(0xFFCBD5E1),
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

  void _showKegiatanInputSheet(_PokjaSubItem sub, int idx) {
    HapticFeedback.selectionClick();
    final c = _getPokjaColor(_kategori);
    final soft = _getPokjaSoft(_kategori);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: const Color(0xFFE2E8F0),
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
                          color: soft,
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
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              sub.deskripsi,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
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
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _numRow(
                          sub.fieldP.isEmpty ? 'Jumlah' : 'Laki-laki (L)',
                          sub.fieldL,
                          c,
                          const Color(0xFFF8FAFC),
                          Colors.white,
                          const Color(0xFFE2E8F0),
                          const Color(0xFF0F172A),
                          const Color(0xFF64748B),
                          setSheet,
                        ),
                        if (sub.fieldP.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _numRow(
                            'Perempuan (P)',
                            sub.fieldP,
                            c,
                            const Color(0xFFF8FAFC),
                            Colors.white,
                            const Color(0xFFE2E8F0),
                            const Color(0xFF0F172A),
                            const Color(0xFF64748B),
                            setSheet,
                          ),
                        ],
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
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
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
      for (final e in _angkaCtrl.entries) {
        final v = int.tryParse(e.value.text.trim());
        if (v != null && v > 0) dataAngka[e.key] = v;
      }

      if (_kategori == PokjaKategori.pokja4Pyd ||
          _kategori == PokjaKategori.pokja4Posyandu) {
        dataAngka['bulan'] = _tanggal.month;
        dataAngka['tahun'] = _tanggal.year;
      }
      if (_kategori == PokjaKategori.pokja4Rekap) {
        dataAngka['tahun'] = _tanggal.year;
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
      );
      await _service.kirim(item);
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

  int _hitungTotal() {
    int t = 0;
    for (final s in _getSubItems(_kategori)) {
      t += int.tryParse(_angkaCtrl[s.fieldL]?.text ?? '') ?? 0;
      if (s.fieldP.isNotEmpty)
        t += int.tryParse(_angkaCtrl[s.fieldP]?.text ?? '') ?? 0;
    }
    return t;
  }

  int _countFilled() {
    int c = 0;
    for (final s in _getSubItems(_kategori)) {
      if ((int.tryParse(_angkaCtrl[s.fieldL]?.text ?? '') ?? 0) > 0) c++;
      if (s.fieldP.isNotEmpty &&
          (int.tryParse(_angkaCtrl[s.fieldP]?.text ?? '') ?? 0) > 0)
        c++;
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

    final pokjas = PokjaKategori.values;

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
                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF0D9488),
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
              color: const Color(0xFF0D9488).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  size: 16,
                  color: Color(0xFF0D9488),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tips: kamu bisa ganti Pokja lagi nanti lewat tombol di atas form.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF0D9488),
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
                    '${_countFilled()}/${subItems.length} terisi',
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
              int sum = 0;
              if (_angkaCtrl[s.fieldL]?.text.isNotEmpty == true)
                sum += int.tryParse(_angkaCtrl[s.fieldL]!.text) ?? 0;
              if (s.fieldP.isNotEmpty &&
                  _angkaCtrl[s.fieldP]?.text.isNotEmpty == true)
                sum += int.tryParse(_angkaCtrl[s.fieldP]!.text) ?? 0;
              final hasValue = sum > 0;
              String ringkas;
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
                    'Uraian singkat',
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
    void Function(VoidCallback) refresh,
  ) {
    final ctrl = _angkaCtrl[fieldKey]!;

    void ubah(int delta) {
      final cur = int.tryParse(ctrl.text.trim()) ?? 0;
      final next = (cur + delta).clamp(0, 999999);
      ctrl.text = next == 0 ? '' : next.toString();
      refresh(() {});
      setState(() {});
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 12,
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
              InkWell(
                onTap: () => ubah(-1),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.remove_rounded, size: 18, color: c),
                ),
              ),
              SizedBox(
                width: 64,
                child: TextField(
                  controller: ctrl,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: text,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '0',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: sub,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              InkWell(
                onTap: () => ubah(1),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.add_rounded, size: 18, color: c),
                ),
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

  const _PokjaSubItem({
    required this.title,
    required this.deskripsi,
    required this.fieldL,
    required this.fieldP,
    required this.icon,
  });
}
