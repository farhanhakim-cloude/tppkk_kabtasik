// lib/models/catatan_kegiatan.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

// ============================================================
// ENUM â€” TAMBAH 3 SHEET POKJA 4
// ============================================================
enum PokjaKategori {
  pokja1,
  pokja2,
  pokja3,
  pokja4,
  pokja4Pyd, // ✅ BARU
  pokja4Posyandu, // ✅ BARU
  pokja4Rekap, // ✅ BARU
  pokja4DataDukung, // ✅ BARU
  pokja4DataProgram, // ✅ BARU
}

extension PokjaKategoriLabel on PokjaKategori {
  String get label {
    switch (this) {
      case PokjaKategori.pokja1:
        return 'Pokja I - Gotong Royong & Pancasila';
      case PokjaKategori.pokja2:
        return 'Pokja II - Pendidikan & Ekonomi';
      case PokjaKategori.pokja3:
        return 'Pokja III - Pangan, Sandang, Papan';
      case PokjaKategori.pokja4:
        return 'Pokja IV - Kesehatan & Lingkungan';
      case PokjaKategori.pokja4Pyd:
        return 'Pokja IV - Kunjungan PYD';
      case PokjaKategori.pokja4Posyandu:
        return 'Pokja IV - Kegiatan Posyandu';
      case PokjaKategori.pokja4Rekap:
        return 'Pokja IV - Rekapitulasi';
      case PokjaKategori.pokja4DataDukung:
        return 'Pokja IV - Laporan Data Dukung';
      case PokjaKategori.pokja4DataProgram:
        return 'Pokja IV - Data Program (Lama)';
    }
  }

  String get shortLabel {
    switch (this) {
      case PokjaKategori.pokja1:
        return 'Pokja I';
      case PokjaKategori.pokja2:
        return 'Pokja II';
      case PokjaKategori.pokja3:
        return 'Pokja III';
      case PokjaKategori.pokja4:
        return 'Pokja IV';
      case PokjaKategori.pokja4Pyd:
        return 'Kunjungan PYD';
      case PokjaKategori.pokja4Posyandu:
        return 'Kegiatan Posyandu';
      case PokjaKategori.pokja4Rekap:
        return 'Rekapitulasi';
      case PokjaKategori.pokja4DataDukung:
        return 'Laporan Data Dukung';
      case PokjaKategori.pokja4DataProgram:
        return 'Data Program';
    }
  }

  // âœ… KATEGORI_POKJA â€” untuk dikirim ke backend
  String get kategoriPokja {
    switch (this) {
      case PokjaKategori.pokja1:
        return 'I';
      case PokjaKategori.pokja2:
        return 'II';
      case PokjaKategori.pokja3:
        return 'III';
      case PokjaKategori.pokja4:
        return 'IV';
      case PokjaKategori.pokja4Pyd:
        return 'IV-PYD';
      case PokjaKategori.pokja4Posyandu:
        return 'IV-POSYANDU';
      case PokjaKategori.pokja4Rekap:
        return 'IV-REKAP';
      case PokjaKategori.pokja4DataDukung:
        return 'IV-DATADUKUNG';
      case PokjaKategori.pokja4DataProgram:
        return 'IV-DATAPROGRAM';
    }
  }

  // âœ… CHECKER
  bool get isPokja4Sheet {
    return this == PokjaKategori.pokja4Pyd ||
        this == PokjaKategori.pokja4Posyandu ||
        this == PokjaKategori.pokja4Rekap ||
        this == PokjaKategori.pokja4DataDukung ||
        this == PokjaKategori.pokja4DataProgram;
  }

  String get apiEndpoint {
    switch (this) {
      case PokjaKategori.pokja1:
        return '/api/pokja1';
      case PokjaKategori.pokja2:
        return '/api/pokja2';
      case PokjaKategori.pokja3:
        return '/api/pokja3';
      case PokjaKategori.pokja4:
        return '/api/pokja4';
      case PokjaKategori.pokja4Pyd:
      case PokjaKategori.pokja4Posyandu:
      case PokjaKategori.pokja4Rekap:
      case PokjaKategori.pokja4DataDukung:
      case PokjaKategori.pokja4DataProgram:
        return '/api/pokja4'; // placeholder — ga dipakai POST
    }
  }

  /// ✅ Pilihan untuk form input — Data Program (Lama) disembunyikan,
  /// sudah gabung ke Laporan Data Dukung. Dipakai semua picker input.
  static List<PokjaKategori> get inputValues => PokjaKategori.values
      .where((e) => e != PokjaKategori.pokja4DataProgram)
      .toList();

  /// Pilihan khusus kader Pokja 4 — 5 item, 1 form gabungan.
  static const List<PokjaKategori> inputPokja4 = [
    PokjaKategori.pokja4,
    PokjaKategori.pokja4Pyd,
    PokjaKategori.pokja4Posyandu,
    PokjaKategori.pokja4Rekap,
    PokjaKategori.pokja4DataDukung,
  ];

  String get tableName {
    switch (this) {
      case PokjaKategori.pokja1:
        return 'pokja_ones';
      case PokjaKategori.pokja2:
        return 'pokja_twos';
      case PokjaKategori.pokja3:
        return 'pokja_threes';
      case PokjaKategori.pokja4:
        return 'pokja_fours';
      case PokjaKategori.pokja4Pyd:
        return 'pokja4_kunjungan_pyd';
      case PokjaKategori.pokja4Posyandu:
        return 'pokja4_kegiatan_posyandu';
      case PokjaKategori.pokja4Rekap:
        return 'pokja4_rekapitulasi';
      case PokjaKategori.pokja4DataDukung:
        return 'pokja4_data_dukung';
      case PokjaKategori.pokja4DataProgram:
        return 'pokja4_data_program';
    }
  }

  // ============================================================
  // FIELD ANGKA â€” SESUAI DATABASE
  // ============================================================
  List<String> get fieldAngka {
    switch (this) {
      case PokjaKategori.pokja1:
        return [
          // Kader
          'kader_umum', 'kader_khusus',
          // KISAH
          'kisah_kegiatan', 'kisah_volume', 'kisah_metode', 'kisah_sasaran',
          // KILAS
          'kilas_kegiatan', 'kilas_volume', 'kilas_metode', 'kilas_sasaran',
          // KRISAN
          'krisan_kegiatan', 'krisan_volume', 'krisan_metode', 'krisan_sasaran',
          // KIAT
          'kiat_kegiatan', 'kiat_volume', 'kiat_metode', 'kiat_sasaran',
          // KISAK
          'kisak_kegiatan', 'kisak_volume', 'kisak_metode', 'kisak_sasaran',
          // PKBN
          'pkbn_kegiatan', 'pkbn_volume', 'pkbn_metode', 'pkbn_sasaran',
          // Keterangan
          'keterangan',
        ];
      case PokjaKategori.pokja2:
        return [
          'kelompok_warga_buta',
          'warga_buta_l',
          'warga_buta_p',
          'kelompok_belajar_paket_a',
          'warga_belajar_paket_a_l',
          'warga_belajar_paket_a_p',
          'kelompok_belajar_paket_b',
          'warga_belajar_paket_b_l',
          'warga_belajar_paket_b_p',
          'kelompok_belajar_paket_c',
          'warga_belajar_paket_c_l',
          'warga_belajar_paket_c_p',
          'kf',
          'warga_belajar_kf_l',
          'warga_belajar_kf_p',
          'kelompok_paud',
          'paud_l',
          'paud_p',
          'kelompok_taman_bacaan',
          'taman_bacaan_l',
          'taman_bacaan_p',
          'kelompok_bkb',
          'peserta_bkb_l',
          'peserta_bkb_p',
          'ape_bkb',
          'kelompok_simulasi_bkb',
          'kelompok_simulasi_bkb_l',
          'kelompok_simulasi_bkb_p',
          'tutor_kf',
          'tutor_kf_l',
          'tutor_kf_p',
          'tutor_paud',
          'tutor_paud_l',
          'tutor_paud_p',
          'kader_bkb',
          'kader_bkb_l',
          'kader_bkb_p',
          'kader_koperasi',
          'kader_koperasi_l',
          'kader_koperasi_p',
          'kader_keterampilan',
          'kader_keterampilan_l',
          'kader_keterampilan_p',
          'up2k_pemula_kelompok',
          'up2k_pemula_peserta_l',
          'up2k_pemula_peserta_p',
          'up2k_madya_kelompok',
          'up2k_madya_peserta_l',
          'up2k_madya_peserta_p',
          'up2k_utama_kelompok',
          'up2k_utama_peserta_l',
          'up2k_utama_peserta_p',
          'up2k_mandiri_kelompok',
          'up2k_mandiri_peserta_l',
          'up2k_mandiri_peserta_p',
          'koperasi_berbadan_hukum',
          'anggota_koperasi_l',
          'anggota_koperasi_p',
          'ibu_set_bkb',
          'lp3_pkk',
          'lp3_pkk_l',
          'lp3_pkk_p',
          'tp3_pkk',
          'tp3_pkk_l',
          'tp3_pkk_p',
          'damas_pkk',
          'damas_pkk_l',
          'damas_pkk_p',
          'keterangan',
        ];
      case PokjaKategori.pokja3:
        return [
          // JUMLAH KADER
          'jumlah_kader_pangan',
          'jumlah_kader_sandang',
          'jumlah_kader_tata_laksana',
          // PANGAN — Makanan Pokok
          'pangan_beras',
          'pangan_non_beras',
          // PANGAN — Pemanfaatan Pekarangan / HATINYA PKK
          'pangan_peternakan',
          'pangan_perikanan',
          'pangan_warung_hidup',
          'pangan_lumbung_hidup',
          'pangan_toga',
          'pangan_tanaman_keras',
          'pangan_tanaman_lainnya',
          // JUMLAH INDUSTRI RUMAH TANGGA
          'industri_pangan',
          'industri_sandang',
          'industri_jasa',
          // JUMLAH RUMAH
          'rumah_sehat',
          'rumah_tidak_sehat',
          'keterangan',
          // LEGACY — tetap dibaca agar laporan lama tidak hilang
          'jumlah_kader',
          'jumlah_kader_p',
          'makanan_pokok',
          'pemanfaatan_pekarangan',
          'hatinya_pkk',
          'industri_rumah_tangga',
          'jumlah_rumah',
        ];
      case PokjaKategori.pokja4:
        // âœ… FIX: 25 kolom â€” match dengan backend
        return [
          'posyandu',
          'akseptor_kb',
          'phbs',
          'jamban_keluarga',
          'kader_kesehatan',
          'kader_gizi',
          'kader_kesling',
          'kader_phbs',
          'kader_kb',
          'imunisasi',
          'pkg',
          'tbc',
          'spal',
          'tps',
          'mck',
          'air_pdam',
          'air_sumur',
          'air_lainnya',
          'jumlah_pus',
          'jumlah_wus',
          'akseptor_kb_l',
          'akseptor_kb_p',
          'tabungan_keluarga',
          'asuransi_kesehatan',
          'program_kesehatan',
          'program_lingkungan',
          'program_perencanaan',
        ];
      case PokjaKategori.pokja4Pyd:
        // âœ… BARU: 21 kolom Kunjungan PYD
        return [
          'bulan',
          'tahun',
          'bayi_0_12_l',
          'bayi_0_12_p',
          'bayi_0_12_laki_l',
          'bayi_0_12_laki_p',
          'balita_1_5_l',
          'balita_1_5_p',
          'balita_1_5_laki_l',
          'balita_1_5_laki_p',
          'wus',
          'pus',
          'ibu_hamil',
          'ibu_menyusui',
          'bayi_lahir',
          'bayi_meninggal',
          'kematian_ibu',
          'petugas_kader',
          'petugas_plkb',
          'petugas_medis',
          'keterangan',
        ];
      case PokjaKategori.pokja4Posyandu:
        // âœ… BARU: 40 kolom Kegiatan Posyandu
        return [
          'bulan',
          'tahun',
          'ibu_hamil',
          'ibu_hamil_diperiksa',
          'ibu_hamil_dapat_fe',
          'menyusui',
          'kb_iud',
          'kb_mow',
          'kb_mop',
          'kb_implan',
          'kb_pil',
          'kb_suntik',
          'kb_kondom',
          'balita_l',
          'balita_p',
          'balita_kia_l',
          'balita_kia_p',
          'balita_ditimbang_l',
          'balita_ditimbang_p',
          'balita_naik_l',
          'balita_naik_p',
          'vit_a_1',
          'vit_a_2',
          'imunisasi_tt_1',
          'imunisasi_tt_2',
          'imunisasi_bcg',
          'imunisasi_dpt_1',
          'imunisasi_dpt_2',
          'imunisasi_dpt_3',
          'imunisasi_polio_1',
          'imunisasi_polio_2',
          'imunisasi_polio_3',
          'imunisasi_polio_4',
          'imunisasi_campak',
          'imunisasi_hepatitis_1',
          'imunisasi_hepatitis_2',
          'imunisasi_hepatitis_3',
          'balita_diare',
          'balita_oralit',
          'keterangan',
        ];
      case PokjaKategori.pokja4Rekap:
        // âœ… BARU: 19 kolom Rekapitulasi
        return [
          'tahun',
          'ibu_hamil',
          'ibu_melahirkan',
          'ibu_nifas',
          'ibu_meninggal',
          'bayi_lahir_l',
          'bayi_lahir_p',
          'akte_ada',
          'akte_tidak',
          'bayi_meninggal_l',
          'bayi_meninggal_p',
          'balita_meninggal_l',
          'balita_meninggal_p',
          'keterangan',
        ];
      case PokjaKategori.pokja4DataDukung:
        // ✅ GABUNGAN 1 FORM: A. Data Dukung (26) + B. Data Program (70)
        return [...dataDukungKeys, ...dataProgramKeys];
      case PokjaKategori.pokja4DataProgram:
        return [
          // I. Stunting
          'bayi_prematur',
          'bayi_bblr',
          'balita_kurang_gizi',
          'balita_stunting',
          'bayi_balita_periksa',
          'ibu_lahir_jarak_dekat',
          'hamil_tidak_direncanakan',
          // II. PHBS
          'penduduk_tbc',
          'rumah_jamban_sehat',
          'rumah_bak_air',
          'kasus_diare',
          'keluarga_sadar_gizi',
          'rumah_tanpa_asap_rokok',
          'penduduk_babs',
          // III. Kesehatan Keluarga
          'ibu_hamil_periksa',
          'ayah_merokok',
          'kematian_ibu_nifas',
          'kanker_serviks',
          'bayi_balita_imunisasi',
          'bayi_balita_sakit',
          'kematian_bayi_balita',
          // IV. Siaga Kebakaran
          'kebakaran_rumah_tangga',
          'rumah_listrik_standar',
          'rumah_alat_pemadam',
          'rumah_semi_permanen',
          'rumah_kotak_p3k',
          'rumah_info_mitigasi_kebakaran',
          'kader_edukasi_kebakaran',
          // V. Mitigasi Bencana Alam
          'relawan_bencana_alam',
          'rumah_info_mitigasi_alam',
          'kader_edukasi_alam',
          'fasilitas_posko_bencana',
          'relawan_bencana_alam_2',
          'rumah_tas_siaga',
          'kerusakan_fasilitas_umum',
          // VI. Peduli Lingkungan
          'keluarga_bak_sampah',
          'keluarga_anggota_bank_sampah',
          'keluarga_spal',
          'kasus_banjir',
          'bak_sampah_desa',
          'rumah_sehat',
          'kasus_klb',
          // VII. Keluarga Sehat Berkualitas
          'keluarga_2_anak',
          'penduduk_berobat',
          'penyakit_menular',
          'penyakit_tidak_menular',
          'bayi_lahir_sehat',
          'bayi_cukup_bulan',
          'keluarga_gangguan_jiwa',
          // VIII. Keuangan Sehat
          'keluarga_asuransi',
          'kk_pengangguran',
          'kk_tidak_tetap',
          'kk_penghasilan_tetap',
          'ibu_hamil_tabulin',
          'keluarga_tabungan',
          'keluarga_aset_investasi',
          // IX. Pasangan Usia Subur (PUS)
          'ibu_melahirkan_bayi_sehat',
          'wanita_peserta_kb',
          'pria_peserta_kb',
          'pus_masalah_reproduksi',
          'pus_nikah_di_bawah_19',
          'wus_hamil_beresiko',
          'pus_penyakit_seksual',
        ];
    }
  }

  // ============================================================
  // KUNCI 1 FORM GABUNGAN — dipakai untuk split simpan + seksi UI
  // ============================================================
  static const List<String> dataDukungKeys = [
    'jumlah_penduduk',
    'jumlah_kk',
    'jumlah_rumah',
    'jumlah_laki',
    'jumlah_perempuan',
    'jumlah_usia_produktif',
    'jumlah_pus',
    'jumlah_ibu_hamil',
    'jumlah_bayi_0_2',
    'jumlah_bayi_asi',
    'jumlah_balita',
    'jumlah_anak',
    'jumlah_lansia',
    'jumlah_kb_aktif',
    'jumlah_ibu_menyusui',
    'jumlah_keluarga_sejahtera',
    'jumlah_keluarga_pra_sejahtera',
    'jumlah_mbr',
    'jumlah_kader_pkk_rt_rw',
    'jumlah_kader_pkk_kesehatan',
    'jumlah_dasa_wisma',
    'jumlah_kader_dasa_wisma',
    'jumlah_posyandu_aktif',
    'jumlah_bidan_desa',
    'jumlah_bank_sampah',
    'jumlah_posko_bencana',
  ];

  static const List<String> dataProgramKeys = [
    'bayi_prematur',
    'bayi_bblr',
    'balita_kurang_gizi',
    'balita_stunting',
    'bayi_balita_periksa',
    'ibu_lahir_jarak_dekat',
    'hamil_tidak_direncanakan',
    'penduduk_tbc',
    'rumah_jamban_sehat',
    'rumah_bak_air',
    'kasus_diare',
    'keluarga_sadar_gizi',
    'rumah_tanpa_asap_rokok',
    'penduduk_babs',
    'ibu_hamil_periksa',
    'ayah_merokok',
    'kematian_ibu_nifas',
    'kanker_serviks',
    'bayi_balita_imunisasi',
    'bayi_balita_sakit',
    'kematian_bayi_balita',
    'kebakaran_rumah_tangga',
    'rumah_listrik_standar',
    'rumah_alat_pemadam',
    'rumah_semi_permanen',
    'rumah_kotak_p3k',
    'rumah_info_mitigasi_kebakaran',
    'kader_edukasi_kebakaran',
    'relawan_bencana_alam',
    'rumah_info_mitigasi_alam',
    'kader_edukasi_alam',
    'fasilitas_posko_bencana',
    'relawan_bencana_alam_2',
    'rumah_tas_siaga',
    'kerusakan_fasilitas_umum',
    'keluarga_bak_sampah',
    'keluarga_anggota_bank_sampah',
    'keluarga_spal',
    'kasus_banjir',
    'bak_sampah_desa',
    'rumah_sehat',
    'kasus_klb',
    'keluarga_2_anak',
    'penduduk_berobat',
    'penyakit_menular',
    'penyakit_tidak_menular',
    'bayi_lahir_sehat',
    'bayi_cukup_bulan',
    'keluarga_gangguan_jiwa',
    'keluarga_asuransi',
    'kk_pengangguran',
    'kk_tidak_tetap',
    'kk_penghasilan_tetap',
    'ibu_hamil_tabulin',
    'keluarga_tabungan',
    'keluarga_aset_investasi',
    'ibu_melahirkan_bayi_sehat',
    'wanita_peserta_kb',
    'pria_peserta_kb',
    'pus_masalah_reproduksi',
    'pus_nikah_di_bawah_19',
    'wus_hamil_beresiko',
    'pus_penyakit_seksual',
  ];

  // Label untuk field
  String getLabelForField(String field) {
    // ✅ rumah_sehat dipakai dua konteks: Pokja III vs B-VI Data Program.
    if (field == 'rumah_sehat' &&
        (this == PokjaKategori.pokja4DataDukung ||
            this == PokjaKategori.pokja4DataProgram)) {
      return 'Jumlah Rumah sehat';
    }
    switch (field) {
      case 'kader_umum': return 'Kader Umum';
      case 'kader_khusus': return 'Kader Khusus';
      case 'kisah_kegiatan': return 'KISAH (Kegiatan)';
      case 'kisah_volume': return 'KISAH (Volume)';
      case 'kisah_metode': return 'KISAH (Metode)';
      case 'kisah_sasaran': return 'KISAH (Sasaran)';
      case 'kilas_kegiatan': return 'KILAS (Kegiatan)';
      case 'kilas_volume': return 'KILAS (Volume)';
      case 'kilas_metode': return 'KILAS (Metode)';
      case 'kilas_sasaran': return 'KILAS (Sasaran)';
      case 'krisan_kegiatan': return 'KRISAN (Kegiatan)';
      case 'krisan_volume': return 'KRISAN (Volume)';
      case 'krisan_metode': return 'KRISAN (Metode)';
      case 'krisan_sasaran': return 'KRISAN (Sasaran)';
      case 'kiat_kegiatan': return 'KIAT (Kegiatan)';
      case 'kiat_volume': return 'KIAT (Volume)';
      case 'kiat_metode': return 'KIAT (Metode)';
      case 'kiat_sasaran': return 'KIAT (Sasaran)';
      case 'kisak_kegiatan': return 'KISAK (Kegiatan)';
      case 'kisak_volume': return 'KISAK (Volume)';
      case 'kisak_metode': return 'KISAK (Metode)';
      case 'kisak_sasaran': return 'KISAK (Sasaran)';
      case 'pkbn_kegiatan': return 'PKBN (Kegiatan)';
      case 'pkbn_volume': return 'PKBN (Volume)';
      case 'pkbn_metode': return 'PKBN (Metode)';
      case 'pkbn_sasaran': return 'PKBN (Sasaran)';
      case 'posyandu':
        return 'Jumlah Posyandu';
      case 'akseptor_kb':
        return 'Akseptor KB';
      case 'phbs':
        return 'PHBS';
      case 'jamban_keluarga':
        return 'Jamban Keluarga';
      case 'kader_kesehatan':
        return 'Kader Kesehatan';
      case 'kader_gizi':
        return 'Kader Gizi';
      case 'kader_kesling':
        return 'Kader Kesling';
      case 'kader_phbs':
        return 'Kader PHBS';
      case 'kader_kb':
        return 'Kader KB';
      case 'imunisasi':
        return 'Imunisasi';
      case 'pkg':
        return 'PKG';
      case 'tbc':
        return 'TBC';
      case 'spal':
        return 'SPAL';
      case 'tps':
        return 'TPS';
      case 'mck':
        return 'MCK';
      case 'air_pdam':
        return 'Air PDAM';
      case 'air_sumur':
        return 'Air Sumur';
      case 'air_lainnya':
        return 'Air Lainnya';
      case 'jumlah_pus':
        return 'Jumlah PUS';
      case 'jumlah_wus':
        return 'Jumlah WUS';
      case 'akseptor_kb_l':
        return 'Akseptor KB L';
      case 'akseptor_kb_p':
        return 'Akseptor KB P';
      case 'tabungan_keluarga':
        return 'Tabungan Keluarga';
      case 'asuransi_kesehatan':
        return 'Asuransi Kesehatan';
      case 'program_kesehatan':
        return 'Program Kesehatan';
      case 'program_lingkungan':
        return 'Program Lingkungan';
      case 'program_perencanaan':
        return 'Program Perencanaan';
      case 'kelompok_warga_buta': return 'Warga Buta - Jml KLP';
      case 'warga_buta_l': return 'Warga Buta (L)';
      case 'warga_buta_p': return 'Warga Buta (P)';
      case 'kelompok_belajar_paket_a': return 'Kelompok Belajar Paket A';
      case 'warga_belajar_paket_a_l': return 'Warga Belajar Paket A (L)';
      case 'warga_belajar_paket_a_p': return 'Warga Belajar Paket A (P)';
      case 'kelompok_belajar_paket_b': return 'Kelompok Belajar Paket B';
      case 'warga_belajar_paket_b_l': return 'Warga Belajar Paket B (L)';
      case 'warga_belajar_paket_b_p': return 'Warga Belajar Paket B (P)';
      case 'kelompok_belajar_paket_c': return 'Kelompok Belajar Paket C';
      case 'warga_belajar_paket_c_l': return 'Warga Belajar Paket C (L)';
      case 'warga_belajar_paket_c_p': return 'Warga Belajar Paket C (P)';
      case 'kf': return 'Keaksaraan Fungsional (KF)';
      case 'warga_belajar_kf_l': return 'Warga Belajar KF (L)';
      case 'warga_belajar_kf_p': return 'Warga Belajar KF (P)';
      case 'kelompok_paud': return 'PAUD - Jml KLP';
      case 'paud_l': return 'PAUD Sejenis (L)';
      case 'paud_p': return 'PAUD Sejenis (P)';
      case 'kelompok_taman_bacaan': return 'Taman Bacaan - Jml KLP';
      case 'taman_bacaan_l': return 'Taman Bacaan (L)';
      case 'taman_bacaan_p': return 'Taman Bacaan (P)';
      case 'kelompok_bkb': return 'BKB - Jml KLP';
      case 'kelompok_bkb_l': return 'BKB - Jml KLP (L)';
      case 'kelompok_bkb_p': return 'BKB - Jml KLP (P)';
      case 'peserta_bkb_l': return 'Peserta BKB (L)';
      case 'peserta_bkb_p': return 'Peserta BKB (P)';
      case 'ape_bkb': return 'APE BKB';
      case 'kelompok_simulasi_bkb': return 'BKB - Simulasi Jml KLP';
      case 'kelompok_simulasi_bkb_l': return 'Simulasi BKB (L)';
      case 'kelompok_simulasi_bkb_p': return 'Simulasi BKB (P)';
      case 'tutor_kf': return 'Tutor KF Jml';
      case 'tutor_kf_l': return 'Tutor KF (L)';
      case 'tutor_kf_p': return 'Tutor KF (P)';
      case 'tutor_paud': return 'Tutor PAUD Jml';
      case 'tutor_paud_l': return 'Tutor PAUD (L)';
      case 'tutor_paud_p': return 'Tutor PAUD (P)';
      case 'kader_bkb': return 'Kader BKB Jml';
      case 'kader_bkb_l': return 'Kader BKB (L)';
      case 'kader_bkb_p': return 'Kader BKB (P)';
      case 'kader_koperasi': return 'Kader Koperasi Jml';
      case 'kader_koperasi_l': return 'Kader Koperasi (L)';
      case 'kader_koperasi_p': return 'Kader Koperasi (P)';
      case 'kader_keterampilan': return 'Kader Keterampilan Jml';
      case 'kader_keterampilan_l': return 'Kader Keterampilan (L)';
      case 'kader_keterampilan_p': return 'Kader Keterampilan (P)';
      case 'up2k_pemula_kelompok': return 'UP2K Pemula Kelompok';
      case 'up2k_pemula_peserta_l': return 'UP2K Pemula Peserta (L)';
      case 'up2k_pemula_peserta_p': return 'UP2K Pemula Peserta (P)';
      case 'up2k_madya_kelompok': return 'UP2K Madya Kelompok';
      case 'up2k_madya_peserta_l': return 'UP2K Madya Peserta (L)';
      case 'up2k_madya_peserta_p': return 'UP2K Madya Peserta (P)';
      case 'up2k_utama_kelompok': return 'UP2K Utama Kelompok';
      case 'up2k_utama_peserta_l': return 'UP2K Utama Peserta (L)';
      case 'up2k_utama_peserta_p': return 'UP2K Utama Peserta (P)';
      case 'up2k_mandiri_kelompok': return 'UP2K Mandiri Kelompok';
      case 'up2k_mandiri_peserta_l': return 'UP2K Mandiri Peserta (L)';
      case 'up2k_mandiri_peserta_p': return 'UP2K Mandiri Peserta (P)';
      case 'anggota_koperasi_l': return 'Anggota Koperasi (L)';
      case 'anggota_koperasi_p': return 'Anggota Koperasi (P)';
      case 'ibu_set_bkb': return 'Ibu SET BKB';
      case 'lp3_pkk': return 'LP3 PKK Jml';
      case 'lp3_pkk_l': return 'LP3 PKK (L)';
      case 'lp3_pkk_p': return 'LP3 PKK (P)';
      case 'tp3_pkk': return 'TP3 PKK Jml';
      case 'tp3_pkk_l': return 'TP3 PKK (L)';
      case 'tp3_pkk_p': return 'TP3 PKK (P)';
      case 'damas_pkk': return 'Damas PKK Jml';
      case 'damas_pkk_l': return 'Damas PKK (L)';
      case 'damas_pkk_p': return 'Damas PKK (P)';
      case 'keterangan': return 'Keterangan';
      case 'evaluasi': return 'Evaluasi';
      // Pokja III — sesuai format DATA KEGIATAN PKK
      case 'jumlah_kader_pangan': return 'Jml Kader - Pangan';
      case 'jumlah_kader_sandang': return 'Jml Kader - Sandang';
      case 'jumlah_kader_tata_laksana': return 'Jml Kader - Tata Laksana RT';
      case 'pangan_beras': return 'Makanan Pokok - Beras';
      case 'pangan_non_beras': return 'Makanan Pokok - Non Beras';
      case 'pangan_peternakan': return 'HATINYA - Peternakan';
      case 'pangan_perikanan': return 'HATINYA - Perikanan';
      case 'pangan_warung_hidup': return 'HATINYA - Warung Hidup';
      case 'pangan_lumbung_hidup': return 'HATINYA - Lumbung Hidup';
      case 'pangan_toga': return 'HATINYA - TOGA';
      case 'pangan_tanaman_keras': return 'HATINYA - Tanaman Keras';
      case 'pangan_tanaman_lainnya': return 'HATINYA - Tanaman Lainnya';
      case 'industri_pangan': return 'Industri RT - Pangan';
      case 'industri_sandang': return 'Industri RT - Sandang';
      case 'industri_jasa': return 'Industri RT - Jasa';
      case 'rumah_sehat': return 'Rumah Sehat & Layak Huni';
      case 'rumah_tidak_sehat': return 'Rumah Tidak Sehat & Tidak Layak Huni';
      case 'jumlah_kader': return 'Jml Kader (lama)';
      case 'jumlah_kader_p': return 'Jml Kader P (lama)';
      case 'makanan_pokok': return 'Makanan Pokok (lama)';
      case 'pemanfaatan_pekarangan': return 'Pemanfaatan Pekarangan (lama)';
      case 'hatinya_pkk': return 'HATINYA PKK (lama)';
      case 'industri_rumah_tangga': return 'Industri Rumah Tangga (lama)';
      case 'jumlah_rumah': return 'Jumlah Rumah (lama)';
      // Pokja IV — A. Data Dukung (tabel A no. 1-26)
      case 'jumlah_penduduk': return 'Jumlah Penduduk';
      case 'jumlah_kk': return 'Jumlah Kepala Keluarga';
      case 'jumlah_laki': return 'Jumlah Laki-Laki';
      case 'jumlah_perempuan': return 'Jumlah Perempuan';
      case 'jumlah_usia_produktif': return 'Jumlah Usia Produktif (15-64 Tahun)';
      case 'jumlah_ibu_hamil': return 'Jumlah Ibu Hamil';
      case 'jumlah_bayi_0_2': return 'Jumlah Bayi (0-2 Tahun)';
      case 'jumlah_bayi_asi': return 'Jumlah Bayi yang mendapatkan ASI Eksklusif (0-6 Bulan)';
      case 'jumlah_balita': return 'Jumlah Balita (>2-5 Tahun)';
      case 'jumlah_anak': return 'Jumlah Anak (6-14 Tahun)';
      case 'jumlah_lansia': return 'Jumlah Lansia (≥65 Tahun)';
      case 'jumlah_kb_aktif': return 'Jumlah Peserta KB Aktif';
      case 'jumlah_ibu_menyusui': return 'Jumlah Ibu Menyusui';
      case 'jumlah_keluarga_sejahtera': return 'Jumlah Keluarga Sejahtera';
      case 'jumlah_keluarga_pra_sejahtera': return 'Jumlah Keluarga Pra Sejahtera';
      case 'jumlah_mbr': return 'Jumlah Masyarakat Berpenghasilan Rendah (MBR)';
      case 'jumlah_kader_pkk_rt_rw': return 'Jumlah Kader PKK RT/RW';
      case 'jumlah_kader_pkk_kesehatan': return 'Jumlah Kader PKK Bidang Kesehatan';
      case 'jumlah_dasa_wisma': return 'Jumlah Kelompok Dasa Wisma';
      case 'jumlah_kader_dasa_wisma': return 'Jumlah Kader Dasa Wisma';
      case 'jumlah_posyandu_aktif': return 'Jumlah Posyandu Aktif';
      case 'jumlah_bidan_desa': return 'Jumlah Bidan Desa';
      case 'jumlah_bank_sampah': return 'Jumlah Bank Sampah';
      case 'jumlah_posko_bencana': return 'Jumlah Posko Bencana';
      // Pokja IV — B. Data Program (I-IX @ 7)
      case 'bayi_prematur': return 'Jumlah Bayi Lahir Prematur';
      case 'bayi_bblr': return 'Jumlah Bayi Lahir Berat Badan Bayi Lahir Rendah (BBLR)';
      case 'balita_kurang_gizi': return 'Jumlah Balita Kurang Gizi';
      case 'balita_stunting': return 'Jumlah Balita Stunting';
      case 'bayi_balita_periksa': return 'Jumlah bayi dan balita yang rutin dilakukan pemeriksaan tumbuh kembang setiap bulan';
      case 'ibu_lahir_jarak_dekat': return 'Jumlah Ibu Yang Melahirkan dengan Jarak Terlalu Dekat';
      case 'hamil_tidak_direncanakan': return 'Jumlah Kehamilan Yang Tidak Direncanakan / Tidak Diinginkan';
      case 'penduduk_tbc': return 'Jumlah penduduk penderita Tuberkulosis (TBC)';
      case 'rumah_jamban_sehat': return 'Jumlah rumah yang memiliki jamban sehat';
      case 'rumah_bak_air': return 'Jumlah rumah yang memiliki fasilitas instalasi atau bak penampung air bersih';
      case 'kasus_diare': return 'Jumlah kasus penyakit Diare';
      case 'keluarga_sadar_gizi': return 'Jumlah keluarga yang sadar gizi';
      case 'rumah_tanpa_asap_rokok': return 'Jumlah rumah tanpa asap rokok';
      case 'penduduk_babs': return 'Jumlah penduduk yang masih Buang Air Besar Sembarangan (BABS)';
      case 'ibu_hamil_periksa': return 'Jumlah ibu hamil yang rutin memeriksakan kehamilannya pada tenaga kesehatan secara periodik';
      case 'ayah_merokok': return 'Jumlah Ayah yang merokok';
      case 'kematian_ibu_nifas': return 'Jumlah kasus Kematian Ibu nifas';
      case 'kanker_serviks': return 'Jumlah kasus Kanker Serviks pada Perempuan';
      case 'bayi_balita_imunisasi': return 'Jumlah bayi dan balita yang mendapat imunisasi dasar lengkap';
      case 'bayi_balita_sakit': return 'Jumlah bayi dan balita sakit yang terdata pada fasilitas kesehatan';
      case 'kematian_bayi_balita': return 'Jumlah kasus Kematian Bayi dan Balita';
      case 'kebakaran_rumah_tangga': return 'Jumlah kasus Kebakaran Rumah Tangga';
      case 'rumah_listrik_standar': return 'Jumlah Rumah Tangga Yang Memiliki Instalasi Listrik Yang Sesuai Standar';
      case 'rumah_alat_pemadam': return 'Jumlah Rumah Tangga Yang Memiliki Alat Pemadam Kebakaran';
      case 'rumah_semi_permanen': return 'Jumlah Rumah Semi Permanen dan rumah kayu';
      case 'rumah_kotak_p3k': return 'Jumlah Rumah Tangga yang memiliki Kotak P3K';
      case 'rumah_info_mitigasi_kebakaran': return 'Jumlah Rumah Tangga Yang Telah Mendapatkan Informasi, Penyuluhan, Atau Sosialisasi Tentang Mitigasi Dan Penanggulangan Kebakaran';
      case 'kader_edukasi_kebakaran': return 'Jumlah Kader PKK Yang Telah Mendapatkan Edukasi Terkait Mitigasi Bencana Kebakaran';
      case 'relawan_bencana_alam': return 'Jumlah Relawan Bencana Alam';
      case 'rumah_info_mitigasi_alam': return 'Jumlah Rumah Tangga Yang Telah Mendapatkan Informasi, Penyuluhan, Atau Sosialisasi Tentang Mitigasi Dan Penanggulangan Bencana Alam';
      case 'kader_edukasi_alam': return 'Jumlah Kader PKK Yang Telah Mendapatkan Edukasi Terkait Mitigasi Bencana Alam';
      case 'fasilitas_posko_bencana': return 'Jumlah Fasilitas/Bangunan Yang Ditetapkan Sebagai Alternatif Posko Bila Terjadi Bencana Alam';
      case 'relawan_bencana_alam_2': return 'Jumlah Relawan Bencana Alam (2)';
      case 'rumah_tas_siaga': return 'Jumlah Rumah Tangga Yang Memiliki Tas Siaga Bencana';
      case 'kerusakan_fasilitas_umum': return 'Jumlah Kerusakan Fasilitas Umum Yang Diakibatkan Oleh Bencana Alam';
      case 'keluarga_bak_sampah': return 'Jumlah Keluarga yang memiliki bak sampah';
      case 'keluarga_anggota_bank_sampah': return 'Jumlah Keluarga sebagai anggota Bank Sampah';
      case 'keluarga_spal': return 'Jumlah keluarga yang menggunakan Sistem Pembuangan Air Limbah (SPAL)';
      case 'kasus_banjir': return 'Jumlah kasus banjir';
      case 'bak_sampah_desa': return 'Jumlah bak sampah milik desa/kelurahan';
      case 'kasus_klb': return 'Jumlah kasus Kejadian Luar Biasa (KLB)';
      case 'keluarga_2_anak': return 'Jumlah Keluarga dengan 2 anak';
      case 'penduduk_berobat': return 'Jumlah Penduduk yang berobat ke fasilitas kesehatan berdasarkan data di fasilitas kesehatan';
      case 'penyakit_menular': return 'Jumlah kasus penyakit menular';
      case 'penyakit_tidak_menular': return 'Jumlah kasus penyakit tidak menular';
      case 'bayi_lahir_sehat': return 'Jumlah Bayi Lahir Sehat';
      case 'bayi_cukup_bulan': return 'Jumlah Bayi Lahir Cukup Bulan';
      case 'keluarga_gangguan_jiwa': return 'Jumlah keluarga yang memiliki anggota dengan kriteria penyakit gangguan jiwa';
      case 'keluarga_asuransi': return 'Jumlah Keluarga yang memiliki Asuransi Kesehatan';
      case 'kk_pengangguran': return 'Jumlah kepala keluarga yang tidak memiliki pekerjaan / Pengangguran';
      case 'kk_tidak_tetap': return 'Jumlah kepala keluarga yang tidak memiliki pekerjaan tetap';
      case 'kk_penghasilan_tetap': return 'Jumlah Kepala Keluarga yang memiliki penghasilan tetap';
      case 'ibu_hamil_tabulin': return 'Jumlah Ibu hamil yang mempunyai tabungan bersalin (TABULIN)';
      case 'keluarga_tabungan': return 'Jumlah keluarga yang memiliki tabungan';
      case 'keluarga_aset_investasi': return 'Jumlah keluarga yang mempunyai aset untuk investasi';
      case 'ibu_melahirkan_bayi_sehat': return 'Jumlah Ibu melahirkan Bayi sehat';
      case 'wanita_peserta_kb': return 'Jumlah wanita sebagai peserta KB';
      case 'pria_peserta_kb': return 'Jumlah pria peserta KB';
      case 'pus_masalah_reproduksi': return 'Jumlah Pasangan Usia Subur (PUS) yang memiliki masalah kesehatan reproduksi';
      case 'pus_nikah_di_bawah_19': return 'Jumlah Pasangan Usia Subur (PUS) yang menikah dengan istri usia dibawah usia 19 Tahun';
      case 'wus_hamil_beresiko': return 'Jumlah Wanita Usia Subur dengan kehamilan beresiko';
      case 'pus_penyakit_seksual': return 'Jumlah penderita penyakit infeksi menular seksual pada Pasangan Usia Subur (PUS)';
      default:
        return field;
    }
  }

  static PokjaKategori fromString(String value) {
    switch (value) {
      case 'I':
      case 'pokja1':
        return PokjaKategori.pokja1;
      case 'II':
      case 'pokja2':
        return PokjaKategori.pokja2;
      case 'III':
      case 'pokja3':
        return PokjaKategori.pokja3;
      case 'IV':
      case 'pokja4':
        return PokjaKategori.pokja4;
      case 'IV-PYD':
      case 'pokja4Pyd':
        return PokjaKategori.pokja4Pyd;
      case 'IV-POSYANDU':
      case 'pokja4Posyandu':
        return PokjaKategori.pokja4Posyandu;
      case 'IV-REKAP':
      case 'pokja4Rekap':
        return PokjaKategori.pokja4Rekap;
      case 'IV-DATADUKUNG':
      case 'pokja4DataDukung':
        return PokjaKategori.pokja4DataDukung;
      case 'IV-DATAPROGRAM':
      case 'pokja4DataProgram':
        return PokjaKategori.pokja4DataProgram;
      default:
        return PokjaKategori.pokja1;
    }
  }
}

enum StatusKegiatan { terkirim, dibaca }

extension StatusKegiatanLabel on StatusKegiatan {
  String get label =>
      this == StatusKegiatan.dibaca ? 'Sudah Dibaca' : 'Terkirim';
}

// ============================================================
// MODEL
// ============================================================
class CatatanKegiatan {
  final int id;
  final String judul;
  final String deskripsiSingkat;
  final PokjaKategori kategori;
  final Map<String, dynamic> dataAngka; // ✅ dynamic — bisa int + string
  final String kecamatan;
  final String? desa;
  final String? fotoPath;
  final DateTime tanggal;
  final StatusKegiatan status;
  // ✅ KOP LAPORAN DATA DUKUNG (Image 2) — nullable, khusus pokja4DataDukung
  final String? provinsi;
  final String? kabupatenKota;
  final String? program;
  final String? pjDesa;
  final String? pjDesaHp;
  final String? pjKecamatan;
  final String? pjKecamatanHp;
  final String? pjKabupaten;
  final String? pjKabupatenHp;
  final String? pjProvinsi;
  final String? pjProvinsiHp;

  CatatanKegiatan({
    this.id = 0,
    this.judul = '',
    String? deskripsiSingkat,
    String? ceritaSingkat,
    this.kategori = PokjaKategori.pokja1,
    this.dataAngka = const {},
    this.kecamatan = '',
    this.desa,
    this.fotoPath,
    DateTime? tanggal,
    this.status = StatusKegiatan.terkirim,
    this.provinsi,
    this.kabupatenKota,
    this.program,
    this.pjDesa,
    this.pjDesaHp,
    this.pjKecamatan,
    this.pjKecamatanHp,
    this.pjKabupaten,
    this.pjKabupatenHp,
    this.pjProvinsi,
    this.pjProvinsiHp,
  }) : deskripsiSingkat = deskripsiSingkat ?? ceritaSingkat ?? '',
       tanggal = tanggal ?? DateTime.now();

  String get ceritaSingkat => deskripsiSingkat;

  static PokjaKategori parseKategori(dynamic value) {
    if (value is PokjaKategori) return value;
    final str = value?.toString() ?? 'I';
    return PokjaKategoriLabel.fromString(str);
  }

  CatatanKegiatan copyWith({
    int? id,
    String? judul,
    String? deskripsiSingkat,
    PokjaKategori? kategori,
    Map<String, dynamic>? dataAngka,
    String? kecamatan,
    String? desa,
    String? fotoPath,
    DateTime? tanggal,
    StatusKegiatan? status,
    String? provinsi,
    String? kabupatenKota,
    String? program,
    String? pjDesa,
    String? pjDesaHp,
    String? pjKecamatan,
    String? pjKecamatanHp,
    String? pjKabupaten,
    String? pjKabupatenHp,
    String? pjProvinsi,
    String? pjProvinsiHp,
  }) {
    return CatatanKegiatan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsiSingkat: deskripsiSingkat ?? this.deskripsiSingkat,
      kategori: kategori ?? this.kategori,
      dataAngka: dataAngka ?? this.dataAngka,
      kecamatan: kecamatan ?? this.kecamatan,
      desa: desa ?? this.desa,
      fotoPath: fotoPath ?? this.fotoPath,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
      provinsi: provinsi ?? this.provinsi,
      kabupatenKota: kabupatenKota ?? this.kabupatenKota,
      program: program ?? this.program,
      pjDesa: pjDesa ?? this.pjDesa,
      pjDesaHp: pjDesaHp ?? this.pjDesaHp,
      pjKecamatan: pjKecamatan ?? this.pjKecamatan,
      pjKecamatanHp: pjKecamatanHp ?? this.pjKecamatanHp,
      pjKabupaten: pjKabupaten ?? this.pjKabupaten,
      pjKabupatenHp: pjKabupatenHp ?? this.pjKabupatenHp,
      pjProvinsi: pjProvinsi ?? this.pjProvinsi,
      pjProvinsiHp: pjProvinsiHp ?? this.pjProvinsiHp,
    );
  }

  static const List<String> daftar39Kecamatan = [
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

  // ============================================================
  // TO JSON â€” untuk kirim ke backend
  // ============================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsiSingkat,
      'kategori_pokja': kategori.kategoriPokja, // ✅ FIX: string
      'data_angka': dataAngka,
      'kecamatan': kecamatan,
      'desa_kelurahan': desa,
      'foto_path': fotoPath,
      'tanggal': tanggal.toIso8601String(),
      'status': status.index,
      'provinsi': provinsi,
      'kabupaten_kota': kabupatenKota,
      'program': program,
      'pj_desa': pjDesa,
      'pj_desa_hp': pjDesaHp,
      'pj_kecamatan': pjKecamatan,
      'pj_kecamatan_hp': pjKecamatanHp,
      'pj_kabupaten': pjKabupaten,
      'pj_kabupaten_hp': pjKabupatenHp,
      'pj_provinsi': pjProvinsi,
      'pj_provinsi_hp': pjProvinsiHp,
    };
  }

  // ============================================================
  // FROM JSON â€” untuk baca dari backend
  // ============================================================
  factory CatatanKegiatan.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> dataAngka = {};
    if (json['data_angka'] != null) {
      if (json['data_angka'] is Map) {
        dataAngka = Map<String, dynamic>.from(json['data_angka'] as Map);
      } else if (json['data_angka'] is String) {
        try {
          final decoded = jsonDecode(json['data_angka']);
          if (decoded is Map) {
            dataAngka = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
    }

    DateTime parsedTanggal = DateTime.now();
    if (json['created_at'] != null) {
      parsedTanggal =
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    } else if (json['tanggal'] != null) {
      parsedTanggal =
          DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now();
    }

    return CatatanKegiatan(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      judul:
          json['judul']?.toString() ??
          json['judul_kegiatan']?.toString() ??
          json['title']?.toString() ??
          '',
      deskripsiSingkat:
          json['deskripsi']?.toString() ??
          json['deskripsi_singkat']?.toString() ??
          json['keterangan']?.toString() ??
          '',
      kategori: parseKategori(
        json['kategori_pokja'] ?? json['kategori'] ?? 'I',
      ),
      dataAngka: dataAngka,
      kecamatan:
          json['kecamatan']?.toString() ??
          json['nama_kecamatan']?.toString() ??
          '',
      desa:
          json['desa']?.toString() ??
          json['desa_kelurahan']?.toString() ??
          json['kelurahan']?.toString(),
      fotoPath:
          json['foto']?.toString() ??
          json['foto_path']?.toString() ??
          json['foto_url']?.toString(),
      tanggal: parsedTanggal,
      provinsi: json['provinsi']?.toString(),
      kabupatenKota: json['kabupaten_kota']?.toString() ?? json['kabupaten']?.toString(),
      program: json['program']?.toString(),
      pjDesa: json['pj_desa']?.toString() ?? json['penanggung_jawab_desa']?.toString(),
      pjDesaHp: json['pj_desa_hp']?.toString(),
      pjKecamatan: json['pj_kecamatan']?.toString() ?? json['penanggung_jawab_kecamatan']?.toString(),
      pjKecamatanHp: json['pj_kecamatan_hp']?.toString(),
      pjKabupaten: json['pj_kabupaten']?.toString() ?? json['penanggung_jawab_kabupaten']?.toString(),
      pjKabupatenHp: json['pj_kabupaten_hp']?.toString(),
      pjProvinsi: json['pj_provinsi']?.toString() ?? json['penanggung_jawab_provinsi']?.toString(),
      pjProvinsiHp: json['pj_provinsi_hp']?.toString(),
      status: json['status'] == 'dibaca' || json['status'] == 1
          ? StatusKegiatan.dibaca
          : StatusKegiatan.terkirim,
    );
  }

  // ============================================================
  // KIRIM KE BACKEND â€” POST /api/laporan-kegiatan
  // ============================================================
  static Future<Map<String, dynamic>> kirimKeBackend({
    required String token,
    required CatatanKegiatan catatan,
  }) async {
    final payload = {
      'judul': catatan.judul,
      'deskripsi': catatan.deskripsiSingkat,
      'kategori_pokja': catatan.kategori.kategoriPokja, // ✅ IV, IV-PYD, dll
      'data_angka': catatan.dataAngka,
      'kecamatan': catatan.kecamatan,
      'desa_kelurahan': catatan.desa,
      'provinsi': catatan.provinsi,
      'kabupaten_kota': catatan.kabupatenKota,
      'program': catatan.program,
      'pj_desa': catatan.pjDesa,
      'pj_desa_hp': catatan.pjDesaHp,
      'pj_kecamatan': catatan.pjKecamatan,
      'pj_kecamatan_hp': catatan.pjKecamatanHp,
      'pj_kabupaten': catatan.pjKabupaten,
      'pj_kabupaten_hp': catatan.pjKabupatenHp,
      'pj_provinsi': catatan.pjProvinsi,
      'pj_provinsi_hp': catatan.pjProvinsiHp,
    };

    final response = await http.post(
      Uri.parse(
        '${AppConstants.baseUrl}/api/laporan-kegiatan',
      ), // âœ… FIX: endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {
        'success': false,
        'message': 'Gagal kirim laporan: ${response.statusCode}',
        'body': response.body,
      };
    }
  }
}
